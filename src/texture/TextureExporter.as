package texture
{
	import by.blooddy.crypto.image.JPEGEncoder;
	import by.blooddy.crypto.image.PNGEncoder;
	
	import com.adobe.serialization.json.JSONDecoder;
	import com.adobe.serialization.json.JSONEncoder;
	import com.st.framework.utils.FileUtil;
	import com.st.framework.utils.LocalStoreUtil;
	
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.filesystem.File;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	import mx.core.FlexGlobals;
	
	import utils.PNGPacker;
	import utils.image.RipResult;
	import utils.image.SimpleRid;
	
	import view.MyComponents.LoadingInfo;

	public class TextureExporter implements IExporter
	{
		public static function exportTo(actList:Vector.<AnimationAct>, fileName:String, compress:Boolean, quality:int=80, swf2:Boolean=true):void
		{
			if(compress){
				var texport:TextureExporter = new TextureExporter(actList, fileName);
				texport.quality = Math.min(100, Math.max(0, quality));
				texport.swf2 = swf2;
				texport.export();
			}
			else{
				(new TextureExporter(actList, fileName)).exportUncompress();
			}
		}
		
		private var actList:Vector.<AnimationAct>;
		private var fileName:String;
		private var quality:int;
		private var swf2:Boolean;
		
		private static const EXPORT_TEXTURE_NAME:String = "export_texture";
		private static const EXPORT_UNCOMPRESS_TEXTURE_NAME:String = "export_uncompress_texture";
		
		public function TextureExporter(actList:Vector.<AnimationAct>, fileName:String)
		{
			this.actList = actList;
			this.fileName = fileName;
		}
		
		public function exportUncompress():void
		{
			var tfile:File = new File(LocalStoreUtil.read(EXPORT_UNCOMPRESS_TEXTURE_NAME));
			tfile.addEventListener(Event.SELECT, 
				function tselectHandler(event:Event):void
				{
					LocalStoreUtil.save(EXPORT_UNCOMPRESS_TEXTURE_NAME, tfile.nativePath);
					tfile.removeEventListener(Event.SELECT, tselectHandler);
					
					var tf:File = new File(tfile.nativePath + File.separator + fileName);
					if(tf.exists && tf.isDirectory){
						exportImpl(tf, false);
					}
					else{
						tf.createDirectory();
						exportImpl(tf, false);
					}
				});
			tfile.browseForDirectory("选择导出目标目录");
		}
		
		public function export():void
		{
			var tfile:File = LocalStoreUtil.read(EXPORT_TEXTURE_NAME) 
				? new File(LocalStoreUtil.read(EXPORT_TEXTURE_NAME) + File.separator + fileName + ".tt")
				: new File(File.userDirectory.nativePath + File.separator + fileName + ".tt");
			tfile.addEventListener(Event.SELECT, 
				function tselectHandler(event:Event):void
				{
					LocalStoreUtil.save(EXPORT_TEXTURE_NAME, tfile.parent.nativePath);
					tfile.removeEventListener(Event.SELECT, tselectHandler);
					
					if(tfile.name.indexOf(".tt") == -1){
						tfile = new File(tfile.parent.nativePath + File.separator + tfile.name + ".tt");
					}
					exportImpl(tfile);
				});
			tfile.browseForSave("导出纹理文件");
		}
		
		private function exportImpl(file:File, compress:Boolean=true):void
		{
			var tjson:Object = {"type":compress ? (swf2 ? "swf2" : "jpg") : "png"};
			//获取高宽
			var tx:Number = 0;
			var ty:Number = 0;
			
			var tmh:Number = 0;
			var tw:Number = 0;
			
			for(var i:int = 0; i < actList.length; i++)
			{
				tjson[i] = actList[i].props.toObject();
				
				for(var j:int = 0; j < actList[i].props.dirList.length; j++)
				{
					for(var k:int = 0; k < actList[i].props.dirList[j].frames.length; k++)
					{
						var tfbd1:BitmapData = actList[i].props.dirList[j].frames[k].getDisplayObject().bitmapData;
						if(tx + tfbd1.width <= 2048){
							tmh = Math.max(tmh, tfbd1.height);
							tw = Math.max(tw, tx + tfbd1.width);
						}
						else
						{
							tw = 2048;
							tx = 0;
							ty += tmh;
							tmh = tfbd1.height;
						}
						
						tjson[i].dirList[j].frames[k] = actList[i].props.dirList[j].frames[k].props.toObject();
						tjson[i].dirList[j].frames[k].img = {
							"width":tfbd1.width, 
							"height":tfbd1.height,
							"x":tx,
							"y":ty
						};
						tx += tfbd1.width;
					}
				}
			}
			
			//保存到文件
			var tstr:ByteArray = new ByteArray();
			var tout:ByteArray = new ByteArray();
			var tswfJson:Array;
			var tswf:PNGPacker;
			//保存图片帧列表
			var tframes:Vector.<FrameInfo> = new Vector.<FrameInfo>();
			try{
				//生成完整图片
				var tbmd:BitmapData = new BitmapData(tw, ty + tmh, true, 0x00000000);
				for(i = 0; i < actList.length; i++)
				{
					for(j = 0; j < actList[i].props.dirList.length; j++)
					{
						for(k = 0; k < actList[i].props.dirList[j].frames.length; k++)
						{
							var tfbd:BitmapData = actList[i].props.dirList[j].frames[k].getDisplayObject().bitmapData;
							tbmd.copyPixels(tfbd, tfbd.rect, new Point(tjson[i].dirList[j].frames[k].img.x, tjson[i].dirList[j].frames[k].img.y));
						}
					}
				}
				//切分块，行列形式
				var trow:int = Math.ceil(tbmd.height / 512);
				var tcol:int = Math.ceil(tbmd.width / 512);
				
				//写输出文件
				tstr.writeObject(tjson);
				tstr.compress();
				tstr.position = 0;
				tout.writeInt(tstr.length);
				tout.writeBytes(tstr);
				tstr.clear();
				
				tout.writeInt(tbmd.width);
				tout.writeInt(tbmd.height);
				tout.writeByte(trow);
				tout.writeByte(tcol);
				
				var tsw:int = 0;
				var tsh:int = 0;
				for(i = 0; i < trow; i++)
				{
					tsw = 0;
					for(j = 0; j < tcol; j++)
					{
						var tsbmd:BitmapData = new BitmapData(Math.min(512, tbmd.width-tsw), Math.min(512, tbmd.height-tsh), true, 0x00000000);
						tsbmd.copyPixels(tbmd, new Rectangle(512*j, 512*i, tsbmd.width, tsbmd.height), new Point());
						
						tframes.push(new FrameInfo(tsbmd, i, j));
						
						tsw += tsbmd.width;
						if(j == tcol - 1) tsh += tsbmd.height;
					}
				}
			}
			catch(err:*){
				//图片太大，创建失败
				tswfJson = [];
				tjson["type"] = "swf3";
				swf2 = true;
				
				//写输出文件
				tstr.writeObject(tjson);
				tstr.compress();
				tstr.position = 0;
				tout.writeInt(tstr.length);
				tout.writeBytes(tstr);
				tstr.clear();
				
				tout.writeInt(0);
				tout.writeInt(0);
				tout.writeByte(0);
				tout.writeByte(0);

				for(i = 0; i < actList.length; i++)
				{
					for(j = 0; j < actList[i].props.dirList.length; j++)
					{
						for(k = 0; k < actList[i].props.dirList[j].frames.length; k++)
						{
							tframes.push(
								new FrameInfo(
									actList[i].props.dirList[j].frames[k].getDisplayObject().bitmapData.clone(), 
									tjson[i].dirList[j].frames[k].img.x, 
									tjson[i].dirList[j].frames[k].img.y
								)
							);
						}
					}
				}
			}
			
			//导出压缩纹理并且使用swf2格式
			if(compress && swf2)
			{
				tswf = compress ? new PNGPacker() : null;
				tswfJson = [];
			}
			
			var tloading:LoadingInfo = LoadingInfo.Show(FlexGlobals.topLevelApplication as DisplayObject, tframes.length);
			var tloadNum:int = 0;
			var ttimer:Timer = new Timer(10, 2);
			ttimer.addEventListener(TimerEvent.TIMER_COMPLETE,
				function ttimerHandler(e:TimerEvent):void
				{
					if(tframes.length < 1){
						//完成了
						if(compress) {
							//swf2压缩格式
							if(tswf)
							{
								//压缩格式的则保存完整内容
								var tba:ByteArray = new ByteArray();
								tba.writeObject(tswfJson);
								tba.compress();
								tout.writeInt(tba.length);
								tout.writeBytes(tba, 0, tba.length);
								tba.clear();
								
								tba = tswf.publish();
								tout.writeInt(tba.length);
								tout.writeBytes(tba, 0, tba.length);
								//FileUtil.write(file.nativePath + ".swf", tba);
								tba.clear();
							}
							
							FileUtil.write(file, tout);
						}
						else{
							//非压缩格式只保存属性
							FileUtil.write(file.nativePath + File.separator + "prop.amf", tout);
							if(tjson["type"] == "swf3" || tjson["type"] == "swf2"){
								tout.length = 0;
								tout.position = 0;
								tout.writeObject(tswfJson);
								tout.compress();
								FileUtil.write(file.nativePath + File.separator + "class.amf", tout);
							}
						}
						
						tout.clear();
						if(tbmd) tbmd.dispose();
						
						ttimer.removeEventListener(TimerEvent.TIMER_COMPLETE, ttimerHandler);
						tloading.Hide();
						return;
					}
					//
					tloadNum++;
					tloading.setValue(tloadNum);
					//
					var tf:FrameInfo = tframes.shift();
					var trip:RipResult = new SimpleRid(tf.bitmapData, 0x00000000).rip();
					tf.bitmapData.dispose();
					tf.bitmapData = trip.bitmapData;
					if(trip.isNull)
					{
						tf.bitmapData.dispose();
					}
					else
					{
						var tpixel:ByteArray = null;
						if(compress){
							if(tswf){
								//写入图片文件数据
								tswf.addPNG(tf.bitmapData, tf.row + "_" + tf.col, quality);
								tswfJson.push(
									{
										"row":tf.row,
										"col":tf.col,
										"img":
										{
											"x":trip.imageRect.left,
											"y":trip.imageRect.top,
											"width":trip.imageRect.right,
											"height":trip.imageRect.bottom
										}
									}
								);
							}
							else
							{
								tpixel = JPEGEncoder.encode(tf.bitmapData, quality);
							}
						}
						else{
							//保存单张图片
							tpixel = PNGEncoder.encode(tf.bitmapData);
							//
							if(tjson["type"] == "swf3" || tjson["type"] == "swf2"){
								tswfJson.push(
									{
										"row":tf.row,
										"col":tf.col,
										"img":
										{
											"x":trip.imageRect.left,
											"y":trip.imageRect.top,
											"width":trip.imageRect.right,
											"height":trip.imageRect.bottom
										}
									}
								);
							}
						}
						//长度
						if(tpixel)
						{
							tout.writeInt(tpixel.length);
							//行列坐标
							tout.writeByte(tf.row);
							tout.writeByte(tf.col);
							//rect坐标
							tout.writeInt(trip.imageRect.left);
							tout.writeInt(trip.imageRect.top);
							tout.writeInt(trip.imageRect.right);
							tout.writeInt(trip.imageRect.bottom);
							//写入图片文件数据
							if(compress)
							{
								//写入JPG数据
								tout.writeBytes(tpixel, 0, tpixel.length);
								//写入透明数据
								var talpha:BitmapData = new BitmapData(tf.bitmapData.width, tf.bitmapData.height, true, 0);
								talpha.copyChannel(tf.bitmapData, tf.bitmapData.rect, new Point(), BitmapDataChannel.ALPHA, BitmapDataChannel.ALPHA);
								tba = talpha.getPixels(talpha.rect);
								tba.compress();
								tba.position = 0;
								//写入
								tout.writeInt(tba.length);
								tout.writeBytes(tba, 0, tba.length);
								//清理
								tba.clear();
								talpha.dispose();
							}
							else
							{
								FileUtil.write(file.nativePath + File.separator + tf.row + "_" + tf.col + ".png", tpixel);
							}
							//清理
							if(tpixel) tpixel.clear();
						}
						tf.bitmapData.dispose();
					}
					//再次启动
					ttimer.start();
					e.updateAfterEvent();
				}
			);
			ttimer.start();
		}
	
		/** 保存修改的属性 */
		public static function saveChange(file:File, actList:Vector.<AnimationAct>):void
		{
			var tbyte:ByteArray = FileUtil.read(file);
			var tlen:int = tbyte.readInt();
			var tstr:ByteArray = new ByteArray();
			
			//json
			tbyte.readBytes(tstr, 0, tlen);
			tstr.uncompress();
			tstr.position = 0;
			
			//属性修改
			var tjson:Object = tstr.readObject();
			for(var i:int = 0; i < actList.length; i++)
			{
				var tact:Object = actList[i].props.toObject();
				for(var j:int = 0; j < actList[i].props.dirList.length; j++)
				{
					for(var k:int = 0; k < actList[i].props.dirList[j].frames.length; k++)
					{
						tact.dirList[j].frames[k] = actList[i].props.dirList[j].frames[k].props.toObject();
						if(tact.dirList[j].frames[k].img == null
							&& tjson[i].dirList[j].frames[k].img != null){
							//
							tact.dirList[j].frames[k].img = tjson[i].dirList[j].frames[k].img;
						}
					}
				}
				//
				tjson[i] = tact;
			}
			
			//json
			var tout:ByteArray = new ByteArray();
			tstr.length = 0;
			tstr.position = 0;
			tstr.writeObject(tjson);
			tstr.compress();
			tstr.position = 0;
			tout.writeInt(tstr.length);
			tout.writeBytes(tstr);
			tstr.clear();
			
			//data
			tstr.length = 0;
			tstr.position = 0;
			tbyte.readBytes(tstr);
			tout.writeBytes(tstr);
			tstr.clear();
			
			//save
			FileUtil.write(file, tout);
			tout.clear();
			
		}
		
		/**保存tt的配置信息**/
		public static function saveTTConfig(rootPath:String,infoRet:Dictionary):void
		{
			var confgFile:File = new File(rootPath+File.separator+"config"+File.separator+"data_animation.cfg");
			var out:ByteArray = new ByteArray();
			out.writeObject(infoRet);
			out.compress();
			FileUtil.write(confgFile, out);
		}
	}
}
import flash.display.BitmapData;

class FrameInfo
{
	public var bitmapData:BitmapData;
	public var row:int;
	public var col:int;
	
	public function FrameInfo(bitmapData:BitmapData, row:int, col:int)
	{
		this.bitmapData = bitmapData;
		this.row = row;
		this.col = col;
	}
}
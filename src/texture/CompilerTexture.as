package texture
{
	import com.st.framework.utils.FileUtil;
	import com.st.framework.utils.LocalStoreUtil;
	
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.filesystem.File;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	
	import mx.controls.Alert;
	import mx.core.FlexGlobals;
	
	import utils.PNGPacker;
	
	import view.MyComponents.LoadingInfo;

	public class CompilerTexture extends EventDispatcher implements IExporter
	{
		private static const EXPORT_UNCOMPRESS_TEXTURE_NAME:String = "export_uncompress_texture";
		
		public var output:File;
		
		public function export():void
		{
			var tfile:File = new File(LocalStoreUtil.read(EXPORT_UNCOMPRESS_TEXTURE_NAME));
			tfile.addEventListener(Event.SELECT, 
				function tselectHandler(event:Event):void
				{
					LocalStoreUtil.save(EXPORT_UNCOMPRESS_TEXTURE_NAME, tfile.parent.nativePath);
					tfile.removeEventListener(Event.SELECT, tselectHandler);
					
					try{
						exportImpl(tfile);
					}
					catch(e:*){
						Alert.show("编译错误，请检查目标文件夹格式是否正确！");
						dispatchEvent(new Event(Event.COMPLETE));
					}
				});
			tfile.browseForDirectory("选择编译的非压缩纹理目录");
		}
		
		private function exportImpl(file:File):void
		{
			var tbyte:ByteArray = FileUtil.read(file.nativePath + File.separator + "prop.amf");
			var tlen:int = tbyte.readInt();
			var tstr:ByteArray = new ByteArray();
			
			//json
			tbyte.readBytes(tstr, 0, tlen);
			tstr.uncompress();
			tstr.position = 0;
			
			var tjson:Object = tstr.readObject();
			var tw:int = tbyte.readInt();
			var th:int = tbyte.readInt();
			var trow:int = tbyte.readByte();
			var tcol:int = tbyte.readByte();
			
			//保存到文件
			var tout:ByteArray = new ByteArray();
			tstr.compress();
			tstr.position = 0;
			tout.writeInt(tstr.length);
			tout.writeBytes(tstr);
			tstr.clear();
			
			tout.writeInt(tw);
			tout.writeInt(th);
			tout.writeByte(trow);
			tout.writeByte(tcol);
			
			//导出压缩纹理并且使用swf2格式
			if(tjson.type == "swf2" || tjson.type == "swf3")
			{
				var tswf:PNGPacker = new PNGPacker();
				var tswfJson:Array;
				
				tstr = FileUtil.read(file.nativePath + File.separator + "class.amf");
				tstr.uncompress();
				tswfJson = tstr.readObject();
				tstr.clear()
			}
			
			if(tjson.type == "png")
			{
				var targs:Array;
				while(tbyte.bytesAvailable)
				{
					tlen = tbyte.readInt();
					targs = [tbyte.readByte(), tbyte.readByte(), tbyte.readInt(), tbyte.readInt(), tbyte.readInt(), tbyte.readInt()];
					tstr = FileUtil.read(file.nativePath + File.separator + targs[0] + "_" + targs[1] + ".png");
					
					//长度
					tout.writeInt(tstr.length);
					//行列坐标
					tout.writeByte(targs[0]);
					tout.writeByte(targs[1]);
					//rect坐标
					tout.writeInt(targs[2]);
					tout.writeInt(targs[3]);
					tout.writeInt(targs[4]);
					tout.writeInt(targs[5]);
					//写入图片文件数据
					tout.writeBytes(tstr, 0, tstr.length);
					tstr.clear();
				}
				//
				output = new File(file.parent.nativePath + File.separator + file.name + ".tt");
				FileUtil.write(output, tout);
				tout.clear();
				
				dispatchEvent(new Event(Event.COMPLETE));
			}
			else if(tswf)
			{
				//swf2, swf3
				var tload:Loader = new Loader();
				var to:*, i:uint = 0;
				var tloading:LoadingInfo = LoadingInfo.Show(FlexGlobals.topLevelApplication as DisplayObject, tswfJson.length);
				var ttimer:Timer = new Timer(10, 2);
				ttimer.addEventListener(TimerEvent.TIMER_COMPLETE,
					function ttimerHandler(e:TimerEvent):void
					{
						const tloadfunc:Function = function(ev:Event):void
						{
							tload.contentLoaderInfo.removeEventListener(Event.COMPLETE, tloadfunc);
							tswf.addPNG(tload.content["bitmapData"], to.row + "_" + to.col, 80);
							
							i++;
							tloading.setValue(i);
							
							if(i >= tswfJson.length){
								//完成
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
								
								output = new File(file.parent.nativePath + File.separator + file.name + ".tt");
								FileUtil.write(output, tout);
								tout.clear();
								
								ttimer.removeEventListener(TimerEvent.TIMER_COMPLETE, ttimerHandler);
								tloading.Hide();
								
								dispatchEvent(new Event(Event.COMPLETE));
								return;
							}
							//再次启动
							ttimer.start();
							e.updateAfterEvent();
						}
						//load
						to = tswfJson[i];
						tload.contentLoaderInfo.addEventListener(Event.COMPLETE, tloadfunc);
						tload.loadBytes(FileUtil.read(file.nativePath + File.separator + to.row + "_" + to.col + ".png"));
					}
				);
				//启动
				ttimer.start();
			}
		}
	}
}
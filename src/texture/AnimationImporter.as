package texture
{
	import com.st.framework.utils.FileUtil;
	import com.st.framework.utils.LocalStoreUtil;
	
	import config.ConfigData;
	
	import events.ImporterEvent;
	import events.ParamEvent;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.FileFilter;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	import mx.controls.Alert;
	import mx.managers.PopUpManager;
	
	import utils.image.RipResult;
	import utils.image.SimpleRid;
	
	import view.ChoseDirActForSwf;
	
	public class AnimationImporter extends EventDispatcher
	{
		private static const ROOT_FOLDER:String = "jtaFolder";
		private static const IMAGE_FOLDER:String = "imageFolder";
		private static const TEXTURE_FOLDER:String = "textureFolder";
		private static const SWF_FOLDER:String = "swfFolder";
		public var mainApp:DisplayObject;
		private var fileStructMapping:FileMapping;
		
		/**纹理源文件**/
		[Bindable]
		public var textureFile:File;
		/**纹理文件名**/
		public var defaultName:String;
		public var anmFile:File;
		public var actList:Vector.<AnimationAct> = new Vector.<AnimationAct>();
		public var kind:int = 0;
		public var head:String = "yytou";
		
		[Bindable]
		public var swfBytes:ByteArray;
		
		private static const ANM_FILTERS:Array = [new FileFilter("动画文件", "*.jta")];
		private static const TEXTURE_FILTERS:Array = [new FileFilter("纹理文件", "*.tt")];
		private static const SWF_FILTERS:Array = [new FileFilter("Swf文件", "*.swf")];
		
		public function AnimationImporter()
		{
			anmFile = new File(LocalStoreUtil.read(ROOT_FOLDER));
			anmFile.addEventListener(Event.SELECT, anmSelectHandler);
		}
		
		/** 导入动画文件 */
		public function loadAnm():void
		{
			anmFile.browseForOpen("选择动画文件", ANM_FILTERS);
		}
		
		/** 清理 */
		public function unload():void
		{
			for each(var tas:AnimationAct in actList){
				tas.unload();
			}
			actList.length = 0;
			
			if(swfBytes){
				swfBytes.clear();
				swfBytes = null;
			}
			textureFile = null;
		}
		
		public function getFileName():String
		{
			if(!anmFile)
			{
				return "未加载";
			}
			return anmFile.name;
		}
		
		/** 动画文件选择事件处理函数 */
		private function anmSelectHandler(event:Event):void
		{
			LocalStoreUtil.save(ROOT_FOLDER, anmFile.parent.nativePath);
			try{
				loadAnmBy(anmFile);
			}
			catch(e:Error){
				Alert.show("读取文件发生错误了 ; "+e.message);
			}
		}
		
		/** 加载指定动画文件 */
		public function loadAnmBy(file:File, draw:Boolean=true):void
		{
			unload();
			//
			defaultName = file.name.substr(0, file.name.lastIndexOf("."));
			//
			var tas:AnimationAct;
			var tbytes:ByteArray = FileUtil.read(file);
			try{ tbytes.uncompress(); tbytes.position = 0; } catch(err:*){};
			//读头部
			head = tbytes.readUTF();
			kind = tbytes.readInt();
			//读取AnimationSet
			while(tbytes.bytesAvailable)
			{
				tas = new AnimationAct();
				tas.kind = kind;
				tas.load(tbytes);
				if(draw) tas.draw();
				actList.push(tas);
			}
			dispatchEvent(new ImporterEvent(ImporterEvent.ImportComplete));
		}		
		
		/** 导入图片文件夹 */
		public function loadImg():void
		{
			var tfile:File = new File(LocalStoreUtil.read(IMAGE_FOLDER));
			tfile.addEventListener(Event.SELECT, imgSelectHandler);
			tfile.browseForDirectory("选择文件夹");
		}
		
		/** 从文件夹生成数据的第二种实现--利用名字规范 */
		private function imgSelectHandler(event:Event):void
		{
			var tfile:File = event.target as File;
			
			tfile.removeEventListener(Event.SELECT, imgSelectHandler);
			LocalStoreUtil.save(IMAGE_FOLDER, tfile.nativePath);
			try{
				loadImgByFile(tfile);
			}
			catch(e:Error){
				Alert.show("读取文件发生错误了 ; "+e.message);
			}
		}
		
		public function loadImgByFile(tfile:File):void
		{
			unload();
			defaultName = tfile.name;
			
			var tcfg:File = new File(tfile.nativePath + File.separator + "config.xml");
			if(!tcfg.exists)
			{
				tcfg = new File("app:/config.xml");
			}
			//生成文件定义
			fileStructMapping = new FileMapping(new XML(FileUtil.read(tcfg)));
			
			//遍历动作文件夹
			var tlist:Array = tfile.getDirectoryListing();
			try{
				for each(var tf:File in tlist)
				{
					if(tf.isDirectory)
					{
						actList.push(generateAct(tf));
					}
				}
			}
			catch(e:Error){
				Alert.show(e.message);
				return;
			}
			dispatchEvent(new ImporterEvent(ImporterEvent.ImportComplete));
		}
		
		/** 生成动作 */
		private function generateAct(file:File):AnimationAct
		{
			//获得所有图片并且进行方向分类
			var tfiles:Array = file.getDirectoryListing();
			var tact:AnimationAct = new AnimationAct();
			
			tact.props.typeName = file.name;
			if(ConfigData.JTA_TYPES_MAP[file.name] == undefined)
			{
				throw new Error("文件名错误! " + file.name);
			}
			tact.props.type = ConfigData.JTA_TYPES_MAP[file.name];
			//生成层次结构
			var tdic:Dictionary = new Dictionary();
			for each(var tf:File in tfiles)
			{
				if(!tf.isDirectory && [".db", ".DS_Store", ".md5", ".MD5"].indexOf(tf.name.substr(tf.name.lastIndexOf("."))) == -1)
				{
					var tarr:Array = tf.name.match(/_[A-Z|a-z]{1,2}_/);
					if(!tarr)
					{
						throw new Error("文件名不符合规范: "+tf.name);
					}
					if(tarr.length)
					{
						//方向特征
						var trait:String = String(tarr[0]);
						var tds:DirStruct = tdic[trait];
						if(!tds)
						{
							tdic[trait] = tds = new DirStruct();
							tds.trait = trait;
						}
						tds.images.push(new ImageStruct(tf));
					}
				}
			}
			//验证结构
			var tlen:int = -1;
			var tsubs:DirStruct;
			for each(tsubs in tdic)
			{
				if(tlen == -1)
				{
					tlen = tsubs.images.length;
				}
				else{
					if(tlen != tsubs.images.length){
						throw new Error("验证文件失败，请检查方向图片文件的数目是否不一致,图片数量:"+tlen+",特征:"+tsubs.trait);
					}
				}
			}
			tact.props.frameCount = tlen; 
			//图片按照文件名排序, 并且生成AnimationObject对象
			for each(tsubs in tdic)
			{
				//创建方向对象
				var tad:AnimationDir = new AnimationDir();
				tad.props.dirName = fileStructMapping.dirMapping.mapping[tsubs.trait];
				tad.props.dir = ConfigData.JTA_DIRECTION_MAP[tad.props.dirName];
				tact.addDir(tad);
				//排序文件
				tsubs.sortAsc();
				//创建每一帧
				for each(var tis:ImageStruct in tsubs.images)
				{
					var tld:FrameLoader = new FrameLoader();
					var tframe:AnimationFrame = new AnimationFrame();
					tld.frame = tframe;
					tld.loadBytes(FileUtil.read(tis.file));
					tad.addFrame(tframe);
				}
				tact.props.initPro();
			}
			
			return tact;
		}
	
		/** 导入纹理 */
		public function loadTexture():void
		{
			var tfile:File = new File(LocalStoreUtil.read(TEXTURE_FOLDER));
			tfile.addEventListener(Event.SELECT, textureSelectHandler);
			tfile.browseForOpen("选择纹理文件", TEXTURE_FILTERS);
		}
		
		public function extractConfig(rootPath:String,ret:Dictionary):void
		{
			var rootFile:File = new File(rootPath);
			var files:Array = rootFile.getDirectoryListing();
			for each (var tf:File in files){
				if(tf.isDirectory) {
					extractConfig(tf.nativePath,ret)
				}else if( tf.extension.toLowerCase() == "tt" ){
					loadTextureBy(tf,true,ret);
				}
			}
		}
		
		/**导入纹理文件
		 * @param isExtractConfig 是否导出动画配置
		 * @param lastExtractResult 上次导出结果
		 * **/
		public function loadTextureBy(tfile:File,isExtractConfig:Boolean=false,lastExtractResult:Dictionary=null):void
		{
			if( !isExtractConfig ){
				unload();
				textureFile = tfile;
				defaultName = tfile.name.substr(0, tfile.name.lastIndexOf("."));
			}
			
			var tbyte:ByteArray = FileUtil.read(tfile);
			var tlen:int = tbyte.readInt();//json长度
			var tstr:ByteArray = new ByteArray();
			var tcompleteFunc:Function;
			
			//json
			tbyte.readBytes(tstr, 0, tlen);
			tstr.uncompress();
			tstr.position = 0;
			
			var e1:*, i:int, j:int, trect:Rectangle, tfbd:BitmapData, tld:Loader;
			var tact:AnimationAct;
			var tdir:AnimationDir;
			var tframe:AnimationFrame;
			/**json数据**/
			var tobj:Object = tstr.readObject();
			if( isExtractConfig ){
				var ind:int = tfile.nativePath.indexOf("assets");
				var url:String = tfile.nativePath.substring(ind);
				ind = url.indexOf("\\");
				var ind2:int = url.lastIndexOf("\\"); 
				var ind3:int = url.lastIndexOf(".");
				var cat:String = url.substring(ind+1,ind2);
				var name:String = url.substring(ind2+1,ind3);
				if( lastExtractResult[cat] == null )
					lastExtractResult[cat] = new Dictionary();
				lastExtractResult[cat][name] = tobj; 
				return;
			}
			if(tobj.type == "swf")
			{
				//swf压缩格式
				var tlc:LoaderContext = new LoaderContext();
				tld = new Loader();
				/**原始swf字节长度**/
				tlen = tbyte.readUnsignedInt();
				
				tstr.position = 0;
				tstr.length = 0;
				tbyte.readBytes(tstr);
				
				//全部加载完成
				var tdirIdx:Dictionary = new Dictionary();
				for each(e1 in tobj)//循环读取动作
				{
					if(e1 is String) continue;//跳过压缩类型名称
					
					tact = new AnimationAct();
					tact.props.parseObject(e1);
					for(i = 0; i < e1.dirList.length; i++)
					{
						tdir = new AnimationDir();
						tdir.props.parseObject(e1.dirList[i]);
						tact.addDir(tdir);
						
						for(j = 0; j < e1.dirList[i].frames.length; j++)
						{
							tframe = new AnimationFrame();
							
							tframe.props.extpixel = int(e1.dirList[i].frames[j].extpixel);
							tframe.props.rect.x = e1.dirList[i].frames[j].rect.x;
							tframe.props.rect.y = e1.dirList[i].frames[j].rect.y;
							tframe.props.rect.width = e1.dirList[i].frames[j].rect.width;
							tframe.props.rect.height = e1.dirList[i].frames[j].rect.height;
							
							tframe.props.img = new Rect(
								e1.dirList[i].frames[j].img.x,
								e1.dirList[i].frames[j].img.y,
								e1.dirList[i].frames[j].img.width,
								e1.dirList[i].frames[j].img.height
							);
							
							tdir.addFrame(tframe);
						}
						
						tdirIdx[e1.dirList[i].swf_frame] = tdir;
					}
					actList.push(tact);
				}
				//加载完成函数
				tcompleteFunc = function(ev:Event):void
				{
					tld.contentLoaderInfo.removeEventListener(Event.COMPLETE, tcompleteFunc);
					
					var tmc:MovieClip = tld.content as MovieClip;
					var transed:Object = {};
					var tenterFrame:Function = function(ev2:Event):void
						{
							j = tmc.currentFrame;
							if(transed[j]) return;
							transed[j] = true;
							tfbd = null;
							for(var tarr:* in tdirIdx){
								tdir = tdirIdx[tarr];
								if(j >= tarr[0] && j <= tarr[1]){
									tframe = tdir.frames[j-tarr[0]];
									if(tfbd == null){
										trect = new Rectangle(
											tframe.props.img.x, 
											tframe.props.img.y, 
											tframe.props.img.width, 
											tframe.props.img.height
										);
										tfbd = new BitmapData(trect.width, trect.height, true, 0);
										
										var tlrect:Rectangle = tmc.getBounds(tmc);
										var tm:Matrix = new Matrix();
										tm.translate(-tlrect.x-trect.x+tframe.props.extpixel, -tlrect.y-trect.y+tframe.props.extpixel);
										tm.scale(tmc.scaleX, tmc.scaleY);
										tfbd.draw(tmc, tm, null, null, new Rectangle(0, 0, trect.width, trect.height));
									}
									tframe.changeDisplayObject(new Bitmap(tfbd));
								}
							}
							
							if(tmc.currentFrame == tmc.totalFrames){
								//转换完成
								tmc.removeEventListener(Event.ENTER_FRAME, tenterFrame);
								dispatchEvent(new ImporterEvent(ImporterEvent.ImportComplete));
							}
						};
					
					tmc.addEventListener(Event.ENTER_FRAME, tenterFrame);
					tmc.gotoAndPlay(1);
					tenterFrame(null);
				};
				
				swfBytes = tstr;
				tld.contentLoaderInfo.addEventListener(Event.COMPLETE, tcompleteFunc);
				tlc.allowCodeImport = true;
				tld.loadBytes(tstr, tlc);
			}
			else
			{
				//png压缩格式
				var tw:int = tbyte.readInt();
				var th:int = tbyte.readInt();
				var trow:int = tbyte.readByte();
				var tcol:int = tbyte.readByte();
				var timgs:int = 0;
				var tbmd:BitmapData = (tw > 0 && th > 0) ? new BitmapData(tw, th, true, 0x00000000) : null;
				var tldDic:Dictionary = new Dictionary();
				var tcount:int = 0;
				
				//swf2, swf3
				var tswfJson:Array = null;
				
				//jpg
				var talpha:Dictionary = tobj.type == "jpg" ? new Dictionary() : null;
				
				//加载完成处理函数
				tcompleteFunc = function(ev:Event):void
				{
					(ev.target as LoaderInfo).removeEventListener(Event.COMPLETE, tcompleteFunc);
					
					if(tswfJson == null)
					{
						//PNG
						var tld2:Loader = (ev.target as LoaderInfo).loader;
						var tarr:Array = tldDic[tld2];
						var tldbmd:BitmapData = ((ev.target as LoaderInfo).loader.content as Bitmap).bitmapData;
						//JPG
						var t:int = getTimer();
						var tab:BitmapData = null;
						if(talpha && talpha[tld2])
						{
							talpha[tld2].uncompress();
							talpha[tld2].position = 0;
							tab = new BitmapData(tldbmd.width, tldbmd.height, true, 0);
							tab.setPixels(tldbmd.rect, talpha[tld2]);
							//clear
							talpha[tld2].clear();
							delete talpha[tld2];
						}
						//copyPixel
						tbmd.copyPixels(
							tldbmd,
							tldbmd.rect,
							new Point(tarr[1] * 512 + tarr[2], tarr[0] * 512 + tarr[3]),
							tab
						);
						if(tab) tab.dispose();
						trace(tobj.type, "width:", tldbmd.width, "height:", tldbmd.height, "time:", getTimer() - t);
						//
						tcount++;
					}
					else if(tbmd)
					{
						//SWF2
						for each(var to:* in tswfJson){
							var t1:int = getTimer();
							var tcls:Class = tld.contentLoaderInfo.applicationDomain.getDefinition("PNG_" + to.row + "_" + to.col) as Class;
							if(tcls){
								var tmd2:BitmapData = (new tcls()) as BitmapData;
								tbmd.copyPixels(
									tmd2,
									tmd2.rect,
									new Point(to.col * 512 + to.img.x, to.row * 512 + to.img.y)
								);
							}
							trace(tobj.type, "width:", tmd2.width, "height:", tmd2.height, "time:", getTimer() - t1);
						}
					}
					
					if(tswfJson != null || tcount >= timgs)//trow * tcol)
					{
						//全部加载完成
						for each(e1 in tobj)
						{
							if(e1 is String) continue;
							
							tact = new AnimationAct();
							tact.props.parseObject(e1);
							for(i = 0; i < e1.dirList.length; i++)
							{
								tdir = new AnimationDir();
								tdir.props.parseObject(e1.dirList[i]);
								tact.addDir(tdir);
								
								for(j = 0; j < e1.dirList[i].frames.length; j++)
								{
									trect = new Rectangle(
										e1.dirList[i].frames[j].img.x, 
										e1.dirList[i].frames[j].img.y, 
										e1.dirList[i].frames[j].img.width, 
										e1.dirList[i].frames[j].img.height
									);
									tframe = new AnimationFrame();
									tfbd = new BitmapData(trect.width, trect.height, true, 0x00000000);
									
									tframe.props.rect.x = e1.dirList[i].frames[j].rect.x;
									tframe.props.rect.y = e1.dirList[i].frames[j].rect.y;
									tframe.props.rect.width = e1.dirList[i].frames[j].rect.width;
									tframe.props.rect.height = e1.dirList[i].frames[j].rect.height;
									
									if(tbmd) {
										//png,jpg,swf2
										tfbd.copyPixels(tbmd, trect, new Point());
									}
									else{
										//swf3
										tcls = tld.contentLoaderInfo.applicationDomain.getDefinition("PNG_" + e1.dirList[i].frames[j].img.x + "_" + e1.dirList[i].frames[j].img.y) as Class;
										tfbd = (new tcls()) as BitmapData;
									}
									tdir.addFrame(tframe);
									tframe.changeDisplayObject(new Bitmap(tfbd));
								}
							}
							actList.push(tact);
						}
						//清理
						if(tbmd) tbmd.dispose();
						tbyte.clear();
						tstr.clear();
						//
						dispatchEvent(new ImporterEvent(ImporterEvent.ImportComplete));
					}
				}
				
				if(tobj.type == "swf2" || tobj.type == "swf3")
				{
					//第二种swf压缩形式跟第三种swf压缩形式
					var tlc2:LoaderContext = new LoaderContext();
					tlen = tbyte.readInt();
					tstr.position = 0;
					tstr.length = 0;
					tbyte.readBytes(tstr, 0, tlen);
					tstr.uncompress();
					tswfJson = tstr.readObject() as Array;
					
					tstr.position = 0;
					tstr.length = 0;
					tlen = tbyte.readInt();
					tbyte.readBytes(tstr, 0, tlen);
					
					tlc2.allowCodeImport = true;
					tld = new Loader();
					tld.contentLoaderInfo.addEventListener(Event.COMPLETE, tcompleteFunc);
					tld.loadBytes(tstr, tlc2);
				}
				else
				{
					//PNG
					while(tbyte.bytesAvailable)
					{
						tld = new Loader();
						
						timgs++;
						tstr.position = 0;
						tstr.length = 0;
						tlen = tbyte.readInt();
						tldDic[tld] = [tbyte.readByte(), tbyte.readByte(), tbyte.readInt(), tbyte.readInt(), tbyte.readInt(), tbyte.readInt()];
						tbyte.readBytes(tstr, 0, tlen);
						
						//JPG
						if(tobj.type == "jpg")
						{
							talpha[tld] = new ByteArray();
							tlen = tbyte.readInt();
							tbyte.readBytes(talpha[tld], 0, tlen);
						}
						
						tld.contentLoaderInfo.addEventListener(Event.COMPLETE, tcompleteFunc);
						tld.loadBytes(tstr);
					}
				}
			}
		}
		
		/** 导入纹理文件选择结果 */
		private function textureSelectHandler(event:Event):void
		{
			var tfile:File = event.target as File;
			tfile.removeEventListener(Event.SELECT, textureSelectHandler);
			LocalStoreUtil.save(TEXTURE_FOLDER, tfile.parent.nativePath);
			try{
				loadTextureBy(tfile);
			}
			catch(e:Error){
				Alert.show("读取文件发生错误了 ; " + e.message);
			}
		}
	
		public function loadSwf():void
		{
			var tfile:File = new File(LocalStoreUtil.read(SWF_FOLDER));
			tfile.addEventListener(Event.SELECT, swfSelectHandler);
			tfile.browseForOpen("选择SWF文件", SWF_FILTERS);
		}
		
		private var popWin:ChoseDirActForSwf;
		/** 导入SWF文件选择结果 */
		private function swfSelectHandler(event:Event):void
		{
			var tfile:File = event.target as File;
			tfile.removeEventListener(Event.SELECT, swfSelectHandler);
			LocalStoreUtil.save(SWF_FOLDER, tfile.parent.nativePath);
			try{
				loadSwfBy(tfile);
			}
			catch(e:Error){
				Alert.show("读取文件发生错误了 ; " + e.message);
			}
		}
		
		private function onCancelSwf(event:ParamEvent):void
		{
			PopUpManager.removePopUp(popWin);
			if(swfBytes){
				swfBytes.clear();
				swfBytes = null;
			}
		}
		private function onSelectSwf(event:ParamEvent):void
		{
			PopUpManager.removePopUp(popWin);
			doLoadSwf(event.param);
		}
		
		private function doLoadSwf(info:Object):void
		{
			var tcfg:Object = {};
			for( var k:* in info ){
				if( k == "dir" )
					continue;
				tcfg[ConfigData.JTA_TYPES_MAP_INV[k]] = {
					speed:30,
					dir:{}
				};
				
				tcfg[ConfigData.JTA_TYPES_MAP_INV[k]].dir[ConfigData.JTA_DIRECTION_MAP_INV[info.dir]] = [info[k].start,info[k].end];
			}
			/*tcfg[ConfigData.JTA_TYPES_MAP_INV[info[0]]] = {
				speed:1,
				dir:{}
			};
			tcfg[ConfigData.JTA_TYPES_MAP_INV[info[0]]].dir[ConfigData.JTA_DIRECTION_MAP_INV[info[1]]] = new Array(1,400000);*/
			
			//var tfcfg:File = new File(tfile.parent.nativePath + File.separator + "swf_config.xml");
			//if(!tfcfg.exists)
			//{
				//
			//	tfcfg = new File("app:/swf_config.xml");
				//				tcfg[ConfigData.JTA_TYPES_MAP_INV[0]] = {
				//					speed:1,
				//					dir:{}
				//				};
				//				tcfg[ConfigData.JTA_TYPES_MAP_INV[0]].dir[ConfigData.JTA_DIRECTION_MAP_INV[5]] = [1, int.MAX_VALUE];
		//	}
			//生成文件定义
			//var txml:XML = new XML(FileUtil.read(tfcfg));
			//方向
			/*var tdn:Object = {};
			var tdl:XMLList = txml.DirMappings.DirMapping;
			for each(var dx:XML in tdl)
			{
				tdn[String(dx.@trait)] = String(dx.@name);
			}*/
			//动作
			/*var tal:XMLList = txml.ActionMappings.ActionMapping;
			for each(var ax:XML in tal)
			{
				var to:Object = 
					tcfg[String(ax.@name)] = {
						speed:int(ax.@speed),
						dir:{}
					};
				
				for each(dx in ax.children()){
					var tn:String = String(dx.name());
					var tsar:Array = to.dir[tdn["_" + tn +"_"]] = String(dx).split(",");
					
					tsar[0] = int(tsar[0]);
					tsar[1] = int(tsar[1]);
				}
			}*/
			
			//创建配置数据
			var tdirIdx:Dictionary = new Dictionary();
			for(var an:String in tcfg){
				
				var tact:AnimationAct = new AnimationAct();
				tact.props.typeName = an;
				tact.props.type = ConfigData.JTA_TYPES_MAP[tact.props.typeName];
				tact.props.speed = tcfg[an].speed;
				tact.props.frameCount = 0;
				
				for(var dn:String in tcfg[an].dir){
					
					var tdir:AnimationDir = new AnimationDir();
					tdir.props.dirName = dn;
					tdir.props.dir = ConfigData.JTA_DIRECTION_MAP[tdir.props.dirName];
					tdir.props.swf_frame = tcfg[an].dir[dn];
					tact.addDir(tdir);
					
					tdirIdx[tcfg[an].dir[dn]] = tdir;
				}
				
				actList.push(tact);
			}
			
			var tld:Loader = new Loader();
			tld.contentLoaderInfo.addEventListener(Event.COMPLETE,
				function tcomplete(e:Event):void
				{
					tld.contentLoaderInfo.removeEventListener(Event.COMPLETE, tcomplete);
					
					var tp:Point = new Point(int.MIN_VALUE, int.MIN_VALUE);
					var tmc:MovieClip = tld.content as MovieClip;
					var transed:Object = {};
					var tenterFrame:Function = function(e2:Event):void
					{
						if(transed[tmc.currentFrame]) return;
						transed[tmc.currentFrame] = true;
						
						var tlrect:Rectangle = tmc.getBounds(tmc);
						var tbmd:BitmapData = new BitmapData(tlrect.width + 100, tlrect.height + 100, true, 0x00000000);
						var tm:Matrix = new Matrix();
						tm.translate(-tlrect.x+50, -tlrect.y+50);
						tm.scale(tmc.scaleX, tmc.scaleY);
						tbmd.draw(tmc, tm);
						
						var trip:RipResult = new SimpleRid(tbmd, 0x00000000).rip();
						var tframe:AnimationFrame = new AnimationFrame(new Bitmap(trip.bitmapData));
						
						tframe.props.extpixel = 50;
						tframe.props.rect.x += trip.imageRect.left + tlrect.left;
						tframe.props.rect.y += trip.imageRect.top + tlrect.top;
						tframe.props.rect.width = trip.bitmapData.width;
						tframe.props.rect.height = trip.bitmapData.height;
						
						tframe.props.img = new Rect(
							trip.imageRect.left,
							trip.imageRect.top, 
							trip.bitmapData.width,
							trip.bitmapData.height
						);
						
						if(tframe.props.rect.height + trip.imageRect.top > tp.y){
							tp.y = tframe.props.rect.height + trip.imageRect.top;
						}
						if(tlrect.left + trip.imageRect.left + (tframe.props.rect.width * 0.5 >> 0) > tp.x){
							tp.x = (tframe.props.rect.width * 0.5 >> 0) + tlrect.left + trip.imageRect.left;
						}
						tbmd.dispose();
						
						//添加至dir
						var tadded:int = 0;
						for(var tarr:* in tdirIdx){
							if(tmc.currentFrame >= tarr[0] && tmc.currentFrame <= tarr[1]){
								tdir = tdirIdx[tarr] as AnimationDir;
								tdir.addFrame(tadded == 0 ? tframe : tframe.duplicate() as AnimationFrame);
								
								tadded += 1;
							}
						}
						
						//转换完成
						if(tmc.currentFrame == tmc.totalFrames){
							//
							for each(tact in actList){
								
								var tleft0:Number = Number.POSITIVE_INFINITY;
								var tright0:Number = Number.NEGATIVE_INFINITY;
								var ttop0:Number = Number.POSITIVE_INFINITY;
								var tbottom0:Number = Number.NEGATIVE_INFINITY;
								
								for each(tdir in tact.props.dirList){
									
									var tleft:Number = Number.POSITIVE_INFINITY;
									var tright:Number = Number.NEGATIVE_INFINITY;
									var ttop:Number = Number.POSITIVE_INFINITY;
									var tbottom:Number = Number.NEGATIVE_INFINITY;
									for each(tframe in tdir.frames){
										
										tframe.props.rect.x -= tp.x;
										tframe.props.rect.y -= tp.y;
										
										if(tframe.props.rect.x < tleft)
										{
											tleft = tframe.props.rect.x;
										}
										if(tframe.props.rect.y < ttop)
										{
											ttop = tframe.props.rect.y;
										}
										if(tframe.props.rect.x + tframe.props.rect.width > tright)
										{
											tright = tframe.props.rect.x + tframe.props.rect.width;
										}
										if(tframe.props.rect.y + tframe.props.rect.height > tbottom)
										{
											tbottom = tframe.props.rect.y + tframe.props.rect.height;
										}
									}
									tdir.props.rect.x = tleft;
									tdir.props.rect.y = ttop;
									tdir.props.rect.width = tright - tleft;
									tdir.props.rect.height = tbottom - ttop;
									
									tact.props.frameCount = tdir.frames.length;
									
									if(tdir.props.rect.x < tleft0)
									{
										tleft0 = tdir.props.rect.x;
									}
									if(tdir.props.rect.y < ttop0)
									{
										ttop0 = tdir.props.rect.y;
									}
									if(tdir.props.rect.x + tdir.props.rect.width > tright0)
									{
										tright0 = tdir.props.rect.x + tdir.props.rect.width;
									}
									if(tdir.props.rect.y + tdir.props.rect.height > tbottom0)
									{
										tbottom0 = tdir.props.rect.y + tdir.props.rect.height;
									}
								}
								//
								tact.props.rect.x = tleft0;
								tact.props.rect.y = ttop0;
								tact.props.rect.width = tright0 - tleft0;
								tact.props.rect.height = tbottom0 - ttop0;
							}
							
							tmc.removeEventListener(Event.ENTER_FRAME, tenterFrame);
							dispatchEvent(new ImporterEvent(ImporterEvent.ImportComplete));
							
							tmc.stop();
							tld.unloadAndStop();
						}
					};
					
					tmc.addEventListener(Event.ENTER_FRAME, tenterFrame);
					tmc.gotoAndPlay(1);
					tenterFrame(null);
				}
			);
			
			var tlc:LoaderContext = new LoaderContext();
			tlc.allowCodeImport = true;
			//swfBytes = FileUtil.read(tfile);
			tld.loadBytes(swfBytes, tlc);
		}
		
		public function loadSwfBy(tfile:File):void
		{
			unload();
			defaultName = tfile.name.substr(0, tfile.name.lastIndexOf("."));
			swfBytes = FileUtil.read(tfile);
			
			if( popWin == null ){
				popWin = PopUpManager.createPopUp(mainApp,ChoseDirActForSwf,true) as ChoseDirActForSwf;
				popWin.addEventListener(Event.COMPLETE,onSelectSwf);
				popWin.addEventListener(Event.CLOSE,onCancelSwf);
			}else
				PopUpManager.addPopUp(popWin,mainApp,true);
			
			popWin.x = (mainApp.width - popWin.width)>>1;
			popWin.y = (mainApp.height - popWin.height)>>1;
		}
	}
}

//内部使用结构
import flash.display.Loader;
import flash.filesystem.File;
import flash.utils.Dictionary;

class MappingStruct
{
	public var keys:Vector.<String> = new Vector.<String>();
	public var mapping:Dictionary = new Dictionary();
	
	public function clear():void
	{
		for each(var t:String in keys)
		{
			delete mapping[t];
		}
		
		mapping = new Dictionary();
		keys.length = 0;
	}
	
	public function addDef(key:String, value:*):void
	{
		if(keys.indexOf(key) == -1)
		{
			keys.push(key);
		}
		mapping[key] = value;
	}
}

class ActionStruct
{
	public var name:String;
	public var speed:int;
	
	public function ActionStruct(name:String, speed:int)
	{
		this.name = name;
		this.speed = speed;
	}
}

class FileMapping
{
	public var dirMapping:MappingStruct = new MappingStruct();
	public var actMapping:MappingStruct = new MappingStruct();
	
	public function FileMapping(xml:XML):void
	{
		//方向
		var tdl:XMLList = xml.DirMappings.DirMapping;
		for each(var dx:XML in tdl)
		{
			dirMapping.addDef(dx.@trait, String(dx.@name));
		}
		//动作
		var tal:XMLList = xml.ActionMappings.ActionMapping;
		for each(var ax:XML in tal)
		{
			actMapping.addDef(ax.@trait, new ActionStruct(ax.@name, ax.@speed));
		}
	}
}

class DirStruct
{
	public var trait:String;
	public var images:Vector.<ImageStruct> = new Vector.<ImageStruct>();
	
	public function sortAsc():void
	{
		images.sort(sortFunc);
	}
	
	private static const REG:RegExp = /_([0-9]+)\.(\w)+$/;
	private static function sortFunc(a:ImageStruct, b:ImageStruct):int
	{
		var taa:Array = a.filename.match(REG);
		var tba:Array = b.filename.match(REG);
		if(!taa || !tba)
		{
			throw new Error("文件名不符合规范: "+a.filename);
		}
		if(taa.length > 1 && tba.length > 1)
		{
			var tan:int = parseInt(taa[1]);
			var tbn:int = parseInt(tba[1]);
			if(tan > tbn)
			{
				return 1;
			}
			else if(tan < tbn){
				return -1;
			}			
		}
		return 0;
	}
}

class ImageStruct
{
	public var file:File;
	public var filename:String;
	
	public function ImageStruct(file:File)
	{
		this.file = file;
		this.file.canonicalize();
		this.filename = file.nativePath;
	}
}
package texture
{
	import com.st.framework.utils.FileUtil;
	import com.st.framework.utils.LocalStoreUtil;
	
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.utils.ByteArray;

	public class SwfExporter implements IExporter
	{
		public static function exportTo(actList:Vector.<AnimationAct>, fileName:String, swfBytes:ByteArray, compress:Boolean):void
		{
			(new SwfExporter(actList, fileName, swfBytes, compress)).export();
		}
		
		private static const EXPORT_SWF_NAME:String = "export_swf";
		
		private var actList:Vector.<AnimationAct>;
		private var fileName:String;
		private var swfBytes:ByteArray;
		private var compress:Boolean;
		
		public function SwfExporter(actList:Vector.<AnimationAct>, fileName:String, swfBytes:ByteArray, compress:Boolean)
		{
			this.actList = actList;
			this.fileName = fileName;
			this.swfBytes = swfBytes;
			this.compress = compress;
		}
		
		public function export():void
		{
			var tpath:String = LocalStoreUtil.read(EXPORT_SWF_NAME); 
			tpath = tpath ? (tpath + File.separator) : File.userDirectory.nativePath + File.separator;
			
			var tfile:File = compress ? new File(tpath + fileName + ".tt") : new File(tpath + fileName);
			
			tfile.addEventListener(Event.SELECT, 
				function tselectHandler(event:Event):void
				{
					LocalStoreUtil.save(EXPORT_SWF_NAME, tfile.parent.nativePath);
					tfile.removeEventListener(Event.SELECT, tselectHandler);
					
					if(compress ){
						if(tfile.name.indexOf(".tt") == -1){
							tfile = new File(tfile.parent.nativePath + File.separator + tfile.name + ".tt");
						}
					}
					else{
						//创建目录
						tfile.createDirectory();
					}
					exportImpl(tfile);
				});
			
			tfile.browseForSave("导出Swf纹理文件");
		}
		
		private function exportImpl(file:File):void
		{
			var tjson:Object = {"type":"swf"};
			for(var i:int = 0; i < actList.length; i++)
			{
				tjson[i] = actList[i].props.toObject();
				
				for(var j:int = 0; j < actList[i].props.dirList.length; j++)
				{
					for(var k:int = 0; k < actList[i].props.dirList[j].frames.length; k++)
					{
						tjson[i].dirList[j].frames[k] = actList[i].props.dirList[j].frames[k].props.toObject();
					}
				}
			}
			//保存到文件
			var tstr:ByteArray = new ByteArray();
			tstr.writeObject(tjson);
			tstr.compress();
			tstr.position = 0;
			
			if(compress){
				//压缩纹理
				var tout:ByteArray = new ByteArray();
				tout.writeInt(tstr.length);
				tout.writeBytes(tstr);
				
				tout.writeUnsignedInt(swfBytes.length);
				tout.writeBytes(swfBytes, 0, swfBytes.length);
				
				FileUtil.write(file, tout);
				tout.clear();
			}
			else{
				//非压缩纹理
				FileUtil.write(file.nativePath + File.separator + "prop.amf", tstr);
				FileUtil.write(file.nativePath + File.separator + "texture.swf", swfBytes);
			}
			tstr.clear();
		}
	}
}
package texture
{
	import com.st.framework.utils.LocalStoreUtil;
	
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.utils.ByteArray;

	public class AnimationExporter
	{
		public static function exportTo(actList:Vector.<AnimationAct>, fileName:String):void
		{
			(new AnimationExporter(fileName, new AnimationModel(actList))).export();
		}
		
		private var filename:String;
		private var model:IAnimation;
		
		public function AnimationExporter(filename:String, model:IAnimation)
		{
			this.filename = filename;
			this.model = model;
		}
		
		private static const EXPORT_ANM_NAME:String = "ExportJTA";
		
		/** 导出到指定文件名，打开保存对话框 */
		public function export():void
		{
			var tbytes:ByteArray;
			var tsize:int;
			if(model is AnimationModel){
				tbytes = new ByteArray();
				tsize = model.save(tbytes);
			}
			else if(model is ByteArray)
			{
				tbytes = model as ByteArray;
				tsize = tbytes.length;
			}
			//保存到文件
			var tfile:File = new File(LocalStoreUtil.read(EXPORT_ANM_NAME));
			tfile.addEventListener(Event.SELECT, function tselect(evt:Event):void
			{
				tfile.removeEventListener(Event.SELECT, tselect);
				LocalStoreUtil.save(EXPORT_ANM_NAME, tfile.nativePath);
			});
			tbytes.position = 0;
			tfile.save(tbytes, filename);
		}
	}
}
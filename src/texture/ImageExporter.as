package texture
{
	import com.adobe.images.PNGEncoder;
	import com.st.framework.utils.FileUtil;
	import com.st.framework.utils.LocalStoreUtil;
	
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.geom.Matrix;
	
	public class ImageExporter implements IExporter
	{
		/** 导出至... */
		public static function exportTo(actList:Vector.<AnimationAct>, fileName:String):void
		{
			(new ImageExporter(actList, fileName)).export();
		}
		
		public function ImageExporter(actList:Vector.<AnimationAct>, fileName:String)
		{
			this.actList = actList;
			this.fileName = fileName;
			this.fileStructMapping = new FileMapping(new XML(FileUtil.read(new File("app:/config.xml"))));
		}
		
		private var actList:Vector.<AnimationAct>;
		private var fileName:String;
		private var fileStructMapping:FileMapping;
		
		private static const EXPORT_IMAGE_NAME:String = "export_image";
		
		public function export():void
		{
			var tfile:File = new File(LocalStoreUtil.read(EXPORT_IMAGE_NAME));
			tfile.addEventListener(Event.SELECT, 
				function tselectHandler(event:Event):void
				{
					LocalStoreUtil.save(EXPORT_IMAGE_NAME, tfile.nativePath);
					tfile.removeEventListener(Event.SELECT, tselectHandler);
					
					tfile = new File(tfile.nativePath + File.separator + fileName);
					tfile.canonicalize();
					if(!tfile.exists)
					{
						tfile.createDirectory();
					}
					
					for each(var tact:AnimationAct in actList)
					{
						exportActImpl(tact, tfile);
					}
				});
			tfile.browseForDirectory("请选择导出的文件夹");
		}
		
		private function exportActImpl(act:AnimationAct, file:File):void
		{
			var tfile:File = new File(file.nativePath + File.separator + act.props.typeName);
			tfile.canonicalize();
			if(!tfile.exists)
			{
				tfile.createDirectory();
			}
			
			for each(var tdir:AnimationDir in act.props.dirList)
			{
				exportFrameImpl(tdir, tfile);
			}
		}
		
		private static const BITMAP_SIZE:int = 512;
		private function exportFrameImpl(dir:AnimationDir, file:File):void
		{
			var tidx:int = 0;
			for each(var taf:AnimationFrame in dir.frames)
			{
				var tmat:Matrix = new Matrix();
				var tbmd:BitmapData = new BitmapData(BITMAP_SIZE, BITMAP_SIZE, true, 0x00000000);
				tmat.translate(BITMAP_SIZE/2+taf.props.rect.x, BITMAP_SIZE/2+taf.props.rect.y);
				tbmd.draw(taf.getDisplayObject(), tmat);
				
				var tf:File = new File(file.nativePath + File.separator + fileStructMapping.dirMapping[dir.props.dirName] + tidx + ".png");
				FileUtil.write(tf, PNGEncoder.encode(tbmd));

				tbmd.dispose();
				++tidx;
			}
		}
	}
}
import flash.utils.Dictionary;

class FileMapping
{
	public var dirMapping:Dictionary = new Dictionary();
	public var actMapping:Dictionary = new Dictionary();
	
	public function FileMapping(xml:XML):void
	{
		//方向
		var tdl:XMLList = xml.DirMappings.DirMapping;
		for each(var dx:XML in tdl)
		{
			dirMapping[String(dx.@name)] = String(dx.@trait);
		}
		//动作
		var tal:XMLList = xml.ActionMappings.ActionMapping;
		for each(var ax:XML in tal)
		{
			actMapping[String(ax.@name)] = String(ax.@trait);
		}
	}
}
package texture
{
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	
	import mx.controls.Alert;
	
	public class FrameLoader extends Loader
	{
		public var frame:AnimationFrame;
		
		public function FrameLoader()
		{
			contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, loadError, false, 0, true);
			contentLoaderInfo.addEventListener(Event.COMPLETE, frameLoaded, false, 0, true);
		}
		
		private function frameLoaded(event:Event):void
		{
			try{
				frame.changeDisplayObject(content as Bitmap);
				frame.x = frame.props.rect.x = -content.width * 0.5;
				frame.y = frame.props.rect.y = -content.height * 0.5;
				frame.props.rect.width = content.width;
				frame.props.rect.height = content.height;
			}
			catch(e:Error){
				Alert.show("设置图片资源大小发生错误: " + e.message);
			}
		}
		
		private function loadError(event:Event):void
		{
			trace(event.type, event.target);
		}
	}
}
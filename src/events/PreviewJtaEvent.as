package events
{
	import flash.events.Event;
	import flash.filesystem.File;
	
	public class PreviewJtaEvent extends Event
	{
		public function PreviewJtaEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		public static const OPEN:String = "PreviewJtaEvent_OPEN";
		public var file:File;
		
		override public function clone():Event
		{
			var tevt:PreviewJtaEvent = new PreviewJtaEvent(type, bubbles, cancelable);
			tevt.file = file;
			return tevt;
		}
	}
}
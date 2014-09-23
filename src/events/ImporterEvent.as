package events
{
	import flash.events.Event;
	
	public class ImporterEvent extends Event
	{
		public static const ImportComplete:String = "ImportComplete";
		
		public function ImporterEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		override public function clone():Event
		{
			return new ImporterEvent(type, bubbles, cancelable);
		}
	}
}
package events
{
	import flash.events.Event;
	
	public class ParamEvent extends Event
	{
		public var param:*;
		public function ParamEvent(type:String, param:* = null,bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.param = param;
		}
	}
}
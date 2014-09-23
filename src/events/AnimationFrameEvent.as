package events
{
	import flash.events.Event;
	
	import texture.AnimationFrame;
	
	public class AnimationFrameEvent extends Event
	{
		public function AnimationFrameEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		public static const ImageChange:String = "AnimationFrameEvent_ImageChange";
		
		public static const DeleteFrame:String = "AnimationFrameEvent_DeleteFrame";
		
		public var frame:AnimationFrame;
	}
}
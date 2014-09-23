package events
{
	import flash.events.Event;
	
	import texture.AnimationFrame;
	
	public class FrameSelectEvent extends Event
	{
		public function FrameSelectEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		public var animationFrame:AnimationFrame;
		public var alphaValue:Number;
		
		public static const FRAME_SELECTED:String = "FrameSelected";
		public static const FRAME_ALPHA_CHANGED:String = "FrameAlphaChanged";
	}
}
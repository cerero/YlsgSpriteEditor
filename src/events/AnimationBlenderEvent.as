package events
{
	import flash.events.Event;
	
	import texture.AnimationImporter;
	
	public class AnimationBlenderEvent extends Event
	{
		public function AnimationBlenderEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		public static const ANIMATION_ADD:String = "AnimationBlenderEvent_ANIMATION_ADD";
		
		public static const ANIMATION_REMOVED:String = "AnimationBlenderEvent_ANIMATION_REMOVED";
		
		public static const ANIMATION_REMOVED_ALL:String = "AnimationBlenderEvent_ANIMATION_REMOVED_ALL";
		
		public var animationImporter:AnimationImporter;
	}
}
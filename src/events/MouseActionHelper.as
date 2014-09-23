package events
{
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;

	/**
	 * 只允许事件分派器在同类型的事件拥有一个监听器。 
	 * @author Administrator
	 * 
	 */
	public class MouseActionHelper
	{
		private static var instance:MouseActionHelper;
		private var handler:Dictionary;
		
		public function MouseActionHelper()
		{
			handler = new Dictionary();
		}
		
		public static function getSingleton():MouseActionHelper
		{
			if(!instance)
			{
				instance = new MouseActionHelper();
			}
			return instance;
		}
		
		public function addEventListener(eventDispatcher:EventDispatcher, type:String, listener:Function):void
		{
			removeEventListener(eventDispatcher, type);
			handler[type] = listener;
			eventDispatcher.addEventListener(type, listener);
		}
		
		public function removeEventListener(eventDispatcher:EventDispatcher, type:String):void
		{
			if(handler[type])
			{
				eventDispatcher.removeEventListener(type, handler[type]);
				delete handler[type];
			}
		}
		
		
	}
}
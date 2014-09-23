package events
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	public class EventCenter extends EventDispatcher
	{
		public static const CONFIGS_CHANGE:String="configs_change";
		public static const TYPE_ARRAY_CHANGE:String="type_array_change";
		public static const SHOW_SYSTEM_CONFIG:String="show_system_config";
		public static const GENERATE_MAP_DATA:String="generate_map_data";
		public static const OTHERPROTERY_CHANGE:String="otherprotery_change";
		public static const REMOVE_ALL_GRID:String="remove_all_grid";
		private static var instance:EventCenter;
		public function EventCenter(target:IEventDispatcher=null)
		{
			super(target);
		}
		public static function getInstance():EventCenter{
			if(instance==null)
				instance=new EventCenter();
			return instance;
		}
	}
}
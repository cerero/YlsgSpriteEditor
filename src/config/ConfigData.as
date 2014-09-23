package config
{
	import com.st.framework.utils.FileUtil;
	
	import flash.filesystem.File;
	import flash.net.FileFilter;
	
	import mx.collections.ArrayCollection;
	import mx.utils.StringUtil;
	
	public class ConfigData
	{		
		public static var IMAGEFilter:FileFilter = new FileFilter("Image","*.jpg;*.gif;*.bmp;*.jpeg;*.png");
		
		public static var JTA_TYPES_MAP_INV:Object;//{"0":"站立","1":"走动","2":"攻击","3":"受伤","4":"死亡", "5":"坐骑"};
		public static var JTA_TYPES_MAP:Object;//={"站立":0,"走动":1,"攻击":2,"受伤":3,"死亡":4,"坐骑":5};
		
		public static var JTA_DIRECTION_MAP_INV:Object;//={"1":"北","2":"东北","3":"东","4":"东南","5":"南","6":"西南","7":"西","8":"西北"};
		public static var JTA_DIRECTION_MAP:Object;//={"北":1,"东北":2,"东":3,"东南":4,"南":5,"西南":6,"西":7,"西北":8};
		public static var ACT_LIST:ArrayCollection;
		public static var DIR_LIST:ArrayCollection;
		public static function readConfig(file:File):void
		{
			ACT_LIST = new ArrayCollection();
			DIR_LIST = new ArrayCollection();
			var xml:XML = XML(FileUtil.read(file));
			var anim_xml:XMLList = xml..animation;
			var dir_xml:XMLList = xml..direction;
			var sx:XML;
			var name:String;
			var value:String;
			//Animation Type
			if(anim_xml.length() > 0)
			{
				JTA_TYPES_MAP = {};
				JTA_TYPES_MAP_INV = {};
				for each(sx in anim_xml)
				{
					name = StringUtil.trim(String(sx.@name));
					value = StringUtil.trim(String(sx.@value));
					JTA_TYPES_MAP[name] = int(value);
					JTA_TYPES_MAP_INV[value] = name;
					ACT_LIST.addItem({label:name,data:value});
				}
			}
			
			//Direction
			if(dir_xml.length() > 0)
			{
				JTA_DIRECTION_MAP_INV = {};
				JTA_DIRECTION_MAP = {};
				for each(sx in dir_xml)
				{
					name = StringUtil.trim(String(sx.@name));
					value = StringUtil.trim(String(sx.@value));
					JTA_DIRECTION_MAP[name] = int(value);
					JTA_DIRECTION_MAP_INV[value] = name;
					DIR_LIST.addItem({label:name,data:value});
				}
			}
		}
	}
}

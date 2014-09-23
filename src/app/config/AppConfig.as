package app.config
{
	public class AppConfig
	{
		public var version:String = "0";
		public var filename:String = "SpriteEditor.air";
		public var updateServer:String = "";
		public var desc:Array = new Array();
		
		public function parse(cfgXML:XML):void
		{			
			filename = cfgXML.FileName[0].@value;
			version = cfgXML.Version[0].@value;
			updateServer = cfgXML.UpdateServer[0].@value;
			for each(var dx:XML in cfgXML.Descritions.Desc)
			{
				desc.push(String(dx.@value));
			}
		}
		
		public static function compareVersion(oldConfig:AppConfig, newConfig:AppConfig):int
		{
			var oa:Array = oldConfig.version.split(".");
			var na:Array = newConfig.version.split(".");
			var len:int = oa.length < na.length ? oa.length : na.length;
			for(var i:int = 0; i < len; ++i)
			{
				if(oa[i] < na[i])
				{
					return -1;
				}else if(oa[i] > na[i]){
					return 1;
				}
			}
			if(oa.length < na.length){
				return -1;
			}else if(oa.length > na.length){
				return 1;
			}
			return 0;
		}
	}
}
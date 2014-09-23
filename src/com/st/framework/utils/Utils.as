package com.st.framework.utils
{
	public class Utils extends Object
	{
		private static const CONST1:Number = 57.2958;
		private static const CONST2:int = 1.04858e+006;
		private static var DEG_DIR_MAP:Array;
		private static const CONST3:int = 86400;
		private static const CONST4:int = 3600;
		private static const _2PI:Number = 6.28319;
		
		/** html元素编码 */
		public static function encodeHTML(value:String) : String
		{
			if (!value)
			{
				return "";
			}
			return value.replace(/&/, "&amp;").replace(/</, "&lt;").replace(/>/, "&gt;").replace(/'/, "&apos;");
		}
		
		/** 把color值转换为html使用的color值 */
		public static function convertToHtmlColor(color:uint) : String
		{
			var tr:String = (color >> 16 & 255).toString(16);
			var tg:String = (color >> 8 & 255).toString(16);
			var tb:String = (color & 255).toString(16);
			if (tr.length == 1)
			{
				tr = "0" + tr;
			}
			if (tg.length == 1)
			{
				tg = "0" + tg;
			}
			if (tb.length == 1)
			{
				tb = "0" + tb;
			}
			return "#" + tr + tg + tb;
		}
		
		/** 格式化时间 */
		public static function formatDate(date:Date) : String
		{
			return date.getFullYear() + "-" + (date.getMonth() + 1) + "-" + date.getDate() + " " + date.getHours() + ":" + date.getMinutes() + ":" + date.getSeconds();
		}
		
		/** 得到时间中文表示 */
		public static function getTimeName(time:int) : String
		{
			var tname:String = "";
			if (time > CONST3)
			{
				tname = tname + (time / CONST3 + "天");
				time = time % CONST3;
			}
			if (time > CONST4)
			{
				tname = tname + (time / CONST4 + "小时");
				time = time % CONST4;
			}
			if (time > 60)
			{
				tname = tname + (time / 60 + "分钟");
				time = time % 60;
			}
			if (time > 0)
			{
				tname = tname + (time + "秒");
			}
			return tname;
		}
		
		/** 文件尺寸转化 */
		public static function getSizeName(size:int) : String
		{
			if (size > CONST2)
			{
				return Number(size / CONST2).toFixed(2) + "MB";
			}
			return Number(size / 1024).toFixed(2) + "KB";
		}
	}
}

package com.st.framework.utils
{
	/**数学工具类*/
	public class MathUtils
	{
		/**得到范围内随机整形*/
		public static function randomInt(a:int,b:int):int
		{
			return Math.floor(Math.random() * (1+b-a)) + a;
		}
		
		/**得到范围内随机无符号整形*/
		public static function randomUint(a:uint,b:uint):uint
		{
			return Math.floor(Math.random() * (1+b-a)) + a;
		}
		
		/**得到范围内随机浮点形*/
		public static function randomFloat(a:Number, b:Number):Number
		{
			return Math.random() * (1+b-a) + a;
		}
		
		/**千分位格式化数字*/
		public static function formatToThousands( pNumber:Number ):String 
		{   
			var tflag:Boolean = pNumber < 0;
			var tstr:String = Math.abs(Math.floor(pNumber)).toString();
			var str:String = "";
			var tlen:uint = tstr.length;
			while(tlen > 0){
				str = (tlen-3 > 0 ? "," : "") + tstr.substr(tlen-3) + str;
				tstr = tstr.substr(0, tlen - 3);
				tlen = tstr.length;
			}
			
			return (tflag ? "-" : "") + str;
		}  
		
		/**以千分位格式化之后的字符串转换成数字*/
		public static function thousandsToNumber(str:String):Number
		{
			return Number(str.replace(/,/g, ""));
		}
	}
}
package com.st.framework.utils
{
	public class LanguageUtil
	{
		/**
		 * 格式化语言 {1} {2} 等替换成相应的参数
		 */ 
		public static function formater(lan:String, ...args):String
		{
			var tlen:int = args.length;
			for(var i:int = 0; i < tlen; i++){
				lan = lan.replace("{" + (i + 1).toString() + "}", String(args[i]));
			}
			return lan;
		}
	}
}
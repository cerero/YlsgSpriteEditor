package com.st.framework.utils
{
	import com.adobe.utils.StringUtil;

	public class JsonFormatter
	{
		/**  
		 * json字符串的格式化，友好格式  
		 *   
		 * @param json json串  
		 * @param fillStringUnit 填充字符，比如四个空格  
		 * @return  
		 */  
		public static function formatJson(json:String, fillStringUnit:String="\t"):String
		{   
			json = StringUtil.trim(json);
			if (json == null || json.length == 0) {   
				return null;   
			}   
			
			var token:String;
			var tokenList:Array = [];
			var jsonTemp:String = json;   
			//预读取   
			while (jsonTemp.length > 0) {   
				token = getToken(jsonTemp);   
				jsonTemp = jsonTemp.substring(token.length);   
				token = StringUtil.trim(token);   
				tokenList.push(token);   
			}              
			
			var buf:String = "";
			var count:int = 0;   
			for (var i:int = 0; i < tokenList.length; i++) {   
				token = tokenList[i];   
				if (token === (",")) {   
					buf += token;   
					buf = doFill(buf, count, fillStringUnit);   
					continue;   
				}   
				if (token === (":")) {   
					buf += (" ") + (token) + (" ");   
					continue;   
				}   
				if (token === ("{")) {   
					var nextToken:String = tokenList[i + 1];   
					if (nextToken === ("}")) {   
						i++;   
						buf += ("{ }");   
					} else {   
						count++;   
						buf += (token);   
						buf = doFill(buf, count, fillStringUnit);   
					}   
					continue;   
				}   
				if (token === ("}")) {   
					count--;   
					buf = doFill(buf, count, fillStringUnit);   
					buf += (token);   
					continue;   
				}   
				if (token === ("[")) {   
					nextToken = tokenList[i + 1];   
					if (nextToken === ("]")) {   
						i++;   
						buf += ("[ ]");   
					} else {   
						count++;   
						buf += (token);   
						buf = doFill(buf, count, fillStringUnit);   
					}   
					continue;   
				}   
				if (token === ("]")) {   
					count--;   
					buf = doFill(buf, count, fillStringUnit);   
					buf += (token);   
					continue;   
				}   
				
				buf += (token);   
			}   
			return buf;   
		}   
		
		private static function getToken(json:String):String
		{   
			var buf:String = ""; 
			var isInYinHao:Boolean = false;   
			while (json.length > 0) {   
				var token:String = json.substring(0, 1);   
				json = json.substring(1);   
				
				if (!isInYinHao &&    
					(token === ":" || token === "{" || token === "}"    
						|| token === "[" || token === ("]")   
						|| token === (","))) {   
					if (buf.length == 0) {                     
						buf += (token);
					}   
					break;   
				}   
				
				if (token === ("\\")) {   
					buf += (token);   
					buf += (json.substring(0, 1));   
					json = json.substring(1);   
					continue;   
				}   
				if (token === ("\"")) {   
					buf += (token);   
					if (isInYinHao) {   
						break;   
					} else {   
						isInYinHao = true;   
						continue;   
					}                  
				}   
				buf += (token);   
			}   
			return buf;
		}   
		
		private static function doFill(buf:String, count:int, fillStringUnit:String):String
		{   
			buf += ("\n");   
			for (var i:int = 0; i < count; i++) {   
				buf += (fillStringUnit);   
			}   
			return buf;
		}   
	}
}
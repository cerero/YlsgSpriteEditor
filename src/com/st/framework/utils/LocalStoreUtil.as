package com.st.framework.utils
{
	import flash.data.EncryptedLocalStore;
	import flash.utils.ByteArray;

	public class LocalStoreUtil
	{
		/** 保存信息 */
		public static function save(name:String, value:*):void
		{
			//保存路径信息
			var tbyte:ByteArray = new ByteArray();
			tbyte.writeObject(value);
			
			EncryptedLocalStore.setItem(name, tbyte);
		}
		
		/** 读到信息 */
		public static function read(name:String):*
		{
			var tbyte:ByteArray = EncryptedLocalStore.getItem(name);
			
			if(tbyte != null){
				try{
					return tbyte.readObject();
				}
				catch(e:Error){}
			}
			
			return null;
		}
	}
}
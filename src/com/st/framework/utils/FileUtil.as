package com.st.framework.utils
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;

	public class FileUtil
	{
		/** 从文件读取 */
		public static function read(file:*, position:uint=0, length:uint=0):ByteArray
		{
			var tfs:FileStream;
			if(file is File)
			{
				tfs = new FileStream();
				tfs.open(file, FileMode.READ);
			}
			else if(file is FileStream)
			{
				tfs = file;
			}
			else if(file is String){
				file = new File(file);
				tfs = new FileStream();
				tfs.open(file, FileMode.READ);
			}
			else{
				throw new Error("参数类型不正确");
			}
			
			var tbyte:ByteArray = new ByteArray();
			tfs.position = position;
			tfs.readBytes(tbyte, 0, length);
			tfs.close();
			tbyte.position = 0;
			return tbyte;
		}
		
		/** 写入到文件 */
		public static function write(file:*, byte:*):void
		{
			var tfs:FileStream;
			if(file is File)
			{
				tfs = new FileStream();
				tfs.open(file, FileMode.WRITE);
			}
			else if(file is FileStream)
			{
				tfs = file;
			}
			else if(file is String){
				file = new File(file);
				tfs = new FileStream();
				tfs.open(file, FileMode.WRITE);
			}
			else{
				throw new Error("参数类型不正确");
			}
			
			if(byte is ByteArray){
				tfs.writeBytes(byte);
			}
			else if(byte is String){
				tfs.writeMultiByte(byte, "utf-8");
			}
			tfs.close();
			trace("save:" + file.nativePath);
		}
	}
}
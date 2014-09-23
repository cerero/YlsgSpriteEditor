package utils
{
	import flash.display.BitmapData;
	import flash.display.JPEGEncoderOptions;
	import flash.geom.Point;
	import flash.utils.ByteArray;
	
	import mx.graphics.codec.JPEGEncoder;
	
	/**
	 * ...
	 * @author Nidin P Vinayakan
	 */
	public class JPEG3Encoder
	{
		
		public static function encode(source:BitmapData, quality:uint=80):Object
		{
			var tobj:Object = {};
			
			var tbmd:BitmapData = new BitmapData(source.width, source.height, false, 0);
			tbmd.copyPixels(source, source.rect, new Point());
			
			tobj.bitmapBytes = new ByteArray();//JPEGEncoder.encode(tbmd, quality);
			tbmd.encode(tbmd.rect, new JPEGEncoderOptions(quality), tobj.bitmapBytes);
			tobj.bitmapAlphaBytes = new ByteArray();
			tbmd.dispose();
			
			if (source.transparent)
			{
				for (var y:int = 0; y < source.height; y++)
				{
					//IDAT.writeByte(0); // no filter
					for (var x:int = 0; x < source.width; x++)
					{
						var pixel:uint = source.getPixel32(x, y);
						//IDAT.writeUnsignedInt(uint(((pixel & 0xFFFFFF) << 8) |(pixel >>> 24)));
						//trace(pixel.toString(16));
						tobj.bitmapAlphaBytes.writeByte(pixel >> 24 & 0xFF);
					}
				}
			}
			(tobj.bitmapAlphaBytes as ByteArray).compress();
			
			return tobj;
		}
	}
}
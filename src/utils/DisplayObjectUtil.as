package utils
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.geom.Point;

	public class DisplayObjectUtil
	{
		/** 获取DisplayObject对象对应的Bitmap实例 */
		public static function getBitmapFromDisplayObject(dp:DisplayObject):Bitmap
		{
			var bitmap:Bitmap = new Bitmap();
			if(dp == null || dp.width == 0 || dp.height == 0)
			{
				bitmap.bitmapData = new BitmapData(1,1,true, 0);
			}
			else if(dp is Bitmap)
			{
				bitmap.bitmapData = (dp as Bitmap).bitmapData;
			}
			else
			{
				bitmap.bitmapData = new BitmapData(dp.width, dp.height, true, 0);
				bitmap.bitmapData.draw(dp);
			}
			return bitmap;
		}
	}
}
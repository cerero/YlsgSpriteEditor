package utils.image
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class SimpleRid
	{
		private var bitmapData:BitmapData;
		//四个边的像素
		public var left:uint;
		public var right:uint;
		public var top:uint;
		public var bottom:uint;
		
		private var keyColor:uint;
		
		public function SimpleRid(bd:BitmapData, keyColor:uint)
		{
			this.bitmapData = bd;
			this.keyColor = keyColor;
					
			this.left = bd.width;
			this.right = 0;
			this.top = bd.height;
			this.bottom = 0;
		}
		
		public function rip():RipResult
		{
			//所有像素的数组
			var twidth:Number = bitmapData.width;
			var theight:Number = bitmapData.height;
			for(var j:int = 0; j < theight; ++j)
			{
				for(var i:int = 0; i < twidth; ++i){
					var tcolor:uint = bitmapData.getPixel32(i, j);
					if((tcolor >> 24 & 0xFF) == 0)
					{
						continue;
					}
					else if(tcolor != keyColor)
					{
						if(i < left)
						{
							left = i;
						}
						if(i >= right)
						{
							right = i + 1;
						}
						if(j < top)
						{
							top = j;
						}
						if(j >= bottom)
						{
							bottom = j + 1;
						}
					}
				}
			}
			//已经获得四个边，切割它
			twidth = right - left;
			theight = bottom - top;
			
//			if(twidth <= 0) 
//			{
//				twidth = 1;
//			}
//			if(theight <= 0)
//			{
//				theight = 1;
//			} 
			var tbd:BitmapData = new BitmapData(Math.max(1, twidth), Math.max(1, theight), true, 0x00000000);
			var trect:Rectangle = new Rectangle(left, top, twidth, theight);
			tbd.copyPixels(bitmapData, trect, new Point());
			
			//生成结果
			var tret:RipResult = new RipResult();
			var trr:RippedRect = new RippedRect();
			trr.left = left;
			trr.right = right;
			trr.top = top;
			trr.bottom = bottom;
			tret.imageRect = trr;
			tret.bitmapData = tbd;
			tret.isNull = twidth < 1 || theight < 1;
			return tret;
		}		
		
	}
}
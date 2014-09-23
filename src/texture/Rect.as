package texture
{
	public class Rect
	{
		public var width:int;
		public var height:int;
		public var x:int;
		public var y:int;
		
		public function Rect(vx:int=0, vy:int=0, w:int=0, h:int=0)
		{
			x = vx;
			y = vy;
			width = w;
			height = h;
		}
		
		public function isNull():Boolean
		{
			return x == 0 && y == 0 && width == 0 && height == 0;
		}
		
		public function clone():Rect
		{
			return new Rect(x, y, width, height);
		}
		
		public function toObject():Object
		{
			return {"x":x, "y":y, "width":width, "height":height};
		}
	}
}
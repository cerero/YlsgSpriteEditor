package utils
{
	import mx.core.Container;
	
	import view.SpritePoint;

	/**构建笛卡尔坐标系视图**/
	public class AxisUtil
	{
		private var midX:Number;
		private var midY:Number;
		
		private var lastContainsHeight:int=0;
		private var lastContainsWidth:int=0;
		
		public function drawXYaxis(canImageContains:Container,canAxis:Container):void
		{
			midX = canAxis.width * 0.5;
			midY = canAxis.height * 0.5;
			drawYaxis(canImageContains,canAxis);
			drawXaxis(canImageContains,canAxis);
		}
		
		public function drawYaxis(canImageContains:Container,canAxis:Container):void
		{
			for(var i:int=lastContainsHeight;i<canImageContains.height;i+=15){
				var spritePoint:SpritePoint=new SpritePoint(midY-i,true);
				spritePoint.x=midX;
				spritePoint.y=i;
				canAxis.rawChildren.addChild(spritePoint);
			}
			lastContainsHeight=i;
		}
		
		public function drawXaxis(canImageContains:Container,canAxis:Container):void
		{
			for(var i:int=lastContainsWidth;i<canImageContains.width;i+=15){
				if(i==midX)
					continue;
				var spritePoint:SpritePoint=new SpritePoint(midX-i);
				spritePoint.x=i;
				spritePoint.y=midY;
				canAxis.rawChildren.addChild(spritePoint);
			}
			lastContainsWidth=i;
		}
	}
}
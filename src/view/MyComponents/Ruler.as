package view.MyComponents
{
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import mx.containers.Canvas;
	
	public class Ruler extends Canvas
	{
		public var idle:Boolean = true;
		public var thePool:RulerPool = null;
		public function Ruler()
		{
			super();
			addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		}
		
		private function onMouseDown(event:MouseEvent):void
		{
			if(!stage.hasEventListener(MouseEvent.MOUSE_MOVE))
			{
				stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
				stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			}
		}
		
		private function onMouseUp(event:MouseEvent):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);			
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			if(thePool)
			{
				if(thePool.canRestoreRuler(this))
				{
					thePool.restoreRuler(this);
				}
			}
			
		}
		
		private function onMouseMove(event:MouseEvent):void
		{
			if(thePool)
			{
				var p:Point = thePool.globalToLocal(new Point(event.stageX, event.stageY));
				thePool.moveRuler(this, p.x, p.y);
			}
		}
	}
}
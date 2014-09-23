package view.MyComponents
{
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import mx.containers.Canvas;

	public class ComDragCanvas extends Canvas
	{
		private var dragEnable:Boolean = true;
		private var cachedPos:Point = new Point();
		
		public function ComDragCanvas()
		{
			addEventListener(MouseEvent.MOUSE_DOWN, onMouseDownHandle);
		}
		
		public function set DrapEnable(bool:Boolean):void
		{
			dragEnable = bool;
			onMouseUpHandle(null);
			if(bool){
				addEventListener(MouseEvent.MOUSE_DOWN, onMouseDownHandle);
			}
			else{
				removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDownHandle);
			}
		}
		
		private function onMouseDownHandle(event:MouseEvent):void
		{
			if(dragEnable){
				cachedPos.x = stage.mouseX;
				cachedPos.y = stage.mouseY;
				
				parent.mouseChildren = false;
				removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDownHandle);
				stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUpHandle);
				stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMoveHandle);
			}
		}
		
		private function onMouseUpHandle(event:MouseEvent):void
		{
			parent.mouseChildren = true;
			addEventListener(MouseEvent.MOUSE_DOWN, onMouseDownHandle);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUpHandle);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMoveHandle);
		}
		
		private function onMouseMoveHandle(event:MouseEvent):void
		{
			x += int(stage.mouseX - cachedPos.x);
			y += int(stage.mouseY - cachedPos.y);
			
			cachedPos.x = stage.mouseX;
			cachedPos.y = stage.mouseY;
			
			event.updateAfterEvent();
		}
	}
}
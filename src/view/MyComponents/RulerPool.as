package view.MyComponents
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import mx.containers.Canvas;
	
	public class RulerPool extends Canvas
	{
		private var rulers:Array = new Array();
		private var _maximum:int = 5;
		public var theSelectedRuler:Ruler = null;
		
		
		public function RulerPool()
		{
			super();
			addEventListener(Event.ADDED_TO_STAGE, onAddToStage); 
			setStyle("horizontalScrollPolicy", "off");
			setStyle("verticalScrollPolicy", "off");
			clipContent = false;
		}
		
		private function onAddToStage(event:Event):void
		{
			addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
		}
		
		private function onMouseOver(event:MouseEvent):void
		{			
			addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			addEventListener(MouseEvent.MOUSE_UP, onMouseUp, true);
		}
		
		private function onMouseOut(event:MouseEvent):void
		{
			removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			removeEventListener(MouseEvent.MOUSE_UP, onMouseUp, true);
		}
		
		protected function createRuler():Ruler
		{
			if(rulers.length >= _maximum)
			{
				return null;
			}
			var ruler:Ruler = createRulerImpl();
			rulers.push(ruler);
			return ruler;
		}
		
		protected function createRulerImpl():Ruler
		{
			var ruler:Ruler = new Ruler();
			ruler.thePool = this;
			return ruler;
		}
		
		private function onMouseDown(event:MouseEvent):void
		{
			if(event.target is Ruler)
			{
				if(Ruler(event.target).thePool == this)
				{
					return;
				}
			}
			//看看是否有没有被使用的ruler，如果有的话就取出来用用。
			var ruler:Ruler = null;
			for each(var r:Ruler in rulers)
			{
				if(r.idle)
				{
					ruler = r;
					break;
				}
			}
			//看看是否超过最大值，如果没有超过的话就新建一个。
			if(!ruler && rulers.length <= _maximum)
			{
				ruler = createRuler();
			}
			
			if(ruler)
			{
				ruler.idle = false;
				addChild(ruler);
			}
			theSelectedRuler = ruler;
			if(ruler)
			{
				stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			}
		}
		
		private function onMouseUp(event:MouseEvent):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		}
		
		private function onMouseMove(event:MouseEvent):void
		{
			if(theSelectedRuler)
			{
				var p:Point = globalToLocal(new Point(event.stageX, event.stageY));
				moveRuler(theSelectedRuler, p.x, p.y);
			}
		}
		
		public function restoreRuler(ruler:Ruler):void
		{
			if(ruler.thePool == this)
			{
				try{
					ruler.idle = true;
					ruler.parent.removeChild(ruler);
				}catch(e:Error){}
			}
		}
		
		public function canRestoreRuler(ruler:Ruler):Boolean
		{
			return false;
		}
		
		public function moveRuler(ruler:Ruler, mouseX:int, mouseY:int):void
		{
		}
	}
}
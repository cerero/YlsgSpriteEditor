package utils
{
	import flash.events.KeyboardEvent;
	
	import mx.controls.Image;
	import mx.core.UIComponent;

	public class KeyboardUtil
	{
		private var target:UIComponent;
		public function KeyboardUtil(ui:UIComponent,_target:UIComponent)
		{
			target=_target;
			ui.addEventListener(KeyboardEvent.KEY_UP,onKeyUpHandle);
		}
		private function onKeyUpHandle(event:KeyboardEvent):void{
			if(target is Image){
				if(!(target as Image).source)
					return;
			}
			if(!target.visible)
				return;

			switch(event.keyCode){
				case 65:
					target.x-=1;
					break;
				case 87:
					target.y-=1;
					break;
				case 68:
					target.x+=1;
					break;
				case 83:
					target.y+=1;
					break;
			}
		}
	}
}
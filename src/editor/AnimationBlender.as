package editor
{
	import events.AnimationBlenderEvent;
	import events.ImporterEvent;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	
	import mx.core.UIComponent;
	
	import texture.AnimationAct;
	import texture.AnimationDir;
	import texture.AnimationImporter;
	
	public class AnimationBlender extends EventDispatcher
	{
		private var anmDic:Dictionary = new Dictionary();
		
		/** 加载参考纹理 */
		public function load():void
		{
			var tipt:AnimationImporter = new AnimationImporter();
			tipt.addEventListener(ImporterEvent.ImportComplete, importedHandler);
			tipt.loadTexture();
		}
		
		public var container:Sprite;
		
		/** 移除参考纹理 */
		public function remove(importer:AnimationImporter):void
		{
			var twpr:AnimationWrapper = anmDic[importer];
			if(twpr)
			{
				delete anmDic[importer];
				if( twpr.container.parent ){
					twpr.container.parent.removeChild(twpr.container);
				}
				if(twpr.bitmap.parent)
				{
					twpr.bitmap.bitmapData = null;
					twpr.bitmap.parent.removeChild(twpr.bitmap);
				}
				importer.unload();
				var tevt:AnimationBlenderEvent = new AnimationBlenderEvent(AnimationBlenderEvent.ANIMATION_REMOVED);
				tevt.animationImporter = twpr.anmImporter;
				dispatchEvent(tevt);
			}
		}
		
		/** 移除全部参考纹理 */
		public function removeAll():void
		{
			for each(var twpr:AnimationWrapper in anmDic)
			{
				if( twpr.container.parent ){
					twpr.container.parent.removeChild(twpr.container);
				}
				if(twpr.bitmap.parent != null)
				{
					twpr.bitmap.bitmapData = null;
					twpr.bitmap.parent.removeChild(twpr.bitmap);
				}
				twpr.anmImporter.unload();
			}
			
			anmDic = new Dictionary();
			dispatchEvent(new AnimationBlenderEvent(AnimationBlenderEvent.ANIMATION_REMOVED_ALL));
		}
		
		/** 加载完成 */
		private function importedHandler(event:ImporterEvent):void
		{
			var tipt:AnimationImporter = AnimationImporter(event.currentTarget);
			/*var tname:String = tipt.defaultName;
			if(anmDic[tname])
			{
				//已经有了
				tipt.unload();
				return;
			}
			else
			{*/
				var twpr:AnimationWrapper = new AnimationWrapper();
				twpr.anmImporter = tipt;
				anmDic[tipt] = twpr;
				
				var tevt:AnimationBlenderEvent = new AnimationBlenderEvent(AnimationBlenderEvent.ANIMATION_ADD);
				tevt.animationImporter = tipt;
				dispatchEvent(tevt);
			//}
		}
		
		public function getWrapper(importer:AnimationImporter):AnimationWrapper
		{
			return anmDic[importer];
		}
		
		/**同步动画播放**/
		public function synchronizeAnimation(actType:int,dir:int,frame:int):void
		{
			for each(var twpr:AnimationWrapper in anmDic)
			{
				updateAct:
				for( var i:int = 0;i<twpr.anmImporter.actList.length;i++ ){
					var tact:AnimationAct = twpr.anmImporter.actList[i];
					var findAct:Boolean=false;
					if(tact.props.type == actType)
					{
						twpr.currAS = tact;
						findAct = true;
						updateDir:
						for( var j:int =0;j<twpr.currAS.props.dirList.length;j++ ){
							var tdir:AnimationDir = twpr.currAS.props.dirList[j];
							if(tdir.props.dir == dir)
							{
								tdir.updateFrame2(frame);
								twpr.currAO = tdir;
								twpr.bitmap.bitmapData = tdir.bitmapData;
								twpr.bitmap.x = tdir.x;
								twpr.bitmap.y = tdir.y;
								twpr.container.addChild(twpr.bitmap);
								if( twpr.container.parent == null ){
									var ui:UIComponent = new UIComponent();
									ui.addChild(twpr.container);
									container.addChild(ui);
								}
								
								if( twpr.container.parent.parent == null){
									container.addChild(twpr.container.parent);
								}
								
								/*if(twpr.bitmap.parent == null){
									container.addChild(twpr.bitmap);
								}*/
								break updateDir;
							}
						}
						break updateAct;
					}
					if( (i+1) == twpr.anmImporter.actList.length && !findAct){//找不到动作
						twpr.currAS = null;
					}
				}
			}
		}
		
		/** 同步动作类型 **/
		/*public function synchronizeAnimationAct(type:int):void
		{
			for each(var twpr:AnimationWrapper in anmDic)
			{
				for each(var tact:AnimationAct in twpr.anmImporter.actList)
				{
					if(tact.props.type == type)
					{
						twpr.currAS = tact;
						break;
					}
				}
			}
		}*/
		
		/** 同步方向类型 **/
		/*public function synchronizeAnimationDir(dir:int):void
		{
			for each(var twpr:AnimationWrapper in anmDic)
			{
				if(twpr.currAS == null)
				{
					continue;
				}
				for each(var tdir:AnimationDir in twpr.currAS.props.dirList)
				{
					if(tdir.props.dir == dir)
					{
						twpr.currAO = tdir;
						twpr.bitmap.bitmapData = tdir.bitmapData;
						twpr.bitmap.x = tdir.x;
						twpr.bitmap.y = tdir.y;
						if(twpr.bitmap.parent == null){
							addChild(twpr.bitmap);
						}
						break;
					}
				}
			}
		}*/
		
		/** 同步帧索引 **/
		/*public function synchronizeFrameIndex(frame:int, frameLength:int):void
		{
			for each(var twpr:AnimationWrapper in anmDic)
			{
				if(!twpr.currAO)
				{
					continue;
				}
				if(twpr.currAO.frames.length == frameLength)
				{
					twpr.currAO.props.currFrame = frame;
				}
			}
		}*/
		
		/** 更新动画 **/
		/*public function updateAllAnimation():void
		{
			for each(var twpr:AnimationWrapper in anmDic)
			{
				if(!twpr.currAO)
				{
					continue;
				}
				twpr.currAO.updateFrame();
				twpr.bitmap.x = twpr.currAO.x;
				twpr.bitmap.y = twpr.currAO.y;
				twpr.bitmap.bitmapData = twpr.currAO.bitmapData;
			}
		}*/
		
		//指定动作类型和方向类型
		/*public function specifyAnimation(anmName:String, act:AnimationAct, dir:AnimationDir):void
		{
			var twpr:AnimationWrapper = anmDic[anmName];
			if(!twpr)
			{
				return;
			}
			var tcurrAS:AnimationAct = null;
			for each(var tact:AnimationAct in twpr.anmImporter.actList)
			{
				if(tact.props.type == act.props.type)
				{
					tcurrAS = tact;
					break;
				}
			}
			
			if(!tcurrAS)
			{
				return;
			}
			
			twpr.currAS = tcurrAS;
			for each(var tdir:AnimationDir in tcurrAS.props.dirList)
			{
				if(tdir.props.dir == dir.props.dir)
				{
					twpr.currAO = tdir;
					twpr.bitmap.bitmapData = tdir.bitmapData;
					twpr.bitmap.x = tdir.x;
					twpr.bitmap.y = tdir.y;
					if(twpr.bitmap.parent == null){
						addChild(twpr.bitmap);
					}
					break;
				}
			}
		}*/
	}
}



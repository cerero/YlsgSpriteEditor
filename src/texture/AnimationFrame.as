package texture
{
	import by.blooddy.crypto.image.PNGEncoder;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	
	import mx.core.UIComponent;
	
	import spark.effects.Animate;
	
	/** 代表某一帧 */
	public class AnimationFrame extends UIComponent implements IAnimation
	{
		private var synmmetryBitmap:Bitmap;
		private var bitmap:Bitmap;
		private var loader:Loader;
		public var props:FrameProperties;
		public var act:AnimationAct;  //冗余数据
		
		public function AnimationFrame(dp:Bitmap=null, props:FrameProperties=null)
		{
			this.props = props == null ? new FrameProperties() : props;
			if(dp != null)
			{
				bitmap = dp;
				addChild(dp);
			}
		}
		
		public function getDisplayObject():Bitmap
		{
			if( renderBitmap )
				return renderBitmap;
			else
				return bitmap;
		}
		
		private var renderBitmap:Bitmap
		
		/**对称镜像**/
		public function getSynmmetryDisplayObject():Bitmap
		{
			return synmmetryBitmap;
		}
		
		/**设置对称方式**/
		public function set synmmetry(val:int):void
		{
			var synBd:BitmapData;
			var matrix:Matrix;
			if( val == AnimationAct.SYNMMETRY_NONE){
				if( synmmetryBitmap ){
					synmmetryBitmap.bitmapData.dispose();
					if( synmmetryBitmap.parent )
						synmmetryBitmap.parent.removeChild(synmmetryBitmap);
					synmmetryBitmap = null;
				}
				if( renderBitmap ){
					renderBitmap.bitmapData.dispose();
					if( renderBitmap.parent ){
						bitmap.x = renderBitmap.x;
						bitmap.y = renderBitmap.y;
						renderBitmap.parent.addChild(bitmap);
						renderBitmap.parent.removeChild(renderBitmap);
					}
					renderBitmap = null;
				}
			}else if( val == AnimationAct.SYNMMETRY_LR || val == AnimationAct.SYNMMETRY_UD ){
				var scaleX:int = val == AnimationAct.SYNMMETRY_LR?-1:1;
				var scaleY:int = val == AnimationAct.SYNMMETRY_UD?-1:1;
				var translateX:Number = val == AnimationAct.SYNMMETRY_LR?bitmap.width:0;
				var translateY:Number = val == AnimationAct.SYNMMETRY_UD?bitmap.height:0;
				
				synBd = new BitmapData(bitmap.width,bitmap.height,true,0x00000000);
				matrix = new Matrix(scaleX,0,0,scaleY,translateX,translateY);
				synBd.draw(bitmap.bitmapData,matrix);
				synmmetryBitmap = new Bitmap(synBd);
				
				
				var renderBd:BitmapData;
				//设置镜像图片
				var gapW:int = synmmetryBitmap.width;
				var gapH:int = synmmetryBitmap.height;
				var synX:Number = 0;
				var synY:Number = 0;
				if( val == AnimationAct.SYNMMETRY_LR ){
					synX = gapW;
					renderBd = new BitmapData(2*gapW,gapH,true,0x00000000);
				}else{
					synY = gapH;
					renderBd = new BitmapData(gapW,2*gapH,true,0x00000000);
				}
				
				renderBd.draw(bitmap.bitmapData);
				renderBd.draw(synmmetryBitmap.bitmapData,new Matrix(1,0,0,1,synX,synY));
				renderBitmap = new Bitmap(renderBd); 
				if( bitmap.parent ){
					renderBitmap.x = bitmap.x;
					renderBitmap.y = bitmap.y;
					bitmap.parent.addChild(renderBitmap);
					bitmap.parent.removeChild(bitmap);
				}
			}
		}
		
		public function changeDisplayObject(dp:Bitmap):void
		{
			while(numChildren > 0)
			{
				removeChildAt(0);
			}
			
			if(dp != null){
				bitmap = dp;
				addChild(bitmap);
				synmmetry = act.props.symmetry; 
			}
		}
		
		/** 保存JTA数据为byteArray */
		public function save(byte:ByteArray):int
		{
			var tprops:FrameProperties = new FrameProperties();
			var tchange:Boolean = false;
			var tstart:int = byte.position;
			var tbitmap:BitmapData = bitmap.bitmapData;
			
			tprops.rect = props.rect.clone();
			tprops.raw = new ByteArray();
			//输出png8格式
			tprops.raw = PNGEncoder.encode(tbitmap);//PNG8Encoder.encode(tbitmap);
			tprops.alpha = null;
			tchange = true;
			//公共属性
			tprops.rect.width = tbitmap.width;
			tprops.rect.height = tbitmap.height;
			byte.writeShort(tprops.rect.x);
			byte.writeShort(tprops.rect.y);
			byte.writeShort(tprops.rect.width);
			byte.writeShort(tprops.rect.height);
			//不同格式的保存
			if(tprops.alpha is ByteArray && tprops.alpha.length > 0)
			{
				//JPG加透明通道格式
				byte.writeInt(int.MIN_VALUE);
				byte.writeInt(tprops.raw.length);
				byte.writeBytes(tprops.raw);
				byte.writeInt(tprops.alpha.length);
				byte.writeBytes(tprops.alpha);
			}
			else
			{
				//PNG格式
				byte.writeInt(tprops.raw.length);
				byte.writeBytes(tprops.raw);
			}
			//返回postion
			return byte.position - tstart;
		}
		
		/** 转化ByteArra为内部格式 */ 
		public function load(byte:ByteArray):int
		{
			var tlen:int;
			var start:int = byte.position;
			//公共属性
			props.rect.x = byte.readShort();
			props.rect.y = byte.readShort();
			props.rect.width = byte.readShort();
			props.rect.height = byte.readShort();
			//图片byteArray.length
			tlen = byte.readInt();
			if(tlen == int.MIN_VALUE)
			{
				//保存了alpha通道数据
				tlen = byte.readInt();
				if(tlen > 0)
				{
					props.raw = new ByteArray();
					props.alpha = new ByteArray();
					byte.readBytes(props.raw, 0, tlen);
					tlen = byte.readInt();
					byte.readBytes(props.alpha, 0, tlen);
				}
				else
				{
					props.alpha = null;
					props.raw = null;
				}
			}
			else if(tlen > 0)
			{
				//PNG格式图片
				props.raw = new ByteArray();
				byte.readBytes(props.raw, 0, tlen);
				props.alpha = null;
			}
			else{
				props.raw = null;
				props.alpha = null;
			}
			//返回position
			return byte.position - start;
		}
		
		/** 转化为bitmapData数据 */
		public function draw():void
		{
			if(loader == null && props.raw != null)
			{
				loader = new Loader();
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadCompleteHandler);
				loader.loadBytes(props.raw);
			}
		}
		
		/** 加载完成事件 */
		private static const ALPHP_CACHE:BitmapData = new BitmapData(1000, 580, true, 0);
		private static const POINT:Point = new Point();
		private function loadCompleteHandler(event:Event):void
		{
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, loadCompleteHandler);
			var tbmp:Bitmap = loader.content as Bitmap;
			if(props.alpha is ByteArray && props.alpha.length > 0)
			{
				var tbitmap:BitmapData = tbmp.bitmapData;
				var trect:Rectangle = tbitmap.rect;
				try{ props.alpha.uncompress();props.alpha.position = 0; } catch(e:*){};
				ALPHP_CACHE.setPixels(trect, props.alpha);
				
				//创建透明图片
				tbmp.bitmapData = new BitmapData(trect.width, trect.height, true, 0);
				tbmp.bitmapData.copyPixels(tbitmap, trect, POINT);
				tbmp.bitmapData.copyChannel(ALPHP_CACHE, trect, POINT, BitmapDataChannel.RED, BitmapDataChannel.ALPHA);
				
				//更新bitmapData
				tbitmap.dispose();
			}
			//更新
			if(bitmap == null){
				bitmap = tbmp;
				addChild(bitmap);
			}
			else{
				bitmap.bitmapData = tbmp.bitmapData;
			}
		}
		
		/** 内存清理 */
		public function unload():void
		{
			//bitmap
			if(bitmap is Bitmap && bitmap.bitmapData != null){
				bitmap.bitmapData.dispose();
				bitmap.bitmapData = null;
			}
			if( renderBitmap && renderBitmap.bitmapData != null){
				renderBitmap.bitmapData.dispose();
				renderBitmap.bitmapData = null;
			}
			//loader
			if(loader is Loader){
				try{ Bitmap(loader.content).bitmapData.dispose(); } catch(e:*){};
				loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, loadCompleteHandler);
				loader.unloadAndStop();
				loader = null;
			}
			//raw
			if(props.raw is ByteArray){
				props.raw.clear();
				props.raw = null;
			}
			//alpha
			if(props.alpha is ByteArray){
				props.alpha.clear();
				props.alpha = null;
			}
		}
		
		/** 先克隆displayObject */
		public function duplicate():IAnimation
		{
			return new AnimationFrame(bitmap ? new Bitmap(bitmap.bitmapData.clone()) : null, props.clone());
		}
	}
}

import flash.display.Bitmap;
import flash.utils.ByteArray;

import texture.Rect;

class FrameProperties
{
	public var raw:ByteArray;							//PNG或JPG图片
	public var alpha:ByteArray;							//透明通道，如果图片为PNG则不存在此属性
	/**帧坐标大小定义**/
	public var rect:Rect = new Rect();					
	/**扩展像素值(SWF绘制时，增加的宽与高半径)**/
	public var extpixel:int;
	/**单帧绘制后截取图片坐标及高宽定义**/
	public var img:Rect;
	public var visible:Boolean = true;
	
	public function toObject():Object
	{
		var tobj:Object = {
			"rect":rect.toObject()
		};
		if(img){
			tobj["img"] = img.toObject();
		}
		if(extpixel != 0){
			tobj["extpixel"] = extpixel;
		}
		return tobj;
	}
	
	public function clone():FrameProperties
	{
		var tobj:FrameProperties = new FrameProperties();
		tobj.visible = visible;
		tobj.extpixel = extpixel;
		tobj.rect = rect.clone();
		
		if(img) tobj.img = img.clone();
		
		if(raw){
			tobj.raw = new ByteArray();
			
			raw.position = 0;
			raw.readBytes(tobj.raw);
			raw.position = 0;
		}
		
		if(alpha){
			tobj.alpha = new ByteArray();
			
			alpha.position = 0;
			alpha.readBytes(tobj.alpha);
			alpha.position = 0;
		}
		
		return tobj;
	}
}


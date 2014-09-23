package utils
{
	// Dependencies:
	// as3swf.swc
	// as3commons-bytecode-1.0-RC1.swc
	// as3commons-lang-0.3.2.swc
	// as3commons-logging-2.0.swc
	// as3commons-reflect-1.3.4.swc
	
	import com.codeazur.as3swf.SWF;
	import com.codeazur.as3swf.data.SWFSymbol;
	import com.codeazur.as3swf.tags.TagDefineBitsJPEG3;
	import com.codeazur.as3swf.tags.TagDoABC;
	import com.codeazur.as3swf.tags.TagEnd;
	import com.codeazur.as3swf.tags.TagFileAttributes;
	import com.codeazur.as3swf.tags.TagShowFrame;
	import com.codeazur.as3swf.tags.TagSymbolClass;
	
	import flash.display.BitmapData;
	import flash.utils.ByteArray;
	
	import org.as3commons.bytecode.abc.AbcFile;
	import org.as3commons.bytecode.abc.enum.Opcode;
	import org.as3commons.bytecode.emit.IAbcBuilder;
	import org.as3commons.bytecode.emit.IClassBuilder;
	import org.as3commons.bytecode.emit.ICtorBuilder;
	import org.as3commons.bytecode.emit.IPackageBuilder;
	import org.as3commons.bytecode.emit.impl.AbcBuilder;
	import org.as3commons.bytecode.io.AbcSerializer;
	
	
	public class PNGPacker
	{
		private var swf:SWF;
		private var abcBuilder:IAbcBuilder;
		private var pkgBuilder:IPackageBuilder;
		private var sblClass:TagSymbolClass;
		private var currId:uint;
		
		private static const PACKAGENAME:String = "";
		private static const CLASSNAME_PREFIX:String = "PNG_";
		
		public function PNGPacker()
		{
			init();
		}
		
		public function addPNG(data:BitmapData, clsnm:String, quality:uint=80):void
		{
			if(data.width > 0 && data.height > 0)
			{
				var tclsnm:String = PACKAGENAME + CLASSNAME_PREFIX + clsnm;
				var tclsbuilder:IClassBuilder = pkgBuilder.defineClass(tclsnm, "flash.display.BitmapData");
				tclsbuilder.isDynamic = true;
				// BitmapData subclasses need a custom constructor, for example:
				// public function BitmapDataSubclass(width:int = 550, height:int = 400) {
				//    super(width, height)
				// }
				var tctorBuilder:ICtorBuilder = tclsbuilder.defineConstructor();
				tctorBuilder.addOpcode(Opcode.getlocal_0)
					.addOpcode(Opcode.pushint, [data.width])
					.addOpcode(Opcode.pushint, [data.height])
					.addOpcode(Opcode.constructsuper, [2])
					.addOpcode(Opcode.returnvoid);
				//
				sblClass.symbols.push(SWFSymbol.create(currId, tclsnm));
				//
				var tobj:Object = JPEG3Encoder.encode(data, quality);
				var tjpg:TagDefineBitsJPEG3 = new TagDefineBitsJPEG3();
				tjpg.characterId = currId;
				tjpg.bitmapData.writeBytes(tobj.bitmapBytes);
				tjpg.bitmapAlphaData.writeBytes(tobj.bitmapAlphaBytes);
				//
				swf.tags.push(tjpg);
				currId++;
			}
		}
		
		private function init():void
		{
			swf = new SWF();
			swf.version = 9;
			swf.tags.push(new TagFileAttributes());
			
			abcBuilder = new AbcBuilder();
			pkgBuilder = abcBuilder.definePackage(PACKAGENAME);
			sblClass = new TagSymbolClass();
			currId = 1;
		}
		
		public function publish():ByteArray
		{
			var abcFile:AbcFile = abcBuilder.build();
			var abcSerializer:AbcSerializer = new AbcSerializer();
			var abcBytes:ByteArray = abcSerializer.serializeAbcFile(abcFile);
			
			swf.tags.push(TagDoABC.create(abcBytes));
			swf.tags.push(sblClass);
			swf.tags.push(new TagShowFrame());
			swf.tags.push(new TagEnd());
			
			var ba:ByteArray = new ByteArray();
			swf.publish(ba);
			return ba;
		}
	}
}
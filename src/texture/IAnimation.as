package texture
{
	import flash.utils.ByteArray;

	public interface IAnimation
	{
		function save(byte:ByteArray):int;
		function load(byte:ByteArray):int;
		function draw():void;
		function duplicate():IAnimation;
		function unload():void
	}
}
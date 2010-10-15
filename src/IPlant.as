package
{
	import as3isolib.display.IsoSprite;

	public interface IPlant
	{	
		function growUp ():void;
		function plant (xpos:int, ypos:int):void;
		function getID ():int;
		function grub ():void;
		function isPlanted ():Boolean;
	}
}
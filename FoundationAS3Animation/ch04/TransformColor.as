package
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	// Flash CS3のみで必要です
	
	public class TransformColor extends Sprite
	{
		// Flex 2で必要です
		//[Embed(source="picture.jpg")]
		//public var Picture:Class;
		
		public function TransformColor()
		{
			init();
		}
		
		private function init():void
		{
			// Flash CS3のみのコード
			var picData:BitmapData = new Picture(0, 0);
			var pic:Bitmap = new Bitmap(picData);
			// Flex 2のコード
			// var pic:Bitmap = new Picture() as Bitmap;

			addChild(pic);
			
			pic.transform.colorTransform = new ColorTransform(-1, -1, -1, 1, 
															  255, 255, 255, 0);
		}
	}
}

package
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	public class MultiCurves3 extends Sprite
	{
		private var numPoints:uint = 9;
		public function MultiCurves3()
		{
			init();
		}
		
		private function init():void
		{
			var points:Array = new Array();
			for (var i:int = 0; i < numPoints; i++)
			{
				points[i] = new Object();
				points[i].x = Math.random() * stage.stageHeight;
				points[i].y = Math.random() * stage.stageHeight;
			}
			
			// 1つめの中間点を求め、そこに移動します
			var xc1:Number = (points[0].x + points[numPoints - 1].x) / 2;
			var yc1:Number = (points[0].y + points[numPoints - 1].y) / 2;
			graphics.lineStyle(1);
			graphics.moveTo(xc1, yc1);

			// 残りの点をループ処理し、各中間点まで曲線を描きます
			for (i = 0; i < numPoints - 1; i ++)
			{
				var xc:Number = (points[i].x + points[i + 1].x) / 2;
				var yc:Number = (points[i].y + points[i + 1].y) / 2;
				graphics.curveTo(points[i].x, points[i].y, xc, yc);
			}
			
			// 最後の点を通って、1つめの中間点に戻る曲線を描きます
			graphics.curveTo(points[i].x, points[i].y, xc1, yc1);
		}
	}
}

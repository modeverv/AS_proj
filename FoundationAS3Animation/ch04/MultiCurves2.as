package
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	public class MultiCurves2 extends Sprite
	{
		private var numPoints:uint = 9;
		public function MultiCurves2()
		{
			init();
		}
		
		private function init():void
		{
			// まずランダムな点を持った配列を設定します
			var points:Array = new Array();
			for (var i:int = 0; i < numPoints; i++)
			{
				points[i] = new Object();
				points[i].x = Math.random() * stage.stageHeight;
				points[i].y = Math.random() * stage.stageHeight;
			}
			graphics.lineStyle(1);

			// 1つめの点に移動
			graphics.moveTo(points[0].x, points[0].y);

			// 残りの点をループ処理し、各中間点まで曲線を描きます
			for (i = 1; i < numPoints - 2; i ++)
			{
				var xc:Number = (points[i].x + points[i + 1].x) / 2;
				var yc:Number = (points[i].y + points[i + 1].y) / 2;
				graphics.curveTo(points[i].x, points[i].y, xc, yc);
			}
		
			// 最後の2つの点の曲線を描きます
			graphics.curveTo(points[i].x, points[i].y, points[i+1].x, points[i+1].y);
		}
	}
}

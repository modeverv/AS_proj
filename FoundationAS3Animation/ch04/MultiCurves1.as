package
{
	import flash.display.Sprite;
	
	public class MultiCurves1 extends Sprite
	{
		private var numPoints:uint = 9;
		public function MultiCurves1()
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

			// 次の各ペアのループ処理
			for (i = 1; i < numPoints; i += 2)
			{
				graphics.curveTo(points[i].x, points[i].y,
								 points[i + 1].x, points[i + 1].y);
			}
		}
	}
}

package
{
	import flash.display.Sprite;
	import flash.filters.BlurFilter;
	import flash.filters.DropShadowFilter;
	
	public class MultiFilters extends Sprite
	{
		public function MultiFilters()
		{
			init();
		}
		
		private function init():void
		{
			var sprite:Sprite = new Sprite();
			sprite.graphics.lineStyle(2);
			sprite.graphics.beginFill(0xffff00);
			sprite.graphics.drawRect(100, 100, 100, 100);
			sprite.graphics.endFill()
			addChild(sprite);
			
			// 1番目のフィルタ
			sprite.filters = [new BlurFilter(5, 5, 3)];

			// 2番目のフィルタ
			var filters:Array = sprite.filters;
			filters.push(new DropShadowFilter(10, 45, 0, 1, 10, 10, .3));
			sprite.filters = filters;
			
			// 短縮形
			//sprite.filters = sprite.filters.concat(new BlurFilter(5, 5, 3));
			//sprite.filters = sprite.filters.concat(new DropShadowFilter(10, 45, 0, 1, 10, 10, .3));
			
		}
	}
}

package  fortest{
	import flash.display.Sprite;
	import fortest.Ball;
	
	public class WeightBall extends Ball {
		public var mass :Number = 1;

		public function WeightBall(radius:Number = 40 , color:uint = 0xff0000, _x:Number = 0, _y:Number = 0, _mass:Number = 2, _vx:Number = 0, _vy:Number = 0 ) {
			super(radius, color);//引数付きのコンストラクタをキック
			trace(radius + "color:" + color);
			super.x = _x;
			super.y = _y;
			this.mass = _mass;
			super.vx = _vx;
			super.vy = _vy;
			this.initWeightBall();
		}
		
		protected function initWeightBall():void {
			trace(this.name + "initWeightBall()");
		}
		
		public function hoge(str:String = "this is WeightBall::hoge()"):void {
			trace(str);
		}
		

	}
	
	
}
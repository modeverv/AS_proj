package 
{
//等速移動
	//俺俺
	import net.hires.debug.Stats;
	
	//fortest
	import fortest.Ball;
	import fortest.Arrow;
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author modeverv
	 */
	public class Main extends Sprite 
	{
		//等速運動用
		private var ball:Ball;
		private var vx:Number = 5;
		private var vy:Number = 10;
		
		//等速運動用２角度版
		private var ball2:Ball;
		private var angle:Number = 30;
		private var speed:Number = 3;
		
		//マウスを追いかける
		private var arrow:Arrow;
		private var arrowspeed:Number = 5;
		
		//矢印を等速回転
		private var arrow2:Arrow;
		private var vr:Number = 5;
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			
			//俺俺
			var stats:Stats = new Stats();
			stats.y = 200;
			addChild(stats);
			
			//等速運動用
			ball = new Ball(40,0xff0000);
			addChild(ball);
			ball.x = stage.stageWidth / 2;
			ball.y = stage.stageHeight / 2;			
			addEventListener(Event.ENTER_FRAME, mvBall);
			
			//等速運動用２角度版
			ball2 = new Ball(40,0xffff00);
			addChild(ball2);
			ball2.x = stage.stageWidth / 2;
			ball2.y = stage.stageHeight / 2;			
			addEventListener(Event.ENTER_FRAME, mvBall2);

			//マウスを追いかける
			arrow = new Arrow(0xff0000);
			addChild(arrow);
			arrow.x = stage.stageWidth / 2;
			arrow.y = stage.stageHeight / 2;			
			addEventListener(Event.ENTER_FRAME, ArrowforrowMouse);

			//矢印をを等速回転
			arrow2 = new Arrow(0xffff00);
			addChild(arrow2);
			arrow2.x = stage.stageWidth / 2;
			arrow2.y = stage.stageHeight / 2;			
			addEventListener(Event.ENTER_FRAME, ArrowRotate);

		}
		
		//ballの等速運動ルーチン
		private function mvBall(evt:Event):void {
			ball.x += vx;
			if (ball.x > stage.stageWidth) {
				ball.x = 0;
			}
			ball.y -= vy;
			if (ball.y < 0) {
				ball.y = stage.stageHeight;
			}
		}

		//ball2の等速運動ルーチン
		private function mvBall2(evt:Event):void {
			var radians:Number = angle * Math.PI / 180;
			var vx2:Number = Math.cos(radians) * speed;
			var vy2:Number = Math.sin(radians) * speed;
			//trace(vx2);trace(vy2);
			ball2.x += vx2;
			if (ball2.x > stage.stageWidth) {
				ball2.x = 0;
			}
			ball2.y += vy2;
			if (ball2.y > stage.stageHeight) {
				ball2.y = 0;
			}
		}
		
		//マウスを追いかける
		private function ArrowforrowMouse(evt:Event):void {
			var dxm:Number = mouseX - arrow.x;
			var dym:Number = mouseY - arrow.y;
			//trace(mouseX); trace(mouseY);
			trace(dxm); trace(dym);
			var anglem:Number = Math.atan2(dym, dxm);
			arrow.rotation = anglem * 180 / Math.PI ;
			//trace(anglem);
			
			var vxm:Number = Math.cos(anglem) * arrowspeed;
			var vym:Number = Math.sin(anglem) * arrowspeed;
			//trace(vxm); trace(vym);
			
			arrow.x += vxm;
			arrow.y += vym;
/*			
			if (Math.abs(dxm) < 10) {
				arrow.scaleX += vxm / 10;
				if (arrow.scaleX > 2) {
					arrow.scaleX = 2;
				}
			}else {
				arrow.scaleX -= vxm / 10 ;
			}
			if (Math.abs(dym) < 10) {
				arrow.scaleY += vym / 10; 
				if (arrow.scaleY > 2) {
					arrow.scaleY = 2;
				}
			}else {
				arrow.scaleY -= vym / 10;
			}
*/			
		}
		
		//マウスを等速回転させる
		private function ArrowRotate(evt:Event):void {
			arrow2.rotation += vr;
		}
		
	}
	
}
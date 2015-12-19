package 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;	
	
	import flash.geom.Point;
	
	import fortest.WeightBall;
	import fortest.Ball;
	
	import net.hires.debug.Stats;	
		
	/**
	 * ...
	 * @author modeverv
	 */
	public class Main extends Sprite 
	{
		private var particles:Array;
		private var numParticles:uint = 100;
		private var bounce:Number = -0.7;
		private var ball:WeightBall;
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;			
			var stats:Stats = new Stats()
			stats.y = 200;
			addChild(stats);	
			
			particles = new Array();
			/*
			for (var i:Number = 0 ; i < numParticles ; i++) {
				var particle:WeightBall = new WeightBall(1 + 10 * Math.random(), Math.random() * 0xffffff);
				particle.mass = 1 + Math.random() * 2;
				setBalltoRandomPlace(particle);
				addChild(particle);
				particles.push(particle);
			}
			*/
			var sun:WeightBall = new WeightBall(100,0xffffff00);
			//setBalltoRandomPlace(sun);
			sun.x = stage.stageWidth / 2;
			sun.y = stage.stageHeight / 2;
			sun.mass = 10000;			
			addChild(sun);
			particles.push(sun);
			
			var planet:WeightBall = new WeightBall(10, 0x00ff00)
			//setBalltoRandomPlace(planet);
			planet.x = stage.stageWidth / 2 + 200;
			planet.y = stage.stageHeight / 2;
			addChild(planet);
			planet.vy = 7;
			planet.mass = 1;
			particles.push(planet);
			
			ball = new WeightBall(40, 0xff00ff);
			ball.x = 0; ball.y = stage.stageHeight;
			ball.vx = 7;
			ball.vy = -3;
			ball.mass = 100;
			addChild(ball);
			
			//stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			
			graphics.lineStyle(1, 0, .5);
			graphics.moveTo(planet.x, planet.y);			
		}
		

		
		private function onEnterFrame(e:Event):void {
			checkWalls(ball);
			gravitate(ball, particles[0] as WeightBall);
			normalMove(ball);
			for (var i :Number= 0,len:Number=particles.length ; i < len ; i++) {
				var b:WeightBall = particles[i] as WeightBall;
				//setBalltoRandomPlace(b);
				//checkWalls(b);
//				normalMove(b);
			}
			normalMove(particles[1] as WeightBall);
			for ( i = 0 ; i < len ; i++) {
				var partA:WeightBall = particles[i] as WeightBall;
				for (var j:uint = i + 1; j < len ; j++) {
					var partB:WeightBall = particles[j] as WeightBall;
					gravitate(partA, partB);
					checkCollision(partA, partB);
				}
			}
			graphics.lineTo(particles[1].x, particles[1].y);			
		}
		private function gravitate(partA:WeightBall, partB:WeightBall):void {
			var dx:Number = partB.x - partA.x;
			var dy:Number = partB.y - partA.y;
			
			var distSQ:Number = dx * dx + dy * dy;
			var dist:Number = Math.sqrt(distSQ);
			var force:Number = partA.mass * partB.mass / distSQ;
			var ax :Number = 3 * force * dx / dist;
			var ay :Number = 3 * force * dy / dist;
			partA.vx += ax / partA.mass;
			partB.vx -= ax / partB.mass;
			partA.vy += ay / partA.mass;
			partB.vy -= ay / partB.mass;
			
		}
		
		private function normalMove(b:Ball):void {
			b.x += b.vx;
			b.y += b.vy;
		}
		
		private function onMouseDown(e:MouseEvent):void {
			for (var i :Number= 0,len:Number = particles.length; i < len ; i++) {
				var b:Ball = particles[i] as Ball;
				setBalltoRandomPlace(b);
			}
		}
		private function setBalltoRandomPlace(b:Sprite):void {
			b.x = Math.random() * stage.stageWidth;
			b.y = Math.random() * stage.stageHeight;
		}
		private function onBallChange(b:WeightBall):void {
			b.chgColor(Math.random() * 0xffffff);
		}
		
		private function checkCollision(ball0:WeightBall, ball1:WeightBall):void {
			//distを
			var dx:Number = ball1.x - ball0.x;
			var dy:Number = ball1.y - ball0.y;
			var dist:Number = Math.sqrt(dx * dx + dy * dy);
			if (dist < ball0.radius + ball1.radius) {
				trace("衝突");
				onBallChange(ball0);
				onBallChange(ball1);
				var angle:Number = Math.atan2(dy, dx);
				var sin:Number = Math.sin(angle);
				var cos:Number = Math.cos(angle);

				//ball0の回転
				var pos0:Point = new Point(0, 0);
			
				//ball1の回転
				var pos1:Point = rotate(dx, dy, sin, cos, true);
				
				//ball0速度の回転
				var vel0:Point = rotate(ball0.vx, ball0.vy, sin, cos, true);
				
				//ball1速度の回転
				var vel1:Point = rotate(ball1.vx, ball1.vy, sin, cos, true);
				
				var vxTotal:Number = vel0.x - vel1.x;
				vel0.x = ((ball0.mass - ball1.mass) * vel0.x  + 2 * ball1.mass * vel1.x)
					/ (ball0.mass + ball1.mass);
				vel1.x = vxTotal + vel0.x;
				
				//この実装だとボール同士が埋まるエンドレス内側衝突
				//pos0.x += vel0.x;
				//pos1.x += vel1.x;
				
				var absV:Number = Math.abs(vel0.x) + Math.abs(vel1.x);
				var overlap:Number = (ball0.radius + ball1.radius) - Math.abs(pos0.x - pos1.x);
				pos0.x += vel0.x / absV * overlap;
				pos1.x += vel1.x / absV * overlap;
				
				
				var pos0F:Point = rotate(pos0.x, pos0.y, sin, cos, false);
				var pos1F:Point = rotate(pos1.x, pos1.y, sin, cos, false);

				ball1.x = ball0.x + pos1F.x;
				ball1.y = ball0.y + pos1F.y;
				ball0.x = ball0.x + pos0F.x;
				ball0.y = ball0.y + pos0F.y;
				
				//速度の回転
				var vel0F:Point = rotate(vel0.x, vel0.y, sin, cos, false);
				var vel1F:Point = rotate(vel1.x, vel1.y, sin, cos, false);
				
				ball0.vx = vel0F.x;
				ball0.vy = vel0F.y;
				ball1.vx = vel1F.x;
				ball1.vy = vel1F.y;
			}
			
		}
		
		private function checkWalls(ball:WeightBall):void {
			if (ball.x + ball.radius > stage.stageWidth) {
				ball.x = stage.stageWidth - ball.radius;
				ball.vx *= bounce;
			}else if (ball.x - ball.radius < 0) {
				ball.x = ball.radius;
				ball.vx *= bounce;
			}
			
			if (ball.y + ball.radius > stage.stageHeight) {
				ball.y = stage.stageHeight - ball.radius;
				ball.vy *= bounce;
			}else if (ball.y - ball.radius < 0) {
				ball.y = ball.radius;
				ball.vy *= bounce;
			}
		}		

		private function rotate(x:Number,y:Number,sin:Number,cos:Number,reverse:Boolean) :Point{
			var result:Point = new Point();
			if (reverse) {
				result.x = x * cos + y * sin;
				result.y = y * cos - x * sin;
			}else {
				result.x = x * cos - y * sin;
				result.y = y * cos + x * sin;
			}
			return result;
		}
	
		
		
	}
	
}
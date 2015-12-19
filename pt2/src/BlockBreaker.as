
// forked from coppieee's パーティクル崩れない
// forked from coppieee's パーティクル崩し
//コードはめっちゃ汚いよ！
//ブロックの数465*100
//がんばってクリアしてください
//
//お前らチートばっかりするから、難しくしてやったぞ！
//
//参考
//http://wonderfl.net/code/31a7251b9d62a22753ee35a2865e64a3020eea0c
//
//自動化したよ！！

package 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	//import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import net.hires.debug.Stats;
	
	[SWF(width = "465", height = "465", frameRate = "30")]
	public class BlockBreaker extends Sprite 
	{
		private static const HEIGHT:Number = 465;
		private static const WIDTH:Number = 465;
		private var _canvas:BitmapData;
		private var _blocks:Blocks;
		private var _fallBlocks:Vector.<Particle>;
		private var _balls:Vector.<Particle>;
		private var _bar:Bitmap;
		
		//コンストらクタ
		public function BlockBreaker()
		{
			_canvas = new BitmapData(WIDTH, HEIGHT,false,0x000000);
			addChild(new Bitmap(_canvas));
			
			_blocks = new Blocks(WIDTH, 100);
			
			_fallBlocks = new Vector.<Particle>();
			
			var b:BitmapData = new BitmapData(50, 10, false, 0x00FF00);
			addChild(_bar = new Bitmap(b));
			_bar.y = WIDTH -b.width;
			var _ball:Particle = new Particle(WIDTH / 2, HEIGHT / 2);
			var radian:Number = Math.random() * Math.PI*2;
			_ball.vx = Math.cos(radian)*10;
			_ball.vy = Math.sin(radian)*10;
			_ball.color = 0xFFFFFF;
			
			_balls = new Vector.<Particle>();
			_balls.push(_ball);
			
			var stats:Stats = new Stats();
			stats.y = 200;
			addChild(stats);
			
			addEventListener(Event.ENTER_FRAME, update);
		}
		
		//アップデート 辺り判定外されてるwww
		private function update(e:Event):void
		{
			_canvas.lock();
			_canvas.colorTransform(_canvas.rect, new ColorTransform (0.0, 0.0, 0.0));
			
			var ballX:Number = 1000;
			var ballY:Number = 1000;
			if (_balls.length > 0)
			{
				ballX = _balls[0].x
				ballY = _balls[0].y;
			}
			for each(var block:Particle in _blocks.values)
			{
				if (block)
				{
					var dx:Number = block.x - ballX;
					var dy:Number = block.y - ballY;
					var rr:Number = dx * dx + dy * dy;
					var r:Number = Math.sqrt(rr);
					
					//Math.atan2()重い。
					//var theta:Number = Math.atan2(dy, dx);
					var d:Number = 3000 / rr;
					block.vx = dx / r * d + (block.column - block.x) * 0.1;
					block.vy = dy / r * d + (block.row - block.y ) * 0.1;
					block.x += block.vx;
					block.y += block.vy;
					_canvas.setPixel(block.x, block.y, block.color);
				}
			}
			var removeBalls:Vector.<Particle> = new Vector.<Particle>();
			 for each(var ball:Particle in _balls)
			 {
				var bvx:Number = ball.vx;
				var bvy:Number = ball.vy;
				var bspeed:Number = Math.sqrt(bvx * bvx + bvy * bvy);
				var bradius:Number = Math.atan2(bvy, bvx);
				for (var i:int = 0; i < bspeed;i++)
				{
					ball.x += ball.vx/bspeed;
					ball.y += ball.vy / bspeed;
					
					//当たり判定とか要らないよね＾＾
					//var hitParticle:Particle = _blocks.getParticle(ball.x, ball.y);
					//if(hitParticle)
					//{
						//var removedP:Particle = _blocks.removeParticle(ball.x, ball.y);
						//removedP.vx = Math.cos(bradius+Math.PI*2/(30*Math.random())-15)*3;
						//removedP.vy = 1;
						//removedP.color = hitParticle.color;
						//_fallBlocks.push(removedP);
						//ball.vy = -ball.vy;
					//}
					var changeBallAngle:Function = function():void{
						var r:Number = Math.sqrt(ball.vx * ball.vx + ball.vy * ball.vy);
						var theta:Number = Math.atan2(ball.vy, ball.vx) + (Math.random()* 2 - 1)/(Math.PI *2);
						ball.vx = Math.cos(theta) * r;
						ball.vy = Math.sin(theta) * r;
						
					};
					if ((ball.x < 0 && ball.vx < 0) || (ball.x > WIDTH && ball.vx > 0))
					{
						changeBallAngle();
						ball.vx = -ball.vx;
					}
					if (ball.y < 0 && ball.vy < 0)
					{
						changeBallAngle();
						ball.vy = -ball.vy;
					}
					if (ball.y > HEIGHT)
					{
						changeBallAngle();
						removeBalls.push(ball);
					}
					if (_bar.hitTestPoint(ball.x, ball.y))
					{
						changeBallAngle();
						ball.vy = -Math.abs(ball.vy);
					}
					_canvas.setPixel(ball.x, ball.y, ball.color);
				}
			}
			removeBalls.forEach(function(b:Particle, ...args):void {
				var index:int = _balls.indexOf(b);
				if (index != -1)
				{
					_balls.splice(index, 1);
				}
			});
			
			var removeFallBs:Vector.<Particle> = new Vector.<Particle>();
			_fallBlocks.forEach(function(fallP:Particle, ...args):void {
				fallP.vy += 0.1;
				fallP.x += fallP.vx;
				fallP.y += fallP.vy;
				_canvas.setPixel(fallP.x, fallP.y, fallP.color);
				if (_bar.hitTestPoint(fallP.x,fallP.y))
				{
					var newball:Particle = new Particle(fallP.x,fallP.y);
					newball.vx = Math.random() * 10;
					newball.vy = Math.random() * 9 + 1;
					newball.color = fallP.color;
					_balls.push(newball);
					removeFallBs.push(fallP);
				}else if (fallP.y > HEIGHT)
				{
					removeFallBs.push(fallP);
				}
			});
			
			removeFallBs.forEach(function(b:Particle,...args):void{
				var index:int = _fallBlocks.indexOf(b);
				if (index != -1)
				{
					_fallBlocks.splice(index, 1);
				}
			});
			//_bar.x = stage.mouseX;
			_bar.x = _balls[0].x - 25;
			_canvas.unlock();
			
			if (_blocks.count == 0)
			{
				removeEventListener(Event.ENTER_FRAME, update);
				var clearTF:TextField = new TextField();
				clearTF.text = "CLEAR!\nおめでと";
				clearTF.textColor = 0xFFFFFF;
				clearTF.autoSize = TextFieldAutoSize.LEFT;
				_canvas.draw(clearTF,new Matrix(5,0,0,5,WIDTH/2-clearTF.width*5/2,HEIGHT/2-clearTF.height*5/2));
			}
			
		}
	}
}
//import libs.ColorHSV;
import frocessing.color.ColorHSV;
class Blocks
{
	public function get count():int { return _count;}
	private var _count:int;
	public function get width():Number { return _width; }
	private var _width:Number;
	public function get height():Number { return _height; }
	private var _height:Number;
	public var values:Vector.<Particle>;
	
	//上のブロック
	function Blocks(width:Number,height:Number)
	{
		_width = width;
		_height = height;
		_count = width * height;
		values = new Vector.<Particle>(width * height, false);
		var c:ColorHSV = new ColorHSV();
		for (var i:int = 0; i < _width; i++)
		{
			c.h = 360 * i / _width;
			for (var j:int = 0 ; j < _height; j++ )
			{
				var p:Particle = new Particle(i, j);
				p.row = p.y;
				p.column = p.x;
				p.color = c.value;
				values[i + j * _width] = p;
			}
		}
	}
	
	//パーティクルを得る
	public function getParticle(x:int, y:int):Particle
	{
		var index:int = x + y * _width;
		if (index >= values.length || index < 0)
		{
			return null;
		}
		return values[x + y * _width];
	}
	
	//パーティクルを消す？
	public function removeParticle(x:int, y:int):Particle
	{
		var p:Particle = values[x + y * _width];
		if (p)
		{
			_count--;
			values[x + y * _width] = undefined;
		}
		return p;
	}
}

//パーティクルを表現スルっぽい
class Particle
{
	public var row:Number;
	public var column:Number;
	public var x:Number;
	public var y:Number;
	public var vx:Number = 0;
	public var vy:Number = 0;
	public var color:uint;
	public function Particle(x:Number=0,y:Number=0 )
	{
		this.x = x;
		this.y = y;
	}
}

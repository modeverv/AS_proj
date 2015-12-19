package 
{
	import flash.display.Sprite;
	import flash.events.AsyncErrorEvent;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLRequestHeader;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import net.hires.debug.Stats;
	
	import flash.net.URLRequest;
	import flash.display.Loader;
	
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.media.Video;
	
	
	
	import flash.events.ErrorEvent;
	
	/**
	 * ...
	 * @author modeverv
	 */
	public class Main extends Sprite 
	{
		private var x0:Number = 100;
		private var y0:Number = 200;
		private var x1:Number;
		private var y1:Number;
		private var x2:Number = 300;
		private var y2:Number = 200;
		
		private function onMouseCurve(evt:MouseEvent):void {
			//x1 = mouseX;
			//y1 = mouseY;
			x1 = mouseX * 2 - (x0 + x2) / 2;
			y1 = mouseY * 2 - (y0 +y2) / 2;
			graphics.clear();
			graphics.lineStyle(10, 0, 1);
			graphics.moveTo(x0, y0);
			graphics.curveTo(x1, y1, x2, y2);
		}
		
		
		private var ts:TextField = new TextField();
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		private var arrow:Arrow;
		
		private function tT(t:String):void {
			ts.text = t;
		}
		private var u:String = "http://akvideos.metacafe.com/ItemFiles/%5BFrom%20www.metacafe.com%5D%204355261.13542075.11.flv";
		private var video_obj:Video;
		private function loadVideo():void {
			var connection:NetConnection = new NetConnection();
			connection.connect(null);
			var netStream:NetStream = new NetStream(connection);
			netStream.addEventListener(AsyncErrorEvent.ASYNC_ERROR, errorHandler);
			video_obj = new Video();
			stage.addChild(video_obj);
			video_obj.alpha = 0.5;
			video_obj.scaleX = 2;
			video_obj.scaleY = 2;

			video_obj.attachNetStream(netStream);

			netStream.play(u);
		
		}
		private var iu:String = "http://image.space.rakuten.co.jp/lg01/57/0000914157/89/img2ae7e70czik5zj.jpeg";
		private var loader:Loader;
		private function loadImage() {
			loader = new Loader;
			addChild(loader);
			loader.load(new URLRequest(iu));
		}
		
		private function errorHandler(err:ErrorEvent){
			trace(err.text);
		}
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			loadVideo();
			//loadImage();

				
			addChild(ts);
			ts.defaultTextFormat = new TextFormat(null, 280);
			ts.autoSize = "left";


			var stats:Stats = new Stats();
			stats.y = 200;
			addChild(stats);
			
			// entry point
			arrow = new Arrow();
			addChild(arrow);
			arrow.x = stage.stageWidth / 2;
			arrow.y = stage.stageHeight / 2;
			
			bob = new Bobbin();
			addChild(bob);
			bob.x = stage.stageWidth / 2 + 100;
				
			bob2 = new Bobbin();
			addChild(bob2);
			bob2.x = 0;
			
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			addEventListener(Event.ENTER_FRAME, onEnterFrame2);
			addEventListener(Event.ENTER_FRAME, onEnterFrameOval);
			addEventListener(Event.ENTER_FRAME, onEnterFrameMv);			
			addEventListener(Event.ENTER_FRAME, dispPitagorasu);	

			addEventListener(MouseEvent.MOUSE_MOVE, onMouseLine);	
			addEventListener(MouseEvent.MOUSE_MOVE, onMouseCurve);	
		}
		public function onEnterFrameMv(evt:Event):void {
			//loader.x += 1;
			//if (loader.x > stage.stageWidth) {
			//	loader.x = 0;
			//}
			//同一スプライトに動かしながらloaderとimageは共存不可っぽい
			video_obj.y += 1;
			if (video_obj.y > stage.stageHeight) {
				video_obj.y = 0;
			}
		}
		
		//マウスとの距離＋線
		public function onMouseLine(evt:MouseEvent):void {
			graphics.clear();
			graphics.lineStyle(1, 0, 1);
			graphics.moveTo(arrow.x, arrow.y);
			graphics.lineTo(mouseX, mouseY);
//			tT(pitagorasu(arrow.x, arrow.y, mouseX, mouseY));			
		}
		
		private function pitagorasu(p1x:Number, p1y:Number, p2x:Number, p2y:Number):String {
			trace(p1x);
			trace(p1y);
			trace(p2x);
			trace(p2y);
			var dx:Number = p1x - p2x;
			var dy:Number = p2x - p2y;
			var dist:Number = Math.sqrt(dx * dx + dy * dy);
			trace(dist);
			
			return dist.toString();
		}
		private function dispPitagorasu(e:Event):void {
			tT(pitagorasu(bob.x, bob.y, bob2.x, bob2.y));
		}			
		
		private var bob2:Bobbin;
		private var CenterX2:Number = stage.stageWidth / 2;
		private var CenterY2:Number = stage.stageHeight / 2;
		private var radiusX2:Number = 200;
		private var radiusY2:Number = 100;
		private var angle2:Number = 0;
		
		private var speed2:Number = 0.1;
		public function onEnterFrameOval(evt:Event):void {
			bob2.x = CenterX2 + Math.sin(angle2) * radiusX2;
			bob2.y = CenterY2 + Math.cos(angle2) * radiusY2;
			angle2 += speed2;			
			var pulse:Number =  Math.sin(angle2 * 2 ) * 0.3 + 0.9 ;
			var alpha:Number = Math.sin(angle2 * 3) * 0.3 + 0.9;
			bob2.scaleX = pulse;
			bob2.scaleY = pulse;
			bob2.alpha = alpha;
			
		}
		
		private var bob:Bobbin;
		private var angle:Number = 0;
		private function onEnterFrame2(e:Event):void {
			bob.y = stage.stageHeight / 2 + Math.sin(angle) * 50;
			angle += 0.1;
			bob.x += 1;
			if (bob.x > stage.stageWidth) {
				bob.x = 0;
			}
			var pulse:Number =  Math.sin(angle) * 0.3 + 0.9 ;
			var alpha:Number = Math.sin(angle) * 0.3 + 0.9;
			bob.scaleX = pulse;
			bob.scaleY = pulse;
			bob.alpha = alpha;
		}
		private function onEnterFrame(e:Event) :void {
			var dx:Number = mouseX - arrow.x;
			var dy:Number = mouseY - arrow.y;
			var radians:Number = Math.atan2(dy, dx);
			
			arrow.rotation = radians * 180 / Math.PI;
			//arrow.x = mouseX - 200 ;
			//arrow.y = mouseY - 200;

		}
		
	}
	
}
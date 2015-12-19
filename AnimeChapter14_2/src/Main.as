package 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import modeverv.movable.segment.Segment;
	import flash.geom.Point;
	import flash.display.StageScaleMode;
	import flash.display.StageAlign;	
	
	import flash.text.TextField;
	/**
	 * ...
	 * @author modeverv
	 */
	public class Main extends Sprite
	{
		private var segments:Array;
		private var numSegments:Number = 150;

		public function Main()
		{
			init();
		}
		private var tfs:Array;

		private function init():void
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
		
			segments = new Array();
			tfs = new Array();
			var xposi:Number = 20;
			var yposi:Number = 10;
			
			for (var i:uint = 0; i < numSegments; i++) {
				var segment:Segment = new Segment(20, 5);
				addChild(segment);
				segments.push(segment)
				
				var tf:TextField = new TextField();
				addChild(tf);
				tfs.push(tf);
				tf.text = i.toString();
				tf.x = xposi;
				tf.y = yposi * (i + 1);
			}

			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		
		}
		private function onEnterFrame(event:Event):void
		{
			drag(segments[0], mouseX, mouseY);
			for (var i:Number = 1; i < numSegments; i++) {
				var sA:Segment = segments[i];
				var sB:Segment = segments[i -1];
				TextField(tfs[i]).text = "x:" + Math.round(sA.x) + " y:" + Math.round(sA.y);
				
				drag(sA, sB.x, sB.y);

			}
		}

		private function drag(segment:Segment, xpos:Number, ypos:Number):void {
			var dx:Number = xpos - segment.x;
			var dy:Number = ypos - segment.y;
			var angle:Number = Math.atan2(dy, dx);
			segment.rotation = angle * 180 / Math.PI;
			
			var w:Number = segment.getPin().x - segment.x;
			var h:Number = segment.getPin().y - segment.y;
			segment.x = xpos - w;
			segment.y = ypos - h;
		}
	}
	
}
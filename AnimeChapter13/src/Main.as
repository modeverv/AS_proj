package {
	import flash.display.Sprite;
	import flash.display.StageScaleMode;
	import flash.display.StageAlign;
	import flash.events.Event;
	import modeverv.movable.segment.Segment;
	import fortest.SimpleSlider;
	public class Main extends Sprite
	{
		private var slider0:SimpleSlider;
		private var slider1:SimpleSlider;
		private var segment0:Segment;
		private var segment1:Segment;
		private var segment2:Segment;
		private var segment3:Segment;

		private var cycle:Number = 0;
		
		public function Main()
		{
			init();
		}
		
		private function init():void
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			segment0 = new Segment(100, 20);
			addChild(segment0);
			segment0.x = 200;
			segment0.y = 200;
			
			segment1 = new Segment(100, 20);
			addChild(segment1);
			segment1.x = segment0.getPin().x;
			segment1.y = segment0.getPin().y;
			
			segment2 = new Segment(100, 20);
			addChild(segment2);
			segment2.x = segment1.getPin().x;
			segment2.y = segment1.getPin().y;
			
			
			segment3 = new Segment(100, 20);
			addChild(segment3);
			segment3.x = segment2.getPin().x;
			segment3.y = segment2.getPin().y;			
			
			
			slider0 = new SimpleSlider(-90, 90, 0);
			addChild(slider0);
			slider0.x = 320;
			slider0.y = 20;
			slider0.addEventListener(Event.CHANGE, onChange);

			slider1 = new SimpleSlider(-160, 0, 0);
			addChild(slider1);
			slider1.x = 340;
			slider1.y = 20;
			slider1.addEventListener(Event.CHANGE, onChange);
			
			addEventListener(Event.ENTER_FRAME, onEF);
		}
		
		private function onEF(e:Event):void {
			cycle += .05;
//			var angle0:Number = Math.sin(cycle) * 45 +90;
//			var angle1:Number = Math.sin(cycle) * 45 + 45;
//			segment0.rotation = angle0;
//			segment1.rotation = segment0.rotation + angle1;
//			segment1.x = segment0.getPin().x;
//			segment1.y = segment0.getPin().y;
			walk(segment0, segment1, cycle);
		}
		private var offset:Number = 1.3;
		private function walk(segA:Segment, segB:Segment, cyc:Number):void {
			var angleA:Number = Math.sin(cyc) * 45 + 90;
			var angleB:Number = Math.sin(cyc + offset) * 45 + 45;
			segA.rotation = angleA;
			segB.rotation = angleB + segA.rotation;
			segB.x = segA.getPin().x;
			segB.y = segA.getPin().y;
		}
		private function onChange(event:Event):void
		{
			segment0.rotation = slider0.value;
			segment1.rotation = segment0.rotation + slider1.value;
			segment1.x = segment0.getPin().x;
			segment1.y = segment0.getPin().y;
		}
	}
}

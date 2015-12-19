package 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextFormat;
	import modeverv.movable.segment.Segment;
	import fortest.SimpleSlider;	
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
		private var segment0:Segment;
		private var segment1:Segment;
		private var segment2:Segment;
		private var segment3:Segment;
		private var speedSlider:SimpleSlider;
		private var thighRangeSlider:SimpleSlider;
		private var thighBaseSlider:SimpleSlider;
		private var calfRangeSlider:SimpleSlider;
		private var calfOffsetSlider:SimpleSlider;
		private var gravitySlider:SimpleSlider;
		private var cycle:Number = 0;
		private var vx:Number = 0;
		private var vy:Number = 0;
		
		public function Main()
		{
			init();
		}
		private var tf0:TextField;
		private var tf1:TextField;
		private var tf2:TextField;
		private var tf3:TextField;
		private var tf4:TextField;
		private var tf5:TextField;
		
		private function init():void
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
		
			tf0 = new TextField();
			tf0.x = 150;
			tf0.y = 20;
			addChild(tf0);
			tf1 = new TextField();
			tf1.x = 150;
			tf1.y = 40;
			addChild(tf1);
			tf2 = new TextField();
			tf2.x = 150;
			tf2.y = 60;
			addChild(tf2);
			tf3 = new TextField();
			tf3.x = 150;
			tf3.y = 80;
			addChild(tf3);
			tf4 = new TextField();
			tf4.x = 150;
			tf4.y = 100;
			addChild(tf4);
			tf5 = new TextField();
			tf5.x = 150;
			tf5.y = 120;
			addChild(tf5);

			
			
			segment0 = new Segment(125, 35);
			addChild(segment0);
			segment0.x = stage.stageWidth / 2;//200;
			segment0.y = stage.stageHeight / 2 ;//100;
			
			segment1 = new Segment(125, 25);
			addChild(segment1);
			segment1.x = segment0.getPin().x;
			segment1.y = segment0.getPin().y;
			
			segment2 = new Segment(125, 35);
			addChild(segment2);
			segment2.x = 200;
			segment2.y = 100;
			
			segment3 = new Segment(125, 25);
			addChild(segment3);
			segment3.x = segment2.getPin().x;
			segment3.y = segment2.getPin().y;
			
			speedSlider = new SimpleSlider(0, 0.3, 0.12);
			addChild(speedSlider);
			speedSlider.x = 10;
			speedSlider.y = 10;
			
			thighRangeSlider = new SimpleSlider(0, 90, 45);
			addChild(thighRangeSlider);
			thighRangeSlider.x = 30;
			thighRangeSlider.y = 10;
			
			thighBaseSlider = new SimpleSlider(0, 180, 90);
			addChild(thighBaseSlider);
			thighBaseSlider.x = 50;
			thighBaseSlider.y = 10;
			
			calfRangeSlider = new SimpleSlider(0, 90, 45);
			addChild(calfRangeSlider);
			calfRangeSlider.x = 70;
			calfRangeSlider.y = 10;
			
			calfOffsetSlider = new SimpleSlider(-3.14, 3.14, -1.57);
			addChild(calfOffsetSlider);
			calfOffsetSlider.x = 90;
			calfOffsetSlider.y = 10;
			
			gravitySlider = new SimpleSlider(0, 1, 0.81);
			addChild(gravitySlider);
			gravitySlider.x = 110;
			gravitySlider.y = 10;
			
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		private function onEnterFrame(event:Event):void
		{
//			doVelocity();
//			walk(segment0, segment1, cycle);
//			walk(segment2, segment3, cycle + Math.PI);
//			cycle += speedSlider.value;
//			checkFloor(segment1);
//			checkFloor(segment3);
//			checkWalls();
//			dispValues();
			var dx:Number = mouseX - segment0.x;
			var dy:Number = mouseY - segment0.y;
			var angle:Number = Math.atan2(dy, dx);
			segment0.rotation = angle * 180 / Math.PI;
			
			var w:Number = segment0.getPin().x - segment0.x;
			var h :Number = segment0.getPin().y - segment0.y;
			segment0.x = mouseX - w;
			segment0.y = mouseY - h;
			
			dx = segment0.x - segment1.x;
			 dy = segment0.y - segment1.y;
			 angle = Math.atan2(dy, dx);
			segment1.rotation = angle * 180 / Math.PI;
			
			 w = segment1.getPin().x - segment1.x;
			 h  = segment1.getPin().y - segment1.y;
			segment1.x = segment0.x - w;
			segment1.y = segment0.y - h;			
			
		}
		
		private function dispValues():void {
			tf0.text = "speed       :" + speedSlider.value;
			tf1.text = "thighRange:" + thighRangeSlider.value;
			tf2.text = "thighBase :" + thighBaseSlider.value;
			tf3.text = "calfRange :" + calfRangeSlider.value;
			tf4.text = "calfoffset  :" + calfOffsetSlider.value;
			tf5.text = "gravity      :" + gravitySlider.value;
			
		}
		
		private function walk(segA:Segment, segB:Segment, cyc:Number):void
		{
			var foot:Point = segB.getPin();
			var angleA:Number = Math.sin(cyc) *
								thighRangeSlider.value + 
								thighBaseSlider.value;
			var angleB:Number = Math.sin(cyc + calfOffsetSlider.value) *
								calfRangeSlider.value +
								calfRangeSlider.value;
			segA.rotation = angleA;
			segB.rotation = segA.rotation + angleB;
			segB.x = segA.getPin().x;
			segB.y = segA.getPin().y;
			segB.vx = segB.getPin().x - foot.x;
			segB.vy = segB.getPin().y - foot.y;
		}

		private function doVelocity():void
		{
			vy += gravitySlider.value;
			segment0.x += vx;
			segment0.y += vy;
			segment2.x += vx;
			segment2.y += vy;
		}

		private function checkFloor(seg:Segment):void
		{
			var yMax:Number = seg.getBounds(this).bottom;
			if(yMax > stage.stageHeight)
			{
				var dy:Number = yMax - stage.stageHeight;
				segment0.y -= dy;
				segment1.y -= dy;
				segment2.y -= dy;
				segment3.y -= dy;
				vx -= seg.vx;
				vy -= seg.vy;
			}
		}
		
		private function checkWalls():void
		{
			var w:Number = stage.stageWidth + 200;
			if(segment0.x > stage.stageWidth + 100)
			{
				segment0.x -= w;
				segment1.x -= w;
				segment2.x -= w;
				segment3.x -= w;
			}
			else if(segment0.x < -100)
			{
				segment0.x += w;
				segment1.x += w;
				segment2.x += w;
				segment3.x += w;
			}
		}
	}
	
}
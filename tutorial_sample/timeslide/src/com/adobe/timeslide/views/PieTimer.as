package com.adobe.timeslide.views
{
	import flash.display.Shape;
	import flash.display.Sprite;

	public class PieTimer extends Sprite
	{		
		private var percentComplete:uint;
		private var diameter:uint;
		private var radius:uint;
		
		public function PieTimer(diameter:uint, percentComplete:uint)
		{
			this.percentComplete = percentComplete;
			this.diameter = diameter;
			this.radius = (this.diameter / 2);
			this.width = diameter;
			this.height = diameter;
			this.draw();
		}

		private function draw():void
		{
			// Draw a simple circle
			var circle:Shape = new Shape();
			circle.graphics.beginFill(0x058DC7);
			circle.graphics.drawCircle(this.radius, this.radius, this.radius);
			circle.graphics.endFill();
			addChild(circle);

			// Draw the wedge
			var slice:Shape = new Shape();
			slice.graphics.lineStyle(1, 0xED561B);
			slice.graphics.beginFill(0xED561B);

			slice.graphics.moveTo(this.radius, this.radius);

			var angle:Number;
			var radians:Number;
			var pointX:Number;
			var pointY:Number;

			for (var i:uint = 0; i <= this.percentComplete; ++i)
			{
				angle = 360 * ((i - 25) / 100);
				radians = angle * (Math.PI/180);
				pointX = this.radius * Math.cos(radians);
				pointY = this.radius * Math.sin(radians);
				slice.graphics.lineTo(pointX + this.radius, pointY + this.radius);
			}

			slice.graphics.lineTo(this.radius, this.radius);
			slice.graphics.endFill();
			addChild(slice);
		}
	}
}

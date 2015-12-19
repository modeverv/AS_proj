/*
	Adobe Systems Incorporated(r) Source Code License Agreement
	Copyright(c) 2008 Adobe Systems Incorporated. All rights reserved.
	
	Please read this Source Code License Agreement carefully before using
	the source code.
	
	Adobe Systems Incorporated grants to you a perpetual, worldwide, non-exclusive, 
	no-charge, royalty-free, irrevocable copyright license, to reproduce,
	prepare derivative works of, publicly display, publicly perform, and
	distribute this source code and such derivative works in source or 
	object code form without any attribution requirements.  
	
	The name "Adobe Systems Incorporated" must not be used to endorse or promote products
	derived from the source code without prior written permission.
	
	You agree to indemnify, hold harmless and defend Adobe Systems Incorporated from and
	against any loss, damage, claims or lawsuits, including attorney's 
	fees that arise or result from your use or distribution of the source 
	code.
	
	THIS SOURCE CODE IS PROVIDED "AS IS" AND "WITH ALL FAULTS", WITHOUT 
	ANY TECHNICAL SUPPORT OR ANY EXPRESSED OR IMPLIED WARRANTIES, INCLUDING,
	BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
	FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  ALSO, THERE IS NO WARRANTY OF 
	NON-INFRINGEMENT, TITLE OR QUIET ENJOYMENT.  IN NO EVENT SHALL MACROMEDIA
	OR ITS SUPPLIERS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
	EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, 
	PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
	OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
	WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR 
	OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOURCE CODE, EVEN IF
	ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

package com.adobe.apprise.views
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
			circle.graphics.beginFill(0xffffff);
			circle.graphics.drawCircle(this.radius, this.radius, this.radius);
			circle.graphics.endFill();
			circle.alpha = 0;
			addChild(circle);

			// Draw the wedge
			var slice:Shape = new Shape();
			slice.graphics.lineStyle(1, 0x3399ff);
			slice.graphics.beginFill(0x3399ff);

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

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
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.controls.ColorPicker;
	import mx.controls.Label;
	import mx.controls.Tree;
	import mx.controls.treeClasses.TreeItemRenderer;
	import mx.effects.Glow;
	import mx.events.DragEvent;
	import mx.events.ResizeEvent;

	public class FeedTreeItemRenderer extends TreeItemRenderer
	{	
		private var count:Label;
		private var openTimer:Timer;
		private var timerGraphic:Sprite;
		private var displayName:Label;
		
		public function FeedTreeItemRenderer()
		{
			super();
			this.addEventListener(DragEvent.DRAG_ENTER, onDragEnter);
			this.addEventListener(DragEvent.DRAG_EXIT, onDragExit);
			this.addEventListener(DragEvent.DRAG_DROP, onDragDrop);
			this.addEventListener(MouseEvent.CLICK, onMouseClick);
		}
		
		public function onDragEnter(e:DragEvent):void
		{
			if (this.data && this.data.is_folder && this.openTimer)
			{
				this.openTimer.reset();
				this.openTimer.start();
			}
		}

		public function onDragExit(e:DragEvent):void
		{
			if (this.openTimer)
			{
				this.openTimer.stop();
				this.removeTimerGraphic();
			}
		}

		public function onDragDrop(e:DragEvent):void
		{
			if (this.openTimer)
			{
				this.openTimer.stop();
			}
		}
		
		public function onMouseClick(e:MouseEvent):void
		{
			if (this.data || this.data.highlight)
			{
				this.data.highlight = 0;
			}
		}
		
		override public function set data(value:Object):void
		{
			super.data = value;
			this.updateCount();
			if (value && value.is_folder && !this.openTimer)
			{
				this.openTimer = new Timer(10, 60);
				this.openTimer.addEventListener(TimerEvent.TIMER, drawTimer);
				this.openTimer.addEventListener(TimerEvent.TIMER_COMPLETE,
					function(e:TimerEvent):void
					{
						expandNode(true);
						openTimer.stop();
						removeTimerGraphic();
					});
			}
		}
		
		private function removeTimerGraphic():void
		{
			if (this.timerGraphic && this.contains(this.timerGraphic))
			{
				this.removeChild(timerGraphic);
			}
		}
		
		private function drawTimer(e:TimerEvent):void
		{
			var tree:Tree = this.parent.parent as Tree;
			if (!this.data || !tree) return;
			if (tree.isItemOpen(this.data)) return;
			this.removeTimerGraphic();
			var percentComplete:uint = Math.round((this.openTimer.currentCount / this.openTimer.repeatCount)*100);
			this.timerGraphic = new PieTimer(15, percentComplete);
			this.timerGraphic.width = 15;
			this.timerGraphic.height = 15;
			this.timerGraphic.alpha = .55;
			this.timerGraphic.x = this.icon.x;
			this.timerGraphic.y = 2;
			this.addChild(timerGraphic);
		}
		
		private function expandNode(expand:Boolean):void
		{
			var t:FeedTree = parent.parent as FeedTree;
			if (t == null) return;
			t.springLoadedFolders.push(this.data);
			t.expandItem(data, expand, true, true);
		}
		
		override protected function createChildren():void
		{
			super.createChildren();
		}

		override protected function childrenCreated():void
		{
			super.childrenCreated();			
			this.count = new Label();
			this.count.width = 50;
			this.count.height = 22;
			this.count.setStyle("textAlign", "right");
			this.count.setStyle("verticalAlign", "middle");
			this.parent.addEventListener(ResizeEvent.RESIZE, this.positionCount);
			this.positionCount(null);
			this.addChild(this.count);
			this.updateCount();			
		}
		
		private function updateCount():void
		{
			if (this.data && this.count)
			{
				this.count.text = "(" + this.data.unread + ")";
			}
		}
		
		private function positionCount(e:Event):void
		{
			this.count.x = this.parent.width - 50;
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			if (this.data)
			{
				if (this.data.custom_name) 
				{
					this.label.text = this.data.custom_name;
				}
				else
				{
					this.label.text = this.data.name;
				}
				if (!this.data.parsable)
				{
					this.label.setColor(0xFF0000);
				}
				else if (this.data.highlight)
				{
					var g:Glow = new Glow(this);
					g.duration = 2000;
					g.alphaFrom = 1.0;
					g.alphaTo = 0.0;
					g.color = 0x00FF00;
					g.blurXFrom = 0;
					g.blurYFrom = 0;
					g.blurYTo = 16;
					g.blurXTo = 16;
					g.strength = 2;
					g.play();
					this.data.highlight = false;					
				}		
			}
			
			if ( this.data )
			{				
				this.label.width = this.parent.width - this.count.textWidth - this.icon.x - this.icon.width;
				this.label.truncateToFit("..");
			}
		}
	}
}
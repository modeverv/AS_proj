package com.adobe.pixelperfect
{
	import flash.desktop.NativeApplication;
	import flash.display.NativeWindow;
	import flash.display.NativeWindowInitOptions;
	import flash.display.NativeWindowResize;
	import flash.display.NativeWindowSystemChrome;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.events.FullScreenEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.NativeWindowBoundsEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import flash.ui.Keyboard;

    /**
    * The Ruler class extends NativeWindow to add the ruler window
    * features. Because Ruler does not extend Sprite, it cannot be used
    * as the main class for an application.
    */
	public class Ruler
		extends NativeWindow
	{

		private static var GRIPPER_SIZE:uint = 20;
		private var xTicks:Array;
		private var yTicks:Array;
		private var sprite:Sprite;
		private var dimensions:TextField;

		private var newRulerMenuItem:ContextMenuItem;
		private var fullScreenMenuItem:ContextMenuItem;
		private var preset800x600MenuItem:ContextMenuItem;
		private var preset1024x768MenuItem:ContextMenuItem;
		private var onTopMenuItem:ContextMenuItem;
		private var closeMenuItem:ContextMenuItem;
		private var exitMenuItem:ContextMenuItem;
		
		public function Ruler(width:uint = 300, height:uint = 300, x:uint = 50, y:uint = 50, alpha:Number = .4)
		{
			var winArgs:NativeWindowInitOptions = new NativeWindowInitOptions();
			winArgs.systemChrome = NativeWindowSystemChrome.NONE;
			winArgs.transparent = true;
			super(winArgs);
			
			this.title = "PixelPerfect";
			this.activate();

			// Configure the window
			this.alwaysInFront = false;
			this.x = x;
			this.y = y;
			this.width = width;
			this.height = height;
			minSize = new Point(30,30);
			maxSize = new Point(2000,2000);

			// Create the drawing sprite
			sprite = new Sprite();
			sprite.alpha = alpha;
			sprite.useHandCursor = true;

			// Configure the context menu
			stage.showDefaultContextMenu = true;
			var cm:ContextMenu = new ContextMenu();
			cm.hideBuiltInItems();
			newRulerMenuItem = new ContextMenuItem("New");
			fullScreenMenuItem = new ContextMenuItem("Full Screen");
			preset800x600MenuItem = new ContextMenuItem("800x600");
			preset1024x768MenuItem = new ContextMenuItem("1024x768");
			onTopMenuItem = new ContextMenuItem("Keep On Top");
			exitMenuItem = new ContextMenuItem("Exit");
			closeMenuItem = new ContextMenuItem("Close Window");
			newRulerMenuItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onNewRulerMenuItem);
			fullScreenMenuItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onFullScreenMenuItem);
			preset800x600MenuItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, resizeTo);
			preset1024x768MenuItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, resizeTo);
			onTopMenuItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, toggleAlwaysInFront);
			closeMenuItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onCloseMenuItem);
			exitMenuItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onExitMenuItem);
			cm.customItems.push(newRulerMenuItem);
			cm.customItems.push(fullScreenMenuItem);
			cm.customItems.push(preset800x600MenuItem);
			cm.customItems.push(preset1024x768MenuItem);
			cm.customItems.push(onTopMenuItem);
			cm.customItems.push(closeMenuItem);
			cm.customItems.push(exitMenuItem);
			sprite.contextMenu = cm;

			// Configure the stage
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.addChild(sprite);

			// Cache text fields for performance
			var tickFormat:TextFormat;
			tickFormat = new TextFormat();
			tickFormat.font = "Verdana";
			tickFormat.color = 0x000000;
			tickFormat.size = 10;
			xTicks = new Array();
			yTicks = new Array();
			var xNum:TextField;
			var yNum:TextField;
			for (var i:uint = 0; i < 40; ++i)
			{
				xNum = new TextField();
				xNum.defaultTextFormat = tickFormat;
				xNum.selectable = false;
				xNum.height = 15;
				xNum.text = String(i * 50);
				xTicks.push(xNum);
				yNum = new TextField();
				yNum.defaultTextFormat = tickFormat;
				yNum.selectable = false;
				yNum.height = 15;
				yNum.width = 10;
				yNum.text = String(i * 50);
				yTicks.push(yNum);
			}

			// Set up event listeners
			this.addEventListener(Event.RESIZE, onWindowResize);
			sprite.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			sprite.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
			sprite.doubleClickEnabled = true;
			sprite.addEventListener(MouseEvent.DOUBLE_CLICK, onDoubleClick);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(FullScreenEvent.FULL_SCREEN, onFullScreen);
			
			// Set up the dimensions text field
			var dimFormat:TextFormat;
			dimFormat = new TextFormat();
			dimFormat.font = "Verdana";
			dimFormat.color = 0x000000;
			dimFormat.size = 12;
			dimFormat.bold = true;
			dimFormat.align = "center";
			dimensions = new TextField();
			dimensions.width = 100;
			dimensions.height = 20;
			dimensions.border = false;
			dimensions.selectable = false;
			dimensions.defaultTextFormat = dimFormat;
			sprite.addChild(dimensions);
			updateDimensions(width, height);
			drawTicks(width, height);
			visible = true;
		}
				
		private function toggleAlwaysInFront(e:Event):void
		{
			this.alwaysInFront = !this.alwaysInFront;
			this.onTopMenuItem.checked = this.alwaysInFront;
		}
		
		// Handle the preset commands in the context menu
		private function resizeTo(e:Event):void
		{
			switch (e.target)
			{
				case preset800x600MenuItem:
					this.bounds = new Rectangle(this.x, this.y, 800, 600);
					break;
				case preset1024x768MenuItem:
					this.bounds = new Rectangle(this.x, this.y, 1024, 768);
					break;
			}
		}
		
		// Handle the new ruler command in the context menu
		private function onNewRulerMenuItem(e:ContextMenuEvent):void
		{
			createNewRuler();
		}
		
		// Handle the fullscreen mode toggle command in the context menu
		private function onFullScreenMenuItem(e:ContextMenuEvent):void
		{
			stage.displayState = (stage.displayState == StageDisplayState.NORMAL) ? StageDisplayState.FULL_SCREEN : StageDisplayState.NORMAL;
		}

        // Handle the fullscreen event
		private function onFullScreen(e:FullScreenEvent):void
		{
			fullScreenMenuItem.caption = (e.fullScreen) ? "Full Screen Off" : "Full Screen";
		}
		
		// Handle the close window command in the context menu
		private function onCloseMenuItem(e:ContextMenuEvent):void
		{
			 close();	
		}
		
		// Handle the exit command in the context menu
		private function onExitMenuItem(e:ContextMenuEvent):void
		{
			NativeApplication.nativeApplication.exit();
		}
		
		// Update the label for the window dimensions
		private function updateDimensions(_width:int, _height:int):void
		{
			dimensions.text = _width + " x " + _height;
			dimensions.x = (_width / 2) - (dimensions.width / 2);
			dimensions.y = (_height / 2) - (dimensions.height / 2);
		}
		
		// Change the window opacity when the mouse wheel is rotated
		private function onMouseWheel(e:MouseEvent):void
		{
			var delta:int = (e.delta < 0) ? -1 : 1;
			if (sprite.alpha >= .1 || e.delta > 0)
				sprite.alpha += (delta / 50);
		}
		
		// Handle window mouse down events
		private function onMouseDown(e:Event):void
		{
			if (stage.mouseX >= 0 && stage.mouseX <= GRIPPER_SIZE && stage.mouseY >= 0 && stage.mouseY <= GRIPPER_SIZE)
			{
				startResize(NativeWindowResize.TOP_LEFT);
			}
			else if (stage.mouseX <= this.width && stage.mouseX >= this.width - GRIPPER_SIZE && stage.mouseY >= 0 && stage.mouseY <= GRIPPER_SIZE)
			{
				startResize(NativeWindowResize.TOP_RIGHT);					
			}
			else if (stage.mouseX >= 0 && stage.mouseX <= GRIPPER_SIZE && stage.mouseY <= this.height && stage.mouseY >= this.height - GRIPPER_SIZE)
			{
				startResize(NativeWindowResize.BOTTOM_LEFT);					
			}
			else if (stage.mouseX <= this.width && stage.mouseX >= this.width - GRIPPER_SIZE && stage.mouseY <= this.height && stage.mouseY >= this.height - GRIPPER_SIZE)
			{
				startResize(NativeWindowResize.BOTTOM_RIGHT);					
			}
			else if (stage.mouseX >= 0 && stage.mouseX <= GRIPPER_SIZE)
			{
				startResize(NativeWindowResize.LEFT);					
			}
			else if (stage.mouseX >= this.width - GRIPPER_SIZE && stage.mouseX <= this.width)
			{
				startResize(NativeWindowResize.RIGHT);					
			}
			else if (stage.mouseY >= 0 && stage.mouseY <= GRIPPER_SIZE)
			{
				startResize(NativeWindowResize.TOP);					
			}
			else if (stage.mouseY >= this.height - GRIPPER_SIZE && stage.mouseY <= this.height)
			{
				startResize(NativeWindowResize.BOTTOM);					
			}
			else
			{
				startMove();
			}
		}
		
		// Redraw the window when a resize event is dispatched
		private function onWindowResize(e:NativeWindowBoundsEvent):void
		{
			drawTicks(e.afterBounds.width, e.afterBounds.height);
			updateDimensions(e.afterBounds.width, e.afterBounds.height);
		}
		
		// Draw the ruler tick marks
		private function drawTicks(_width:int, _height:int):void
		{
			sprite.graphics.clear();
			sprite.graphics.beginFill(0x8597f3);
			sprite.graphics.drawRect(0, 0, _width, _height);
			sprite.graphics.endFill();
			
			var len:uint = 0;
			var num:TextField;
			var i:uint;

			for (i = 10; i < _width; i += 5)
			{
				if ((i % 50) == 0)
				{
					len = 15;
					num = TextField(xTicks[i/50]);
					if (sprite.contains(num))
						sprite.removeChild(num);
					sprite.addChild(num);
					num.width = 100;
					num.x = (i < 100) ? i - 9 : i - 12;
					num.y = 15;
				}
				else
				{
					len = 10;
				}
				
				// left black
				sprite.graphics.beginFill(0x000000);
				sprite.graphics.drawRect(i, 0, 1, len);

				// left white
				sprite.graphics.beginFill(0xffffff);
				sprite.graphics.drawRect(i+1, 1, 1, len);

				// black bottom
				if (i < _width - 5)
				{
					sprite.graphics.beginFill(0x000000);
					sprite.graphics.drawRect(i, _height - len, 1, len);
				}
			}

			len = 0;
			for (i = 10; i < _height; i += 5)
			{
				if ((i % 50) == 0)
				{
					len = 15;
					num = TextField(yTicks[i/50]);
					if (sprite.contains(num))
						sprite.removeChild(num);
					sprite.addChild(num);
					num.width = 100;
					num.x = 17,
					num.y = i - 8;
				}
				else
				{
					len = 10;
				}
				
				// top black
				sprite.graphics.beginFill(0x000000);
				sprite.graphics.drawRect(0, i, len, 1);
				
				// top white
				sprite.graphics.beginFill(0xffffff);
				sprite.graphics.drawRect(1, i+1, len, 1);

				// black right
				if (i < _height - 5)
				{
					sprite.graphics.beginFill(0x000000);
					sprite.graphics.drawRect(_width - len, i, len, 1);
				}
			}
			sprite.graphics.endFill();
		}
		
		// Close the window on a double-click event
		private function onDoubleClick(e:Event):void
		{
			close();
		}
		
		private function createNewRuler():void
		{
			var r:Ruler = new Ruler(width, height, x+20, y+20, sprite.alpha);
		}
		
		// Handle keyboard events
		private function onKeyDown(e:KeyboardEvent):void
		{
			switch (e.keyCode)
			{
				case Keyboard.DOWN:
					if (e.shiftKey)
						height += 1;
					else
						y += 1;
					break;
				case Keyboard.UP:
					if (e.shiftKey)
						height -= 1;
					else
						y -= 1;
					break;
				case Keyboard.RIGHT:
					if (e.shiftKey)
						width += 1;
					else
						x += 1;
					break;
				case Keyboard.LEFT:
					if (e.shiftKey)
						width -= 1;
					else
						x -= 1;
					break;
				case 78:
					if (e.ctrlKey)
					{
						createNewRuler();
					}
					break;
			}					
		}
	}
}






































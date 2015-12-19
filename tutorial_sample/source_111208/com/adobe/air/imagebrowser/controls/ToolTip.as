﻿package com.adobe.air.imagebrowser.controls{		import com.gskinner.motion.GTween;		import flash.display.DisplayObject;	import flash.display.Graphics;	import flash.display.Sprite;	import flash.display.Stage;	import flash.events.Event;	import flash.events.MouseEvent;	import flash.filters.DropShadowFilter;	import flash.text.TextField;	import flash.text.TextFieldAutoSize;	import flash.text.TextFieldType;	import flash.text.TextFormat;	import flash.utils.Dictionary;	public class ToolTip extends Sprite {				protected const PADDING:uint = 5;		protected const TEXT_PADDING_TOP:uint = 2;		protected const TEXT_PADDING_SIDE:uint = 4;				protected static var _instance:ToolTip;		protected static var _canInit:Boolean = false;				protected var displayObjectHash:Dictionary;		protected var bg:Sprite;		protected var textField:TextField;		protected var _stage:Stage;				protected var fadeOut:GTween;		protected var fadeIn:GTween;				public function ToolTip() {			super();						displayObjectHash = new Dictionary(true);			bg = new Sprite();			textField = new TextField();						var tf:TextFormat = new TextFormat('Gill Sans', 13, 0xffffff);			tf.letterSpacing = 1;						textField.defaultTextFormat = tf; 			textField.type = TextFieldType.DYNAMIC;			textField.border = true;			textField.embedFonts = true;			textField.selectable = false;			textField.autoSize = TextFieldAutoSize.CENTER;						mouseChildren = false;			mouseEnabled = false;						bg.filters = [new DropShadowFilter(3, 45, 0x333333, .8, 3, 3)];						fadeOut = new GTween(this, .1, {alpha:0}, {autoPlay:false});			fadeOut.addEventListener(Event.COMPLETE, onFadeOutComplete);						fadeIn = new GTween(this, .1, {alpha:1}, {autoPlay:false});						alpha = 0;						addChild(bg);			addChild(textField);		}				public static function register(p_displayObject:DisplayObject, p_text:String):void {			getInstance().register(p_displayObject, p_text);		}				protected function register(p_displayObject:DisplayObject, p_text:String):void {			if (_stage == null) {				if (p_displayObject.stage == null) {					p_displayObject.addEventListener(Event.ADDED_TO_STAGE, onStage);				} else {					_stage = p_displayObject.stage;				}			}						displayObjectHash[p_displayObject] = p_text;			p_displayObject.addEventListener(MouseEvent.ROLL_OVER, onDisplayObjectOver, false, 0, true);			p_displayObject.addEventListener(MouseEvent.ROLL_OUT, onDisplayObjectOut, false, 0, true);		}				protected function onStage(p_event:Event):void {			_stage = p_event.target.stage;			p_event.target.removeEventListener(Event.ADDED_TO_STAGE, onStage);		}				protected function onDisplayObjectOver(p_event:MouseEvent):void {			var txt:String = displayObjectHash[p_event.target]; 			if (txt == null) { return; }						textField.text = txt;			textField.width = Math.min(textField.width, 25);						var g:Graphics = bg.graphics;			g.clear();			g.lineStyle(1, 0xffffff, .7);			g.beginFill(0x000000, .8);			g.drawRect(0, 0, textField.width + (TEXT_PADDING_SIDE*2), textField.height + (TEXT_PADDING_TOP*2));			g.endFill();						textField.x = TEXT_PADDING_SIDE;			textField.y = TEXT_PADDING_TOP/2;						_stage.addEventListener(MouseEvent.MOUSE_MOVE, onStageMouseMove, false, 0, true);			move(p_event.stageX, p_event.stageY);						fadeOut.pause();						fadeIn.invalidate();			fadeIn.play();						_stage.addChild(this);		}				protected function onStageMouseMove(p_e:MouseEvent):void {			move(p_e.stageX, p_e.stageY);		}				protected function move(p_x:Number, p_y:Number):void {			this.x = Math.max(0+PADDING, Math.min(_stage.stageWidth-this.width-PADDING, p_x-PADDING-width));			this.y = Math.max(0+this.height-PADDING, Math.min(_stage.stageHeight-this.height-PADDING, p_y-PADDING-height));		}				protected function onDisplayObjectOut(p_event:MouseEvent):void {			if (_stage.contains(this)) {				fadeOut.invalidate();				fadeOut.pause();				fadeOut.play();			}		}				protected function onFadeOutComplete(p_event:Event):void {			_stage.removeChild(this);			_stage.removeEventListener(MouseEvent.MOUSE_MOVE, onStageMouseMove);		}				protected static function getInstance():ToolTip {			if (_instance == null) {				_canInit = true; _instance = new ToolTip(); _canInit = false;			}			return _instance;		}			}}
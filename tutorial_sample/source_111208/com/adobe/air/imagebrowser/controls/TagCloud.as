﻿package com.adobe.air.imagebrowser.controls {	import com.adobe.air.imagebrowser.data.TagFactory;	import com.adobe.air.imagebrowser.events.TagEvent;		import fl.containers.ScrollPane;	import fl.controls.ScrollPolicy;		import flash.display.Sprite;	import flash.events.MouseEvent;		public class TagCloud extends Sprite {			// Constants:			// Public Properties:		public var minFontSize:Number=12;		public var maxFontSize:Number=30;		public var minCount:Number=3;		public var maxTags:uint=100;		public var verticleGap:Number = 0;			// Private Properties:		protected var _data:Array;		protected var _width:Number;		protected var _height:Number;		protected var tags:Array;		protected var tagFactory:TagFactory;	// UI Elements		public var container:Sprite;		public var sp:ScrollPane;			// Initialization:		public function TagCloud() {			sp.horizontalScrollPolicy = ScrollPolicy.OFF;			_width = width-16;			_height = height;			addEventListener(MouseEvent.CLICK, clickTag, false, 0, true);			addEventListener(MouseEvent.MOUSE_OVER, highlightPhotos, false, 0, true);			addEventListener(MouseEvent.MOUSE_OUT, highlightPhotos, false, 0, true);			sp.setStyle("upSkin", new Sprite());						// Create Container for tags			container = new Sprite();			sp.source = container;			tags = [];						tagFactory = new TagFactory();		}			// Public getter / setters:		public function set data(value:Array):void {			if (value != null) {				_data = value.slice();			} else {				_data = null;			}			buildTagCloud();		}				public function get selected():Array {			var arr:Array = [];			for (var i:int=0; i<tags.length; i++) {				if (tags[i].active || tags[i].selected) { arr.push(tags[i].label); }			}			return arr;		}				public function get active():Array {			var arr:Array = [];			for (var i:int=0; i<tags.length; i++) {				if (tags[i].active) { arr.push(tags[i].label); }			}			return arr;		}				public function highlight(p_tags:Array):void {			for (var i:int=0; i<tags.length; i++) {				var tag:Tag = tags[i] as Tag;				tag.highlighted = (p_tags != null && p_tags.indexOf(tag.label) > -1);			}		}				public function get tagsHeight():Number {			return container.height;		}				override public function set height(value:Number):void {			_height = value;			sp.height = value;		}		override public function get height():Number {			return sp.height;		}				override public function set width(value:Number):void {			_width = value;			sp.width = value;		}		override public function get width():Number {			return sp.width;		}			// Public Methods:					// Private Methods:		protected function highlightPhotos(p_event:MouseEvent):void {			if (!(p_event.target is Tag)) { return; }			var tags:Array;			if (p_event.type == MouseEvent.MOUSE_OVER) {				tags = [(p_event.target as Tag).label];			}			dispatchEvent(new TagEvent(TagEvent.HIGHLIGHT_PHOTOS, tags));		}				protected function buildTagCloud():void {			while(tags.length) {				var t:Tag = tags.pop() as Tag;				container.removeChild(t);				tagFactory.addTag(t);			}			sp.source = container;						if (_data == null || _data.length == 0) { return; }						_data.sortOn("count", Array.NUMERIC|Array.DESCENDING);						var arr:Array = _data.slice(0, maxTags);			var l:Number = arr.length;			var minValue:Number = 1;			var maxValue:Number = arr[0].count;			var range:Number = maxValue-minValue;						arr.sortOn("word");						var tmpTag:Tag = tagFactory.getTag();			tmpTag.update('A', maxFontSize, maxFontSize);			tagFactory.addTag(tmpTag);						var maximumHeight:Number = tmpTag.height;			var paddingLeft:Number = 4;						var yPos:Number = maximumHeight;			var xPos:Number = paddingLeft;						var tag:Tag;			_width = sp.width - 20;						//Create Tags			for (var i:uint=0;i<l;i++) {				var item:Object = arr[i];				var size:int = (range == 0) ? maxFontSize : Math.round(((item.count-minValue)/range)*(maxFontSize-minFontSize)+minFontSize);								// Create Tag				tag = tagFactory.getTag();				tag.active = false;				ToolTip.register(tag, 'Search for: ' + item.word);				tag.update(item.word, size, maxFontSize);				tag.x = xPos;				tag.y = yPos;				container.addChild(tag);				tags.push(tag);								// Determine if tag exceeds cloud's width				if (xPos > 0 && tag.x + tag.width > _width) {					tag.x = xPos = paddingLeft;					yPos = tag.y + maximumHeight + verticleGap; 					tag.y = yPos;				}								xPos += tag.width + 8;			}									sp.update();		}				protected function clickTag(p_event:MouseEvent):void {			var tag:Tag = p_event.target as Tag;			if (tag == null) { return; }			var word:String = tag.label;			tag.active = !tag.active;						dispatchEvent(new TagEvent(TagEvent.HIGHLIGHT_ACTIVE, active));		}	}}
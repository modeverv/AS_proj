﻿package com.adobe.air.imagebrowser.service {		import com.adobe.air.imagebrowser.events.ImageEvent;	import com.adobe.air.imagebrowser.net.FlickrDelegate;		import flash.events.Event;	import flash.events.EventDispatcher;	import flash.events.IEventDispatcher;	public class ImageDelegate extends EventDispatcher {				protected var flickr:FlickrDelegate;				protected static var _instance:ImageDelegate;		protected static var _canInit:Boolean = false;				public function ImageDelegate(target:IEventDispatcher=null) {			flickr = new FlickrDelegate();			super(target);		}				public static function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, weak:Boolean=false):void {			getInstance().addEventListener(type, listener, useCapture, priority, weak);		}				public static function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void {			getInstance().removeEventListener(type, listener, useCapture);		}				public static function search(p_term:String, p_page:Number = 1, p_results:Number = 100):void { getInstance().search(p_term, p_page, p_results); }				protected function search(p_term:String, p_page:Number = 1, p_results:Number = 100):void {			if (p_term == null || p_term == '') {				dispatchEvent(new ImageEvent(ImageEvent.LOAD_END, false, false, []));				return;			}						flickr.search(p_term, p_page, p_results);			flickr.addEventListener(Event.COMPLETE, onImagesLoad);			dispatchEvent(new ImageEvent(ImageEvent.LOAD_START));		}				protected static function getInstance():ImageDelegate {			if (_instance == null) { _canInit = true; _instance = new ImageDelegate(); _canInit = false; }			return _instance;		}				protected function onImagesLoad(p_event:Event):void {			dispatchEvent(new ImageEvent(ImageEvent.LOAD_END, false, false, flickr.data, flickr.imageListData));		}	}}
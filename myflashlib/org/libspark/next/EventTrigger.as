package org.libspark.next {
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	internal class EventTrigger extends Trigger {
	
		private var target:EventDispatcher;
		private var type:String;
		
		public function EventTrigger(obj:EventDispatcher, eventName:String) {
			target = obj;
			type = eventName;
			obj.addEventListener(eventName, onEvent);
		}
		
		override public function halt(... args:Array):void {
			onEvent(null);
		}
		
		private function onEvent(e:Event):void {
			target.removeEventListener(type, onEvent);
			call(e);
		}

	}
}
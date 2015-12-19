package org.libspark.next {
	import flash.utils.setTimeout;
	import flash.utils.clearTimeout;
	public class TimeTrigger extends Trigger{
		private var uid:uint;
		public function TimeTrigger (delay:Number) {
			uid = setTimeout(call, delay);
		}
		override public function halt(... args:Array):void {
			clearTimeout(uid);
			super.halt();
		}
	}
}
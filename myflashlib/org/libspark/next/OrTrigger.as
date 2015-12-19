package org.libspark.next {
	
	import flash.events.Event;
	import org.libspark.as3bind.*;
	
	/**
	* 他のどれかの Trigger が shot したら自分も shot する Trigger.
	*/
	internal class OrTrigger extends Trigger {
		
		/**
		* 他のTriggerのリスト
		*/
		private var triggers:Array;
		
		/**
		* すでに call された
		*/
		private static const ALREADY:Array=[];
		
		/**
		* 中止中
		*/
		private static const HALTING:Array=[];
			
		/**
		* コンストラクタ
		*/
		public function OrTrigger(triggers:Array):void {
			this.triggers = triggers;
			if(triggers.length==0) throw new Error('何も指定されていません.');
			for each(var t:ITrigger in triggers) t.then = bind(check, t, _all);
		}
		
		/**
		* 中断
		*/
		override public function halt(... args):void {
			var triggers2:Array = triggers; triggers = HALTING;
			for each(var t:ITrigger in triggers2.slice(1)) t.halt();
			triggers = triggers2;
			triggers2[0].halt();
		}

		/**
		* 次へすすんでもいいかなチェック
		*/
		private function check(t:ITrigger, ... args:Array):void {
			if(triggers==ALREADY) return;
			else if(triggers==HALTING) return;
			else triggers=ALREADY;
			super.call.apply(null, args);
		}
	}
}
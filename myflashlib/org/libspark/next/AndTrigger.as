package org.libspark.next {
	
	import flash.events.Event;
	import org.libspark.as3bind.*;
	
	/**
	* 他のすべての Trigger が shot したら自分も shot する Trigger.
	*/
	internal class AndTrigger extends Trigger {
		
		/**
		* 他のTriggerのリスト
		*/
		private var triggers:Array;

		/**
		* 他の Trigger が shot したときの引数
		*/
		private var argsList:Array=[];
			
		/**
		* コンストラクタ
		*/
		public function AndTrigger(triggers:Array):void {
			if(triggers.length==0) {
				super.call();
				return;
			}
			this.triggers = triggers;
			for each(var t:ITrigger in triggers) t.then = bind(check, t, _all);
		}

		/**
		* 次へすすんでもいいかなチェック
		*/
		private function check(t:ITrigger, ... args:Array):void {
			if(triggers==null) return;
			var i:int = triggers.indexOf(t);
			if(i!=-1) argsList[i] = args;
			else if(t!=this) throw new Error("未所有の Trigger が渡されました。");
			var allArgs:Array = [];
			for(var j:int; j<triggers.length; j++) {
				if(argsList[j]) allArgs = allArgs.concat(argsList[j]);
				else return;
			}
			triggers = null;
			super.call(allArgs);
		}
		
		override public function halt(... args:Array):void {
			for each(var t:ITrigger in triggers) { t.halt(); }
		}
	}
}
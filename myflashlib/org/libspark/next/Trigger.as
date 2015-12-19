package org.libspark.next {
	/**
	* ITrigger のシンプルな実装.
	*/
	public class Trigger implements ITrigger {
		/**
		* すでに呼び出されたか？
		*/
		private static const ALREADY:Object = {};
		/**
		* コールのための一時保存場所
		*/
		private var temp:*;
		/**
		* 呼び出す関数のセット
		*/
		public function set then(v:Function):void { _then(v); }
		public function get then():Function { return _then; }
		private function _then(v:Function):void { if(temp) _call(v, temp); else temp = v; }
		/**
		* 結果を通知する
		*/
		public function call(... args:Array):void { if(temp) _call(temp, args); else temp = args; }
		/**
		* 実際に呼び出される関数
		*/
		private function _call(f:Function, args:Array):* {
			if(temp==ALREADY) throw new Error("すでに呼び出されています");
			else temp=ALREADY;
			f.apply(null, args);
		}
		/**
		* 作業中止
		*/
		public function halt(... args:Array):void {
			call.apply(this, args);
		}
	}
}
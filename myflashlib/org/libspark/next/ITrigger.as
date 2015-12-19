package org.libspark.next {
	/**
	* 一定時間後に結果が返るすべての処理を表すインターフェイス.
	* <p>ITrigger は基本的にはコンストラクトされた瞬間に処理が始まり、
	*    処理終了時に結果を then に渡すクラスを想定している。</p>
	* <p>処理が終了してから then を登録しても問題ない。</p>
	*/
	public interface ITrigger {
		/** 
		* 処理が終了したときに呼び出す関数を登録する.
		* <p>obj.then = f; という形でも obj.then(f); という形でも登録が可能</p>
		*/
		function get then():Function;
		function set then(f:Function):void;
		/**
		* 処理を中断し今すぐ then を呼び出す
		*/
		function halt(... args:Array):void;
	}
}
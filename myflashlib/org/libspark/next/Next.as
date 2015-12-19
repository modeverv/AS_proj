package org.libspark.next {

	import org.libspark.as3bind.*;
	import flash.events.Event;
	
	/**
	* コンストラクトした瞬間に処理が始まってその終了を待てる ITrigger がある。
	* それをつなげるのが Next。
	*/

	/**
	* 遅延呼び出し
	*/
	public dynamic class Next implements ITrigger {
	
		/**
		* 非同期関数のリスト
		*/
		private var chain:Array = [];

		/**
		* 非同期関数の実行結果の配列
		*/
		public function get args():Array { return _args.slice(); }
		private var _args:Array = [];
		
		/**
		* 現在の ITrigger にアクセス
		*/
		public function get current():* { return _current; }
		private var _current:ITrigger;
		
		/**
		* もう始まってる？
		*/
		private var started:Boolean = false;
		
		/**
		* 次に登録された関数を即座に実行するか？
		*/
		private var ready:Boolean = false;
		
		/**
		* 呼び出しカウント
		*/
		private var callCount:int = 0;
		
		/**
		* 登録場所
		*/
		private var insertIndex:int = 0;
		
		/**
		* エラーハンドラ
		*/
		public var errorHandler:Function = defaultErrorHandler;
		
		/**
		* デフォルトのエラーハンドラ
		*/
		private static function defaultErrorHandler(e:Error):void { throw e; }
		
		/**
		* コンストラクタ
		*/
		public function Next () {
		}

		/**
		* チェーンに非同期処理を追加
		*/
		public function push(... args:Array):Next {
			/*
			var f:Function;
			if(args[0] is Function) {
				// IThen を返す関数
				f = args.length==1 ? args[0] : bind.apply(null, [null].concat(args));
			} else if(args[0] is Class) {
				// IThen を実装したクラス
				f = bind.apply(null, [null, createInstance].concat(args)); 
			}
			*/
			if(callCount==0) chain.push(/*f*/args);
			else chain.splice(insertIndex++, 0, /*f*/args);
			if(ready) _next();
			return this;
		}
		
		/**
		* 登録された非同期処理を削除.
		* <p>ただし then で登録された関数は削除されない</p>
		*/
		public function clear():void {
			chain = chain.filter(function(list:Array, i:int, a:Array):Boolean {
				return list[0]==callThen;
			});
		}
		
		/**
		* 非同期処理の中断
		*/
		public function halt(... args:Array):void {
			clear();
			if(current) current.halt.apply(current, args);
		}
		
		/**
		* 引数削除
		*/
		public function clearArgs():Array {
			return _args.splice(0, _args.length);
		}

		/**
		* 次へ進める
		*/
		private function _next(... args:Array):void {
			// 引数を保存
			_args.splice.apply(null, [_args.length, 0].concat(args));
			// 呼び出し
			if(chain.length>0) {
				var list:Array = chain.shift();
				_current = null;
				try {
					if(list[0] is Function) {
						_current = list[0].apply(null, list.slice(1)) as ITrigger;
					} else if(list[0] is Class) {
						_current = createInstance.apply(null, list) as ITrigger;
					}
				} catch(e:Error) { errorHandler(e); }
				ready = false;
				if(_current) _current.then = _next; else _next();
			} else {
				// 即時実行フラグ
				ready = true;
			}
		}
		
		/**
		* 始める
		*/
		public function start():Next {
			if(started==false) {
				started = true;
				_next();
			}
			return this;
		}

		/**
		* 関数を登録する
		*/
		public function set func(v:Function):void { _func(v); }
		
		/**
		* 関数を登録する
		*/
		public function get func():Function { return _func; }
		
		/**
		* 関数登録を行う本体
		*/
		private function _func(f:Function):Next {
			push(callFunc, f);
			return this;
		}

		/**
		* 関数を呼び出す
		*/
		private function callFunc(f:Function):ITrigger {
			++callCount;
			var result:Array = (f.apply(this, clearArgs()) as Array);
			if(result) _args = _args.concat(result);
			if(--callCount==0) insertIndex=0;
			return null;
		}
		
		/**
		* then として呼ぶ
		*/
		private function callThen(f:Function):ITrigger {
			return callFunc(f);
		}

		/**
		* Trigger が満たされた時呼び出される関数をセットします.
		*/
		public function set then(v:Function):void { _then(v); }
		public function get then():Function { return _then; }
		
		/**
		* _then の実態
		*/
		private function _then(v:Function):Next {
			push(callThen, v);
			start();
			return this;
		}

		/**
		* 非同期関数を登録する
		*/
		public static function register(name:String, type:*):void {
			Overload.check([type], [Function], [Class]);
			Next.prototype[name] = bind(_this, "push", type, _all);
		}

		/**
		* and
		*/
		public function and(triggers:Array):Next {	
			return push(AndTrigger, triggers);
		}
		
		/**
		* or
		*/
		public function or(triggers:Array):Next {
			return push(OrTrigger, triggers);
		}
		
		/**
		* join
		*/
		public function join(other:Next):Next {
			return push(OrTrigger, [other]);
		}

		/**
		* event
		*/
		public function event(obj:Object, eventName:String):Next {
			return push(EventTrigger, obj, eventName);
		}

		/**
		* load
		*/
		public function load(... args:Array):Next {
			return push.apply(null, [LoaderTrigger].concat(args));
		}
		
		/**
		* time
		*/
		public function time(d:Number):Next {
			return push(TimeTrigger, d);
		}
		
		/**
		* trigger
		*/
		public function trigger(t:ITrigger):Next {
			return push(triggerHelper, t);
		}
		
		/**
		* trigger で使用するヘルパ
		*/
		private function triggerHelper(t:ITrigger):ITrigger { return t; }
	}
}
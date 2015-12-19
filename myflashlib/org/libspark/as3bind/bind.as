package org.libspark.as3bind {
	/**
	* 引数束縛を行います.
	* <p>許される書式</p>
	* bind(obj, f, ... args) // 一般形
	* bind(f, ... args)		 // this オブジェクト省略
	* bind(obj, s, ... args) // 引数を文字列で
	* bind(s, ... args)		 // this オブジェクト省略
	*/
	public function bind(... bindArgs:Array):Function {
		// 引数チェック
		if(bindArgs.length==0) throw new ArgumentError();
		if(bindArgs[0]==_all) throw new ArgumentError("_all は thisObject に指定できません");
		// 省略された thisObject の保管
		if (bindArgs[1] is Function) ;
		else if (bindArgs[0] is Function) bindArgs.unshift(_this);
		else if (bindArgs[1] is String) ;
		else if (bindArgs[0] is String)	bindArgs.unshift(_this);
		else throw new ArgumentError("関数が指定されていません");
		// 関数生成
		return function (... args):* {
			var newArgs:Array = bindArgs.slice();
			for(var i:int=0; i<newArgs.length; i++) {
				switch(newArgs[i]) {
					case _1: newArgs[i] = args[0]; break;
					case _2: newArgs[i] = args[1]; break;
					case _3: newArgs[i] = args[2]; break;
					case _4: newArgs[i] = args[3]; break;
					case _5: newArgs[i] = args[4]; break;
					case _6: newArgs[i] = args[5]; break;
					case _7: newArgs[i] = args[6]; break;
					case _8: newArgs[i] = args[7]; break;
					case _9: newArgs[i] = args[8]; break;
					case _this: newArgs[i] = this; break;
					case _all:
						newArgs.splice.apply(null, [i, 1].concat(args));
						i+=args.length-1;
						break;
				}
			}
			var thisObject:* = newArgs.shift();
			var func:Function = newArgs[0] is Function ? newArgs.shift() : thisObject[newArgs.shift()];
			return func.apply(thisObject, newArgs);
		};
	}
}
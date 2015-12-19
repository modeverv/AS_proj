package org.libspark.next {
	/**
	* 関数オーバーロードを応援するためのクラス
	*/
	public class Overload {
		public static function check(args:Array, ... typesList:Array):int {
			typesLoop: for(var i:int=0; i<typesList.length; i++) {
				for(var j:int=0; j<typesList[i].length; j++) {
					if(!(args[j] is typesList[i][j])) continue typesLoop;
				}
				return i;
			}
			throw new ArgumentError("引数のフォーマットが間違っています");
		}
	}
}
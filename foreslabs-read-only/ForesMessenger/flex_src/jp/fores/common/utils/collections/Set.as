package jp.fores.common.utils.collections
{

	/**
	 * JavaっぽいSetインターフェース。
	 */
	public interface Set
	{
		//==========================================================
		//メソッド
	
		//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
		//抽象メソッド
	
		/**
		 * 指定されたオブジェクトがセット内になかった場合、セットに追加します。
		 * セット内にすでに指定されたオブジェクトがある場合、セットを変更せずにfalseを返します。
		 *
		 * @param obj セットに追加するオブジェクト
		 * @return true=オブジェクトをセットに追加した場合, false=セット内にすでに指定されたオブジェクトがある場合
		 */
		function add(obj :Object) :Boolean;
	
		/**
		 * 指定されたオブジェクトがセット内にあった場合、セットから削除します。
		 * セット内に指定したオブジェクトがない場合は、セットを変更せずにfalseを返します。
		 *
		 * @param obj セットから削除するオブジェクト
		 * @return true=オブジェクトをセットから削除した場合, false=セット内に指定されたオブジェクトがない場合
		 */
		function remove(obj :Object) :Boolean;
		
		/**
		 * セットからすべての要素を削除します。
		 */
		function clear() :void;
		
		/**
		 * 指定されたオブジェクトがセット内にあるかどうかを返します。
		 *
		 * @param obj 検索対象のオブジェクト
		 * @return true=セット内にオブジェクトがある場合, false=セット内にオブジェクトがない場合
		 */
		function contains(obj :Object) :Boolean;
		
		/**
		 * セット内の要素数を返します。
		 *
		 * @return セット内の要素数
		 */
		function size() :int;
		
		/**
		 * セット内のすべての要素が格納されている配列を返します。
		 *
		 * @param セット内のすべての要素が格納されている配列
		 */
		function toArray() :Array;
	
		/**
		 * クローンを作成して返します。
		 * このクローンはシャローコピーなので、セット内の要素のクローンまでは作成されません。
		 *
		 * @return クローン
		 */
		function clone() :Set;
	
		/**
		 * 指定されたオブジェクトがこのセットと同じ内容かどうかを比較します。
		 * 指定されたオブジェクトがセットのインスタンスでない場合は、falseを返します。
		 *
		 * @param obj 比較対象のオブジェクト
		 * @return true=同じ内容, false=違う内容
		 */
		function equals(obj :Object) :Boolean;
		
	}
}
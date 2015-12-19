package jp.fores.common.utils.collections
{
	/**
	 * JavaっぽいMapインターフェース。
	 */
	public interface Map
	{
		//==========================================================
		//メソッド
	
		//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
		//抽象メソッド
	
		/**
		 * 指定された値と指定されたキーをこのマップに関連付けます。
		 * マップにすでにこのキーに対するマッピングがある場合、古い値は指定された値に置き換えられます。
		 *
		 * @param key キー
		 * @param value キーに関連付けられる値
		 * @return キーに対して以前にマッピングされていた値(マッピングされていなかった場合はnull)
		 */
		function put(key :Object, value :Object) :Object;
		
		/**
		 * 指定されたキーにマッピングされている値を返します。
		 * 指定されたキーにマッピングされている値がない場合はnullを返します。
		 *
		 * @param key キー
		 * @return 指定されたキーにマッピングされている値(指定されたキーにマッピングされている値がない場合はnull)
		 */
		function getValue(key :Object) :Object;
	
		/**
		 * 指定されたキーに対するマッピングをこのマップから削除します。
		 *
		 * @param key キー
		 * @return キーに対して以前にマッピングされていた値(マッピングされていなかった場合はnull)
		 */
		function remove(key :Object) :Object;
		
		/**
		 * マップからマッピングをすべて削除します 。
		 */
		function clear() :void;
		
		/**
		 * 指定されたキーのマッピングがマップに含まれているかどうかを返します。
		 *
		 * @param key キー
		 * @return true=マップが指定のキーのマッピングを保持する場合, false=マップが指定のキーのマッピングを保持しない場合
		 */
		function containsKey(key :Object) :Boolean;
		
		/**
		 * 指定された値に1つ以上のキーがマッピングされているかどうかを返します。
		 *
		 * @param value マップにあるかどうかを判定される値
		 * @return true=指定された値に1つ以上のキーがマッピングされている場合, false=指定された値に1つ以上のキーがマッピングされていない場合
		 */
		function containsValue(value :Object) :Boolean;
		
		/**
		 * マップ内のキーと値のマッピングの数を返します。
		 *
		 * @return マップ内のキーと値のマッピングの数
		 */
		function size() :int;
		
		/**
		 * マップに含まれているキーのセットビューを返します。
		 *
		 * @return マップに含まれているキーのセットビュー
		 */
		function keySet() :Set;
		
		/**
		 * マップに含まれている値の配列ビューを返します。
		 *
		 * @param マップに含まれている値の配列ビュー
		 */
		function values() :Array;
	
		/**
		 * クローンを作成して返します。
		 *
		 * @return クローン
		 */
		function clone() :Map;
		
	
		/**
		 * 指定されたオブジェクトがこのマップと同じ内容かどうかを比較します。
		 * 指定されたオブジェクトがマップのインスタンスでない場合は、falseを返します。
		 *
		 * @param obj 比較対象のオブジェクト
		 * @return true=同じ内容, false=違う内容
		 */
		function equals(obj :Object) :Boolean;
	}
}
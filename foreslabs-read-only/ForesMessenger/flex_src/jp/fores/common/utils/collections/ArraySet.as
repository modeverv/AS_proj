package jp.fores.common.utils.collections
{
	import jp.fores.common.utils.ArrayUtil;
	
	import mx.utils.ObjectUtil;
	
	
	/**
	 * Arrayを使ったSetの実装クラス。
	 * 値が追加された順番は維持されます。
	 */
	public class ArraySet implements Set
	{
		//==========================================================
		//フィールド
	
		//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
		//インスタンス変数
	
		/**
		 * オブジェクトを保持する配列
		 */
		private var _array :Array = new Array();
		
		
		//==========================================================
		//メソッド
	
		//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
		//インターフェースの実装
	
		/**
		 * 指定されたオブジェクトがセット内になかった場合、セットに追加します。
		 * セット内にすでに指定されたオブジェクトがある場合、セットを変更せずにfalseを返します。
		 *
		 * @param obj セットに追加するオブジェクト
		 * @return true=オブジェクトをセットに追加した場合, false=セット内にすでに指定されたオブジェクトがある場合
		 */
		public function add(obj :Object) :Boolean
		{
			//セット内にすでに指定されたオブジェクトがある場合
			if(this.contains(obj))
			{
				//falseを返して終了
				return false;
			}
			
			//フィールドの配列の末尾に引数のオブジェクトを追加
			this._array.push(obj);
			
			//オブジェクトをセットに追加したのでtrueを返す
			return true;
		}
	
		/**
		 * 指定されたオブジェクトがセット内にあった場合、セットから削除します。
		 * セット内に指定したオブジェクトがない場合は、セットを変更せずにfalseを返します。
		 *
		 * @param obj セットから削除するオブジェクト
		 * @return true=オブジェクトをセットから削除した場合, false=セット内に指定されたオブジェクトがない場合
		 */
		public function remove(obj :Object) :Boolean
		{
			//フィールドの配列から引数のオブジェクトと一致する要素を削除し、戻り値をそのまま返す
			return ArrayUtil.removeFirstObject(this._array, obj);
		}
		
		/**
		 * セットからすべての要素を削除します。
		 */
		public function clear() :void
		{
			//フィールドの配列を空にする
			ArrayUtil.clear(this._array);
		}
		
		/**
		 * 指定されたオブジェクトがセット内にあるかどうかを返します。
		 *
		 * @param obj 検索対象のオブジェクト
		 * @return true=セット内にオブジェクトがある場合, false=セット内にオブジェクトがない場合
		 */
		public function contains(obj :Object) :Boolean
		{
			//フィールドの配列に引数のオブジェクトが含まれているかどうかを返す
			return ArrayUtil.contains(this._array, obj);
		}
		
		/**
		 * セット内の要素数を返します。
		 *
		 * @return セット内の要素数
		 */
		public function size() :int
		{
			//フィールドの配列の要素数をそのまま返す
			return this._array.length;
		}
		
		/**
		 * セット内のすべての要素が格納されている配列を返します。
		 *
		 * @param セット内のすべての要素が格納されている配列
		 */
		public function toArray() :Array
		{
			//フィールドの配列のクローンを作成して返す
			return ArrayUtil.createClone(this._array);
		}
	
		/**
		 * クローンを作成して返します。
		 *
		 * @return クローン
		 */
		public function clone() :Set
		{
			//ObjectUtilを使って自分自身のインスタンスのクローンを作成し、キャストしてから返す
			return ObjectUtil.copy(this) as Set;
		}
	
		/**
		 * 指定されたオブジェクトがこのセットと同じ内容かどうかを比較します。
		 * 指定されたオブジェクトがセットのインスタンスでない場合は、falseを返します。
		 *
		 * @param obj 比較対象のオブジェクト
		 * @return true=同じ内容, false=違う内容
		 */
		public function equals(obj :Object) :Boolean
		{
			//同じインスタンスの場合
			if(obj === this)
			{
				//絶対に同じ内容なのでtrueを返す
				return true;
			}
			
			//Setのインスタンスでない場合
			if(!(obj is Set))
			{
				//内容を比較しようがないのでfalseを返す
				return false;
			}
	
			//配列の内容が同じ場合
			if(ArrayUtil.arrayEquals(this.toArray(), obj.toArray()))
			{
				//同じ内容なのでtrueを返す
				return true;
			}
			//配列の内容が違う場合
			else
			{
				//違う内容なのでfalseを返す
				return false;
			}
		}
		
		
		//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
		//オーバーライドするメソッド
		
		/**
		 * このオブジェクトの文字列表現を返します。
		 *
		 * @return 文字列表現
		 */
		public function toString() :String
		{
			//クラス名とフィールドの配列の内容を結合して返す
			return "jp.co.artstaff.campuseos.util.collections.ArraySet - [" + this._array.toString() + "]";
		}
		
	}
}
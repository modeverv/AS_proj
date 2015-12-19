package jp.fores.common.utils.collections
{
	import mx.utils.ObjectUtil;
	
	/**
	 * Objectを使ったHashMapっぽいMapの実装クラス。
	 * キーが追加された順番は維持されません。
	 *
	 * (注)
	 * キーには文字列だけでなく任意の型の値を使用できますが、内部的には文字列として扱われます。
	 * 例えば、文字列「"123"」と数値「123」は同じキーとみなされます。
	 */
	public class ObjectMap implements Map
	{
		//==========================================================
		//フィールド
	
		//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
		//インスタンス変数
	
		/**
		 * マッピングを保持するオブジェクト
		 */
		private var _mapObj :Object = new Object();
		
		
		//==========================================================
		//メソッド
	
		//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
		//インターフェースの実装
	
		/**
		 * 指定された値と指定されたキーをこのマップに関連付けます。
		 * マップにすでにこのキーに対するマッピングがある場合、古い値は指定された値に置き換えられます。
		 *
		 * @param key キー
		 * @param value キーに関連付けられる値
		 * @return キーに対して以前にマッピングされていた値(マッピングされていなかった場合はnull)
		 */
		public function put(key :Object, value :Object) :Object
		{
			//指定されたキーにマッピングされている値を取得
			var mapValue :Object = this.getValue(key);
			
			//フィールドのマッピングを保持するオブジェクトに指定されたキーと値のマッピングを追加
			this._mapObj[key] = value;
			
			//あらかじめ取得しておいた値を返す
			return mapValue;
		}
		
		/**
		 * 指定されたキーにマッピングされている値を返します。
		 * 指定されたキーにマッピングされている値がない場合はnullを返します。
		 *
		 * @param key キー
		 * @return 指定されたキーにマッピングされている値(指定されたキーにマッピングされている値がない場合はnull)
		 */
		public function getValue(key :Object) :Object
		{
			//フィールドのマッピングを保持するオブジェクトのキーに対するプロパティの値を返す
			return this._mapObj[key];
		}
	
		/**
		 * 指定されたキーに対するマッピングをこのマップから削除します。
		 *
		 * @param key キー
		 * @return キーに対して以前にマッピングされていた値(マッピングされていなかった場合はnull)
		 */
		public function remove(key :Object) :Object
		{
			//指定されたキーにマッピングされている値を取得
			var value :Object = this.getValue(key);
			
			//フィールドのマッピングを保持するオブジェクトから指定されたキーに対するマッピングを削除
			delete this._mapObj[key];
			
			//あらかじめ取得しておいた値を返す
			return value;
		}
		
		/**
		 * マップからマッピングをすべて削除します 。
		 */
		public function clear() :void
		{
			//ループをまわして地道に全部のマッピングを削除しても良いが、
			//それでは面倒なのでフィールドのマッピングを保持するオブジェクトを別のオブジェクトに差し替える
			this._mapObj = new Object();
		}
		
		/**
		 * 指定されたキーのマッピングがマップに含まれているかどうかを返します。
		 *
		 * @param key キー
		 * @return true=マップが指定のキーのマッピングを保持する場合, false=マップが指定のキーのマッピングを保持しない場合
		 */
		public function containsKey(key :Object) :Boolean
		{
			//フィールドのマッピングを保持するオブジェクトに引数のキーに対するプロパティが設定されている場合
			if(this._mapObj[key] != null)
			{
				//マッピングが見つかったのでtrueを返す
				return true;
			}
			//それ以外の場合
			else
			{
				//マッピングが見つからなかったのでtrueを返す
				return false;
			}
		}
		
		/**
		 * 指定された値に1つ以上のキーがマッピングされているかどうかを返します。
		 *
		 * @param value マップにあるかどうかを判定される値
		 * @return true=指定された値に1つ以上のキーがマッピングされている場合, false=指定された値に1つ以上のキーがマッピングされていない場合
		 */
		public function containsValue(value :Object) :Boolean
		{
			//フィールドのマッピングを保持するオブジェクトの全てのプロパティに対してループをまわす
			for(var prop :String in this._mapObj)
			{
				//指定された値と現在のプロパティの値が一致する場合
				if(value === this._mapObj[prop])
				{
					//見つかったのでtrueを返す
					return true;
				}
			}
			
			//最後まで見つからなかったのでfalseを返す
			return false;
		}
		
		/**
		 * マップ内のキーと値のマッピングの数を返します。
		 *
		 * @return マップ内のキーと値のマッピングの数
		 */
		public function size() :int
		{
			//カウント
			var count :int = 0;
			
			//フィールドのマッピングを保持するオブジェクトの全てのプロパティに対してループをまわし、
			//プロパティの数(=マッピングの数)をカウントする
			for(var prop :String in this._mapObj)
			{
				count++;
			}
			
			//カウントを返す
			return count;
		}
		
		/**
		 * マップに含まれているキーのセットビューを返します。
		 *
		 * @return マップに含まれているキーのセットビュー
		 */
		public function keySet() :Set
		{
			//結果格納用のSetのインスタンスを生成
			var setObj :Set = new ArraySet();
			
			//フィールドのマッピングを保持するオブジェクトの全てのプロパティに対してループをまわす
			for(var prop :String in this._mapObj)
			{
				//プロパティ名(=マップのキー)をSetに追加
				setObj.add(prop);
			}
			
			//結果のSetを返す
			return setObj;
		}
		
		/**
		 * マップに含まれている値の配列ビューを返します。
		 *
		 * @param マップに含まれている値の配列ビュー
		 */
		public function values() :Array
		{
			//結果格納用の配列を生成
			var array :Array = new Array();
			
			//フィールドのマッピングを保持するオブジェクトの全てのプロパティに対してループをまわす
			for(var prop :String in this._mapObj)
			{
				//プロパティの値(=マップの値)を配列に追加
				array.push(this._mapObj[prop]);
			}
			
			//結果の配列を返す
			return array;
		}
	
		/**
		 * クローンを作成して返します。
		 *
		 * @return クローン
		 */
		public function clone() :Map
		{
			//ObjectUtilを使って自分自身のインスタンスのクローンを作成し、キャストしてから返す
			return ObjectUtil.copy(this) as Map;
		}
	
		/**
		 * 指定されたオブジェクトがこのマップと同じ内容かどうかを比較します。
		 * 指定されたオブジェクトがマップのインスタンスでない場合は、falseを返します。
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
			
			//Mapのインスタンスでない場合
			if(!(obj is Map))
			{
				//内容を比較しようがないのでfalseを返す
				return false;
			}
	
			
			//引数の比較対象のオブジェクトをMapにキャスト
			var testMap :Map = obj as Map;
			
			//サイズが異なる場合
			if(this.size() !== testMap.size())
			{
				//同じでないのでfalseを返す
				return false;
			}
			
			//自分自身のインスタンスのフィールドのマッピングを保持するオブジェクトの全てのプロパティに対してループをまわす
			for (var prop :String in this._mapObj)
			{
				//値が違う要素が見つかった場合
				if(this.getValue(prop) !== testMap.getValue(prop))
				{
					//同じでないのでfalseを返す
					return false;
				}
			}
			
			//全てのチェックをくぐり抜けたのでtrueを返す
			return true;
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
			//==========================================================
			//クラス名とマッピングの内容を結合して返す
			var str :String = "";
			str += "jp.co.artstaff.campuseos.util.collections.ObjectMap - size=" + this.size() + "\n";
			str += "{\n";
			
			//フィールドのマッピングを保持するオブジェクトの全てのプロパティに対して処理を行う
			for(var prop :String in this._mapObj)
			{
				//プロパティのキーと値を文字列に追加する
				str += "    " + prop + " => " + this._mapObj[prop] + "\n";
			}
			
			str += "}";
			
			//作成した文字列を返す
			return str;
		}
		
	}
}
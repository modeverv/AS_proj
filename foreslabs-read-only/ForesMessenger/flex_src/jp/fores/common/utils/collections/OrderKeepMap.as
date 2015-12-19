package jp.fores.common.utils.collections
{
	/**
	 * ObjectMapを改良してキーが追加された順番を維持するようにしたMapの実装クラス。
	 * ただし、その分若干処理効率は落ちます。
	 */
	public class OrderKeepMap extends ObjectMap
	{
		//==========================================================
		//フィールド
	
		//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
		//インスタンス変数
	
		/**
		 * キーの順番を維持するために使用するSet
		 */
		private var _keySet :ArraySet = new ArraySet();
		
		
		//==========================================================
		//メソッド
	
		//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
		//オーバーライドするメソッド
	
		/**
		 * 指定された値と指定されたキーをこのマップに関連付けます。
		 * マップにすでにこのキーに対するマッピングがある場合、古い値は指定された値に置き換えられます。
		 *
		 * @param key キー
		 * @param value キーに関連付けられる値
		 * @return キーに対して以前にマッピングされていた値(マッピングされていなかった場合はnull)
		 */
		override public function put(key :Object, value :Object) :Object
		{
			//基底クラスの処理を呼び出して、戻り値を取得
			var result :Object = super.put(key, value);
			
			//戻り値がnullの場合
			//(新規にマッピングされる場合)
			if(result == null)
			{
				//フィールドのキーの順番を維持するために使用するSetにもキーを追加する
				this._keySet.add(key);
			}
			
			//先ほど取得した戻り値を返す
			return result;
		}
		
		/**
		 * 指定されたキーに対するマッピングをこのマップから削除します。
		 *
		 * @param key キー
		 * @return キーに対して以前にマッピングされていた値(マッピングされていなかった場合はnull)
		 */
		override public function remove(key :Object) :Object
		{
			//基底クラスの処理を呼び出して、戻り値を取得
			var result :Object = super.remove(key);
			
			//戻り値がnullでない場合
			//(マッピングされていた場合)
			if(result != null)
			{
				//フィールドのキーの順番を維持するために使用するSetからもキーを削除する
				this._keySet.remove(key);
			}
			
			//先ほど取得した戻り値を返す
			return result;
		}
		
		/**
		 * マップからマッピングをすべて削除します 。
		 */
		override public function clear() :void
		{
			//基底クラスの処理を先に呼び出す
			super.clear();
			
			//フィールドのキーの順番を維持するために使用するSetを空にする
			this._keySet.clear();
		}
		
		/**
		 * マップ内のキーと値のマッピングの数を返します。
		 *
		 * @return マップ内のキーと値のマッピングの数
		 */
		override public function size() :int
		{
			//フィールドのキーの順番を維持するために使用するSetのサイズをそのまま返す
			//(本当はこのメソッドはオーバーライドしなくても良いが、
			// ループをまわしてカウントを取得するよりもSetのサイズを取得する処理の方が軽いので、
			// 少しでも処理効率を上げるためにオーバーライド)
			return this._keySet.size();
		}
		
		/**
		 * マップに含まれているキーのセットビューを返します。
		 *
		 * @return マップに含まれているキーのセットビュー
		 */
		override public function keySet() :Set
		{
			//フィールドのキーの順番を維持するために使用するSetのクローンを作成して返す
			return this._keySet.clone();
		}
		
		/**
		 * マップに含まれている値の配列ビューを返します。
		 *
		 * @param マップに含まれている値の配列ビュー
		 */
		override public function values() :Array
		{
			//結果格納用の配列を生成
			var array :Array = new Array();
			
			//フィールドのキーの順番を維持するために使用するSetを配列に変換
			var keyArray:Array = this._keySet.toArray();
			
			//全てのキーに対してループをまわす
			for(var i :int = 0; i < keyArray.length; i++)
			{
				//キーにマッピングされている値を配列に追加
				array.push(this.getValue(keyArray[i]));
			}
			
			//結果の配列を返す
			return array;
		}
	
		/**
		 * このオブジェクトの文字列表現を返します。
		 *
		 * @return 文字列表現
		 */
		override public function toString() :String
		{
			//==========================================================
			//クラス名とマッピングの内容を結合して返す
			var str :String = "";
			str += "jp.co.artstaff.campuseos.util.collections.OrderKeepMap - size=" + this.size() + "\n";
			str += "{\n";
			
			//フィールドのキーの順番を維持するために使用するSetを配列に変換
			var keyArray:Array = this._keySet.toArray();
			
			//全てのキーに対してループをまわす
			for(var i :int = 0; i < keyArray.length; i++)
			{
				//キーとそれにマッピングされている値を文字列に追加する
				str += "    " + keyArray[i] + " => " + this.getValue(keyArray[i]) + "\n";
			}
			
			str += "}";
			
			//作成した文字列を返す
			return str;
		}
		
	}
}
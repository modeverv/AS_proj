package jp.fores.common.utils
{
	/**
	 * 配列操作用ユーティリティクラス。
	 */
	public class ArrayUtil
	{
		//==========================================================
		//メソッド
	
		//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
		//クラスメソッド
	
		/**
		 * 引数の配列の指定したインデックスの位置にオブジェクトを追加します。
		 * 無効なインデックスが指定された場合は何もしません。
		 *
		 * @param arrayArg 処理対象の配列
		 * @param indexArg オブジェクトを追加する位置
		 * @param objArg 追加するオブジェクト
		 */
		public static function add(arrayArg :Array, indexArg :Number, objArg :Object) :void
		{
			//無効なインデックスの場合
			if((indexArg < 0) || (indexArg > arrayArg.length))
			{
				//何もしないで終了
				return;
			}
			
			//spliceメソッドを使って指定したインデックスにオブジェクトを追加
			arrayArg.splice(indexArg, 0, objArg);
		}
		
		/**
		 * 引数の配列を空にします。
		 *
		 * @param arrayArg 処理対象の配列
		 */
		public static function clear(arrayArg : Array) : void
		{
			//強制的にlengthを0にして、配列を空にする
			arrayArg.length = 0;
		}
		
		/**
		 * 引数の配列がnullまたは空配列かどうかを返します。
		 *
		 * @param arrayArg 処理対象の配列
		 * @return true=nullまたは空配列の場合, false=それ以外の場合
		 */
		public static function isBlank(arrayArg :Array) :Boolean
		{
			//nullまたは空配列の場合
			if((arrayArg == null) || (arrayArg.length === 0))
			{
				//trueを返す
				return true;
			}
			//それ以外の場合
			else
			{
				//falseを返す
				return false;
			}
		}
		
		/**
		 * 引数の配列に指定されたオブジェクトが含まれているかどうかを返します。
		 *
		 * @param arrayArg 処理対象の配列
		 * @param objArg 検索対象のオブジェクト
		 * @return true=オブジェクトが含まれている場合, false=オブジェクトが含まれていない場合
		 */
		public static function contains(arrayArg :Array, objArg :Object) :Boolean
		{
			//indexOf()を呼び出して配列に指定されたオブジェクトが含まれているかどうかを調べる
			//(戻り値が-1でない場合は含まれている)
			if(arrayArg.indexOf(objArg) !== -1)
			{
				//含まれているのでtrueを返す
				return true;
			}
			//indexOf()の戻り値が-1の場合
			else
			{
				//含まれているのでfalseを返す
				return false;
			}
		}
		
		/**
		 * 引数の配列の指定されたインデックスの要素を削除します。
		 * 削除された要素の後ろにある要素は詰められ、配列のサイズは1つ減ります。
		 * 無効なインデックスが指定された場合は、何もせずにnullを返します。
		 *
		 * @param arrayArg 処理対象の配列
		 * @param indexArg 削除する要素のインデックス
		 * @return 配列から削除されたオブジェクト(無効なインデックスが指定された場合はnull)
		 */
		public static function remove(arrayArg :Array, indexArg :Number) :Object
		{
			//無効なインデックスの場合
			if((indexArg < 0) || (indexArg >= arrayArg.length))
			{
				//nullを返して終了
				return null;
			}
			
			//削除対象の要素を取得
			var resultObj:Object = arrayArg[indexArg];
			
			//splice()を使って、インデックスの位置から1つ分要素を削除
			arrayArg.splice(indexArg, 1);
			
			//先ほど取得しておいた削除対象の要素を返す
			return resultObj;
		}
		
		/**
		 * 引数の配列に指定されたオブジェクトが含まれている場合は、最初に見つかった位置の要素を削除します。
		 * 削除された要素の後ろにある要素は詰められ、配列のサイズは1つ減ります。
		 * オブジェクトが含まれていない場合は、何もせずにfalseを返します。
		 *
		 * @param arrayArg 処理対象の配列
		 * @param objArg 削除対象のオブジェクト
		 * @return true=要素を削除した場合, false=オブジェクトが見つからず要素を削除しなかった場合
		 */
		public static function removeFirstObject(arrayArg :Array, objArg :Object) :Boolean
		{
			//indexOf()を呼び出して配列に指定されたオブジェクトが含まれているインデックスを取得
			var index:Number = arrayArg.indexOf(objArg);
			
			//オブジェクトが含まれていない場合
			if(index === -1)
			{
				//falseを返して終了
				return false;
			}
			
			//オブジェクトが見つかった位置の要素を削除する
			ArrayUtil.remove(arrayArg, index);
			
			//要素を削除したのでtrueを返す
			return true;
		}
		
		/**
		 * 引数の配列に指定されたオブジェクトが含まれている場合は、見つかった全ての要素を削除します。
		 * 削除された要素の後ろにある要素は詰められ、配列のサイズはその分減ります。
		 * オブジェクトが含まれていない場合は、何もせずにfalseを返します。
		 * (このメソッドは配列を空にするメソッドではありませんので注意して下さい。)
		 *
		 * @param arrayArg 処理対象の配列
		 * @param objArg 削除対象のオブジェクト
		 * @return true=要素を削除した場合, false=オブジェクトが見つからず要素を削除しなかった場合
		 */
		public static function removeAllObject(arrayArg :Array, objArg :Object) :Boolean
		{
			//要素を削除したかどうかのフラグ
			//(初期値はfalse)
			var resultFlag:Boolean = false;
			
			//オブジェクトが見つからなくなるまでループをまわし、配列内の一致するオブジェクトを全て削除する
			while(ArrayUtil.removeFirstObject(arrayArg, objArg))
			{
				//要素を削除したので、フラグをたてる
				resultFlag = true;
			}
			
			//要素を削除したかどうかのフラグを返す
			return resultFlag;
		}
		
		/**
		 * 引数の配列のクローンを作成して返します。
		 * このクローンはシャローコピーなので、配列内の要素のクローンまでは作成されません。
		 *
		 * @param arrayArg クローンを作成する配列
		 * @return クローンの配列
		 */
		public static function createClone(arrayArg :Array) :Array
		{
			//引数なしのslice()を使って配列のクローンを作成して、そのまま返す
			return arrayArg.slice();
		}
		
		/**
		 * 引数の２つの配列の内容が同じかどうかを返します。
		 * 両方の配列にnullが指定された場合はtrueを、どちらか一方のみにnullが指定された場合はfalseを返します。
		 *
		 * @param array1Arg 比較対象の配列1
		 * @param array1Arg 比較対象の配列2
		 * @return true=同じ内容の配列, false=違う内容の配列
		 */
		public static function arrayEquals(array1Arg :Array, array2Arg :Array) :Boolean
		{
			//同じインスタンスの場合
			//(nullとundefinedは同一視したいので、ここはあえて「===」ではなく「==」としています)
			if(array1Arg == array2Arg)
			{
				//絶対に同じ内容なのでtrueを返す
				return true;
			}
	
			//どちらか一方の配列がnullの場合
			if((array1Arg == null) || (array2Arg === null))
			{
				//同じでないのでfalseを返す
				return false;
			}
	
			//配列の長さが異なる場合
			if(array1Arg.length !== array2Arg.length)
			{
				//同じでないのでfalseを返す
				return false;
			}
			
			//配列1の要素数に応じてループをまわす
			for(var i:Number = 0; i < array1Arg.length; i++)
			{
				//違う要素が見つかった場合
				if(array1Arg[i] !== array2Arg[i])
				{
					//同じでないのでfalseを返す
					return false;
				}
			}
			
			//全てのチェックをくぐり抜けたのでtrueを返す
			return true;
		}
		
		/**
		 * オブジェクトの配列から指定されたフィールドの値だけを抽出し、配列として取得します。
		 * 
		 * @param array 対象の配列
		 * @param fieldName フィールド名
		 * @return 指定されたフィールドの値だけを抽出した配列
		 */
		public static function extractFieldArray(array :Array, fieldName :String) :Array
		{
			//結果を格納する配列
			var resultArray :Array = new Array();
			
			//引数の配列の全ての要素に対して処理を行う
			for each(var obj :Object in array)
			{
				//現在処理対象のオブジェクトに指定されたフィールドが存在しない場合
				if(obj[fieldName] === undefined)
				{
					//例外を投げる
					throw new Error("フィールド[" + fieldName + "]が存在しません");;
				}
			
				//現在処理対象のオブジェクトの指定されたフィールドの値を結果を格納する配列に追加する
				resultArray.push(obj[fieldName]);
			}

			//結果を格納する配列を返す
			return resultArray;
		}
		
		/**
		 * ツリー構造になっている配列をフラットな配列に変換します。
		 * 
		 * @param treeArray ツリー構造になっている配列
		 * @param childrenFieldName 子供の配列を格納するフィールド名(デフォルト値="children")
		 * @return フラットな配列
		 */
		public static function convertTreeArrayToFlat(treeArray :Array, childrenFieldName :String = "children") :Array
		{
			//引数のツリー構造になっている配列がnullまたは空配列の場合
			if(isBlank(treeArray))
			{
				//引数のツリー構造になっている配列の値をそのまま返す
				return treeArray;
			}
			
			//引数のツリー構造になっている配列の最初の要素に子供の配列を格納するフィールドが存在しない場合
			if(treeArray[0][childrenFieldName] === undefined)
			{
				//引数のツリー構造になっている配列の値をそのまま返す
				return treeArray;
			}
			
			//結果を格納する配列
			var resultArray :Array = new Array();
			
			//引数のツリー配列の全ての要素に対して処理を行う
			for each(var obj :Object in treeArray)
			{
				//配列に含まれるオブジェクトを基点として、再帰処理を行うメソッドを呼び出す
				convertTreeArrayToFlatRecursive(obj, childrenFieldName, resultArray);
			}
			
			//結果を格納する配列を返す
			return resultArray;
		}
		
		/**
		 * ツリー構造になっている配列に検索対象のオブジェクトが含まれているかどうかを返します。
		 * 
		 * @param treeArray ツリー構造になっている配
		 * @param obj 検索対象のオブジェクト
		 * @param childrenFieldName 子供の配列を格納するフィールド名(デフォルト値="children")
		 * @return true=オブジェクトが含まれている場合, false=オブジェクトが含まれていない場合
		 */
		public static function containsTreeArray(treeArray :Array, obj :Object, childrenFieldName :String = "children") :Boolean
		{
			//引数のツリー構造になっている配列がnullまたは空配列の場合
			if(isBlank(treeArray))
			{
				//一致する要素が見つからなかったとみなすのでfalseを返す
				return false;
			}
			
			//引数のツリー構造になっている配列の最初の要素に子供の配列を格納するフィールドが存在しない場合
			if(treeArray[0][childrenFieldName] === undefined)
			{
				//一致する要素が見つからなかったとみなすのでfalseを返す
				return false;
			}
			
			//引数のツリー配列の全ての要素に対して処理を行う
			for each(var child :Object in treeArray)
			{
				//配列に含まれるオブジェクトを基点として、再帰処理を行うメソッドを呼び出す
				var result :Boolean = containsTreeArrayRecursive(child, obj, childrenFieldName);
				
				//一致する要素が見つかった場合
				if(result)
				{
					//trueを返す
					return true;
				}
			}
			
			//最後まで一致する要素が見つからなかったのでfalseを返す
			return false;
		}
		
		/**
		 * ツリー構造になっている配列から対象のオブジェクトを削除します。
		 * オブジェクトが含まれていない場合は、何もせずにfalseを返します。
		 * 
		 * @param treeObj ツリー構造になっているオブジェクト
		 * @param obj 対象のオブジェクト
		 * @param childrenFieldName 子供の配列を格納するフィールド名(デフォルト値="children")
		 * @return true=要素を削除した場合, false=オブジェクトが見つからず要素を削除しなかった場合
		 */
		public static function removeObjectFromTreeArray(treeArray :Array, obj :Object, childrenFieldName :String = "children") :Boolean
		{
			//引数のツリー構造になっている配列がnullまたは空配列の場合
			if(isBlank(treeArray))
			{
				//一致する要素が見つからなかったとみなすのでfalseを返す
				return false;
			}
			
			
			//結果を格納する作業用変数
			var result :Boolean = false;
			
			//ツリー構造になっている配列から対象のオブジェクトを削除
			result = removeFirstObject(treeArray, obj)
			
			//要素の削除に成功した場合
			if(result)
			{
				//trueを返す
				return true;
			}

			//引数のツリー構造になっている配列の最初の要素に子供の配列を格納するフィールドが存在しない場合
			if(treeArray[0][childrenFieldName] === undefined)
			{
				//一致する要素が見つからなかったとみなすのでfalseを返す
				return false;
			}
			
			//引数のツリー配列の全ての要素に対して処理を行う
			for each(var child :Object in treeArray)
			{
				//配列に含まれるオブジェクトを基点として、再帰処理を行うメソッドを呼び出す
				result = removeObjectFromTreeArrayRecursive(child, obj, childrenFieldName);
				
				//要素の削除に成功した場合
				if(result)
				{
					//trueを返す
					return true;
				}
			}
			
			//最後まで要素が削除できなかったのでfalseを返す
			return false;
		}

		
		//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
		//内部処理用
		
		/**
		 * 再帰処理によりツリー構造になっている配列をフラットな配列に変換します。
		 * 
		 * @param obj 現在の処理対象のオブジェクト
		 * @param childrenFieldName 子供の配列を格納するフィールド名
		 * @param resultArray 結果を格納する配列
		 */
		private static function convertTreeArrayToFlatRecursive(obj :Object, childrenFieldName :String, resultArray :Array) :void
		{
			//結果を格納する配列に現在の処理対象のオブジェクトを追加する
			resultArray.push(obj);
			
			//子供の配列を取得
			var children :Array = obj[childrenFieldName] as Array;
			
			//子供の配列が存在する場合
			if(!isBlank(children))
			{
				//子供の配列の全ての要素に対して処理を行う
				for each(var child :Object in children)
				{
					//子供の配列に含まれるオブジェクトを基点として、再帰的にこのメソッドを呼び出す
					convertTreeArrayToFlatRecursive(child, childrenFieldName, resultArray);
				}
			}
			
		}

		/**
		 * 再帰処理によりツリー構造になっている配列に検索対象のオブジェクトが含まれているかどうかを返します。
		 * 
		 * @param treeObj ツリー構造になっているオブジェクト
		 * @param obj 検索対象のオブジェクト
		 * @param childrenFieldName 子供の配列を格納するフィールド名
		 * @return true=オブジェクトが含まれている場合, false=オブジェクトが含まれていない場合
		 */
		private static function containsTreeArrayRecursive(treeObj :Object, obj :Object, childrenFieldName :String) :Boolean
		{
			//ツリー構造になっているオブジェクトと検索対象のオブジェクトが一致する場合
			if(treeObj == obj)
			{
				//trueを返す
				return true;
			}
			
			//ツリー構造になっているオブジェクトの子供の配列を取得
			var children :Array = treeObj[childrenFieldName] as Array;
			
			//子供の配列が存在する場合
			if(!isBlank(children))
			{
				//子供の配列の全ての要素に対して処理を行う
				for each(var child :Object in children)
				{
					//子供の配列に含まれるオブジェクトを基点として、再帰的にこのメソッドを呼び出す
					var result :Boolean = containsTreeArrayRecursive(child, obj, childrenFieldName);
					
					//一致する要素が見つかった場合
					if(result)
					{
						//trueを返す
						return true;
					}
				}
			}
			
			//最後まで一致する要素が見つからなかったのでfalseを返す
			return false;
		}

		/**
		 * 再帰処理によりツリー構造になっている配列から対象のオブジェクトを削除します。
		 * オブジェクトが含まれていない場合は、何もせずにfalseを返します。
		 * 
		 * @param treeObj ツリー構造になっているオブジェクト
		 * @param obj 対象のオブジェクト
		 * @param childrenFieldName 子供の配列を格納するフィールド名
		 * @return true=要素を削除した場合, false=オブジェクトが見つからず要素を削除しなかった場合
		 */
		private static function removeObjectFromTreeArrayRecursive(treeObj :Object, obj :Object, childrenFieldName :String) :Boolean
		{
			//結果を格納する作業用変数
			var result :Boolean = false;

			//ツリー構造になっているオブジェクトの子供の配列を取得
			var children :Array = treeObj[childrenFieldName] as Array;
			
			//子供の配列が存在する場合
			if(!isBlank(children))
			{
				//子供の配列から対象のオブジェクトを削除
				result = removeFirstObject(children, obj)
				
				//要素の削除に成功した場合
				if(result)
				{
					//trueを返す
					return true;
				}
					
				//子供の配列の全ての要素に対して処理を行う
				for each(var child :Object in children)
				{
					//子供の配列に含まれるオブジェクトを基点として、再帰的にこのメソッドを呼び出す
					result = removeObjectFromTreeArrayRecursive(child, obj, childrenFieldName);
					
					//要素の削除に成功した場合
					if(result)
					{
						//trueを返す
						return true;
					}
				}
			}
			
			//最後まで要素が削除できなかったのでfalseを返す
			return false;
		}

	}
}
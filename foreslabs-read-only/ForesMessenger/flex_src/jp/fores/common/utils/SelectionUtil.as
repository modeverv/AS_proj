package jp.fores.common.utils
{
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	import jp.fores.common.controls.CheckTreeRenderer;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.controls.CheckBox;
	import mx.controls.ComboBox;
	import mx.controls.List;
	import mx.controls.RadioButton;
	import mx.controls.RadioButtonGroup;
	import mx.events.ListEvent;
	
	/**
	 * 選択用コンポーネントの選択状態制御用ユーティリティクラス。
	 */
	public class SelectionUtil
	{
		//==========================================================
		//メソッド
		
		//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
		//クラスメソッド
		
		/**
		 * コンボボックスの選択状態を変化させます。
		 * 
		 * @param comboBox 対象のコンボボックス
		 * @param selectTargetObject 選択状態にする対象のオブジェクト
		 * @param comboBoxFieldName コンボボックスの比較基準にするフィールド名(指定しない場合はオブジェクト自体を基準にして比較します)
		 * @param selectTargetObjectFieldName 選択状態にする対象のオブジェクトの比較基準にするフィールド名(指定しない場合はオブジェクト自体を基準にして比較します)
		 * @return true=一致する値が見つかった場合, false=一致する値が見つからなかった場合
		 */
		public static function selectComboBox(comboBox :ComboBox, selectTargetObject :Object, comboBoxFieldName :String = null, selectTargetObjectFieldName :String = null) :Boolean
		{
			//コンボボックスのデータプロバイダがArrayCollectionでない場合
			if(!(comboBox.dataProvider is ArrayCollection))
			{
				//例外を投げる
				throw new Error("データプロバイダがArrayCollection以外の場合、このメソッドは使用できません");
			}
			
			//選択状態にする対象の値を取得
			//(初期値には引数の選択状態にする対象のオブジェクトを設定)
			var selectTargetValue :Object = getTargetValue(selectTargetObject, selectTargetObjectFieldName);
			
			//コンボボックスのデータプロバイダをArrayCollectionにキャストして取得
			var dataProvider :ArrayCollection = comboBox.dataProvider as ArrayCollection;
			
			//コンボボックスの現在の選択インデックスを取得
			var originalSelectedIndex :int = comboBox.selectedIndex;
			
			
			//データプロバイダに対してループをまわす
			for (var i :int = 0; i < dataProvider.length; i++)
			{
				//データプロバイダの現在の要素の対象の値を取得
				var dataProviderTargetValue :Object = getTargetValue(dataProvider[i], comboBoxFieldName);
				
				//データプロバイダの現在の要素の対象の値と選択状態にする対象の値が一致する場合
				if(dataProviderTargetValue == selectTargetValue)
				{
					//コンボボックスの選択インデックスに現在のインデックスを設定
					comboBox.selectedIndex = i;
					
					//コンボボックスの選択インデックスが変化した場合
					if(comboBox.selectedIndex != originalSelectedIndex)
					{
						//コンボボックスの変更イベントを投げる
						comboBox.dispatchEvent(new ListEvent(ListEvent.CHANGE));
					}
					
					//一致する値が見つかったのでtrueを返す
					return true;
				}
			}
			
			//コンボボックスの選択インデックスに-1を設定
			//(未選択状態にする)
			comboBox.selectedIndex = -1;
			
			//コンボボックスの選択インデックスが変化した場合
			if(comboBox.selectedIndex != originalSelectedIndex)
			{
				//コンボボックスの変更イベントを投げる
				comboBox.dispatchEvent(new ListEvent(ListEvent.CHANGE));
			}
			
			//一致する値が見つからなかったのでfalseを返す
			return false;
		}
	
		/**
		 * リストの選択状態を変化させます。
		 * 
		 * @param list 対象のリスト
		 * @param selectTargetObject 選択状態にする対象のオブジェクト
		 * @param listFieldName リストの比較基準にするフィールド名(指定しない場合はオブジェクト自体を基準にして比較します)
		 * @param selectTargetObjectFieldName 選択状態にする対象のオブジェクトの比較基準にするフィールド名(指定しない場合はオブジェクト自体を基準にして比較します)
		 * @return true=一致する値が見つかった場合, false=一致する値が見つからなかった場合
		 */
		public static function selectList(list :List, selectTargetObject :Object, listFieldName :String = null, selectTargetObjectFieldName :String = null) :Boolean
		{
			//リストのデータプロバイダがArrayCollectionでない場合
			if(!(list.dataProvider is ArrayCollection))
			{
				//例外を投げる
				throw new Error("データプロバイダがArrayCollection以外の場合、このメソッドは使用できません");
			}
			
			//選択状態にする対象の値を取得
			//(初期値には引数の選択状態にする対象のオブジェクトを設定)
			var selectTargetValue :Object = getTargetValue(selectTargetObject, selectTargetObjectFieldName);
			
			//リストのデータプロバイダをArrayCollectionにキャストして取得
			var dataProvider :ArrayCollection = list.dataProvider as ArrayCollection;
			
			//リストの現在の選択インデックスを取得
			var originalSelectedIndex :int = list.selectedIndex;
			
			
			//データプロバイダに対してループをまわす
			for (var i :int = 0; i < dataProvider.length; i++)
			{
				//データプロバイダの現在の要素の対象の値を取得
				var dataProviderTargetValue :Object = getTargetValue(dataProvider[i], listFieldName);
				
				//データプロバイダの現在の要素の対象の値と選択状態にする対象の値が一致する場合
				if(dataProviderTargetValue == selectTargetValue)
				{
					//リストの選択インデックスに現在のインデックスを設定
					list.selectedIndex = i;
					
					//リストの選択インデックスが変化した場合
					if(list.selectedIndex != originalSelectedIndex)
					{
						//リストの変更イベントを投げる
						list.dispatchEvent(new ListEvent(ListEvent.CHANGE));
					}
					
					//一致する値が見つかったのでtrueを返す
					return true;
				}
			}
			
			//リストの選択インデックスに-1を設定
			//(未選択状態にする)
			list.selectedIndex = -1;
			
			//リストの選択インデックスが変化した場合
			if(list.selectedIndex != originalSelectedIndex)
			{
				//リストの変更イベントを投げる
				list.dispatchEvent(new ListEvent(ListEvent.CHANGE));
			}
			
			//一致する値が見つからなかったのでfalseを返す
			return false;
		}
	
		/**
		 * ラジオボタンの選択状態を変化させます。
		 * 
		 * @param radioButtonGroup 対象のラジオボタングループ
		 * @param selectTargetObject 選択状態にする対象のオブジェクト
		 * @param radioButtonFieldName ラジオボタンの比較基準にするフィールド名(デフォルト値="label") (指定しない場合はオブジェクト自体を基準にして比較します)
		 * @param selectTargetObjectFieldName 選択状態にする対象のオブジェクトの比較基準にするフィールド名(指定しない場合はオブジェクト自体を基準にして比較します)
		 * @return true=一致する値が見つかった場合, false=一致する値が見つからなかった場合
		 */
		public static function selectRadioButton(radioButtonGroup :RadioButtonGroup, selectTargetObject :Object, radioButtonFieldName :String = "label", selectTargetObjectFieldName :String = null) :Boolean
		{
			//選択状態にする対象の値を取得
			//(初期値には引数の選択状態にする対象のオブジェクトを設定)
			var selectTargetValue :Object = getTargetValue(selectTargetObject, selectTargetObjectFieldName);
			
			//ラジオボタングループの現在選択されているラジオボタンへの参照を取得
			var originalSelection :RadioButton = radioButtonGroup.selection;
			
			
			//ラジオボタングループに属するラジオボタンに対してループをまわす
			for (var i :int = 0; i < radioButtonGroup.numRadioButtons; i++)
			{
				//インデックスに対応するラジオボタンを取得
				var radioButton :RadioButton = radioButtonGroup.getRadioButtonAt(i);
				
				//現在のラジオボタンの対象の値を取得
				var radioButtonTargetValue :Object = getTargetValue(radioButton, radioButtonFieldName);
				
				//現在のラジオボタンの対象の値と選択状態にする対象の値が一致する場合
				if(radioButtonTargetValue == selectTargetValue)
				{
					//ラジオボタングループの選択対象を現在のラジオボタンに変更
					radioButtonGroup.selection = radioButton;
					
					//ラジオボタングループの選択対象が変化した場合
					if(radioButtonGroup.selection != originalSelection)
					{
						//ラジオボタングループの変更イベントを投げる
						radioButtonGroup.dispatchEvent(new Event(Event.CHANGE));
					}
					
					//一致する値が見つかったのでfalseを返す
					return true;
				}
			}
			
			//ラジオボタングループの選択対象にnullを設定
			//(未選択状態にする)
			radioButtonGroup.selection = null;
			
			//ラジオボタングループの選択対象が変化した場合
			if(radioButtonGroup.selection != originalSelection)
			{
				//ラジオボタングループの変更イベントを投げる
				radioButtonGroup.dispatchEvent(new Event(Event.CHANGE));
			}
			
			//一致する値が見つからなかったのでfalseを返す
			return false;
		}
	
		/**
		 * チェックボックスの選択状態を変化させます。
		 * 
		 * @param checkBox 対象のチェックボックス
		 * @param selectTargetObjectArray 選択状態にする対象のオブジェクトの配列
		 * @param checkBoxFieldName チェックボックスの比較基準にするフィールド名(デフォルト値="label") (指定しない場合はオブジェクト自体を基準にして比較します)
		 * @param selectTargetObjectFieldName 選択状態にする対象のオブジェクトの比較基準にするフィールド名(指定しない場合はオブジェクト自体を基準にして比較します)
		 * @return true=一致する値が見つかった場合, false=一致する値が見つからなかった場合
		 */
		public static function selectCheckBox(checkBox :CheckBox, selectTargetObjectArray :Array, checkBoxFieldName :String = "label", selectTargetObjectFieldName :String = null) :Boolean
		{
			//チェックボックスの選択状態を取得
			var originalSelected :Boolean = checkBox.selected;
			
			//チェックボックスの対象の値を取得
			var checkBoxTargetValue :Object = getTargetValue(checkBox, checkBoxFieldName);
			
			//選択状態にする対象のオブジェクトの配列に対してループをまわす
			for each(var selectTargetObject :Object in selectTargetObjectArray)
			{
				//選択状態にする対象の値を取得
				//(初期値には引数の選択状態にする対象のオブジェクトを設定)
				var selectTargetValue :Object = getTargetValue(selectTargetObject, selectTargetObjectFieldName);
				
				//チェックボックスの対象の値と選択状態にする対象の値が一致する場合
				if(checkBoxTargetValue == selectTargetValue)
				{
					//チェックボックスを選択状態にする
					checkBox.selected = true;
					
					//チェックボックスの選択対象が変化した場合
					if(checkBox.selected != originalSelected)
					{
						//チェックボックスの変更イベントを投げる
						checkBox.dispatchEvent(new Event(Event.CHANGE));
					}
					
					//一致する値が見つかったのでtrueを返す
					return true;
				}
			}
			
			//チェックボックスを未選択状態にする
			checkBox.selected = false;
			
			//チェックボックスの選択対象が変化した場合
			if(checkBox.selected != originalSelected)
			{
				//チェックボックスの変更イベントを投げる
				checkBox.dispatchEvent(new Event(Event.CHANGE));
			}
			
			//一致する値が見つからなかったのでfalseを返す
			return false;
		}
	
		/**
		 * 複数のチェックボックスの選択状態を一括で変化させます。
		 * 
		 * @param checkBoxArray 対象のチェックボックスの配列
		 * @param selectTargetObjectArray 選択状態にする対象のオブジェクトの配列
		 * @param checkBoxFieldName チェックボックスの比較基準にするフィールド名(デフォルト値="label") (指定しない場合はオブジェクト自体を基準にして比較します)
		 * @param selectTargetObjectFieldName 選択状態にする対象のオブジェクトの比較基準にするフィールド名(指定しない場合はオブジェクト自体を基準にして比較します)
		 */
		public static function selectCheckBoxArray(checkBoxArray :Array, selectTargetObjectArray :Array, checkBoxFieldName :String = "label", selectTargetObjectFieldName :String = null) :void
		{
			//対象のチェックボックスの配列の全ての要素に対して処理を行う
			for each(var checkBox :CheckBox in checkBoxArray)
			{
				//実際に処理を行うメソッドを呼び出す
				selectCheckBox(checkBox, selectTargetObjectArray, checkBoxFieldName, selectTargetObjectFieldName);
			}
		}
	
		/**
		 * チェックボックス付きツリー表示用の配列の選択状態を変化させます。
		 * 子要素が選択状態の場合は、親要素も選択状態になるようにします。
		 * 
		 * @param treeArray 対象のツリー表示用の配列
		 * @param selectTargetObjectArray 選択状態にする対象のオブジェクトの配列
		 * @param treeArrayFieldName ツリー表示用の配列の比較基準にするフィールド名(指定しない場合はオブジェクト自体を基準にして比較します)
		 * @param selectTargetObjectFieldName 選択状態にする対象のオブジェクトの比較基準にするフィールド名(指定しない場合はオブジェクト自体を基準にして比較します)
		 * @param stateFieldName チェック状態を保持するためのフィールド名(デフォルト値="checkState")
		 */
		public static function selectCheckBoxTree(treeArray :Array, selectTargetObjectArray :Array, treeArrayFieldName :String = null, selectTargetObjectFieldName :String = null, stateFieldName :String = "checkState") :void
		{
			//ツリー表示用の配列をフラットな配列に変換
			var flatArray :Array = ArrayUtil.convertTreeArrayToFlat(treeArray);
			
			//親子関係を登録するためのDictionary
			//(オブジェクトをキーに使用するので、Mapは使えないので代わりにDictionaryを使用する)
			var parentDictionary :Dictionary = new Dictionary();
			
			
			//ツリー表示用のフラットな配列に対してループをまわす
			for each(var treeObject :Object in flatArray)
			{
				//ツリー表示用のオブジェクトのチェック状態を保持するためのフィールドの値を未選択状態にする
				treeObject[stateFieldName] = CheckTreeRenderer.STATE_UNCHECKED;
				
				//配下の要素の配列を取得
				var children :Array = treeObject["children"] as Array;
				
				//配下の要素の配列が存在する場合
				if(!ArrayUtil.isBlank(children))
				{
					//配下の要素の配列の全ての要素に対して処理を行う
					for each(var child :Object in children)
					{
						//親子関係を登録するためのDictionaryに追加する
						parentDictionary[child] = treeObject;
					}
				}
				
				
				//ツリー表示用のオブジェクトの対象の値を取得
				var treeTargetValue :Object = getTargetValue(treeObject, treeArrayFieldName);
			
				//選択状態にする対象のオブジェクトの配列に対してループをまわす
				for each(var selectTargetObject :Object in selectTargetObjectArray)
				{
					//選択状態にする対象の値を取得
					//(初期値には引数の選択状態にする対象のオブジェクトを設定)
					var selectTargetValue :Object = getTargetValue(selectTargetObject, selectTargetObjectFieldName);
					
					//チェックボックスの対象の値と選択状態にする対象の値が一致する場合
					if(treeTargetValue == selectTargetValue)
					{
						//ツリー表示用のオブジェクトのチェック状態を保持するためのフィールドの値を選択状態にする
						treeObject[stateFieldName] = CheckTreeRenderer.STATE_CHECKED;
						
						
						//==========================================================
						//親要素も選択状態にする
						
						//現在処理対象の要素
						var currentItem :Object = treeObject;
						
						//現在処理対象の要素に親要素が存在する場合
						while(parentDictionary[currentItem] != null)
						{
							//親要素を取得して、現在処理対象の要素を置き換える
							currentItem = parentDictionary[currentItem];
							
							//現在処理対象の要素のツリー表示用のオブジェクトのチェック状態を保持するためのフィールドの値を選択状態にする
							currentItem[stateFieldName] = CheckTreeRenderer.STATE_CHECKED;
						}
						//==========================================================
						
						//内側のループを抜ける
						break;
					}
				}
			}
		}
	
		/**
		 * チェックボックス付きツリー表示用の配列の選択されている要素のみを抽出した配列を取得します。
		 * デフォルトでは末端の要素だけを対象とします。
		 * 
		 * @param treeArray 対象のツリー表示用の配列
		 * @param isLeafOnly 末端の要素だけを対象とするかどうかのフラグ(デフォルト値=true)
		 * @param stateFieldName チェック状態を保持するためのフィールド名(デフォルト値="checkState")
		 * @return 選択されている要素のみを抽出した配列
		 */
		public static function extractCheckBoxTreeCheckedObjectArray(treeArray :Array, isLeafOnly :Boolean = true, stateFieldName :String = "checkState") :Array
		{
			//ツリー表示用の配列をフラットな配列に変換
			var flatArray :Array = ArrayUtil.convertTreeArrayToFlat(treeArray);
			
			//結果を格納する配列
			var resultArray :Array = new Array();
			
			//ツリー表示用のフラットな配列に対してループをまわす
			for each(var treeObject :Object in flatArray)
			{
				//末端の要素だけを対象とするフラグがたっていて、配下の要素が存在する場合
				if(isLeafOnly && (treeObject["children"] != null))
				{
					//対象外なので、次の要素に処理を進める
					continue;
				}
				
				//現在処理対象のオブジェクトのチェック状態を保持するためのフィールドの値が選択状態の場合
				if(treeObject[stateFieldName] == CheckTreeRenderer.STATE_CHECKED)
				{
					//現在処理対象のオブジェクトを結果を格納する配列に追加する
					resultArray.push(treeObject);
				}
			}

			//結果を格納する配列を返す
			return resultArray;
		}
	
		
		//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
		//内部処理用
		
		/**
		 * 対象のオブジェクトとフィールド名から対象の値を取得します。
		 * 対象のオブジェクトがnullの場合は、nullを返します。
		 * フィールド名が指定されていない場合は、対象のオブジェクトの値をそのまま返します。
		 * フィールド名が指定されている場合は、対象のオブジェクトの指定されたフィールドの値を返します。
		 * 対象のオブジェクトに指定されたフィールドが存在しない場合は、例外を投げます。
		 * 
		 * @param obj 対象のオブジェクト
		 * @param fieldName フィールド名
		 * @return 対象の値
		 */
		private static function getTargetValue(obj :Object, fieldName :String) :Object
		{
			//対象のオブジェクトがnullの場合
			if(obj == null) 
			{
				//nullを返す
				return null;
			}
			
			//フィールド名が指定されていない場合
			if(fieldName == null)
			{
				//対象のオブジェクトの値をそのまま返す
				return obj;
			}
			
			//対象のオブジェクトの該当するフィールドが存在しない場合
			if(obj[fieldName] === undefined)
			{
				//例外を投げる
				throw new Error("対象のオブジェクトに該当するフィールドが存在しません。 対象のオブジェクト[" + obj + "], フィールド名[" + fieldName + "]");
			}
			
			//対象のオブジェクトの該当するフィールドの値を返す
			return obj[fieldName];
		}
	}
}
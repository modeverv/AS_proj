package jp.fores.common.controls
{
	import flash.events.MouseEvent;
	import flash.xml.*;
	
	import mx.collections.*;
	import mx.controls.CheckBox;
	import mx.controls.Tree;
	import mx.controls.listClasses.*;
	import mx.controls.treeClasses.*;
	
	/**
	 * チェックボックス付きのツリーを表示するためのレンダラー。
	 * このクラスを使用するためには、データ側にチェック状態を保持するためのフィールド(デフォルトではstate)を
	 * 用意しておく必要があります。
	 */
	public class CheckTreeRenderer extends TreeItemRenderer
	{
		//==========================================================
		//定数
		
		/**
		 * 選択状態の値
		 */
		public static const STATE_CHECKED :Boolean = true;

		/**
		 * 選択されていない状態の値
		 */
		public static const STATE_UNCHECKED :Boolean = false;
		
		
		//==========================================================
		//フィールド
		
		/**
		 * 選択状態を保持するためのフィールド名
		 */
		[Inspectable(default="checkState")]
		public var stateField :String = "checkState";
		
		/**
		 * 配下の要素が全て未選択になった場合に親要素のチェックを外すかどうかのフラグ
		 */
		[Inspectable(default=true)]
		public var isAutoUnCheckedParent :Boolean = true;
		
		//チェック状態表示用のチェックボックス
		protected var myCheckBox :CheckBox;
		
		
		//==========================================================
		//メソッド
		
		/**
		 * コンストラクタです。
		 */
		public function CheckTreeRenderer()
		{
			//親クラスのコンストラクタの呼び出し
			super();
			
			//マウスを無効にする
			super.mouseEnabled = false;
		}


		//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
		//オーバーライドするメソッド

		/**
		 * データを設定します。
		 * 
		 * @param value 値
		 */
		override public function set data(value :Object):void
		{
			//親クラスの処理を先に呼び出す
			super.data = value;
			
			//値が指定されていない場合、またはチェック状態を保持するためのフィールドが存在しない場合
			if((super.data == null) || (super.data[this.stateField] == undefined))
			{
				//チェックボックスを選択されていない状態にする
				this.myCheckBox.selected = false;
				
				//以降の処理を行わない
				return;
			}
			
			//チェック状態を保持するためのフィールドの値が選択状態の値の場合
			if (super.data[this.stateField] == STATE_CHECKED)
			{
				//チェックボックスを選択状態にする
				this.myCheckBox.selected = true;
			}
			//それ以外の場合
			else
			{
				//チェックボックスを選択されていない状態にする
				this.myCheckBox.selected = false;

				//チェック状態を保持するためのフィールドの値に選択されていない状態の値を設定する
				super.data[this.stateField] = STATE_UNCHECKED;
			}
		}

		/**
		 * コンポーネントの子オブジェクトを作成します。
		 */
		override protected function createChildren() :void
		{
			//親クラスの処理を先に呼び出す
			super.createChildren();
			
			//チェックボックスを作成して自分自身に追加
			this.myCheckBox = new CheckBox();
			myCheckBox.setStyle("verticalAlign", "middle");
			myCheckBox.addEventListener(MouseEvent.CLICK, onClickCheckBox);
			super.addChild(myCheckBox);
		}

		/**
		 * オブジェクトの描画およびその子のサイズや位置の設定を行います。
		 * 
		 * @param unscaledWidth コンポーネントの scaleX プロパティの値にかかわらず、コンポーネントの座標内でピクセル単位によりコンポーネントの幅を指定します。
		 * @param unscaledHeight コンポーネントの scaleY プロパティの値にかかわらず、コンポーネントの座標内でピクセル単位でコンポーネントの高さを指定します。
		 */
		override protected function updateDisplayList(unscaledWidth :Number, unscaledHeight :Number) :void
		{
			//親クラスの処理を先に呼び出す
			super.updateDisplayList(unscaledWidth, unscaledHeight);

			//データが存在する場合
			if(super.data)
			{
				//==========================================================
				//アイコンの有無で表示位置を微調整する
				if (super.icon != null)
				{
					this.myCheckBox.x = super.icon.x;
					this.myCheckBox.y = super.height / 2;
					super.icon.x = myCheckBox.x + 17;
					super.label.x = super.icon.x + super.icon.width + 3;
				}
				else
				{
					myCheckBox.x = super.label.x;
					myCheckBox.y = super.height / 2;
					super.label.x = myCheckBox.x + 17;
				}
			}
		}

		//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
		//内部処理用
		
		/**
		 * このレンダラーが対象としているTreeオブジェクトを取得します。
		 * 
		 * @return Treeオブジェクト
		 */
		private function get targetTree() :Tree
		{
			//リストデータのオーナーをキャストして返す
			return super.listData.owner as Tree;
		}

		/**
		 * チェックボックスがクリックされた場合のイベント処理を行います。
		 * 
		 * @param event イベントオブジェクト
		 */
		private function onClickCheckBox(event :MouseEvent = null):void
		{
			//データが存在しない場合
			if (super.data == null)
			{
				//以降の処理を行わない
				return;
			}
			
			//チェックボックスが選択されている場合
			if(this.myCheckBox.selected)
			{
				//配下の要素も含めて選択状態にする
				toggleChildren(super.data, STATE_CHECKED);
			}
			//チェックボックスが選択されていない場合
			else
			{
				//配下の要素も含めて選択されていない状態にする
				toggleChildren(super.data, STATE_UNCHECKED);
			}

			//親の要素を取得
			var parent :Object = this.targetTree.getParentItem(super.data);
			
			//親の要素の選択状態を再帰的に変化させる
			toggleParents(parent, getChildSelectedState(parent));
		}

		/**
		 * 配下の要素の選択状態を再帰的に変化させます。
		 * 
		 * @param item 対象の要素
		 * @param state 選択状態
		 */
		private function toggleChildren(item :Object, state :Boolean) :void
		{
			//対象の要素がnullの場合
			if (item == null)
			{
				//以降の処理を行わない
				return;
			}

			//対象の要素の選択状態を保持するためのフィールドに引数の値を設定する
			item[this.stateField] = state;


			//==========================================================
			//配下の要素が存在する場合は、再帰的に処理を呼び出す
			
			//配下の要素が存在する場合
			var treeData:ITreeDataDescriptor = this.targetTree.dataDescriptor;
			if(treeData.hasChildren(item))
			{
				//ツリーの各要素にループをまわすためのカーソルを取得
				var cursor:IViewCursor = treeData.getChildren(item).createCursor();

				//カーソルの最後までループを回す
				while(!cursor.afterLast)
				{
					//配下の要素に対して、自分自身のメソッドを再帰的に呼び出す
					toggleChildren(cursor.current, state);

					//カーソルを進める
					cursor.moveNext();
				}
			}
		}
		
		/**
		 * 親の要素の選択状態を再帰的に変化させます。
		 * 
		 * @param item 対象の要素
		 * @param state 選択状態
		 */
		private function toggleParents(item :Object, state :Boolean) :void
		{
			//対象の要素がnullの場合
			if (item == null)
			{
				//以降の処理を行わない
				return;
			}

			//フィールドの配下の要素が全て未選択になった場合に親要素のチェックを外すかどうかのフラグがOFFで、選択されていない状態の場合
			if(!this.isAutoUnCheckedParent && (state == STATE_UNCHECKED))
			{
				//親要素のチェックは外さないので以降の処理を行わない
				return;
			}

			
			//対象の要素の選択状態を保持するためのフィールドに引数の値を設定する
			item[this.stateField] = state;
			
			//親の要素を取得
			var parent :Object = this.targetTree.getParentItem(item);
			
			//親の要素に対して、自分自身のメソッドを再帰的に呼び出す
			toggleParents(parent, getChildSelectedState(parent));
		}
		
		/**
		 * 指定された親要素の配下の要素の選択状態を取得します。
		 * 1つでも選択されている要素が存在する場合は選択状態と見なします
		 * 
		 * @param parent 親要素
		 * @return 選択状態
		 */
		private function getChildSelectedState(parent :Object) :Boolean
		{
			//引数の親要素がnullの場合
			if (parent == null)
			{
				//選択されていないと見なす
				return STATE_UNCHECKED;
			}

			//ツリーの各要素にループをまわすためのカーソルを取得
			var treeData :ITreeDataDescriptor = this.targetTree.dataDescriptor;
			var cursor :IViewCursor = treeData.getChildren(parent).createCursor();

			//カーソルの最後までループを回す
			while(!cursor.afterLast)
			{
				//カーソルの現在の要素の選択状態を保持するためのフィールドの値が選択状態の定数と一致する場合
				if (cursor.current[this.stateField] == STATE_CHECKED)
				{
					//選択状態と見なす
					return STATE_CHECKED;
				}
				
				//カーソルを進める
				cursor.moveNext();
			}

			//最後まで選択状態の要素が見つからなかったので、選択されていないと見なす
			return STATE_UNCHECKED;
		}
		
	}
}
package jp.fores.common.controls
{
	import mx.collections.ArrayCollection;
	import mx.collections.ICollectionView;
	import mx.collections.IList;
	import mx.collections.ListCollectionView;
	import mx.core.UIComponent;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	import mx.containers.VBox;
	import mx.containers.HBox;
	import mx.controls.ToggleButtonBar;
	import mx.controls.Button;
	import flash.events.Event;
	import mx.controls.Spacer;
	import mx.events.ItemClickEvent;
	import flash.events.MouseEvent;
	import mx.events.FlexEvent;
	import mx.styles.ISimpleStyleClient;
	import mx.effects.AnimateProperty;
	import mx.controls.Alert;
	
	//表示ページが変更されたときのイベント
	[Event(name="changePage", type="flash.events.Event")]

	/**
	 * ページ切り替え機能用の汎用コントローラー。
	 */
	[Bindable]
	public class PageController extends VBox
	{
		//==========================================================
		//フィールド
		
		/**
		 * 現在のページに表示する対象のデータ
		 */
		private var _pageData :ArrayCollection = new ArrayCollection();
		
		/**
		 * 対象データの総件数
		 */
		private var _totalCount :int = 0;

		/**
		 * 現在表示しているページ番号
		 */
		private var _currentPage :int = 1;

		/**
		 * 1ページあたりの表示件数(デフォルト=20)
		 */
		private var _perPage :int = 20;

		/**
		 * ページ切り替えのボタンの表示有無(デフォルト=true)
		 */
		private var _isDisplayButton :Boolean = true;

		/**
		 * ページ切り替えのボタンの表示位置(デフォルト="center")
		 */
		private var _pageChangeButtonAlign :String = "center";

		/**
		 * ページ切り替えのボタンを表示する数(デフォルト=10)
		 */
		private var _pageChangeButtonCount :int = 10;

		/**
		 * ページ切り替えのボタンの幅(デフォルト=40)
		 */
		private var _pageChangeButtonWidth :int = 40;

		/**
		 * ページ切り替えのボタンのスクロールの際のエフェクトの有無(デフォルト=true)
		 */
		private var _isEnablePageScrollEffect :Boolean = true;

		/**
		 * ページ切り替えのボタンのスクロールの際のエフェクトの継続時間(ミリ秒単位)(デフォルト=500)
		 */
		private var _pageScrollEffectDuration :int = 500;

		/**
		 * ページ情報が変化したときに呼び出されるコールバック関数
		 */
		private var _callBackFuction :Function = null;

		/**
		 * 内部処理用のコレクション
		 */
		private var collection :ICollectionView = null;
		
		/**
		 * メインのHBox
		 */
		private var mainHBox :HBox = null;
		
		/**
		 * 左側のボタンを束ねるHBox
		 */
		private var leftHBox :HBox = null;
		
		/**
		 * 右側のボタンを束ねるHBox
		 */
		private var rightHBox :HBox = null;
		
		/**
		 * 真ん中のボタンを束ねるToggleButtonBar
		 */
		private var centerToggleButtonBar :ToggleButtonBar = null;
		
		/**
		 * ページボタンスクロール用のエフェクト
		 */
		private var scrollEffect :AnimateProperty = null;
		
		/**
		 * 最初のページに戻るボタン
		 */
		private var firstPageButton :Button = null;
		
		/**
		 * 前のページに戻るボタン
		 */
		private var prevPageButton :Button = null;
		
		/**
		 * 次のページに進むボタン
		 */
		private var nextPageButton :Button = null;
		
		/**
		 * 最後のページに進むボタン
		 */
		private var lastPageButton :Button = null;
		
		/**
		 * ページの表示範囲の開始インデックス
		 */
		private var startIndex :int = 1;
			
		/**
		 * ページの表示範囲の終了インデックス
		 */
		private var endIndex :int = 1;
		
		
		//==========================================================
		//メソッド
		
		//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
		//コンストラクタ
		
		/**
		 * コンストラクタです。
		 */
		public function PageController()
		{
			//親クラスのコンストラクタを先に呼び出す
			super();
			
			//==========================================================
			//内部に表示するコンポーネントの設定
			
			//内部に表示するコンポーネントを初期化
			initInternalComponent();
			
			//内部に表示するコンポーネントを再構築
			rebuildInternalComponent();
		}
		
		//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
		//Getter, Setter
		
		[Inspectable(defaultValue=0)]
		/**
		 * 対象データの総件数を設定します。
		 * 
		 * @param num 対象データの総件数
		 */
		public function set totalCount(num :int) :void
		{
			//引数の値をフィールドに設定
			this._totalCount = num;

			//真ん中のToggleButtonBarに表示するボタンのデータを再計算
			refreshToggleButtonBar();
			
			//現在のページが総ページ数を超えてしまう場合
			//(このチェックを行うのは、currentPageのSetterで行う処理と同じ処理が重複して行われないようにするため)
			if(this.currentPage > this.totalPage)
			{
				//現在のページに総ページ数を設定
				this.currentPage = this.totalPage;
			}
			//それ以外の場合
			else
			{
				//表示するボタンの情報を設定
				setButtonStatus();
			}
		}
		
		/**
		 * 対象データの総件数を取得します。
		 * 
		 * @return 対象データの総件数
		 */
		public function get totalCount() :int
		{
			//フィールドの値を返す
			return this._totalCount;
		}
		
		[Inspectable(defaultValue=1)]
		/**
		 * 現在表示しているページ番号を設定します。
		 * 
		 * @param num ページ番号
		 */
		public function set currentPage(num :int) :void
		{
			//引数のページ番号に0以下の値が指定された場合
			if(num <= 0)
			{
				//引数の値を無視して、フィールドに1を設定
				this._currentPage = 1;
			}
			//引数のページ番号に総ページ数より大きい値が指定された場合
			else if(this.totalPage < num)
			{
				//引数の値を無視して、フィールドに総ページ数を設定
				this._currentPage = this.totalPage;
			}
			//それ以外の場合
			else
			{
				//引数の値をフィールドに設定
				this._currentPage = num;
			}
			
			//表示するボタンの情報を設定
			setButtonStatus();
			
			//ページ変更のイベントを投げる
			dispatchEvent(new Event("changePage"));
			
			//必要に応じてコールバック関数を呼び出す
			callCallBuckFuction();
		}
		
		/**
		 * 現在表示しているページ番号を取得します。
		 * 
		 * @return 現在表示しているページ番号
		 */
		public function get currentPage() :int
		{
			//フィールドの値を返す
			return this._currentPage;
		}
		
		[Inspectable(defaultValue=20)]
		/**
		 * 1ページあたりの表示件数を設定します。
		 * 
		 * @param num 1ページあたりの表示件数
		 */
		public function set perPage(num :int) :void
		{
			//変更前の表示データの開始インデックスを取得しておく
			var oldDisplayStartIndex :int = this.displayStartIndex;
			
			//引数の値をフィールドに設定
			this._perPage = num;
			
			//真ん中のToggleButtonBarに表示するボタンのデータを再計算
			refreshToggleButtonBar();
			
			//==========================================================
			//現在のページをできるだけ矛盾がない方法で再計算する
			
			//変更前の表示データの開始インデックスを元に表示するページを計算
			var tmp : int = Math.ceil(oldDisplayStartIndex / this._perPage);
			
			//現在のページが変化する場合
			//(このチェックを行うのは、currentPageのSetterで行う処理と同じ処理が重複して行われないようにするため)
			if(tmp != this.currentPage)
			{
				//現在のページをSetter経由で設定する
				this.currentPage = tmp;
			}
			//現在のページが変化しない場合
			else
			{
				//表示するボタンの情報を設定
				setButtonStatus();
				
				//ページ変更のイベントを投げる
				dispatchEvent(new Event("changePage"));
				
				//必要に応じてコールバック関数を呼び出す
				callCallBuckFuction();
			}
		}
		
		/**
		 * 1ページあたりの表示件数を取得します。
		 * 
		 * @return 1ページあたりの表示件数
		 */
		public function get perPage() :int
		{
			//フィールドの値を返す
			return this._perPage;
		}
		
		[Inspectable(enumeration="true,false", defaultValue="true")]
		/**
		 * ページ切り替えのボタンの表示有無を設定します。
		 * 
		 * @param flg ページ切り替えのボタンの表示有無
		 */
		public function set isDisplayButton(flg :Boolean) :void
		{
			//引数の値をフィールドに設定
			this._isDisplayButton = flg;

			//内部に表示するコンポーネントを再構築
			rebuildInternalComponent();
		}
		
		/**
		 * ページ切り替えのボタンの表示有無を取得します。
		 * 
		 * @return ページ切り替えのボタンの表示有無
		 */
		public function get isDisplayButton() :Boolean
		{
			//フィールドの値を返す
			return this._isDisplayButton;
		}
		
		[Inspectable(enumeration="top,center,bottom", defaultValue="center")]
		/**
		 * ページ切り替えのボタンの表示位置を設定します。
		 * 
		 * @param str ページ切り替えのボタンの表示位置
		 */
		public function set pageChangeButtonAlign(str :String) :void
		{
			//引数の値をフィールドに設定
			this._pageChangeButtonAlign = str;
			
			//内部に表示するコンポーネントを再構築
			rebuildInternalComponent();
		}
		
		/**
		 * ページ切り替えのボタンの表示位置を取得します。
		 * 
		 * @return ページ切り替えのボタンの表示位置
		 */
		public function get pageChangeButtonAlign() :String
		{
			//フィールドの値を返す
			return this._pageChangeButtonAlign;
		}
		
		[Inspectable(defaultValue=10)]
		/**
		 * ページ切り替えのボタンを表示する数を設定します。
		 * 
		 * @param num ページ切り替えのボタンを表示する数
		 */
		public function set pageChangeButtonCount(num :int) :void
		{
			//引数の値をフィールドに設定
			this._pageChangeButtonCount = num;

			//真ん中のボタンを束ねるToggleButtonBarの幅に 、ページ切り替えのボタンを表示する数 * ページ切り替えのボタンの幅を設定する
			this.centerToggleButtonBar.width = this.pageChangeButtonCount * this.pageChangeButtonWidth;
			
			//真ん中のToggleButtonBarに表示するボタンのデータを再計算
			refreshToggleButtonBar();
			
			//表示するボタンの情報を設定
			setButtonStatus();
		}
		
		/**
		 * ページ切り替えのボタンを表示する数を取得します。
		 * 
		 * @return ページ切り替えのボタンを表示する数
		 */
		public function get pageChangeButtonCount() :int
		{
			//フィールドの値を返す
			return this._pageChangeButtonCount;
		}
		
		[Inspectable(defaultValue=40)]
		/**
		 * ページ切り替えのボタンの幅を設定します。
		 * 
		 * @param num ページ切り替えのボタンの幅
		 */
		public function set pageChangeButtonWidth(num :int) :void
		{
			//引数の値をフィールドに設定
			this._pageChangeButtonWidth = num;

			//真ん中のボタンを束ねるToggleButtonBarのボタンの幅のスタイルに指定された値を設定
			this.centerToggleButtonBar.setStyle("buttonWidth", this._pageChangeButtonWidth);
			
			//真ん中のボタンを束ねるToggleButtonBarの幅に 、ページ切り替えのボタンを表示する数 * ページ切り替えのボタンの幅を設定する
			this.centerToggleButtonBar.width = this.pageChangeButtonCount * this.pageChangeButtonWidth;
			
			//真ん中のToggleButtonBarの表示位置をスクロールさせる
			scrollToggleButtonBar();
		}
		
		/**
		 * ページ切り替えのボタンの幅を取得します。
		 * 
		 * @return ページ切り替えのボタンの幅
		 */
		public function get pageChangeButtonWidth() :int
		{
			//フィールドの値を返す
			return this._pageChangeButtonWidth;
		}
		
		[Inspectable(enumeration="true,false", defaultValue="true")]
		/**
		 * ページ切り替えのボタンのスクロールの際のエフェクトの有無を設定します。
		 * 
		 * @param flg ページ切り替えのボタンのスクロールの際のエフェクトの有無
		 */
		public function set isEnablePageScrollEffect(flg :Boolean) :void
		{
			//引数の値をフィールドに設定
			this._isEnablePageScrollEffect = flg;
		}
		
		/**
		 * ページ切り替えのボタンのスクロールの際のエフェクトの有無を取得します。
		 * 
		 * @return ページ切り替えのボタンのスクロールの際のエフェクトの有無
		 */
		public function get isEnablePageScrollEffect() :Boolean
		{
			//フィールドの値を返す
			return this._isEnablePageScrollEffect;
		}
		
		[Inspectable(defaultValue=500)]
		/**
		 * ページ切り替えのボタンのスクロールの際のエフェクトの継続時間(ミリ秒単位)を設定します。
		 * 
		 * @param num ページ切り替えのボタンのスクロールの際のエフェクトの継続時間(ミリ秒単位)
		 */
		public function set pageScrollEffectDuration(num :int) :void
		{
			//引数の値をフィールドに設定
			this._pageScrollEffectDuration = num;

			//ページボタンスクロール用のエフェクトの継続時間に指定された値を設定
			this.scrollEffect.duration = this._pageScrollEffectDuration;
		}
		
		/**
		 * ページ切り替えのボタンのスクロールの際のエフェクトの継続時間(ミリ秒単位)を取得します。
		 * 
		 * @return ページ切り替えのボタンのスクロールの際のエフェクトの継続時間(ミリ秒単位)
		 */
		public function get pageScrollEffectDuration() :int
		{
			//フィールドの値を返す
			return this._pageScrollEffectDuration;
		}
		
		[Inspectable(defaultValue=null)]
		/**
		 * コールバック関数を設定します。
		 * 
		 * @param func コールバック関数
		 */
		public function set callBackFunction(func :Function) :void
		{
			//引数の値をフィールドに設定
			this._callBackFuction = func;
		}
		
		/**
		 * コールバック関数を取得します。
		 * 
		 * @return コールバック関数
		 */
		public function get callBackFunction() :Function
		{
			//フィールドの値を返す
			return this._callBackFuction;
		}
		
		[Inspectable(defaultValue=null)]
		/**
		 * dataProviderを設定します。
		 * 
		 * @param value dataProvider
		 */
		public function set dataProvider(value: Object):void{
			//==========================================================
			//とりあえず元ネタの処理をほとんどそのまま行う
			
			if (value is Array){
				collection = new ArrayCollection(value as Array);
			}else if (value is ICollectionView) {
				collection = ICollectionView(value);
			}else if (value is IList){
				collection = new ListCollectionView(IList(value));
			}else{
				// convert it to an array containing this one item
				var tmp:Array = [];
				if (value != null)
					tmp.push(value);
				collection = new ArrayCollection(tmp);
			}
 
			var event:CollectionEvent = new CollectionEvent(CollectionEvent.COLLECTION_CHANGE);
			event.kind = CollectionEventKind.RESET;

			dispatchEvent(event);
		}
		
		/**
		 * dataProviderを取得します。
		 * 
		 * @return dataProvider
		 */
		public function get dataProvider() :Object {
			return collection;
		}

		//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
		//読み取り専用のプロパティ
		
		/**
		 * 総ページ数を返します。
		 * 対象データが存在しない場合は、1を返します。
		 * 
		 * @return 総ページ数
		 */
		public function get totalPage() :int
		{
			//対象データの総件数が0以下の場合
			if(this.totalCount <= 0)
			{
				//1を返す
				return 1;
			}
			//対象データの総件数を1ページあたりの表示件数で割った結果を切り上げして返す
			return Math.ceil(this.totalCount / this.perPage);
		}
		
		/**
		 * 現在表示しているデータの開始インデックスを返します。
		 * 
		 * @return 総ページ数
		 */
		public function get displayStartIndex() :int
		{
			//対象データの総件数が0以下の場合
			if(this.totalCount <= 0)
			{
				//0を返す
				return 0;
			}
			
			//((現在表示しているページ番号 - 1) * 1ページあたりの表示件数)+ 1を返す
			//(前のページの最後のインデックス + 1)
			return ((this.currentPage - 1) * this.perPage) + 1;
		}
		
		/**
		 * 現在表示しているデータの終了インデックスを返します。
		 * 
		 * @return 総ページ数
		 */
		public function get displayEndIndex() :int
		{
			//最後のページの場合
			if(this.isLastPage)
			{
				//対象データの総件数を返す
				return this.totalCount;
			}
			
			//現在表示しているページ番号 * 1ページあたりの表示件数を返す
			return this.currentPage * this.perPage;
		}
		
		/**
		 * 最初のページかどうかを返します。
		 * 
		 * @return true=最初のページ, false=最初のページでない
		 */
		public function get isFirstPage() :Boolean
		{
			//現在表示しているページ番号が1の場合
			if(this.currentPage == 1)
			{
				//最初のページなのでtrueを返す
				return true;
			}
			//それ以外の場合
			else
			{
				//最初のページでないのでfalseを返す
				return false;
			}
		}
		
		/**
		 * 最後のページかどうかを返します。
		 * 
		 * @return true=最後のページ, false=最後のページでない
		 */
		public function get isLastPage() :Boolean
		{
			//現在表示しているページ番号 * 1ページあたりの表示件数 が対象データの総件数以上の場合
			if((this.currentPage * this.perPage) >= this.totalCount)
			{
				//最後のページなのでtrueを返す
				return true;
			}
			//それ以外の場合
			else
			{
				//最後のページでないのでfalseを返す
				return false;
			}
		}
		
		
		//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
		//内部処理用
		
		/**
		 * 内部に表示するコンポーネントを初期化します。
		 */
		private function initInternalComponent() :void
		{
			//==========================================================
			//自分自身のスタイルの設定
			
 			//縦の間隔を0にする
			super.setStyle("verticalGap", "0");

			//横方向の並びを中央揃えにする
			super.setStyle("horizontalAlign", "center");
			
			
			//==========================================================
			//メインのHBox
			this.mainHBox = new HBox();
			this.mainHBox.setStyle("horizontalAlign", "center");
			this.mainHBox.setStyle("horizontalGap", "0");
			this.mainHBox.percentWidth = 100;


			//==========================================================
			//左側のボタンを束ねるHBox
			this.leftHBox = new HBox();
			this.leftHBox.setStyle("horizontalAlign", "left");
			this.leftHBox.setStyle("horizontalGap", "0");
			this.leftHBox.percentWidth = 100;
			
			//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
			//最初のページに戻るボタン
			this.firstPageButton = new Button();
			this.firstPageButton.label = "<<";

			//ボタンがクリックされた場合のイベントを割り当てる
			this.firstPageButton.addEventListener(MouseEvent.CLICK, this.onFirstPageButtonClick);
			
			//左側のボタンを束ねるHBoxに作成したボタンを追加する
			this.leftHBox.addChild(this.firstPageButton);

			//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
			//前のページに戻るボタン
			this.prevPageButton = new Button();
			this.prevPageButton.label = "<";

			//ボタンがクリックされた場合のイベントを割り当てる
			this.prevPageButton.addEventListener(MouseEvent.CLICK, this.onPrevPageButtonClick);
			
			//左側のボタンを束ねるHBoxに作成したボタンを追加する
			this.leftHBox.addChild(this.prevPageButton);


			//==========================================================
			//右側のボタンを束ねるHBox
			this.rightHBox = new HBox();
			this.rightHBox.setStyle("horizontalAlign", "right");
			this.rightHBox.setStyle("horizontalGap", "0");
			this.rightHBox.percentWidth = 100;

			//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
			//次のページに進むボタン
			this.nextPageButton = new Button();
			this.nextPageButton.label = ">";

			//ボタンがクリックされた場合のイベントを割り当てる
			this.nextPageButton.addEventListener(MouseEvent.CLICK, this.onNextPageButtonClick);
			
			//右側のボタンを束ねるHBoxに作成したボタンを追加する
			this.rightHBox.addChild(this.nextPageButton);

			//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
			//最後のページに進むボタン
			this.lastPageButton = new Button();
			this.lastPageButton.label = ">>";

			//ボタンがクリックされた場合のイベントを割り当てる
			this.lastPageButton.addEventListener(MouseEvent.CLICK, this.onLastPageButtonClick);
			
			//右側のボタンを束ねるHBoxに作成したボタンを追加する
			this.rightHBox.addChild(this.lastPageButton);


			//==========================================================
			//真ん中のボタンを束ねるToggleButtonBar
			this.centerToggleButtonBar = new ToggleButtonBar();
			this.centerToggleButtonBar.setStyle("buttonWidth", this.pageChangeButtonWidth);
			
			//真ん中のボタンを束ねるToggleButtonBarの幅に 、ページ切り替えのボタンを表示する数 * ページ切り替えのボタンの幅を設定する
			this.centerToggleButtonBar.width = this.pageChangeButtonCount * this.pageChangeButtonWidth;
			
			//ボタンがクリックされた場合のイベントを割り当てる
			this.centerToggleButtonBar.addEventListener(ItemClickEvent.ITEM_CLICK, this.onPageNoButtonClick);
			
			
			//==========================================================
			//ページボタンスクロール用のエフェクト
			this.scrollEffect = new AnimateProperty(this.centerToggleButtonBar);
			this.scrollEffect.duration = this.pageScrollEffectDuration;
			this.scrollEffect.property = "horizontalScrollPosition";
			this.scrollEffect.roundValue = true;
		}
		
		/**
		 * 内部に表示するコンポーネントを再構築します。
		 */
		private function rebuildInternalComponent() :void
		{
			//==========================================================
			//下準備
			
			//自分自身のコンテナから全ての子供のコンポーネントを取り除く
			//(ページ切り替えのボタンを表示しない場合もこの処理を行うのは、
			// 単にvisibleを変更して見えなくするだけだと、幅と高さが残ってしまうため)
			super.removeAllChildren();
				
			//ページ切り替えのボタンを表示しない場合
			if(!this.isDisplayButton)
			{
				//以降の処理を行わない
				return;
			}
			
			//メインのHBoxからも全ての子供のコンポーネントを取り除く
			this.mainHBox.removeAllChildren();
			
			//表示するボタンの情報を設定
			setButtonStatus();
			
			//==========================================================
			//ページ切り替えのボタンの表示位置に応じてコンポーネントの組み立て方を変える
			
			//スペーサー
			//(変数名の重複を避けるためにif分の外側で定義)
			var spacer :Spacer = null;

			//上に表示する場合
			if(this.pageChangeButtonAlign == "top")
			{
				//自分自身のコンテナにメインのHBoxを追加する
				super.addChild(this.mainHBox);
				
				//メインのHBoxに左側のボタンを束ねるHBoxを追加する
				this.mainHBox.addChild(this.leftHBox);
				
				//メインのHBoxに幅20のスペーサーを追加する
				spacer = new Spacer();
				spacer.width = 20;
				this.mainHBox.addChild(spacer);
				
				//メインのHBoxに右側のボタンを束ねるHBoxを追加する
				this.mainHBox.addChild(this.rightHBox);

				//自分自身のコンテナに真ん中のボタンを束ねるToggleButtonBarを追加する
				super.addChild(this.centerToggleButtonBar);
			}
			//下に表示する場合
			else if(this.pageChangeButtonAlign == "bottom")
			{
				//自分自身のコンテナに真ん中のボタンを束ねるToggleButtonBarを追加する
				super.addChild(this.centerToggleButtonBar);
				
				//自分自身のコンテナにメインのHBoxを追加する
				super.addChild(this.mainHBox);
				
				//メインのHBoxに左側のボタンを束ねるHBoxを追加する
				this.mainHBox.addChild(this.leftHBox);
				
				//メインのHBoxに幅20のスペーサーを追加する
				spacer = new Spacer();
				spacer.width = 20;
				this.mainHBox.addChild(spacer);
				
				//メインのHBoxに右側のボタンを束ねるHBoxを追加する
				this.mainHBox.addChild(this.rightHBox);
			}
			//(それ以外の場合)
			//(中央に表示する場合)
			else
			{
				//自分自身のコンテナにメインのHBoxを追加する
				super.addChild(this.mainHBox);
				
				//メインのHBoxに左側のボタンを束ねるHBoxを追加する
				this.mainHBox.addChild(this.leftHBox);
				
				//メインのHBoxに幅10のスペーサーを追加する
				spacer = new Spacer();
				spacer.width = 10;
				this.mainHBox.addChild(spacer);
				
				//メインのHBoxに真ん中のボタンを束ねるToggleButtonBarを追加する
				this.mainHBox.addChild(this.centerToggleButtonBar);
				
				//メインのHBoxに幅10のスペーサーを追加する
				spacer = new Spacer();
				spacer.width = 10;
				this.mainHBox.addChild(spacer);
				
				//メインのHBoxに右側のボタンを束ねるHBoxを追加する
				this.mainHBox.addChild(this.rightHBox);
			}
		}
		
		/**
		 * 表示するボタンの情報を設定します。
		 */
		private function setButtonStatus() :void
		{
			//==========================================================
			//ページの表示範囲を計算
			
			//総ページ数
			//(計算して算出する値なので、何度も計算しなくてもいいようにローカル変数に値をコピー)
			var totalPage :int = this.totalPage;
			
			//ページ切り替えのボタンを表示する数が総ページ数以上の場合
			if(this.pageChangeButtonCount >= totalPage)
			{
				//開始インデックスに1を設定
				this.startIndex = 1;

				//終了インデックスに総ページ数を設定
				this.endIndex = totalPage;
			}
			//それ以外の場合
			else
			{
				//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
				//できるだけ現在のページが中央にくるように補正する
				
				//現在のページの前に表示するページの数
				//(ページ切り替えのボタンを表示する数から1をひいてから割っているのは、
				// 偶数の場合は後に表示するページの数よりも前に表示するページの数の方を少なく表示するため)
				var minusCount :int = Math.floor((this.pageChangeButtonCount - 1) / 2);

				//現在のページの前に表示する後の数
				var plusCount :int = Math.floor(this.pageChangeButtonCount / 2);
				
				//左端に表示するページが1より小さくなってしまった場合
				if((this.currentPage - minusCount) < 1)
				{
					//開始インデックスに1を設定
					this.startIndex = 1;
					
					//終了インデックスにページ切り替えのボタンを表示する数を設定
					this.endIndex = this.pageChangeButtonCount;
				}
				//右端に表示するページが総ページ数より大きくなってしまった場合
				else if((this.currentPage + plusCount) > totalPage)
				{
					//開始インデックスに総ページ数 - ページ切り替えのボタンを表示する数 + 1を設定
					this.startIndex = totalPage - this.pageChangeButtonCount + 1;
					
					//終了インデックスに総ページ数を設定
					this.endIndex = totalPage;
				}
				//左端も右端も正常に収まりきる場合
				else
				{
					//開始インデックスに現在のページ - 現在のページの前に表示するページの数を設定
					this.startIndex = this.currentPage - minusCount;
					
					//終了インデックスに現在のページ + 現在のページの後に表示するページの数を設定
					this.endIndex = this.currentPage + plusCount;
				}
			}
			
			
			//==========================================================
			//ページ切り替えのボタンを表示しない場合
			if(!this.isDisplayButton)
			{
				//以降の処理を行わない
				return;
			}
			
			
			//==========================================================
			//両端のボタンの押下可能状態を変更
			
			//ページの表示範囲に最初のページが含まれている場合
			if(this.startIndex <= 1)
			{
				//最初のページに戻るボタンと前のページに戻るボタンを無効にする
				this.firstPageButton.enabled = false;
				this.prevPageButton.enabled = false;
			}
			//それ以外の場合
			else
			{
				//最初のページに戻るボタンと前のページに戻るボタンを有効にする
				this.firstPageButton.enabled = true;
				this.prevPageButton.enabled = true;
			}
			
			//ページの表示範囲に最後のページが含まれている場合
			if(this.endIndex >= this.totalPage)
			{
				//次のページに進むボタンと最後のページに進むボタンを無効にする
				this.nextPageButton.enabled = false;
				this.lastPageButton.enabled = false;
			}
			//それ以外の場合
			else
			{
				//次のページに進むボタンと最後のページに進むボタンを有効にする
				this.nextPageButton.enabled = true;
				this.lastPageButton.enabled = true;
			}
			
			
			//==========================================================
			//真ん中のToggleButtonBarの設定
			
			//現在のページを選択状態にする
			//(インデックスは0から、ページは1から始まるので補正する)
			this.centerToggleButtonBar.selectedIndex = this.currentPage - 1;
			
			//真ん中のToggleButtonBarの表示位置をスクロールさせる
			scrollToggleButtonBar();
		}
		
		/**
		 * 必要に応じてコールバック関数を呼び出します。
		 */
		private function callCallBuckFuction() :void
		{
			//初期化処理が終わっていない場合
			//(このチェックを入れないとなぜか動かなくなることがあるので念のためチェック)
			if(!initialized)
			{
				//以降の処理を行わない
				return;
			}
			
			//コールバック関数が設定されている場合
			if(this.callBackFunction != null)
			{
				//引数に現在表示しているページ番号と1ページあたりの表示件数を指定して、コールバック関数を呼び出す
				this.callBackFunction(this.currentPage, this.perPage);
			}
		}
		
		/**
		 * 真ん中のToggleButtonBarに表示するボタンのデータを再計算します。
		 */
		private function refreshToggleButtonBar() :void
		{
			//==========================================================
			//1ページ目から総ページ数までの値をもつ配列を生成
			
			//総ページ数
			//(計算して算出する値なので、何度も計算しなくてもいいようにローカル変数に値をコピー)
			var totalPage :int = this.totalPage;
			
			//配列を生成
			var array :Array = new Array();
			
			//開始インデックスから総ページ数までループをまわす
			//(最後のページも含む)
			for(var i :int = 1; i <= this.totalPage; i++)
			{
				//現在の数値を文字列に変換して配列に追加
				array.push(i.toString());
			}
			
			
			//==========================================================
			//真ん中のボタンを束ねるToggleButtonBarに値を設定

			//作成した配列を真ん中のボタンを束ねるToggleButtonBarのdataProviderに設定
			this.centerToggleButtonBar.dataProvider = array;
		}
		
		/**
		 * 真ん中のToggleButtonBarの表示位置をスクロールさせます。
		 */
		private function scrollToggleButtonBar() :void
		{
			//ページ切り替えのボタンを表示しない場合、または初期化処理が終わっていない場合
			if(!this.isDisplayButton || !super.initialized)
			{
				//以降の処理を行わない
				return;
			}
			
			//ページ切り替えのボタンのスクロールの際のエフェクトが有効な場合
			if(this.isEnablePageScrollEffect)
			{
				//エフェクトの終了値(スクロール位置)に、ページの表示範囲の開始インデックス * ページ切り替えのボタンの幅を設定
				this.scrollEffect.toValue = (this.startIndex - 1) * this.pageChangeButtonWidth;
				
				//エフェクトを実行する
				this.scrollEffect.play();
			}
			//ページ切り替えのボタンのスクロールの際のエフェクトが無効な場合
			else
			{
				//真ん中のボタンを束ねるToggleButtonBarのスクロール位置に、ページの表示範囲の開始インデックス * ページ切り替えのボタンの幅を設定
				this.centerToggleButtonBar.horizontalScrollPosition = (this.startIndex - 1) * this.pageChangeButtonWidth;
			}
			
		}
		
		
		/**
		 * 最初のページに戻るボタンが押された場合のイベント処理を行います。
		 * 
		 * @param event イベント
		 */
		private function onFirstPageButtonClick(event :Event = null) :void
		{
			//現在表示しているページ番号を最初のページに戻す
			this.currentPage = 1;
		}
		
		/**
		 * 前のページに戻るボタンが押された場合のイベント処理を行います。
		 * 
		 * @param event イベント
		 */
		private function onPrevPageButtonClick(event :Event = null) :void
		{
			//現在表示しているページ番号からページ切り替えのボタンを表示する数をひく
			//(ページがあふれた場合はcurrentPageのSetterで自動的に補正されるのでここでは気にしない)
			this.currentPage -= this.pageChangeButtonCount;
		}
		
		/**
		 * 次のページに進むボタンが押された場合のイベント処理を行います。
		 * 
		 * @param event イベント
		 */
		private function onNextPageButtonClick(event :Event = null) :void
		{
			//現在表示しているページ番号にページ切り替えのボタンを表示する数を足す
			//(ページがあふれた場合はcurrentPageのSetterで自動的に補正されるのでここでは気にしない)
			this.currentPage += this.pageChangeButtonCount;
		}
		
		/**
		 * 最後のページに進むボタンが押された場合のイベント処理を行います。
		 * 
		 * @param event イベント
		 */
		private function onLastPageButtonClick(event :Event = null) :void
		{
			//現在表示しているページ番号に総ページ数を設定する
			this.currentPage = this.totalPage;
		}
		
		/**
		 * ページ番号のボタンが押された場合のイベント処理を行います。
		 * 
		 * @param event イベント
		 */
		private function onPageNoButtonClick(event :ItemClickEvent) :void
		{
			//現在表示しているページ番号にクリックされた要素を数値に変換して設定する
			this.currentPage = int(event.item);

			//クリックされたボタンを選択状態にする
			//(本当はこの処理はいらないはずだが、うまく選択状態にならないことがあるので念のため)
			this.centerToggleButtonBar.selectedIndex = this.currentPage - 1;
		}
		
	}
}
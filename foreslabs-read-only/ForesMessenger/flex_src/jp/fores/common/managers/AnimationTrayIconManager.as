package jp.fores.common.managers
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import jp.fores.common.utils.ArrayUtil;
	import jp.fores.common.utils.TrayIconUtil;
	
	/**
	 * アニメーション機能付きのトレイアイコンの管理クラス。
	 */
	[Bindable]
	public class AnimationTrayIconManager
	{
		//==========================================================
		//定数
		
		/**
		 * トレイアイコンのアニメーションのデフォルトの間隔(単位=ミリ秒)
		 */
		public static const TRAY_ICON_ANIMATION_DEFAULT_SPAN :uint = 50;


		//==========================================================
		//フィールド

		/**
		 * アイコンをアニメーションさせるかどうかのフラグ
		 */
		[Inspectable(default=false)]
		public var isAnimation :Boolean = false;
		
		/**
		 * クリック時にアニメーションを停止するかどうかのフラグ
		 */
		[Inspectable(default=true)]
		public var isStopAnimationOnClick :Boolean = true;
		
		/**
		 * トレイアイコンのアニメーションの間隔(単位=ミリ秒)
		 */
		[Inspectable(default=TRAY_ICON_ANIMATION_DEFAULT_SPAN)]
		public var animationSpan :uint = TRAY_ICON_ANIMATION_DEFAULT_SPAN;
		
		/**
		 * 通常時のアイコンのビットマップデータの配列
		 */
		private var _normalIconBitmaps :Array = new Array();
		
		/**
		 * アニメーション時のアイコンのビットマップデータの配列の配列
		 */
		private var _animationIconBitmapsArray :Array = new Array();
		
		/**
		 * アニメーション用のタイマー
		 */
		private var _animationTimer :Timer = null;
		
		/**
		 * アイコンアニメーション用のインデックス
		 */
		private var _iconIndex :int = -1;
		
		
		//==========================================================
		//メソッド

		//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
		//

		/**
		 * コンストラクタです。
		 * 
		 * @param normalIconBitmaps 通常時のアイコンのビットマップデータの配列
		 * @param animationIconBitmapsArray アニメーション時のアイコンのビットマップデータの配列の配列(省略可能)
		 */
		public function AnimationTrayIconManager(normalIconBitmaps :Array, animationIconBitmapsArray :Array = null)
		{
			//==========================================================
			//引数の値をフィールドに設定
			this.normalIconBitmaps = normalIconBitmaps;
			this.animationIconBitmapsArray = animationIconBitmapsArray;
			
			
			
			//==========================================================
			//アニメーション用のタイマーの設定

			//アニメーション用のタイマーのインスタンスを生成
			//(永遠に繰り返すので繰り返し回数には0を指定)
			this._animationTimer = new Timer(this.animationSpan, 0);

			//アニメーション用のタイマーのタイマーイベントに対するイベントリスナーを設定
			this._animationTimer.addEventListener(TimerEvent.TIMER, onAnimationTimer);

			//アニメーション用のタイマーを開始する
			this._animationTimer.start();
			
			
			//==========================================================
			//トレイアイコンのクリックイベントに対するイベントリスナーを設定
			TrayIconUtil.addClickEventListener(onTrayIconClick);
		}


		//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
		//Setter, Getter

		/**
		 * 通常時のアイコンのビットマップデータの配列を設定します。
		 * 引数の配列の中身には、ビットマップデータに変換できるデータなら何でも指定できます。
		 * 
		 * @param bitmaps ビットマップデータに変換できるデータの配列
		 */
		public function set normalIconBitmaps(bitmaps :Array) :void
		{
			//引数の配列をビットマップデータの配列に変換して、フィールドに設定する
			this._normalIconBitmaps = TrayIconUtil.convertBitmapDataArray(bitmaps);
		}

		/**
		 * 通常時のアイコンのビットマップデータの配列を取得します。
		 * 
		 * @return 通常時のアイコンのビットマップデータの配列
		 */
		public function get normalIconBitmaps() :Array
		{
			//フィールドの値をそのまま返す
			return this._normalIconBitmaps;
		}

		/**
		 * アニメーション時のアイコンのビットマップデータの配列の配列を設定します。
		 * 引数の配列の中身には、ビットマップデータに変換できるデータなら何でも指定できます。
		 * 
		 * @param bitmaps ビットマップデータに変換できるデータの配列
		 */
		public function set animationIconBitmapsArray(bitmapsArray :Array) :void
		{
			//引数の配列がnullまたは空配列の場合
			if(ArrayUtil.isBlank(bitmapsArray))
			{
				//フィールドに空配列を設定する
				this._animationIconBitmapsArray = new Array();
				
				//以降の処理を行わない
				return;
			}
			
			//作業用の配列のインスタンスを生成
			var array :Array = new Array();
			
			//引数の配列の全ての要素に対して処理を行う
			for each(var obj :Object in bitmapsArray)
			{
				//対象のオブジェクトが配列でない場合
				if(!(obj is Array))
				{
					//対象のオブジェクトを配列に変換する
					obj = [obj];
				}
				
				//対象のオブジェクトをビットマップデータの配列に変換してから作業用の配列に詰める
				array.push(TrayIconUtil.convertBitmapDataArray(obj as Array));
			}
			
			//作成した配列をフィールドに設定する
			this._animationIconBitmapsArray = array;
		}

		/**
		 * アニメーション時のアイコンのビットマップデータの配列の配列を取得します。
		 * 
		 * @return アニメーション時のアイコンのビットマップデータの配列の配列
		 */
		public function get animationIconBitmapsArray() :Array
		{
			//フィールドの値をそのまま返す
			return this._animationIconBitmapsArray;
		}


		//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
		//内部処理用

		/**
		 * アニメーション用のタイマーのタイマーイベントに対応する処理を行います。
		 * 
		 * @param event イベントオブジェクト
		 */
		private function onAnimationTimer(event :Event = null) :void
		{
			//アニメーション用のタイマーを一度停止させる
			this._animationTimer.stop();
			
			//アニメーション用のタイマーの間隔にフィールドの値を再設定する
			this._animationTimer.delay = this.animationSpan;
			
			//アニメーション用のタイマーを再び開始する
			this._animationTimer.start();

			//アイコンをアニメーションさせない場合、またはアニメーション時のアイコンのビットマップデータの配列の配列がnullまたは空配列の場合
			if(!isAnimation || ArrayUtil.isBlank(this.animationIconBitmapsArray))
			{
				//トレイアイコンが通常時のアイコンでない場合
				if(TrayIconUtil.getIconBitmaps() != normalIconBitmaps)
				{
					//トレイアイコンに通常時のアイコンのビットマップデータの配列を設定する
					TrayIconUtil.setIconBitmaps(this.normalIconBitmaps);
				}
				
				//以降の処理を行わない
				return;
			}
			
			//アイコンアニメーション用のインデックスを1進める
			this._iconIndex++;
			
			//インデックスがアニメーション時のアイコンのビットマップデータの配列の配列の要素数を超えた場合に0に戻すための補正処理
			this._iconIndex = this._iconIndex % this.animationIconBitmapsArray.length;
			
			//トレイアイコンにアニメーション時のアイコンのビットマップデータの配列を設定する
			TrayIconUtil.setIconBitmaps(this.animationIconBitmapsArray[this._iconIndex]);
		}

		/**
		 * トレイアイコンのクリックイベントに対応する処理を行います。
		 * 
		 * @param event イベントオブジェクト
		 */
		private function onTrayIconClick(event :Event = null) :void
		{
			//クリック時にアニメーションを停止するかどうかのフラグがたっている場合
			if(this.isStopAnimationOnClick)
			{
				//アイコンをアニメーションさせるかどうかのフラグをfalseにする
				this.isAnimation = false;
			}
		}
	}
}
package jp.fores.common.utils
{
	import flash.desktop.DockIcon;
	import flash.desktop.NativeApplication;
	import flash.desktop.SystemTrayIcon;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.NativeMenu;
	import flash.events.MouseEvent;
	
	/**
	 * トレイアイコン操作用ユーティリティクラス。
	 * Windowsの場合とMacの場合のどちらにも対応した処理を行います。
	 */
	public class TrayIconUtil
	{
		//==========================================================
		//メソッド
		
		//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
		//クラスメソッド
		
		/**
		 * トレイアイコンのビットマップデータの配列を設定します。
		 * 引数の配列の中身には、ビットマップデータに変換できるデータなら何でも指定できます。
		 * 
		 * @param bitmaps ビットマップデータに変換できるデータの配列
		 */
		public static function setIconBitmaps(bitmaps :Array) :void
		{
			//引数の配列をビットマップデータの配列に変換して、トレイアイコンのビットマップデータの配列に設定する
			NativeApplication.nativeApplication.icon.bitmaps = convertBitmapDataArray(bitmaps);
		}
		
		/**
		 * トレイアイコンのビットマップデータの配列を取得します。
		 * 
		 * @param ビットマップデータの配列
		 */
		public static function getIconBitmaps() :Array
		{
			//トレイアイコンのビットマップデータの配列に上で作成した作業用の配列の値を返す
			return NativeApplication.nativeApplication.icon.bitmaps;
		}
		
		/**
		 * トレイアイコンのツールチップを設定します。
		 * ツールチップがサポートされていない場合は何もしません。
		 * 
		 * @param tooltip ツールチップに指定する文字列
		 */
		public static function setTooltip(tooltip :String) :void
		{
			//システムトレイアイコンがサポートされていない場合
			if(!NativeApplication.supportsSystemTrayIcon)
			{
				//以降の処理を行わない
				return;
			}
			
			
			//システムトレイアイコンのツールチップに引数の値を設定する
			SystemTrayIcon(NativeApplication.nativeApplication.icon).tooltip = tooltip;
		}
		
		/**
		 * トレイアイコンのツールチップを取得します。
		 * ツールチップがサポートされていない場合はnullを返します。
		 * 
		 * @return ツールチップ
		 */
		public static function getTooltip() :String
		{
			//システムトレイアイコンがサポートされていない場合
			if(!NativeApplication.supportsSystemTrayIcon)
			{
				//仕方がないのでnullを返す
				return null;
			}


			//システムトレイアイコンのツールチップの値を返す
			return SystemTrayIcon(NativeApplication.nativeApplication.icon).tooltip;
		}
		
		/**
		 * トレイアイコンのメニューを設定します。
		 * トレイアイコンのメニューがサポートされていない場合は何もしません。
		 * 
		 * @param menu ネイティブメニュー
		 */
		public static function setTrayIconMenu(menu :NativeMenu) :void
		{
			//システムトレイアイコンがサポートされている場合
			if(NativeApplication.supportsSystemTrayIcon)
			{
				//システムトレイアイコンのメニューに引数の値を設定する
				SystemTrayIcon(NativeApplication.nativeApplication.icon).menu = menu;
			}
			//ドックアイコンがサポートされている場合
			else if(NativeApplication.supportsDockIcon)
			{
				//ドックアイコンのメニューに引数の値を設定する
				DockIcon(NativeApplication.nativeApplication.icon).menu = menu;
			}
		}
		
		/**
		 * トレイアイコンのメニューを取得します。
		 * トレイアイコンのメニューがサポートされていない場合はnullを返します。
		 * 
		 * @return ネイティブメニュー
		 */
		public static function getTrayIconMenu() :NativeMenu
		{
			//システムトレイアイコンがサポートされている場合
			if(NativeApplication.supportsSystemTrayIcon)
			{
				//システムトレイアイコンのメニューの値を返す
				return SystemTrayIcon(NativeApplication.nativeApplication.icon).menu;
			}
			//ドックアイコンがサポートされている場合
			else if(NativeApplication.supportsDockIcon)
			{
				//ドックアイコンのメニューの値を返す
				return DockIcon(NativeApplication.nativeApplication.icon).menu;
			}
			
			//ここに来るのはメニューがサポートされていない場合なのでnullを返す
			return null;
		}
		
		/**
		 * アプリケーションのメニューを設定します。
		 * アプリケーションのメニューがサポートされていない場合は何もしません。
		 * 
		 * @param menu ネイティブメニュー
		 */
		public static function setApplicationMenu(menu :NativeMenu) :void
		{
			//アプリケーションのメニューがサポートされている場合
			if(NativeApplication.supportsMenu)
			{
				//アプリケーションのメニューに引数の値を設定する
				NativeApplication.nativeApplication.menu = menu;
			}
		}
		
		/**
		 * アプリケーションのメニューを取得します。
		 * アプリケーションのメニューがサポートされていない場合はnullを返します。
		 * 
		 * @return ネイティブメニュー
		 */
		public static function getApplicationMenu() :NativeMenu
		{
			//アプリケーションのメニューがサポートされている場合
			if(NativeApplication.supportsMenu)
			{
				//アプリケーションのメニューの値を返す
				return NativeApplication.nativeApplication.menu;
			}
			
			//ここに来るのはメニューがサポートされていない場合なのでnullを返す
			return null;
		}
		
		/**
		 * トレイアイコンのクリック時のイベントハンドラを設定します。
		 * クリックイベントがサポートされていない場合は何もしません。
		 * 
		 * @param func ハンドラ関数
		 */
		public static function addClickEventListener(func :Function) :void
		{
			//システムトレイアイコンがサポートされていない場合
			if(!NativeApplication.supportsSystemTrayIcon)
			{
				//以降の処理を行わない
				return;
			}
			
			
			//システムトレイアイコンのクリックイベントのハンドラに引数の値を設定する
			SystemTrayIcon(NativeApplication.nativeApplication.icon).addEventListener(MouseEvent.CLICK, func);
		}
		
		/**
		 * トレイアイコンの右クリック時のイベントハンドラを設定します。
		 * クリックイベントがサポートされていない場合は何もしません。
		 * 
		 * @param func ハンドラ関数
		 */
		public static function addRightClickEventListener(func :Function) :void
		{
			//システムトレイアイコンがサポートされていない場合
			if(!NativeApplication.supportsSystemTrayIcon)
			{
				//以降の処理を行わない
				return;
			}
			
			
			//システムトレイアイコンの右クリックイベントのハンドラに引数の値を設定する
			SystemTrayIcon(NativeApplication.nativeApplication.icon).addEventListener(MouseEvent.RIGHT_CLICK, func);
		}
		
		/**
		 * トレイアイコンをバウンドさせます。
		 * バウンドがサポートされていない場合は何もしません。
		 * 引数の緊急度には、NotificationTypeの値を指定します
		 * 
		 * @param priority ドックをバウンドさせるための緊急度(省略可能, デフォルト="informational")
		 */
		public static function bounce(priority :String = "informational") :void
		{
			//ドックアイコンがサポートされていない場合
			if(!NativeApplication.supportsDockIcon)
			{
				//以降の処理を行わない
				return;
			}
			
			
			//ドックアイコンのバウンド処理を呼び出す
			DockIcon(NativeApplication.nativeApplication.icon).bounce(priority);
		}
		
		/**
		 * OSがWindowsかどうかを判断します。
		 * 
		 * @return true=Windows, false=Windows以外のOS
		 */
		public static function isWindows() :Boolean
		{
			//システムトレイアイコンがサポートされている場合
			if(NativeApplication.supportsSystemTrayIcon)
			{
				//Windowsなのでtrueを返す
				return true;
			}
			//それ以外の場合
			else
			{
				//Windowsでないのでfalseを返す
				return false;
			}
		}
		
		
		/**
		 * 対象のオブジェクトをビットマップデータに変換して返します。
		 * 変換できなかった場合は例外を投げます。
		 * (本来は内部処理用のメソッドですが、外部からもしようできるようにpublicにしています)
		 * 
		 * @param obj 変換対象のオブジェクト
		 * @return ビットマップデータ
		 */
		public static function convertBitmapData(obj :Object) :BitmapData
		{
			//対象のオブジェクトに引数の値を設定
			var targetObj :Object = obj;
			
			//引数のオブジェクトがClassの場合
			if(obj is Class)
			{
				//クラスをインスタンス化して、対象のオブジェクトに設定
				targetObj = new obj();
			}
			
			//対象のオブジェクトがBitmapDataの場合
			if(targetObj is BitmapData)
			{
				//対象のオブジェクトをBitmapDataにキャストして返す
				return targetObj as BitmapData;
			}
			
			//対象のオブジェクトがBitmapの場合
			if(targetObj is Bitmap)
			{
				//対象のオブジェクトをBitmapにキャストして、中身のBitmapDataを返す
				return (targetObj as Bitmap).bitmapData;
			}
			
			//どれとも一致しなかった場合は、どうしようもないので例外を投げる
			throw new Error("BitmapDataへの変換に失敗しました。");
		}

		/**
		 * 対象の配列をビットマップデータの配列に変換して返します。
		 * 変換できなかった場合は例外を投げます。
		 * (本来は内部処理用のメソッドですが、外部からもしようできるようにpublicにしています)
		 * 
		 * @param bitmaps ビットマップデータに変換できるデータの配列
		 * @return ビットマップデータの配列
		 */
		public static function convertBitmapDataArray(bitmaps :Array) :Array
		{
			//引数の配列がnullまたは空配列の場合
			if(ArrayUtil.isBlank(bitmaps))
			{
				//nullを返す
				return null;
			}
			
			//作業用の配列のインスタンスを生成
			var array :Array = new Array();
			
			//引数の配列の全ての要素に対して処理を行う
			for each(var obj :Object in bitmaps)
			{
				//対象のオブジェクトをビットマップデータに変換してから作業用の配列に詰める
				array.push(convertBitmapData(obj));
			}
			
			//作成した配列を返す
			return array;
		}

		
	}
}
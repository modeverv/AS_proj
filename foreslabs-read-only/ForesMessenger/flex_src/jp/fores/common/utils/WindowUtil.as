package jp.fores.common.utils
{
	import flash.desktop.NativeApplication;
	import flash.display.NativeWindow;
	import flash.display.Screen;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	/**
	 * ウインドウ操作用ユーティリティクラス。
	 * (AIR専用)
	 */
	public class WindowUtil
	{
		//==========================================================
		//メソッド
	
		//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
		//クラスメソッド
	
		/**
		 * 指定されたウインドウが画面中央に表示されるように位置を調整します。
		 * 
		 * @param nativeWindow ネイティブウインドウのインスタンス
		 * @param xOffset X座標のオフセット(省略可能, デフォルト=0)
		 * @param yOffset Y座標のオフセット(省略可能, デフォルト=0)
		 */
		public static function centeringWindow(nativeWindow :NativeWindow, xOffset :int = 0, yOffset :int = 0) :void
		{
			//引数のネイティブウインドウがnullの場合
			if(nativeWindow == null)
			{
				//以降の処理を行わない
				return;
			}
			
			//メインスクリーンの左端の座標と幅を基準にして、新しいX座標を計算
			var newX :int = Screen.mainScreen.bounds.x + ((Screen.mainScreen.bounds.width - nativeWindow.bounds.width) / 2) + xOffset;
			
			//メインスクリーンの上端の座標と高さを基準にして、新しいY座標を計算
			var newY :int = Screen.mainScreen.bounds.y + ((Screen.mainScreen.bounds.height - nativeWindow.bounds.height) / 2) + yOffset;
			
			//新しいX座標とY座標を元にして、ネイティブウインドウのboundsを再設定する
			nativeWindow.bounds = new Rectangle(newX, newY, nativeWindow.bounds.width, nativeWindow.bounds.height);
		}
		
		/**
		 * 指定されたウインドウが画面中央からランダムにずれて表示されるように位置を調整します。
		 * 
		 * @param nativeWindow ネイティブウインドウのインスタンス
		 * @param xRandom X座標をランダムにずらす上限値(省略可能, デフォルト=150)
		 * @param yRandom Y座標ランダムにずらす上限値(省略可能, デフォルト=100)
		 */
		public static function centeringWindowRandomPosition(nativeWindow :NativeWindow, xRandom :int = 150, yRandom :int = 100) :void
		{
			//実際に指定するX座標のオフセット値の計算
			//(-XRandom ～ +XRandomの間の数値)
			var xOffSet :int = (Math.random() * xRandom * 2) - xRandom;
			
			//実際に指定するY座標のオフセット値の計算
			//(-YRandom ～ +YRandomの間の数値)
			var yOffSet :int = (Math.random() * yRandom * 2) - yRandom;
			
			//実際に処理を行うメソッドを呼び出す
			centeringWindow(nativeWindow, xOffSet, yOffSet);
		}
		
		/**
		 * 全てのウインドウを閉じます。
		 */
		public static function closeAllWindow() :void
		{
			//アプリケーションによって現在開かれているNatiVeWindowの配列を取得
			var windowArray :Array = NativeApplication.nativeApplication.openedWindows;
			
			//取得した配列がnullまたは空配列の場合
			if(ArrayUtil.isBlank(windowArray))
			{
				//以降の処理を行わない
				return;
			}
			
			//配列の全ての要素に対して処理を行う
			for each(var nativeWindow :NativeWindow in windowArray)
			{
				//キャンセル可能な設定で「closing」イベントを生成
				var event :Event = new Event(Event.CLOSING, true, true);
				
				//生成したイベントを投げる
				nativeWindow.dispatchEvent(event);
				
				//イベントがキャンセルされなかった場合
				if(!event.isDefaultPrevented())
				{
					//ウインドウを閉じる
					nativeWindow.close();
				}
			}
		}

		/**
		 * 全てのウインドウをアクティブ化します。
		 */
		public static function activateAllWindow() :void
		{
			//アプリケーションによって現在開かれているNatiVeWindowの配列を取得
			var windowArray :Array = NativeApplication.nativeApplication.openedWindows;
			
			//取得した配列がnullまたは空配列の場合
			if(ArrayUtil.isBlank(windowArray))
			{
				//以降の処理を行わない
				return;
			}
			
			//配列の全ての要素に対して処理を行う
			for each(var nativeWindow :NativeWindow in windowArray)
			{
				//キャンセル可能な設定で「activate」イベントを生成
				var event :Event = new Event(Event.ACTIVATE, true, true);
				
				//生成したイベントを投げる
				nativeWindow.dispatchEvent(event);
				
				//イベントがキャンセルされなかった場合
				if(!event.isDefaultPrevented())
				{
					//ウインドウをアクティブ化する
					nativeWindow.activate();
				}
				
			}
		}

		/**
		 * タイトルが一致するウインドウをアクティブ化します。
		 * 
		 * @return true=タイトルが一致するウインドウが見つかった場合, false=タイトルが一致するウインドウが見つからなかった場合
		 */
		public static function activateWindowByTitle(title :String) :Boolean
		{
			//アプリケーションによって現在開かれているNatiVeWindowの配列を取得
			var windowArray :Array = NativeApplication.nativeApplication.openedWindows;
			
			//取得した配列がnullまたは空配列でない場合
			if(!ArrayUtil.isBlank(windowArray))
			{
				//配列の全ての要素に対して処理を行う
				for each(var nativeWindow :NativeWindow in windowArray)
				{
					//ウインドウのタイトルが引数の値と一致する場合
					if(nativeWindow.title == title)
					{
						//キャンセル可能な設定で「activate」イベントを生成
						var event :Event = new Event(Event.ACTIVATE, true, true);
						
						//生成したイベントを投げる
						nativeWindow.dispatchEvent(event);
						
						//イベントがキャンセルされなかった場合
						if(!event.isDefaultPrevented())
						{
							//ウインドウをアクティブ化する
							nativeWindow.activate();
						}
						
						//タイトルが一致するウインドウが見つかったのでtrueを返す
						return true;
					}
				}
			}
			
			//タイトルが一致するウインドウが見つからなかったのでfalseを返す
			return false;
		}

	}
}
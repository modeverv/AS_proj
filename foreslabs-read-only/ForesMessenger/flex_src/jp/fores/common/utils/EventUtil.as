package jp.fores.common.utils
{
	import flash.display.InteractiveObject;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.ui.Keyboard;
	import flash.utils.Timer;
	
	import mx.controls.Button;
	import mx.core.mx_internal;
	
	use namespace mx_internal;
	
	/**
	 * イベント関連の処理を行うためのユーティリティクラス。
	 */
	public class EventUtil
	{
		//==========================================================
		//メソッド
		
		//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_a/_/_/_/_/
		//クラスメソッド
		
		/**
		 * Enterキーが離された場合、Spaceキーが離されたイベントを投げるためのイベントハンドラ用関数です。
		 * 
		 * @param event イベント
		 */
		public static function onEnterKeyEventDispatchSpaceKeyEvent(event :KeyboardEvent) :void
		{
			//Enterキーに対するイベントの場合
			if(event.keyCode == Keyboard.ENTER)
			{
				//イベントの発生元のオブジェクトがInteractiveObjectの場合
				if(event.currentTarget is InteractiveObject)
				{
					//イベントの発生元のオブジェクトを取得して、InteractiveObjectにキャスト
					var interactiveObject :InteractiveObject = event.currentTarget as InteractiveObject;

					//引数のイベントのクローンを作成
					var cloneEvent :KeyboardEvent = event.clone() as KeyboardEvent;
					
					//キーコードをSpaceキーのものに変更
					cloneEvent.keyCode = Keyboard.SPACE;

					//作成したクローンイベントを投げる
					interactiveObject.dispatchEvent(cloneEvent);
				}
			}
		}

		/**
		 * Enterキーが押された場合、「click」イベントを投げるためのイベントハンドラ用関数です。
		 * イベント発生元のオブジェクトがButtonの場合は、単純に「click」イベントを投げるだけでなく、
		 * できるだけSpaceキーでクリックされた場合と同じ見た目になるように工夫しています。
		 * (onEnterKeyEventDispatchSpaceKeyEvent()イベントに比べてやや挙動は荒くなりますが、こちらはkeyDownイベントにのみ設定すればよいのでお手軽です)
		 * 
		 * @param event イベントオブジェクト
		 */
		public static function onEnterKeyDownDispatchClick(event :KeyboardEvent) :void
		{
			//Enterキーが押された場合
			if(event.keyCode == Keyboard.ENTER)
			{
				//イベントの発生元のオブジェクトがButtonの場合
				if(event.currentTarget is Button)
				{
					//イベントの発生元のオブジェクトを取得して、Buttonにキャスト
					var button :Button = event.currentTarget as Button;

					//==========================================================
					//ボタンの見た目を押された状態に変えてから、少し遅れて「click」イベントを投げ、ボタンの状態を元に戻す
					//(単純に「click」イベントを投げるだけよりも見た目を良くするため)
					
					//ボタンの見た目を押された状態に変える
					//(Buttonクラスの内部処理だが、これ以外に見た目をあわせる方法がないため)
					button.mx_internal::phase = "down";
					
					//少し処理を遅らせるためのタイマー
					var timer :Timer = new Timer(50, 1);
					
					//タイマーイベントのイベントリスナーをインライン関数で設定
					//(インライン関数は嫌いなのですが、普通の関数にするとUIComponentのインスタンスが渡せなくなるので仕方なくこうしています)
					//(使い捨てにされるオブジェクトなので、一応弱参照のリスナーにしておく)
					timer.addEventListener(TimerEvent.TIMER, 
						function(event :Event) :void
						{
							//タイマーを停止する
							//(一回しか実行されないタイマーだが念のため)
							timer.stop();
							
							//「click」イベントを投げる
							button.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
							
							//ボタンの見た目を元の状態に戻す
							//(Buttonクラスの内部処理だが、これ以外に見た目をあわせる方法がないため)
							button.mx_internal::phase = "up";
						}

					, false, 0, true);

					//タイマーを開始する
					timer.start();
				}
				//イベントの発生元のオブジェクトがInteractiveObjectの場合
				else if(event.currentTarget is InteractiveObject)
				{
					//イベントの発生元のオブジェクトを取得して、InteractiveObjectにキャスト
					var interactiveObject :InteractiveObject = event.currentTarget as InteractiveObject;

					//「click」イベントを投げる
					interactiveObject.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
				}
			
			}
		}

	}
}
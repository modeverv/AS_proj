package jp.fores.foresmessenger.dto
{
	import jp.fores.foresmessenger.constant.ForesMessengerConstant;
	
	/**
	 * 設定情報用DTOクラス。
	 */
	[Bindable]
	public class ConfigDto
	{
		//==========================================================
		//フィールド
		
		/**
		 * 利用者名
		 */
		public var userName :String = "";
		
		/**
		 * グループ名
		 */
		public var groupName :String = "";

		/**
		 * 自動ログインを行うかどうかのフラグ
		 */
		public var isAutoLogin :Boolean = false;

		/**
		 * OS起動時にアプリケーションの自動起動を行うかどうかのフラグ
		 */
		public var isAutoStart :Boolean = false;

		/**
		 * 別のグループからの着信を拒否するかどうかのフラグ
		 */
		public var isDenyOtherGroup :Boolean = false;

		/**
		 * ログをファイルに記録するかどうかのフラグ
		 */
		public var isLogging :Boolean = true;

		/**
		 * 開封前の状態でログをファイルに記録するかどうかのフラグ
		 */
		public var isBeforeOpenLogging :Boolean = false;

		/**
		 * ログファイルの絶対パス
		 */
		public var logFilePath :String = "";

		/**
		 * 着信メッセージをすぐにウインドウで表示するかどうかのフラグ
		 */
		public var isReceiveOpenWindow :Boolean = false;

		/**
		 * 着信通知レベル
		 * (デフォルト値=「全て」)
		 */
		public var receiveNotifyLevel :String = ForesMessengerConstant.NOTIFY_LEVEL_ALL;

		/**
		 * 着信通知の通知ウインドウのタイトルの色
		 * (デフォルト値は白)
		 */
		public var receiveNotifyWindowTitleTextColor :uint = 0xFFFFFF;
		
		/**
		 * 着信通知の通知ウインドウのメッセージの色
		 * (デフォルト値は白)
		 */
		public var receiveNotifyWindowMessageTextColor :uint = 0xFFFFFF;
		
		/**
		 * 着信通知の通知ウインドウの背景の色
		 * (デフォルト値は黒っぽい灰色)
		 */
		public var receiveNotifyWindowBackgroundColor :uint = 0x333333;
		
		/**
		 * 着信通知表示時間(単位=秒)
		 */
		public var receiveNotifyDuration :uint = 3;

		/**
		 * ログイン通知レベル
		 * (デフォルト値=「全て」)
		 */
		public var loginNotifyLevel :String = ForesMessengerConstant.NOTIFY_LEVEL_ALL;

		/**
		 * ログイン通知の通知ウインドウのタイトルの色
		 * (デフォルト値は白)
		 */
		public var loginNotifyWindowTitleTextColor :uint = 0xFFFFFF;
		
		/**
		 * ログイン通知の通知ウインドウのメッセージの色
		 * (デフォルト値は白)
		 */
		public var loginNotifyWindowMessageTextColor :uint = 0xFFFFFF;
		
		/**
		 * ログイン通知の通知ウインドウの背景の色
		 * (デフォルト値は黒っぽい灰色)
		 */
		public var loginNotifyWindowBackgroundColor :uint = 0x333333;
		
		/**
		 * ログイン通知表示時間(単位=秒)
		 */
		public var loginNotifyDuration :uint = 3;

		/**
		 * 開封通知レベル
		 * (デフォルト値=「画面右下の通知ウインドウで通知する」)
		 */
		public var openNotifyLevel :String = ForesMessengerConstant.OPEN_NOTIFY_LEVEL_NOTIFY;

		/**
		 * 開封通知の通知ウインドウのタイトルの色
		 * (デフォルト値は白)
		 */
		public var openNotifyWindowTitleTextColor :uint = 0xFFFFFF;
		
		/**
		 * 開封通知の通知ウインドウのメッセージの色
		 * (デフォルト値は白)
		 */
		public var openNotifyWindowMessageTextColor :uint = 0xFFFFFF;
		
		/**
		 * 開封通知の通知ウインドウの背景の色
		 * (デフォルト値は黒っぽい灰色)
		 */
		public var openNotifyWindowBackgroundColor :uint = 0x333333;
		
		/**
		 * 開封通知表示時間(単位=秒)
		 */
		public var openNotifyDuration :uint = 3;

		/**
		 * 通知ウインドウクリック時の動作
		 * (デフォルト値=「全ての通知をまとめて閉じる」)
		 */
		public var notifyWindowClickOperation :String = ForesMessengerConstant.NOTIFY_WINDOW_CLICK_OPERATION_ALL_CLOSE;

		/**
		 * 自分自身の色
		 * (デフォルト値は赤)
		 */
		public var selfUserColor :uint = 0xFF0000;
		
		/**
		 * 同じグループの色
		 * (デフォルト値は青)
		 */
		public var selfGroupColor :uint = 0x0000FF;
		
		/**
		 * 別のグループの色
		 * (デフォルト値は黒)
		 */
		public var otherGroupColor :uint = 0x000000;

		/**
		 * 長時間音沙汰が無い人の表示を徐々に透明にしていくかどうかのフラグ
		 */
		public var isIdleDisplayTransparent :Boolean = true;

		/**
		 * 完全に音沙汰が無くなったとみなす時間(単位=分)
		 */
		public var idleDisplayMaxDuration :uint = 60;

		/**
		 * 完全に音沙汰が無くなったときの透明度(アルファ値)
		 * (デフォルト値は0.3)
		 */
		public var idleDisplayAlpha :Number = 0.3;

		/**
		 * 自動バージョンアップを行うかどうかのフラグ
		 */
		public var isAutoVersionUp :Boolean = true;

	}
}
package jp.fores.foresmessenger.constant
{
	/**
	 * ForesMessengerの定数集クラス。
	 */
	public class ForesMessengerConstant
	{
		//==========================================================
		//定数
		
		//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
		//URL関連
		
		/**
		 * AIRファイルのURL
		 */
		public static const AIR_URL :String = "http://www.fores.jp/labs/air/ForesMessenger.air";

		/**
		 * デフォルトの接続先のホストのURL
		 */
		public static const DEFAULT_HOST_URL :String = "http://www.fores.jp/ForesMessenger";
		
		
		//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
		//時間関連
		
		/**
		 * アイドル状態になるまでの時間(単位=分)
		 */
		public static const IDLE_THRESHOLD :int = 30;

		/**
		 * ダブルクリックとみなす間隔(単位=ミリ秒)
		 */
		public static const DOUBLE_CLICK_DURATION :int = 500;


		//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
		//フォント関連

		/**
		 * このアプリケーションで使用するメインのフォント
		 */
		public static const MAIN_FONT :String = "IPAUIEmbedded";


		//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
		//添付ファイル関連

		/**
		 * 添付ファイルの最大サイズ
		 * (5Mバイト)
		 */
		public static const ATTACHMENT_FILE_MAX_SIZE :int = 5 * 1024 * 1024;


		//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
		//通知レベル

		/**
		 * 通知レベル: 全て通知する
		 */
		public static const NOTIFY_LEVEL_ALL :String = "1";

		
		/**
		 * 通知レベル: 同じグループの場合に通知する
		 */
		public static const NOTIFY_LEVEL_GROUP :String = "2";

		
		/**
		 * 通知レベル: 通知しない
		 */
		public static const NOTIFY_LEVEL_NONE :String = "3";


		//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
		//開封通知レベル
		
		/**
		 * 開封通知レベル: 画面右下の通知ウインドウで通知する
		 */
		public static const OPEN_NOTIFY_LEVEL_NOTIFY :String = "1";

		/**
		 * 開封通知レベル: ポップアップウインドウで通知する
		 */
		public static const OPEN_NOTIFY_LEVEL_WINDOW :String = "2";

		/**
		 * 開封通知レベル: 通知しない
		 */
		public static const OPEN_NOTIFY_LEVEL_NONE :String = "3";


		//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
		//通知ウインドウクリック時の動作
		
		/**
		 * 通知ウインドウクリック時の動作: 全ての通知をまとめて閉じる
		 */
		public static const NOTIFY_WINDOW_CLICK_OPERATION_ALL_CLOSE :String = "1";

		/**
		 * 通知ウインドウクリック時の動作: 次の通知を表示する
		 */
		public static const NOTIFY_WINDOW_CLICK_OPERATION_NEXT :String = "2";

	}
}
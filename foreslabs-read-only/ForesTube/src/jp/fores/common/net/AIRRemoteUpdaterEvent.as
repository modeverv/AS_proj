package jp.fores.common.net
{
	import flash.events.Event;

	/**
	 * AIRアプリケーションのリモートアップデートで発生するイベント。
	 */
	public class AIRRemoteUpdaterEvent extends Event
	{
		//==========================================================
		//定数
		
		/**
		 * リモートバージョンの取得が完了した場合に投げられるイベントのイベント名
		 */
		public static const REMOTE_VERSION_CHECK :String = "remoteVersionCheck";
		
		/**
		 * リモートアップデートの直前に投げられるイベント
		 */
		public static const REMOTE_UPDATE :String = "remoteUpdate";
		
		
		//==========================================================
		//メソッド
		
		//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
		//コンストラクタ

		/**
		 * コンストラクタです。
		 * 
		 * @param Event.type としてアクセス可能なイベントタイプです。
		 * @param bubbles Event オブジェクトがイベントフローのバブリング段階で処理されるかどうかを判断します。デフォルト値は false です。
		 * @param cancelable Event オブジェクトがキャンセル可能かどうかを判断します。デフォルト値は true です
		 */
		public function AIRRemoteUpdaterEvent(type:String, bubbles :Boolean = false, cancelable :Boolean = true) 
		{
			//親のコンストラクタをそのまま呼び出す
			super(type, bubbles, cancelable);
		}
	}
}
package jp.fores.foresmessenger.dto
{
	/**
	 * メッセージ情報用DTOクラス。
	 */
	[Bindable]
	public class MessageDto
	{
		//==========================================================
		//フィールド
		
		/**
		 * 対象者の利用者情報
		 */
		public var targetUserInfo :UserInfoDto = null;
		
		/**
		 * 送信者の利用者情報
		 */
		public var sendUserInfo :UserInfoDto = null;
		
		/**
		 * 送信日時
		 */
		public var sendTime :Date = null;
		
		
		//==========================================================
		//メソッド
		
		//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
		//コンストラクタ
		
		/**
		 * コンストラクタです。
		 * 
		 * @param sendTime 送信日時(nullが指定された場合は現在日時を設定する, デフォルト値=null)
		 */
		public function MessageDto(sendTime :Date = null)
		{
			//引数の送信日時の値がnullの場合
			if(sendTime == null)
			{
				//フィールドの送信日時に現在日時を設定
				this.sendTime = new Date()
			}
			//それ以外の場合
			else
			{
				//フィールドの送信日時に引数の値を設定
				this.sendTime = sendTime
			}
		}
	}
}
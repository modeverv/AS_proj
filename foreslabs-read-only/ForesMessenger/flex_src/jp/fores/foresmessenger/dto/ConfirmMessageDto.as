package jp.fores.foresmessenger.dto
{
	/**
	 * 開封確認メッセージ情報用DTOクラス。
	 */
	[Bindable]
	public class ConfirmMessageDto extends MessageDto
	{
		//==========================================================
		//メソッド
		
		//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
		//コンストラクタ
		
		/**
		 * コンストラクタです。
		 * 
		 * @param originalMessage 元のメッセージ(デフォルト値=null)
		 * @param sendTime 送信日時(nullが指定された場合は現在日時を設定する, デフォルト値=null)
		 */
		public function ConfirmMessageDto(originalMessage :MessageDto = null, sendTime :Date = null)
		{
			//元のメッセージが指定された場合
			if(originalMessage != null)
			{
				//元のメッセージの対象者情報を送信者情報として設定する
				this.sendUserInfo = originalMessage.targetUserInfo;

				//元のメッセージの送信者情報を対象者情報として設定する
				this.targetUserInfo = originalMessage.sendUserInfo;
			}
			
			//送信日時が指定されていない場合
			if(sendTime == null)
			{
				//フィールドの送信日時に現在日時を設定
				this.sendTime = new Date();
			}
			//それ以外の場合
			else
			{
				//フィールドの送信日時に引数の値を設定
				this.sendTime = sendTime;
			}
		}
	}
}
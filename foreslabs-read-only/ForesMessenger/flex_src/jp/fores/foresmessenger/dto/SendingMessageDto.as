package jp.fores.foresmessenger.dto
{
	import flash.utils.ByteArray;
	
	import jp.fores.common.utils.StringUtil;
	
	/**
	 * 送信メッセージ情報用DTOクラス。
	 */
	[Bindable]
	public class SendingMessageDto extends MessageDto
	{
		//==========================================================
		//フィールド
		
		/**
		 * メッセージ本文
		 */
		public var bodyText :String = null;

		/**
		 * 添付ファイル情報の配列
		 */
		public var attachmentFileArray :Array = new Array();
		
		
		//==========================================================
		//メソッド
		
		//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
		//コンストラクタ
		
		/**
		 * コンストラクタです。
		 * 
		 * @param sendTime 送信日時(nullが指定された場合は現在日時を設定する, デフォルト値=null)
		 */
		public function SendingMessageDto(sendTime :Date = null)
		{
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

		//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
		//Getter
		
		/**
		 * URLをリンクに変換した本文を返します。
		 * 特殊文字は全てエスケープします。
		 * 
		 * @return URLを<a>タグで囲まれたリンクに変換した本文
		 */
		public function get urlToLinkBodyText() :String
		{
			//リンクの色を明るい水色に変更
			StringUtil.linkColor = "#d8fbff";
			
			//本文のXMLの特殊文字をエスケープした後、URLをリンクに変換して返す
			return StringUtil.convertURLToLink(StringUtil.escapeXML(this.bodyText));
		}
		
	}
}
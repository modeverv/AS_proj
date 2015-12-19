package jp.fores.foresmessenger.dto
{
	/**
	 * 利用者情報用DTOクラス。
	 */
	[Bindable]
	[RemoteClass(alias="jp.fores.foresmessenger.dto.UserInfoDto")]
	public class UserInfoDto
	{
		//==========================================================
		//フィールド
		
		/**
		 * 利用者ID
		 */
		public var userID :String = null;
		
		/**
		 * 利用者名
		 */
		public var userName :String = null;
		
		/**
		 * グループ名
		 */
		public var groupName :String = null;

		/**
		 * IPアドレス
		 */
		public var ipAddress :String = null;

		/**
		 * ログイン時間
		 */
		public var loginTime :Date = null;

		/**
		 * 	アイドル秒数
		 */
		public var idleSecond :Number = 0;

		/**
		 * クライアントのバージョン
		 */
		public var clientVersion :String = null;

	}
}
package jp.fores.foresmessenger.service;

import jp.fores.foresmessenger.dto.UserInfoDto;

import org.seasar.flex2.rpc.remoting.service.annotation.RemotingService;

/**
 * メッセンジャー用サービスのインターフェース。<br>
 */
@RemotingService
public interface MessengerService {

	//==========================================================
	//メソッド

	//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
	//抽象メソッド

	/**
	 * ログイン処理を行います。
	 * 
	 * @param userInfo 利用者情報用DTO
	 * @return サーバー側で取得した情報を含めた利用者情報用DTO
	 * @throws Exception 例外
	 */
	public UserInfoDto doLogin(UserInfoDto userInfo) throws Exception;

	/**
	 * ログアウト処理を行います。
	 * 
	 * @throws Exception 例外
	 */
	public void doLogout() throws Exception;

	/**
	 * 利用者情報の変更を行います。
	 * 
	 * @param newUserName 新しい利用者名
	 * @param newGroupName 新しいグループ名
	 * @return サーバー側で取得した情報を含めた利用者情報用DTO
	 * @throws Exception 例外
	 */
	public UserInfoDto changeUserInfo(String newUserName, String newGroupName)
			throws Exception;

	/**
	 * ログインしている利用者のアイドル秒数を変更した後、ログインしている全ての利用者の一覧を取得します。。<br>
	 * 
	 * @param idleSecond アイドル秒数
	 * @return ログインしている全ての利用者の一覧
	 * @throws Exception 例外
	 */
	public UserInfoDto[] changeIdleSecond(long idleSecond) throws Exception;

	/**
	 * ログインしている全ての利用者の一覧を取得します。<br>
	 * 
	 * @return ログインしている全ての利用者の一覧
	 * @throws Exception 例外
	 */
	public UserInfoDto[] getLoginUserList() throws Exception;

	/**
	 * セッションをキープします。<br>
	 * 
	 * @throws Exception 例外
	 */
	public void keepSession() throws Exception;

}

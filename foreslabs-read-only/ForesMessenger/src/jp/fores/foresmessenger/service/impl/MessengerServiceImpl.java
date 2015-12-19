package jp.fores.foresmessenger.service.impl;

import java.util.ArrayList;
import java.util.Enumeration;
import java.util.List;

import javax.servlet.http.HttpSession;

import jp.fores.foresmessenger.dto.UserInfoDto;
import jp.fores.foresmessenger.logic.LoginManager;
import jp.fores.foresmessenger.service.MessengerService;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.seasar.flex2.rpc.remoting.service.annotation.RemotingService;
import org.seasar.framework.container.factory.SingletonS2ContainerFactory;

/**
 * メッセンジャー用サービスの実装クラス。<br>
 */
@RemotingService
public class MessengerServiceImpl implements MessengerService {

	//==========================================================
	//定数

	/**
	 * ログ出力用
	 */
	private static final Log log = LogFactory.getLog(MessengerServiceImpl.class);


	//==========================================================
	//メソッド

	//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
	//インターフェースの実装

	/**
	 * ログイン処理を行います。
	 * 
	 * @param userInfo 利用者情報用DTO
	 * @return サーバー側で取得した情報を含めた利用者情報用DTO
	 * @throws Exception 例外
	 */
	public UserInfoDto doLogin(UserInfoDto userInfo) throws Exception {
		//デバッグログが有効な場合
		if (log.isDebugEnabled()) {
			//デバッグログ出力
			log.debug("☆☆☆☆☆ ログイン処理を行います。 ☆☆☆☆☆");
		}

		//Seasarのコンテナからセッションオブジェクトを取得
		HttpSession session = (HttpSession) SingletonS2ContainerFactory.getContainer().getExternalContext().getSession();

		//セッションに利用者情報を登録する
		//(利用者情報用DTOクラスはHttpSessionBindingListenerを実装しているので、これだけでログイン管理クラスのログイン処理も行われる)
		session.setAttribute("UserInfo", userInfo);

		//デバッグログが有効な場合
		if (log.isDebugEnabled()) {
			//デバッグログ出力
			log.debug("ログインに成功しました:" + userInfo);
		}


		//利用者情報を返す
		return userInfo;
	}

	/**
	 * ログアウト処理を行います。
	 * 
	 * @throws Exception 例外
	 */
	public void doLogout() throws Exception {
		//==========================================================
		//セッションのクリア
		//(invalidate()でセッションを破棄してしまうと、このメソッドを抜けた後にsetAttribute()が呼ばれてエラーになってしまうため)

		//Seasarのコンテナからセッションオブジェクトを取得
		HttpSession session = (HttpSession) SingletonS2ContainerFactory.getContainer().getExternalContext().getSession();

		//セッションから利用者情報を取得する
		UserInfoDto userInfo = (UserInfoDto) session.getAttribute("UserInfo");

		//利用者情報が取得できた場合
		if (userInfo != null) {
			//デバッグログが有効な場合
			if (log.isDebugEnabled()) {
				//デバッグログ出力
				log.debug("☆☆☆☆☆ '" + userInfo.userName + "("
						+ userInfo.groupName + ") [" + userInfo.ipAddress
						+ "] - " + userInfo.userID + "'がログアウト処理を呼び出しました。 ☆☆☆☆☆");
			}
		}

		//作業用リスト
		List<String> tempList = new ArrayList<String>();

		//セッションの属性名のEnumerationの値を一度作業用リストに退避させる
		//(直接removeAttribute()を呼び出すと、java.util.ConcurrentModificationExceptionが発生してしまうため)
		for (Enumeration enume = session.getAttributeNames(); enume.hasMoreElements();) {
			tempList.add((String) enume.nextElement());
		}

		//作業用リストに退避した全ての値に対して処理を行う
		for (String name : tempList) {
			//セッションの値を削除する
			//(利用者情報用DTOクラスはHttpSessionBindingListenerを実装しているので、これだけでログイン管理クラスのログアウト処理も行われる)
			session.removeAttribute(name);
		}
	}

	/**
	 * 利用者情報の変更を行います。
	 * 
	 * @param newUserName 新しい利用者名
	 * @param newGroupName 新しいグループ名
	 * @return サーバー側で取得した情報を含めた利用者情報用DTO
	 * @throws Exception 例外
	 */
	public UserInfoDto changeUserInfo(String newUserName, String newGroupName)
			throws Exception {
		//Seasarのコンテナからセッションオブジェクトを取得
		HttpSession session = (HttpSession) SingletonS2ContainerFactory.getContainer().getExternalContext().getSession();

		//セッションから利用者情報を取得する
		UserInfoDto userInfo = (UserInfoDto) session.getAttribute("UserInfo");

		//利用者情報が取得できた場合
		if (userInfo != null) {
			//デバッグログが有効な場合
			if (log.isDebugEnabled()) {
				//デバッグログ出力
				log.debug("☆☆☆☆☆ '" + userInfo.userName + "("
						+ userInfo.groupName + ") [" + userInfo.ipAddress
						+ "] - " + userInfo.userID
						+ "'が利用者情報の変更処理を呼び出しました。 ☆☆☆☆☆");
			}

			//ログイン管理クラスの利用者情報の変更処理を呼び出す
			LoginManager.getInstance().changeUserInfo(userInfo, newUserName, newGroupName);
		}

		//変更した利用者情報を返す
		return userInfo;
	}

	/**
	 * ログインしている利用者のアイドル秒数を変更した後、ログインしている全ての利用者の一覧を取得します。。<br>
	 * 
	 * @param idleSecond アイドル秒数
	 * @return ログインしている全ての利用者の一覧
	 * @throws Exception 例外
	 */
	public UserInfoDto[] changeIdleSecond(long idleSecond) throws Exception {
		//Seasarのコンテナからセッションオブジェクトを取得
		HttpSession session = (HttpSession) SingletonS2ContainerFactory.getContainer().getExternalContext().getSession();

		//セッションから利用者情報を取得する
		UserInfoDto userInfo = (UserInfoDto) session.getAttribute("UserInfo");

		//利用者情報が取得できた場合
		if (userInfo != null) {
			//デバッグログが有効な場合
			if (log.isDebugEnabled()) {
				//デバッグログ出力
				log.debug("☆☆☆☆☆ '" + userInfo.userName + "("
						+ userInfo.groupName + ") [" + userInfo.ipAddress
						+ "] - " + userInfo.userID
						+ "'がアイドル秒数の変更処理を呼び出しました。 ☆☆☆☆☆\nアイドル秒数:" + idleSecond);
			}

			//引数のアイドル秒数をセッションから取得した利用者情報に設定する
			userInfo.idleSecond = idleSecond;
		}

		//ログインしている全ての利用者の配列を取得する処理を呼び出して、結果をそのまま返す
		return LoginManager.getInstance().getLoginUserArray();
	}

	/**
	 * ログインしている全ての利用者の一覧を取得します。<br>
	 * 
	 * @return ログインしている全ての利用者の一覧
	 * @throws Exception 例外
	 */
	public UserInfoDto[] getLoginUserList() throws Exception {
		//Seasarのコンテナからセッションオブジェクトを取得
		HttpSession session = (HttpSession) SingletonS2ContainerFactory.getContainer().getExternalContext().getSession();

		//セッションから利用者情報を取得する
		UserInfoDto userInfo = (UserInfoDto) session.getAttribute("UserInfo");

		//利用者情報が取得できた場合
		if (userInfo != null) {
			//デバッグログが有効な場合
			if (log.isDebugEnabled()) {
				//デバッグログ出力
				log.debug("☆☆☆☆☆ '" + userInfo.userName + "("
						+ userInfo.groupName + ") [" + userInfo.ipAddress
						+ "] - " + userInfo.userID
						+ "'がログインしている全ての利用者の一覧の取得処理を呼び出しました。 ☆☆☆☆☆");
			}
		}

		//ログインしている全ての利用者の配列を取得する処理を呼び出して、結果をそのまま返す
		return LoginManager.getInstance().getLoginUserArray();
	}

	/**
	 * セッションをキープします。<br>
	 * 
	 * @return 「OK」という文字列
	 * @throws Exception 例外
	 */
	public void keepSession() throws Exception {
		//Seasarのコンテナからセッションオブジェクトを取得
		HttpSession session = (HttpSession) SingletonS2ContainerFactory.getContainer().getExternalContext().getSession();

		//セッションから利用者情報を取得する
		UserInfoDto userInfo = (UserInfoDto) session.getAttribute("UserInfo");

		//利用者情報が取得できた場合
		if (userInfo != null) {
			//デバッグログが有効な場合
			if (log.isDebugEnabled()) {
				//デバッグログ出力
				log.debug("☆☆☆☆☆ '" + userInfo.userName + "("
						+ userInfo.groupName + ") [" + userInfo.ipAddress
						+ "] - " + userInfo.userID
						+ "'がセッションキープ処理を呼び出しました。 ☆☆☆☆☆");
			}
		}
	}
}

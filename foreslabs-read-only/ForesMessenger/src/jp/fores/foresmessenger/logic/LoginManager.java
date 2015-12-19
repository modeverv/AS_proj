package jp.fores.foresmessenger.logic;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.WeakHashMap;

import javax.servlet.http.HttpServletRequest;

import jp.fores.common.util.DateUtil;
import jp.fores.common.util.RequestAnalyzer;
import jp.fores.common.util.StringUtil;
import jp.fores.foresmessenger.dto.UserInfoDto;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.seasar.framework.container.factory.SingletonS2ContainerFactory;

import flex.messaging.MessageBroker;
import flex.messaging.MessageDestination;
import flex.messaging.messages.AsyncMessage;
import flex.messaging.services.MessageService;
import flex.messaging.util.UUIDUtils;

/**
 * ログインしている利用者の情報を管理するためのクラス。<br>
 * <i>(SingletonパターンのSingleton役)</i><br>
 */
public class LoginManager {

	//==========================================================
	//定数

	/**
	 * メッセージサービスのID
	 */
	public static final String MESSAGE_SERVICE_ID = "message-service";

	/**
	 * アクセスログ出力用
	 */
	private static final Log accessLog = LogFactory.getLog("ACCESS_LOG");

	/**
	 * ログ出力用
	 */
	private static final Log log = LogFactory.getLog(LoginManager.class);

	/**
	 * 自分自身のクラスの唯一のインスタンス
	 */
	private static final LoginManager singleton = new LoginManager();


	//==========================================================
	//フィールド

	//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
	//インスタンス変数

	/**
	 * ログインしている利用者のMap
	 * (ガベージコレクションの対象となるように弱参照マップにしておく)
	 * (同時アクセスされた場合を考慮して、一応synchronizedMapにしておく)
	 */
	private final Map<String, UserInfoDto> loginUserMap = Collections.synchronizedMap(new WeakHashMap<String, UserInfoDto>());


	//==========================================================
	//メソッド

	//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
	//コンストラクタ

	/**
	 * コンストラクタです。<br>
	 * (他のクラスからアクセスできないようにわざとprivateにしています。)<br>
	 */
	private LoginManager() {
		//基底クラスのコンストラクタの呼び出し
		super();
	}


	//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
	//クラスメソッド

	/**
	 * このクラスの唯一のインスタンスを返します。<br>
	 *
	 * @return このクラスの唯一のインスタンス
	 */
	public static LoginManager getInstance() {
		//このクラスの唯一のインスタンスを返す
		return singleton;
	}


	//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
	//通常のメソッド

	/**
	 * 利用者のログイン時の処理を行います。
	 * 
	 * @param userInfo 利用者情報
	 */
	public void login(UserInfoDto userInfo) {
		//==========================================================
		//利用者情報の設定

		//利用者情報の利用者IDにユニークなIDを設定
		userInfo.userID = UUIDUtils.createUUID();

		//利用者情報のログイン日時に現在日時を設定
		userInfo.loginTime = DateUtil.getCurrentDate();

		//利用者情報のIPアドレスにリクエストヘッダの情報から取得したクライアントのIPアドレスを設定
		userInfo.ipAddress = getClientIPAddress();

		//フィールドのログインしている利用者のMapに、利用者IDをキーにして引数の値を登録
		this.loginUserMap.put(userInfo.userID, userInfo);


		//==========================================================
		//追加された利用者用のプッシュ配信の宛先を動的に作成

		//メッセージブローカーのインスタンスを取得
		MessageBroker messageBroker = MessageBroker.getMessageBroker(null);

		//メッセージブローカーからメッセージサービスのIDをキーにしてサービスのインスタンスを取得
		MessageService service = (MessageService) messageBroker.getService(MESSAGE_SERVICE_ID);

		//利用者情報の利用者IDをキーにして宛先を動的に作成
		MessageDestination destination = (MessageDestination) service.createDestination(userInfo.userID);

		//サービスが開始されている場合
		if (service.isStarted()) {
			//宛先も開始する
			destination.start();
		}

		//デバッグログが有効な場合
		if (log.isDebugEnabled()) {
			//デバッグログ出力
			log.debug("宛先一覧:" + service.getDestinations().keySet());
		}


		//==========================================================
		//ログイン通知をプッシュ配信する
		pushLoginNotify(userInfo, "login");


		//==========================================================
		//アクセスログ出力
		accessLog.info("'" + userInfo.userName + "(" + userInfo.groupName
				+ ") [" + userInfo.ipAddress + "] - " + userInfo.userID
				+ "' がログインしました。");
	}

	/**
	 * 利用者のログアウト時の処理を行います。
	 * 
	 * @param userInfo 利用者情報
	 */
	public void logout(UserInfoDto userInfo) {
		//==========================================================
		//フィールドのログインしている利用者のMapから引数の利用者情報を除去
		if (this.loginUserMap.remove(userInfo.userID) == null) {
			//Mapに登録されていない情報の場合は以降の処理を行わない
			//(おそらく前回のサーバー停止時に残っていたセッション情報のため)
			return;
		}


		//==========================================================
		//ログアウトした利用者用のプッシュ配信の宛先を動的に削除

		//メッセージブローカーのインスタンスを取得
		MessageBroker messageBroker = MessageBroker.getMessageBroker(null);

		//メッセージブローカーからメッセージサービスのIDをキーにしてサービスのインスタンスを取得
		MessageService service = (MessageService) messageBroker.getService(MESSAGE_SERVICE_ID);

		//利用者情報の利用者IDをキーにして宛先を取得
		MessageDestination destination = (MessageDestination) service.getDestination(userInfo.userID);

		//宛先が取得できた場合
		if (destination != null) {
			try {
				//宛先のIDをキーにして宛先をサービスから削除する
				service.removeDestination(destination.getId());
			}
			//例外処理
			catch (Exception e) {
				//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
				//再チャレンジする

				//デバッグログが有効な場合
				if (log.isDebugEnabled()) {
					//デバッグログ出力
					log.debug("★★★★★★★ 宛先の停止中に例外が発生しましたので再チャレンジします。 ★★★★★★★");
				}

				try {
					//宛先のコントロールに、固定で存在する宛先のコントロールを設定する
					//(すごく無理矢理だがこうすると比較的安定するため)
					destination.setControl(((MessageDestination) service.getDestination("serverConditionNotify")).getControl());

					//宛先のIDをキーにして宛先をサービスから削除する
					service.removeDestination(destination.getId());
				}
				//例外処理
				catch (Exception ex) {
					//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
					//どうしようもないのでログを出力するだけにしておく

					//デバッグログが有効な場合
					if (log.isDebugEnabled()) {
						//デバッグログ出力
						log.debug("★★★★★★★ 再チャレンジしてもやっぱり宛先の停止に失敗しました。 ★★★★★★★", e);
					}
				}
			}
		}

		//デバッグログが有効な場合
		if (log.isDebugEnabled()) {
			//デバッグログ出力
			log.debug("宛先一覧:" + service.getDestinations().keySet());
		}


		//==========================================================
		//ログイン通知をプッシュ配信する
		pushLoginNotify(userInfo, "logout");


		//==========================================================
		//アクセスログ出力
		accessLog.info("'" + userInfo.userName + "(" + userInfo.groupName
				+ ") [" + userInfo.ipAddress + "] - " + userInfo.userID
				+ "' がログアウトしました。");
	}

	/**
	 * 利用者情報の変更処理を行います。
	 * 
	 * @param userInfo 利用者情報
	 * @param newUserName 新しい利用者名
	 * @param newGroupName 新しいグループ名
	 */
	public void changeUserInfo(UserInfoDto userInfo, String newUserName,
			String newGroupName) {
		//==========================================================
		//利用者情報の変更

		//古い利用者名とグループ名を退避
		String oldUserName = userInfo.userName;
		String oldGroupName = userInfo.groupName;

		//新しい利用者名とグループ名を設定
		userInfo.userName = newUserName;
		userInfo.groupName = newGroupName;


		//==========================================================
		//ログインしている全ての利用者の配列をプッシュ配信する
		pushLoginUserArray();


		//==========================================================
		//アクセスログ出力
		accessLog.info("'" + userInfo.userID + "' [" + userInfo.ipAddress
				+ "] - の利用者情報が変更されました。" + oldUserName + "(" + oldGroupName
				+ ") → " + newUserName + "(" + newGroupName + ")");

	}

	/**
	 * ログインしている全ての利用者の配列を取得します。<br>
	 * 
	 * @return userInfo 利用者情報の配列
	 */
	public UserInfoDto[] getLoginUserArray() {
		//フィールドのログインしている利用者のMapの値のを配列に変換して返す
		return this.loginUserMap.values().toArray(new UserInfoDto[0]);
	}


	//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
	//内部処理用

	/**
	 * ログインしている全ての利用者の配列をプッシュ配信します。<br>
	 */
	private void pushLoginUserArray() {
		//ログインしている全ての利用者の配列を取得
		UserInfoDto[] loginUserArray = getLoginUserArray();

		//デバッグログが有効な場合
		if (log.isDebugEnabled()) {
			//デバッグログ出力
			log.debug("=== ログインしている全ての利用者の配列をプッシュ配信 ===\n"
					+ StringUtil.convertDebugString(loginUserArray));
		}

		//メッセージブローカーのインスタンスを取得
		MessageBroker messageBroker = MessageBroker.getMessageBroker(null);

		//非同期メッセージのインスタンスを生成
		AsyncMessage msg = new AsyncMessage();

		//宛先を設定
		msg.setDestination("loginUserList");

		//クライアントIDにユニークなIDを設定
		msg.setClientId(UUIDUtils.createUUID());

		//メッセージIDにユニークなIDを設定
		msg.setMessageId(UUIDUtils.createUUID());

		//タイムスタンプを設定
		msg.setTimestamp(System.currentTimeMillis());

		//ヘッダにメッセージタイプを設定
		//(クライアント側での処理判別のため)
		msg.setHeader("messageType", "serverPush");

		//ボディーにログインしている全ての利用者の配列を設定
		msg.setBody(loginUserArray);

		//メッセージブローカーを使って作成したメッセージのプッシュ配信を行う
		messageBroker.routeMessageToService(msg, null);
	}

	/**
	 * ログイン通知をプッシュ配信します。<br>
	 * 
	 * @return userInfo 利用者情報
	 * @param loginType ログインタイプ(loginまたはlogout)
	 */
	private void pushLoginNotify(UserInfoDto userInfo, String loginType) {
		//デバッグログが有効な場合
		if (log.isDebugEnabled()) {
			//デバッグログ出力
			log.debug("=== ログイン通知をプッシュ配信 ===\n    loginType=" + loginType
					+ "\n    利用者情報=" + userInfo);
		}

		//メッセージブローカーのインスタンスを取得
		MessageBroker messageBroker = MessageBroker.getMessageBroker(null);

		//非同期メッセージのインスタンスを生成
		AsyncMessage msg = new AsyncMessage();

		//宛先を設定
		msg.setDestination("loginNotify");

		//クライアントIDにユニークなIDを設定
		msg.setClientId(UUIDUtils.createUUID());

		//メッセージIDにユニークなIDを設定
		msg.setMessageId(UUIDUtils.createUUID());

		//タイムスタンプを設定
		msg.setTimestamp(System.currentTimeMillis());

		//ヘッダにメッセージタイプを設定
		//(クライアント側での処理判別のため)
		msg.setHeader("messageType", "serverPush");

		//ヘッダにログインタイプを設定
		msg.setHeader("loginType", loginType);

		//ボディーに引数の利用者情報を設定
		msg.setBody(userInfo);

		//メッセージブローカーを使って作成したメッセージのプッシュ配信を行う
		messageBroker.routeMessageToService(msg, null);
	}

	/**
	 * リクエストヘッダの情報を元に、クライアントのIPアドレスを取得します。<br>
	 * 取得できなかった場合は、「不明」という文字列を返します。
	 *
	 * @return クライアントのIPアドレス
	 */
	private String getClientIPAddress() {
		//Seasarのコンテナからリクエストオブジェクトを取得
		HttpServletRequest request = (HttpServletRequest) SingletonS2ContainerFactory.getContainer().getExternalContext().getRequest();

		//デバッグログが有効な場合
		if (log.isDebugEnabled()) {
			log.debug("リクエスト情報:"
					+ RequestAnalyzer.toStringAllRequestInfo(request));
		}

		//「x-forwarded-for」ヘッダの値を取得
		//(Apache - Tomcat連携を行っている場合は、オリジナルのIPアドレスはこちらから取得する)
		String ipAddress = request.getHeader("x-forwarded-for");

		//値が取得できた場合
		if (!StringUtil.isBlank(ipAddress)) {
			//取得した値に「,」が含まれている場合
			//(複数のプロキシを経由した場合などにありえる)
			if (ipAddress.indexOf(",") != -1) {
				//==========================================================
				//外部アドレスが先に表示されるようにするために順番を逆にする

				//「,」を区切り文字にして配列に変換
				String[] ipAddressArray = StringUtil.split(ipAddress);

				//配列をListに変換
				//(asListで返ってきたListはそれ以上操作できないので、ArrayListに変換する)
				List<String> ipAddressList = new ArrayList<String>(Arrays.asList(ipAddressArray));

				//Listの順番を逆にする
				Collections.reverse(ipAddressList);

				//Listを「, 」区切りで結合した文字列に変換して返す
				return StringUtil.combineStringCollection(ipAddressList, ", ");
			}

			//取得した値を返す
			return ipAddress;
		}

		//リモートアドレスの値を取得
		ipAddress = request.getRemoteAddr();

		//値が取得できた場合
		if (!StringUtil.isBlank(ipAddress)) {
			//取得した値を返す
			return ipAddress;
		}

		//取得できなかったので「不明」という文字を返す
		return "不明";
	}
}

package jp.fores.foresmessenger.dto;

import java.io.Serializable;
import java.util.Date;

import javax.servlet.http.HttpSessionBindingEvent;
import javax.servlet.http.HttpSessionBindingListener;

import jp.fores.common.util.ExtendPropertyUtils;
import jp.fores.foresmessenger.logic.LoginManager;

/**
 * 利用者情報用DTOクラス。
 */
public class UserInfoDto implements Serializable, HttpSessionBindingListener {

	//==========================================================
	//フィールド

	/**
	 * 利用者ID
	 */
	public String userID = null;

	/**
	 * 利用者名
	 */
	public String userName = null;

	/**
	 * グループ名
	 */
	public String groupName = null;

	/**
	 * IPアドレス
	 */
	public String ipAddress = null;

	/**
	 * ログイン時間
	 */
	public Date loginTime = null;

	/**
	 * 	アイドル秒数
	 */
	public long idleSecond = 0;

	/**
	 * クライアントのバージョン
	 */
	public String clientVersion = null;


	//==========================================================
	//メソッド

	//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
	//インターフェースの実装

	/**
	 * セッションに関連付けられた場合の処理を行います。<br>
	 *
	 * @param eventArg イベント
	 */
	public void valueBound(HttpSessionBindingEvent eventArg) {
		//ログイン管理クラスのログイン処理を呼び出す
		LoginManager.getInstance().login(this);
	}

	/**
	 * セッションから切り離された場合の処理を行います。<br>
	 *
	 * @param eventArg イベント
	 */
	public void valueUnbound(HttpSessionBindingEvent eventArg) {
		//ログイン管理クラスのログアウト処理を呼び出す
		LoginManager.getInstance().logout(this);
	}


	//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
	//オーバーライドするメソッド

	/**
	 * 文字列表現を返します。<br>
	 * 
	 * @return 文字列表現
	 */
	@Override
	public String toString() {
		try {
			//JavaBeanの内容を読みやすい形式の文字列に変換して返すメソッドに
			//自分自身のインスタンスを渡して、結果をそのまま返す
			return ExtendPropertyUtils.beanToString(this);
		}
		//例外が発生した場合
		catch (Exception e) {
			//仕方がないので親クラスで定義されているtoString()を呼び出す
			return super.toString();
		}
	}

}

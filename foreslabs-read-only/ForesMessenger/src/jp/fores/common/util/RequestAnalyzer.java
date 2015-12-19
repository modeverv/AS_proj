package jp.fores.common.util;

import java.util.Enumeration;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;


/**
 * リクエスト解析用ユーティリティクラス。<br>
 * <br>
 * リクエスト解析用の各種便利関数を実装しています。<br>
 * デバッグログの出力などに使用して下さい。<br>
 */
public final class RequestAnalyzer {

	//==========================================================
	//定数

	/**
	 * ログ出力用
	 */
	private static final Log log = LogFactory.getLog(RequestAnalyzer.class);


	//==========================================================
	//メソッド

	//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
	//コンストラクタ

	/**
	 * コンストラクタです。<br>
	 * (クラスメソッドのみのユーティリティークラスなので、privateにしてインスタンスを作成できないようにしています。)<br>
	 */
	private RequestAnalyzer() {
		//基底クラスのコンストラクタの呼び出し
		super();
	}


	//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
	//クラスメソッド

	/**
	 * リクエストに含まれる有益な情報(リクエストヘッダ情報, リクエストパラメータ情報, リクエスト属性情報, セッション情報)を文字列として取得します。<br>
	 *
	 * @param requestArg リクエスト
	 * @return リクエストに含まれる有益な情報
	 */
	public static String toStringAllRequestInfo(HttpServletRequest requestArg) {
		//作業用StringBufferのインスタンスを生成
		StringBuffer sb = new StringBuffer();

		//リクエストヘッダ情報を追加
		sb.append("<< Request Header Info >>\n");
		sb.append(toStringRequestHeaderInfo(requestArg));
		sb.append("\n");

		//リクエストパラメータ情報を追加
		sb.append("<< Request Parameter Info >>\n");
		sb.append(toStringRequestParameterInfo(requestArg));
		sb.append("\n");

		//リクエスト属性情報を追加
		sb.append("<< Request Attribute Info >>\n");
		sb.append(toStringRequestAttributeInfo(requestArg));
		sb.append("\n");

		//セッション情報を追加
		sb.append("<< Session Info >>\n");
		sb.append(toStringSessionInfo(requestArg.getSession()));


		//結果を文字列に変換して返す
		return sb.toString();
	}

	/**
	 * リクエストのヘッダ情報を文字列として取得します。<br>
	 * ついでに、ヘッダには含まれていない有益な情報(RequestURL, RemoteHost, RemoteAddr)も一緒に取得します。<br>
	 *
	 * @param requestArg リクエスト
	 * @return リクエストのヘッダ情報
	 */
	public static String toStringRequestHeaderInfo(HttpServletRequest requestArg) {
		//作業用StringBufferのインスタンスを生成
		StringBuffer sb = new StringBuffer();

		//==========================================================
		//全てのリクエストヘッダの情報を取得

		//リクエストに含まれる全てのヘッダ名のEnumerationを取得
		Enumeration enume = requestArg.getHeaderNames();

		//全てのヘッダ名に対して処理を行う
		while (enume.hasMoreElements()) {
			//ヘッダ名を取得
			String name = (String) enume.nextElement();

			//ヘッダ名とそれに対応する値を追加
			sb.append(name + " = " + requestArg.getHeader(name) + "\n");
		}


		//==========================================================
		//リクエストヘッダには含まれないが有益な情報を追加
		sb.append("RequestURL = " + requestArg.getRequestURL() + "\n");
		sb.append("RemoteHost = " + requestArg.getRemoteHost() + "\n");
		sb.append("RemoteAddr = " + requestArg.getRemoteAddr() + "\n");

		//結果を文字列に変換して返す
		return sb.toString();
	}

	/**
	 * 全てのリクエストパラメータの情報を文字列として取得します。<br>
	 *
	 * @param requestArg リクエスト
	 * @return 全てのリクエストパラメータの情報
	 */
	public static String toStringRequestParameterInfo(
			HttpServletRequest requestArg) {
		//作業用StringBufferのインスタンスを生成
		StringBuffer sb = new StringBuffer();

		//==========================================================
		//全てのリクエストパラメータの情報を取得

		//全てのリクエストパラメータ名のEnumerationを取得
		Enumeration enume = requestArg.getParameterNames();

		//全てのパラメータ名に対して処理を行う
		while (enume.hasMoreElements()) {
			//パラメータ名を取得
			String name = (String) enume.nextElement();

			//パラメータ名とそれに対応する値を追加
			//(値は配列をデバッグに適した文字列に変換する)
			sb.append(name
					+ " = "
					+ StringUtil.convertDebugString(requestArg.getParameterValues(name))
					+ "\n");
		}

		//結果を文字列に変換して返す
		return sb.toString();
	}

	/**
	 * リクエストに関連付けられた全ての属性の情報を文字列として取得します。<br>
	 *
	 * @param requestArg リクエスト
	 * @return リクエストに関連付けられた全ての属性の情報
	 */
	public static String toStringRequestAttributeInfo(
			HttpServletRequest requestArg) {
		//作業用StringBufferのインスタンスを生成
		StringBuffer sb = new StringBuffer();

		//==========================================================
		//リクエストに関連付けられた全ての属性の情報を取得

		//リクエストに含まれる全ての属性名のEnumerationを取得
		Enumeration enume = requestArg.getAttributeNames();

		//全ての属性名に対して処理を行う
		while (enume.hasMoreElements()) {
			//属性名を取得
			String name = (String) enume.nextElement();

			//属性名とそれに対応する値を追加
			//(値はデバッグに適した文字列に変換する)
			sb.append(name
					+ " = "
					+ StringUtil.convertDebugString(requestArg.getAttribute(name))
					+ "\n");
		}

		//結果を文字列に変換して返す
		return sb.toString();
	}

	/**
	 * セッションのID, 保持期間, 関連付けられた全ての属性の情報を文字列として取得します。<br>
	 *
	 * @param sessionArg セッション
	 * @return セッションのID, 保持期間, 関連付けられた全ての属性の情報
	 */
	public static String toStringSessionInfo(HttpSession sessionArg) {
		//作業用StringBufferのインスタンスを生成
		StringBuffer sb = new StringBuffer();

		//==========================================================
		//セッションのID, 保持期間を追加
		sb.append("ID = " + sessionArg.getId() + "\n");
		sb.append("MaxInactiveInterval = "
				+ sessionArg.getMaxInactiveInterval() + "\n");
		sb.append("\n");


		//==========================================================
		//セッションに関連付けられた全ての属性の情報を取得

		//セッションに含まれる全ての属性名のEnumerationを取得
		Enumeration enume = sessionArg.getAttributeNames();

		//全ての属性名に対して処理を行う
		while (enume.hasMoreElements()) {
			//属性名を取得
			String name = (String) enume.nextElement();

			//属性名とそれに対応する値のクラス名を追加
			//(値の内容まで出力すると過剰に出力されすぎるので、クラス名だけにとどめる)
			sb.append(name + " = "
					+ sessionArg.getAttribute(name).getClass().getName() + "\n");
		}

		//結果を文字列に変換して返す
		return sb.toString();
	}

}

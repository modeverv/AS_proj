package jp.fores.common.filter;

//==========================================================
//import

//J2SE
import java.util.ArrayList;
import java.util.Collections;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletRequestWrapper;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;


/**
 * 日本語対応を施したHttpServletRequestのWrapper。<br>
 */
public class JapaneseRequestWrapper extends HttpServletRequestWrapper {
	//==========================================================
	//定数

	/**
	 * ログ出力用
	 */
	private static final Log log = LogFactory.getLog(JapaneseRequestWrapper.class);


	//==========================================================
	//フィールド

	/**
	 * 文字エンコーディング
	 */
	protected String encoding = null;

	/**
	 * 日本語パラメーターが存在したかどうかのフラグ<br>
	 * (日本語パラメーターが存在しない場合に高速に処理を行うために使用)
	 */
	protected boolean existJapaneseParameterFlag = false;

	/**
	 * 日本語パラメーターのMap
	 */
	protected Map<String, String[]> japaneseParametersMap = new HashMap<String, String[]>();

	/**
	 * 削除されたパラメーターのSet
	 */
	protected Set<String> removedParameterSet = new HashSet<String>();


	//==========================================================
	//メソッド

	//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
	//コンストラクタ

	/**
	 * コンストラクタです。<br>
	 *
	 * @param requestArg HttpServletRequest
	 * @param encoding 文字エンコーディング
	 */
	public JapaneseRequestWrapper(HttpServletRequest requestArg, String encoding) {
		//基底クラスの引数付きコンストラクタの呼び出し
		super(requestArg);

		//引数の文字エンコーディングをフィールドに設定
		this.encoding = encoding;

		//リクエストの全てのパラメーターに対して処理を行う
		for (Enumeration enume = requestArg.getParameterNames(); enume.hasMoreElements();) {
			//元のパラメーター名を取得
			String original = (String) enume.nextElement();

			//パラメーターを日本語に変換
			String japaneseString = convertToJapaneseString(original);

			//元のパラメーターと日本語に変換したパラメーターが異なる場合
			if (!original.equals(japaneseString)) {
				//元のパラメーターの値を取得
				String[] originalValues = requestArg.getParameterValues(original);

				//元のパラメーター名を、フィールドの削除されたパラメーターのSetに追加
				this.removedParameterSet.add(original);

				//日本語パラメーターのMapに、日本語に変換したパラメーター名をキーにして先ほど取得した値を登録
				this.japaneseParametersMap.put(japaneseString, originalValues);

				//日本語パラメーターが存在したのでフラグをたてる
				this.existJapaneseParameterFlag = true;
			}
		}
	}

	//==========================================================
	//通常のメソッド

	/**
	 * クライアントから入力された日本語を含む文字列を、サーバー上で扱えるようにします。<br>
	 * 例外が発生した場合は、与えられた文字列をそのまま返します。<br>
	 *
	 * @param strArg クライアントから入力された文字列
	 * @return 日本語の文字列(例外が発生した場合はそのまま)
	 */
	public String convertToJapaneseString(String strArg) {
		try {
			//nullの場合
			if (strArg == null) {
				//nullを返す
				return null;
			}
			//nullでない場合
			else {
				//一度バイトコードに分解してから、フィールドの文字エンコーディングで組み立て直す
				return new String(strArg.getBytes("ISO_8859_1"), this.encoding);
			}
		}
		//例外が発生した場合
		catch (Exception e) {
			//与えられた文字列をそのまま返す
			return strArg;
		}
	}


	//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
	//オーバーライドするメソッド

	/**
	 * 指定した名前のパラメーターの値を取得します。<br>
	 * 見つからなかった場合はnullを返します。<br>
	 *
	 * @param nameArg パラメーター名
	 * @return パラメーターの値(見つからなかった場合はnull)
	 */
	@Override
	public String getParameter(String nameArg) {
		//基底クラスのメソッドを呼び出して値を取得する
		String value = super.getParameter(nameArg);

		//==========================================================
		//日本語パラメーターが存在しない場合
		//(日本語パラメーターが含まれることはごくまれなので、通常時に少しでも処理を軽くするため分岐する)
		if (!this.existJapaneseParameterFlag) {
			//日本語用変換を行ってから返す
			return convertToJapaneseString(value);
		}
		//==========================================================
		//日本語パラメーターが存在する場合
		else {
			//削除されたパラメーターの場合
			if (this.removedParameterSet.contains(nameArg)) {
				//nullを返す
				return null;
			}

			//値がnullの場合
			if (value == null) {
				//日本語パラメーターから取得する
				String[] japaneseParameterValue = this.japaneseParametersMap.get(nameArg);

				//日本語パラメーターが存在する場合
				if (japaneseParameterValue != null) {
					//日本語パラメーターの最初の値を使用する
					value = japaneseParameterValue[0];
				}

			}

			//日本語用変換を行ってから返す
			return convertToJapaneseString(value);
		}
	}

	/**
	 * 指定した名前のパラメーターの値の配列を取得します。<br>
	 * 見つからなかった場合はnullを返します。<br>
	 *
	 * @param nameArg パラメーター名
	 * @return パラメーターの値の配列(見つからなかった場合はnull)
	 */
	@Override
	public String[] getParameterValues(String nameArg) {
		//基底クラスのメソッドを呼び出して値の配列を取得する
		String values[] = super.getParameterValues(nameArg);

		//==========================================================
		//日本語パラメーターが存在しない場合
		//(日本語パラメーターが含まれることはごくまれなので、通常時に少しでも処理を軽くするため分岐する)
		if (!this.existJapaneseParameterFlag) {
			//値が見つからなかった場合
			if (values == null) {
				//nullを返す
				return null;
			}

			//日本語変換した値を入れる配列
			String japaneseValues[] = new String[values.length];

			//値の数に応じてループをまわす
			for (int i = 0; i < japaneseValues.length; i++) {
				//日本語変換する
				japaneseValues[i] = convertToJapaneseString(values[i]);
			}

			//日本語変換した値の配列を返す
			return japaneseValues;
		}
		//==========================================================
		//日本語パラメーターが存在する場合
		else {
			//削除されたパラメーターの場合
			if (this.removedParameterSet.contains(nameArg)) {
				//nullを返す
				return null;
			}

			//値が見つからなかった場合
			if (values == null) {
				//日本語パラメーターから取得する
				String[] japaneseParameterValue = this.japaneseParametersMap.get(nameArg);

				//日本語パラメーターが存在する場合
				if (japaneseParameterValue != null) {
					//日本語パラメーターの最初の値を使用する
					values = japaneseParameterValue;
				}
				//日本語パラメーターを探しても値が見つからなかった場合
				else {
					//nullを返す
					return null;
				}
			}

			//日本語変換した値を入れる配列
			String japaneseValues[] = new String[values.length];

			//値の数に応じてループをまわす
			for (int i = 0; i < japaneseValues.length; i++) {
				//日本語変換する
				japaneseValues[i] = convertToJapaneseString(values[i]);
			}

			//日本語変換した値の配列を返す
			return japaneseValues;
		}
	}

	/**
	 * このリクエストに含まれているパラメータ名を表す文字列のEnumerationを返します。<br>
	 * リクエストにパラメータが無い場合、空のEnumerationを返します。<br>
	 *
	 * @return パラメータ名を表す文字列のEnumeration
	 */
	@Override
	@SuppressWarnings("unchecked")
	public Enumeration getParameterNames() {
		//日本語パラメーターが存在しない場合
		if (!this.existJapaneseParameterFlag) {
			//基底クラスのメソッドを呼び出して、結果をそのまま返す
			return super.getParameterNames();
		}
		//日本語パラメーターが存在する場合
		else {
			//作業用List
			List list = new ArrayList();

			//基底クラスのメソッドを呼び出してEnumerationを取得し、その内容を作業用Listに移植
			for (Enumeration enume = super.getParameterNames(); enume.hasMoreElements();) {
				list.add(enume.nextElement());
			}

			//日本語パラメーターの全てのキーを、作業用Listに追加
			for (Iterator ite = this.japaneseParametersMap.keySet().iterator(); ite.hasNext();) {
				list.add(ite.next());
			}

			//削除されたパラメーターを作業用Listから削除する
			list.removeAll(this.removedParameterSet);

			//ListをEnumerationに変換して返す
			return Collections.enumeration(list);
		}
	}
}

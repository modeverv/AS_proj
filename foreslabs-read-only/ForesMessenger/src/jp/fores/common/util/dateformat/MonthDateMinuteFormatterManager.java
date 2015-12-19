package jp.fores.common.util.dateformat;

import java.util.Collections;
import java.util.HashMap;
import java.util.Map;
import java.util.Set;

import jp.fores.common.exception.DateFormatterNotFoundException;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;


/**
 * {@link MonthDateMinuteFormatter}を管理するクラス。<br>
 * <br>
 * このクラスでは、文字列をキーとして、{@link MonthDateMinuteFormatter}のインスタンスを登録します。<br>
 * 標準で登録されているフォーマットは以下の通りです。<br>
 * <table border="1">
 *  <tr bgcolor="deepskyblue">
 *      <td>&nbsp;</td>
 *      <td align="center"><strong>日本語用<br><font color="red">(デフォルト)</font></strong></td>
 *      <td align="center"><strong>日本語用(nullハイフン)</strong></td>
 *      <td align="center"><strong>日本語用(秒まで表示)</strong></td>
 *      <td align="center"><strong>日本語用(年無し)</strong></td>
 *  </tr>
 *  <tr>
 *      <td bgcolor="silver"><strong>登録キー</strong></td>
 *      <td>JAPANESE</td>
 *      <td>JAPANESE_NULL_HYPHEN</td>
 *      <td>JAPANESE_SECOND</td>
 *      <td>JAPANESE_NON_YEAR</td>
 *  </tr>
 *  <tr>
 *      <td bgcolor="silver"><strong>年･月</strong></td>
 *      <td>yyyy年MM月</td>
 *      <td>yyyy年MM月</td>
 *      <td>yyyy年MM月</td>
 *      <td>MM月</td>
 *  </tr>
 *  <tr>
 *      <td bgcolor="silver"><strong>年･月・日・時・分</strong></td>
 *      <td>yyyy年MM月dd日</td>
 *      <td>yyyy年MM月dd日</td>
 *      <td>yyyy年MM月dd日</td>
 *      <td>MM月dd日</td>
 *  </tr>
 *  <tr>
 *      <td bgcolor="silver"><strong>年･月・日・時・分</strong></td>
 *      <td>yyyy年MM月dd日 HH時mm分</td>
 *      <td>yyyy年MM月dd日 HH時mm分</td>
 *      <td>yyyy年MM月dd日 HH時mm分ss秒</td>
 *      <td>MM月dd日 HH時mm分</td>
 *  </tr>
 *  <tr>
 *      <td bgcolor="silver"><strong>年･月<br>(nullの場合)</strong></td>
 *      <td>&nbsp;</td>
 *      <td>----年--月</td>
 *      <td>&nbsp;</td>
 *      <td>&nbsp;</td>
 *  </tr>
 *  <tr>
 *      <td bgcolor="silver"><strong>年･月・日<br>(nullの場合)</strong></td>
 *      <td>&nbsp;</td>
 *      <td>----年--月--日</td>
 *      <td>&nbsp;</td>
 *      <td>&nbsp;</td>
 *  </tr>
 *  <tr>
 *      <td bgcolor="silver"><strong>年･月・日・時・分<br>(nullの場合)</strong></td>
 *      <td>&nbsp;</td>
 *      <td>----年--月--日 --時--分</td>
 *      <td>&nbsp;</td>
 *      <td>&nbsp;</td>
 *  </tr>
 * </table>
 * <br>
 * <table border="1">
 *  <tr bgcolor="deepskyblue">
 *      <td>&nbsp;</td>
 *      <td align="center"><strong>英語用</strong></td>
 *      <td align="center"><strong>英語用(nullハイフン)</strong></td>
 *      <td align="center"><strong>英語用(秒まで表示)</strong></td>
 *      <td align="center"><strong>英語用(年無し)</strong></td>
 *  </tr>
 *  <tr>
 *      <td bgcolor="silver"><strong>登録キー</strong></td>
 *      <td>ENGLISH</td>
 *      <td>ENGLISH_NULL_HYPHEN</td>
 *      <td>ENGLISH_SECOND</td>
 *      <td>ENGLISH_NON_YEAR</td>
 *  </tr>
 *  <tr>
 *      <td bgcolor="silver"><strong>年･月</strong></td>
 *      <td>yyyy/MM</td>
 *      <td>yyyy/MM</td>
 *      <td>yyyy/MM</td>
 *      <td>MM</td>
 *  </tr>
 *  <tr>
 *      <td bgcolor="silver"><strong>年･月・日・時・分</strong></td>
 *      <td>yyyy/MM/dd</td>
 *      <td>yyyy/MM/dd</td>
 *      <td>yyyy/MM/dd</td>
 *      <td>MM/dd</td>
 *  </tr>
 *  <tr>
 *      <td bgcolor="silver"><strong>年･月・日・時・分</strong></td>
 *      <td>yyyy/MM HH:mm</td>
 *      <td>yyyy/MM HH:mm</td>
 *      <td>yyyy/MM HH:mm:ss</td>
 *      <td>MM HH:mm</td>
 *  </tr>
 *  <tr>
 *      <td bgcolor="silver"><strong>年･月<br>(nullの場合)</strong></td>
 *      <td>&nbsp;</td>
 *      <td>----/--</td>
 *      <td>&nbsp;</td>
 *      <td>&nbsp;</td>
 *  </tr>
 *  <tr>
 *      <td bgcolor="silver"><strong>年･月・日<br>(nullの場合)</strong></td>
 *      <td>&nbsp;</td>
 *      <td>----/--/--</td>
 *      <td>&nbsp;</td>
 *      <td>&nbsp;</td>
 *  </tr>
 *  <tr>
 *      <td bgcolor="silver"><strong>年･月・日・時・分<br>(nullの場合)</strong></td>
 *      <td>&nbsp;</td>
 *      <td>----/--/-- --:--</td>
 *      <td>&nbsp;</td>
 *      <td>&nbsp;</td>
 *  </tr>
 * </table>
 * <br>
 * これ以外のフォーマットを登録したい場合は、registFormatter()メソッドを使って登録して下さい。<br>
 * また、デフォルトのフォーマットを変更したい場合は、setDefaultFormatter()メソッドを使って下さい。<br>
 * <br>
 *
 * @see MonthDateMinuteFormatter
 * @see ConcreteMonthDateMinuteFormatter
 */
public final class MonthDateMinuteFormatterManager {

	//==========================================================
	//定数

	/**
	 * ログ出力用インスタンス
	 */
	private static final Log log = LogFactory.getLog(MonthDateMinuteFormatterManager.class);

	/**
	 * 日本語用フォーマットの登録キー
	 */
	public static final String JAPANESE = "JAPANESE";

	/**
	 * 日本語用(nullハイフン)フォーマットの登録キー
	 */
	public static final String JAPANESE_NULL_HYPHEN = "JAPANESE_NULL_HYPHEN";

	/**
	 * 日本語用(秒まで表示)フォーマットの登録キー
	 */
	public static final String JAPANESE_SECOND = "JAPANESE_SECOND";

	/**
	 * 日本語用(年無し)フォーマットの登録キー
	 */
	public static final String JAPANESE_NON_YEAR = "JAPANESE_NON_YEAR";

	/**
	 * 英語用フォーマットの登録キー
	 */
	public static final String ENGLISH = "ENGLISH";

	/**
	 * 英語用(nullハイフン)フォーマットの登録キー
	 */
	public static final String ENGLISH_NULL_HYPHEN = "ENGLISH_NULL_HYPHEN";

	/**
	 * 英語用フォーマット(秒まで表示)の登録キー
	 */
	public static final String ENGLISH_SECOND = "ENGLISH_SECOND";

	/**
	 * 英語用(年無し)フォーマットの登録キー
	 */
	public static final String ENGLISH_NON_YEAR = "ENGLISH_NON_YEAR";


	//==========================================================
	//フィールド

	//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
	//クラス変数

	/**
	 * 日付フォーマット変換用インスタンスを格納するMap
	 */
	private static Map<String, MonthDateMinuteFormatter> formatterMap = Collections.synchronizedMap(new HashMap<String, MonthDateMinuteFormatter>());

	/**
	 * デフォルトの日付フォーマット変換用インスタンス
	 */
	private static MonthDateMinuteFormatter defaultFormatter;


	/**
	 * イニシャライザです。<br>
	 * 標準フォーマットを登録します。<br>
	 */
	static {
		//日本語用フォーマットを登録
		registFormatter(JAPANESE, new ConcreteMonthDateMinuteFormatter("yyyy年MM月", "yyyy年MM月dd日", "yyyy年MM月dd日 HH時mm分"));

		//日本語用(nullハイフン)フォーマットを登録
		registFormatter(JAPANESE_NULL_HYPHEN, new ConcreteMonthDateMinuteFormatter("yyyy年MM月", "yyyy年MM月dd日", "yyyy年MM月dd日 HH時mm分", "----年--月", "----年--月--日", "----年--月--日 --時--分"));

		//日本語用(秒まで表示)フォーマットを登録
		registFormatter(JAPANESE_SECOND, new ConcreteMonthDateMinuteFormatter("yyyy年MM月", "yyyy年MM月dd日", "yyyy年MM月dd日 HH時mm分ss秒"));

		//日本語用(年無し)フォーマットを登録
		registFormatter(JAPANESE_NON_YEAR, new ConcreteMonthDateMinuteFormatter("MM月", "MM月dd日", "MM月dd日 HH時mm分"));

		//英語用フォーマットを登録
		registFormatter(ENGLISH, new ConcreteMonthDateMinuteFormatter("yyyy/MM", "yyyy/MM/dd", "yyyy/MM/dd HH:mm"));

		//英語用(nullハイフン)フォーマットを登録
		registFormatter(ENGLISH_NULL_HYPHEN, new ConcreteMonthDateMinuteFormatter("yyyy/MM", "yyyy/MM/dd", "yyyy/MM/dd HH:mm", "----/--", "----/--/--", "----/--/-- --:--"));

		//英語用(秒まで表示)フォーマットを登録
		registFormatter(ENGLISH_SECOND, new ConcreteMonthDateMinuteFormatter("yyyy/MM", "yyyy/MM/dd", "yyyy/MM/dd HH:mm:ss"));

		//英語用(年無し)フォーマットを登録
		registFormatter(ENGLISH_NON_YEAR, new ConcreteMonthDateMinuteFormatter("MM", "MM/dd", "MM/dd HH:mm"));

		//日本語用フォーマットをデフォルトとして設定
		setDefaultFormatter(JAPANESE);
	}


	//==========================================================
	//メソッド

	//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
	//コンストラクタ

	/**
	 * コンストラクタです。<br>
	 * <i>(クラスメソッドのみのクラスなので、privateにしてインスタンスを作成できないようにしています。)</i><br>
	 */
	private MonthDateMinuteFormatterManager() {
		//基底クラスのコンストラクタの呼び出し
		super();
	}


	//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
	//クラスメソッド

	/**
	 * 指定したキーに対応する日付フォーマット変換用インスタンスを取得します。<br>
	 *
	 * @param keyArg キー
	 * @return 指定したキーに対応する日付フォーマット変換用インスタンス
	 * @exception DateFormatterNotFoundException キーに対応する日付フォーマット変換用インスタンスが見つからなかった場合
	 */
	public static MonthDateMinuteFormatter getFormatter(String keyArg)
			throws DateFormatterNotFoundException {
		//Mapから日付フォーマット変換用インスタンスを取得して、キャストする
		MonthDateMinuteFormatter formatter = formatterMap.get(keyArg);

		//見つからなかった場合
		if (formatter == null) {
			//例外を投げる
			throw new DateFormatterNotFoundException("[" + keyArg
					+ "]に対応する日付フォーマット変換用インスタンスが見つかりませんでした。");
		}

		//取得したインスタンスを返す
		return formatter;
	}

	/**
	 * デフォルトの日付フォーマット変換用インスタンスを取得します。<br>
	 *
	 * @return デフォルトの日付フォーマット変換用インスタンス
	 */
	public static MonthDateMinuteFormatter getDefaultFormatter() {
		//フィールドの値をそのまま返す
		return defaultFormatter;
	}

	/**
	 * 日付フォーマット変換用インスタンスを登録します。<br>
	 *
	 * @param keyArg キー
	 * @param formatterArg 登録する日付フォーマット変換用インスタンス
	 */
	public static void registFormatter(String keyArg,
			MonthDateMinuteFormatter formatterArg) {
		//Mapに登録
		formatterMap.put(keyArg, formatterArg);
	}

	/**
	 * デフォルトの日付フォーマット変換用インスタンスを設定します。<br>
	 *
	 * @param keyArg デフォルトの日付フォーマット変換用インスタンスのキー
	 * @exception DateFormatterNotFoundException キーに対応する日付フォーマット変換用インスタンスが見つからなかった場合
	 */
	public static void setDefaultFormatter(String keyArg)
			throws DateFormatterNotFoundException {
		//キーに対応するインスタンスを取得し、フィールドの値に設定する
		defaultFormatter = getFormatter(keyArg);
	}

	/**
	 * 全てのキーを取得します。<br>
	 *
	 * @return 全てのキーが格納された文字列配列
	 */
	public static String[] getKeys() {
		//キーセットを取得
		Set<String> keySet = formatterMap.keySet();

		//キーセットを配列に変換する際に、内部でIteratorを使用するのでMapに対して同期をとる
		//(synchronizedMapを使っていてもこの処理は必要)
		synchronized (formatterMap) {
			//キーセットを文字列配列に変換して返す
			return keySet.toArray(new String[0]);
		}
	}

}

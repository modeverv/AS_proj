package jp.fores.common.util;

import java.io.BufferedWriter;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Iterator;
import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.oro.text.perl.Perl5Util;


/**
 * 文字列操作用ユーティリティクラス。<br>
 * 文字列操作用の各種便利関数や、HTML・CSV用のエスケープ処理を実装しています。<br>
 */
public final class StringUtil {

	//==========================================================
	//定数

	/**
	 * ログ出力用
	 */
	private static final Log log = LogFactory.getLog(StringUtil.class);

	/**
	 * 数値変換用フォーマット
	 */
	private final static DecimalFormat decimalFormat = new DecimalFormat("#,###.#######");

	/**
	 * Perl5互換正規表現ユーティリティクラスのインスタンス
	 * (splitのみを使用するので、定数にして同じインスタンスを共有しています。)
	 */
	private static final Perl5Util perl = new Perl5Util();


	//==========================================================
	//コンストラクタ

	/**
	 * コンストラクタです。<br>
	 * (クラスメソッドのみのユーティリティークラスなので、privateにしてインスタンスを作成できないようにしています。)<br>
	 */
	private StringUtil() {
		//基底クラスのコンストラクタの呼び出し
		super();
	}


	//==============================================================
	//クラスメソッド

	////////////////////////////////////////////////////////////
	//汎用処理

	/**
	 * 与えられた文字列がnullまたは空文字列かどうか判断します。<br>
	 *
	 * @param strArg チェックする文字列
	 * @return true=nullまたは空文字列の場合, false=それ以外の場合
	 */
	public static boolean isBlank(String strArg) {
		//nullまたは空文字列の場合
		if ((strArg == null) || strArg.equals("")) {
			//trueを返す
			return true;
		}
		//それ以外の場合
		else {
			//falseを返す
			return false;
		}
	}

	/**
	 * 指定した配列内で指定した文字列が最初に出現する位置のインデックスを返します。<br>
	 * 見つからなかった場合は、-1を返します。<br>
	 *
	 * @param arrayArg 検索対象の文字列配列
	 * @param searchArg 検索する文字列
	 * @return 検索する文字列が最初に出現する位置のインデックス
	 */
	public static int arrayIndexOf(String[] arrayArg, String searchArg) {
		//検索対象の文字列配列のサイズに応じてループをまわす
		for (int i = 0; i < arrayArg.length; i++) {
			//一致する項目が見つかった場合
			if (arrayArg[i].equals(searchArg)) {
				//インデックスを返す
				return i;
			}
		}

		//最後まで見つからなかったので-1を返す
		return -1;
	}


	////////////////////////////////////////////////////////////
	//汎用変換処理

	/**
	 * 文字列中の指定した文字列を別の文字列に置換します。<br>
	 * (標準のreplaceの引数にStringを取るようにしたものです。)<br>
	 *
	 * @param strBaseArg 元の文字列
	 * @param strOldArg 置換対象の文字列
	 * @param strNewArg 置換する文字列
	 * @return 置換後の文字列
	 */
	public static String replace(String strBaseArg, String strOldArg,
			String strNewArg) {
		//==========================================================
		//初期化

		//結果を入れるStringBuilder
		StringBuilder tempStringBuilder = new StringBuilder();

		//検索開始位置
		int searchStartPos = 0;

		//置換対象の文字列が見つかった位置
		int findPos = -1;


		//==========================================================
		//置換対象の文字列を検索して、置換する

		//置換対象の文字列を検索する
		findPos = strBaseArg.indexOf(strOldArg);

		//置換対象の文字列が見つからなくなるまで続ける
		while (findPos != -1) {
			//結果を入れるStringBuilderに検索開始位置から、置換対象の文字列が見つかった場所までの文字列を追加する
			tempStringBuilder.append(strBaseArg.substring(searchStartPos, findPos));

			//結果を入れるStringBuilderに置換する文字列を追加する
			tempStringBuilder.append(strNewArg);

			//検索開始位置を更新する
			searchStartPos = findPos + strOldArg.length();

			//次の文字列を検索する
			findPos = strBaseArg.indexOf(strOldArg, searchStartPos);
		}

		//結果を入れるStringBuilderに残った部分を追加する
		tempStringBuilder.append(strBaseArg.substring(searchStartPos));


		//結果を入れるStringBuilderを文字列に変換して、置換後の文字列を返す
		return tempStringBuilder.toString();

	}

	/**
	 * 与えられた文字列がnullの場合、空文字列を返します。<br>
	 * null以外の場合はそのままの文字列を返します。<br>
	 *
	 * @param strArg 変換したい文字列
	 * @return nullの場合は空文字列、null以外の場合はそのままの文字列
	 */
	public static String escapeNull(String strArg) {
		//nullの場合
		if (strArg == null) {
			//空文字列を返す
			return "";
		}
		//null以外の場合
		else {
			//そのままの文字列を返す
			return strArg;
		}
	}

	/**
	 * 文字列の入ったCollectionを「,」区切りで結合して返します。<br>
	 *
	 * @param strCollectionArg 文字列の入ったCollection
	 * @return 「,」区切りで結合された文字列
	 */
	public static String combineStringCollection(
			Collection<String> strCollectionArg) {
		//区切り文字に「,」を指定して、実際に結合するメソッドを呼び出す
		return combineStringCollection(strCollectionArg, ",");
	}

	/**
	 * 文字列の入ったCollectionを指定した区切り文字で結合して返します。<br>
	 *
	 * @param strCollectionArg 文字列の入ったCollection
	 * @param delimArg 区切り文字
	 * @return 区切り文字で結合された文字列
	 */
	public static String combineStringCollection(
			Collection<String> strCollectionArg, String delimArg) {
		//作業用StringBuilder
		StringBuilder tempStringBuilder = new StringBuilder();

		//最初だというフラグ
		boolean firstFlag = true;

		//文字列のCollectionの全ての要素に対して処理を行う
		for (Iterator ite = strCollectionArg.iterator(); ite.hasNext();) {
			//最初の場合
			if (firstFlag) {
				//最初だというフラグをfalseにする
				firstFlag = false;
			}
			//最初以外なら
			else {
				//区切り文字を結合する
				tempStringBuilder.append(delimArg);
			}

			//現在の要素を末尾に結合する
			tempStringBuilder.append(ite.next());
		}

		//文字列に変換して値を返す
		return tempStringBuilder.toString();
	}

	/**
	 * 文字列の配列を「,」区切りで結合して返します。<br>
	 *
	 * @param strArrayArg 文字列配列
	 * @return 「,」区切りで結合された文字列
	 */
	public static String combineStringArray(String[] strArrayArg) {
		//区切り文字に「,」を指定して、実際に結合するメソッドを呼び出す
		return combineStringArray(strArrayArg, ",");
	}

	/**
	 * 文字列の配列を指定した区切り文字で結合して返します。<br>
	 *
	 * @param strArrayArg 文字列の配列
	 * @param delimArg 区切り文字
	 * @return 区切り文字で結合された文字列
	 */
	public static String combineStringArray(String[] strArrayArg,
			String delimArg) {
		//作業用StringBuilder
		StringBuilder tempStringBuilder = new StringBuilder();

		//文字列の配列の全ての要素に対して処理を行う
		for (int i = 0; i < strArrayArg.length; i++) {
			//最初以外の場合
			if (i != 0) {
				//区切り文字を結合する
				tempStringBuilder.append(delimArg);
			}

			//現在の要素を末尾に結合する
			tempStringBuilder.append(strArrayArg[i]);
		}

		//文字列に変換して値を返す
		return tempStringBuilder.toString();
	}

	/**
	 * 文字列の入ったCollectionを文字列の配列に変換します。<br>
	 *
	 * @param strCollectionArg 文字列の入ったCollection
	 * @return 文字列の配列
	 */
	public static String[] collectionToStringArray(
			Collection<String> strCollectionArg) {
		//配列に変換して返す
		return strCollectionArg.toArray(new String[0]);
	}


	/**
	 * null,空文字列の場合nullを返します。<br>
	 * それ以外の場合はそのままの文字列を返します。<br>
	 *
	 * @param strArg 変換したい文字列
	 * @return null,空文字列の場合はnull、それ以外の場合はそのままの文字列
	 */
	public static String blankToNull(String strArg) {
		//null,空文字列の場合
		if ((strArg == null) || ("".equals(strArg))) {
			//nullを返す
			return null;
		}

		//null,空文字列でない場合
		else {
			//そのままの文字列を返す
			return strArg;
		}

	}

	/**
	 * 文字列を自然数に変換します。<br>
	 * ただし数値への変換に失敗したとき、自然数でない場合は-1を返します。<br>
	 *
	 * @param strArg 変換したい文字列
	 * @return 変換後の自然数(数値への変換に失敗したとき、自然数でない場合は-1)
	 */
	public static int stringToNaturalNumber(String strArg) {
		try {
			//文字列を数値に変換する
			int intValue = Integer.parseInt(strArg);

			//自然数の場合
			if (intValue >= 0) {
				//変換した数値を返す
				return intValue;
			}
			//自然数でない場合
			else {
				//-1を返す
				return -1;
			}
		}
		//数値への変換に失敗した場合
		catch (Exception e) {
			//-1を返す
			return -1;
		}
	}

	/**
	 * １桁の数値の頭に「0」をつけて２桁の文字列に変換します。<br>
	 * １桁以外の場合は、そのまま文字列に変換します。<br>
	 *
	 * @param valueArg 変換したい数値
	 * @return 変換後の文字列
	 */
	public static String convertTwoDigitString(int valueArg) {
		//１桁の場合
		if ((valueArg >= 0) && (valueArg <= 9)) {
			//頭に「0」をつけて返す
			return "0" + Integer.toString(valueArg);
		}
		//１桁以外の場合
		else {
			//そのまま文字列に変換して返す
			return Integer.toString(valueArg);
		}
	}

	/**
	 * 「\」を「\\」に変換して返します。<br>
	 * nullの場合は空文字列を返します。<br>
	 *
	 * @param strArg 変換したい文字列
	 * @return 変換後の文字列
	 */
	public static String escapeBackSlash(String strArg) {
		//nullを空文字列に変換してから、「\」を「\\」に変換
		return replace(escapeNull(strArg), "\\", "\\\\");
	}

	/**
	 * 「'」を「''」に変換して返します。<br>
	 * nullの場合は空文字列を返します。<br>
	 *
	 * @param strArg 変換したい文字列
	 * @return 変換後の文字列
	 */
	public static String escapeQuotation(String strArg) {
		//nullを空文字列に変換してから、「'」を「''」に変換
		return replace(escapeNull(strArg), "'", "''");
	}

	/**
	 * 与えられた文字列を「'」で囲んで返します。<br>
	 * nullの場合は「''」という文字列を返します。
	 *
	 * @param strArg 「'」で囲みたい文字列
	 * @return 「'」で囲まれた文字列(nullの場合は「''」という文字列)
	 */
	public static String quoting(String strArg) {
		//nullの場合
		if (strArg == null) {
			//「''」という文字列を返す
			return "''";
		}

		//nullでない場合
		else {
			//「'」で囲んで返す
			return "'" + strArg + "'";
		}
	}

	//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
	//HTML用変換処理

	/**
	 * HTML用に特殊文字を変換して返します。<br>
	 * <br>
	 * 以下の通りに変換します。<br>
	 * <table border="1">
	 *  <tr bgcolor="deepskyblue">
	 *      <td align="center"><strong>特殊文字</strong></td>
	 *      <td align="center"><strong>変換後の文字列</strong></td>
	 *  </tr>
	 *  <tr>
	 *      <td><code>&amp;</code></td>
	 *      <td><code>&amp;amp;</code></td>
	 *  </tr>
	 *  <tr>
	 *      <td><code>&lt;</code></td>
	 *      <td><code>&amp;lt;</code></td>
	 *  </tr>
	 *  <tr>
	 *      <td><code>&gt;</code></td>
	 *      <td><code>&amp;gt;</code></td>
	 *  </tr>
	 *  <tr>
	 *      <td><code>&quot;</code></td>
	 *      <td><code>&amp;quot;</code></td>
	 *  </tr>
	 * </table>
	 * <br>
	 * なお、nullの場合は空文字列に変換します。<br>
	 *
	 * @param strArg 変換したい文字列
	 * @return 変換後の文字列
	 */
	public static String escapeSpecialCharacter(String strArg) {
		//結果を入れる文字列
		String resultStr = null;

		//nullを空文字列に変換
		resultStr = escapeNull(strArg);

		//特殊文字の変換
		resultStr = replace(resultStr, "&", "&amp;");
		resultStr = replace(resultStr, "<", "&lt;");
		resultStr = replace(resultStr, ">", "&gt;");
		resultStr = replace(resultStr, "\"", "&quot;");

		//結果を返す
		return resultStr;
	}

	/**
	 * HTMLの表示項目のための変換を行います。<br>
	 * <br>
	 * 以下の順番で処理を行います。<br>
	 * <ol>
	 *  <li>escapeSpecialCharacter()を使って、特殊文字を変換</li>
	 *  <li>半角スペースを「&amp;nbsp;」に変換</li>
	 *  <li>改行を「&lt;br&gt;」に変換</li>
	 *  <li>nullまたは空文字列の場合は「&amp;nbsp;」に変換(テーブルの空セルの表示のため)</li>
	 * </ol>
	 *
	 * @param strArg 変換したい文字列
	 * @return 変換後の文字列
	 */
	public static String stringToHTMLDisplay(String strArg) {
		//結果を入れる文字列
		String resultStr = null;

		//特殊文字の変換
		resultStr = escapeSpecialCharacter(strArg);

		//半角スペースを&nbsp;に変換
		resultStr = replace(resultStr, " ", "&nbsp;");

		//改行を<br>に変換
		resultStr = replace(resultStr, "\r\n", "<br>");
		resultStr = replace(resultStr, "\n", "<br>");
		resultStr = replace(resultStr, "\r", "<br>");

		//空文字列の場合
		if (resultStr.equals("")) {
			//「&nbsp;」という文字に変換する
			resultStr = "&nbsp;";
		}

		//結果を返す
		return resultStr;
	}

	/**
	 * HTMLの入力項目のための変換を行います。<br>
	 * escapeSpecialCharacter()を使って、特殊文字の変換だけを行います。<br>
	 *
	 * @param strArg 変換したい文字列
	 * @return 変換後の文字列
	 */
	public static String stringToHTMLInput(String strArg) {
		//特殊文字の変換だけを行う
		return escapeSpecialCharacter(strArg);
	}

	/**
	 * JavaScriptのための変換を行います。<br>
	 * <br>
	 * 以下の順番で処理を行います。<br>
	 * <ol>
	 *  <li>nullを空文字列に変換</li>
	 *  <li>「\」を「\\」に変換</li>
	 *  <li>「"」を「\"」に変換</li>
	 *  <li>「'」を「\'」に変換</li>
	 *  <li>改行を「\n」に変換</li>
	 * </ol>
	 *
	 * @param strArg 変換したい文字列
	 * @return 変換後の文字列
	 */
	public static String stringToJS(String strArg) {
		//結果を入れる文字列
		String resultStr = null;

		//nullを空文字列に変換
		resultStr = escapeNull(strArg);

		//「\」と「"」と「'」を「\」でエスケープする
		resultStr = replace(resultStr, "\\", "\\\\");
		resultStr = replace(resultStr, "\"", "\\\"");
		resultStr = replace(resultStr, "\'", "\\\'");

		//改行を「\n」に変換
		resultStr = replace(resultStr, "\r\n", "\\n");
		resultStr = replace(resultStr, "\n", "\\n");
		resultStr = replace(resultStr, "\r", "\\n");


		//結果を返す
		return resultStr;
	}


	//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
	//CSV用変換処理

	/**
	 * 「"」を「""」に変換して返します。<br>
	 * nullの場合は空文字列を返します。<br>
	 *
	 * @param strArg 変換したい文字列
	 * @return 変換後の文字列
	 */
	public static String escapeDoubleQuotation(String strArg) {
		//nullを空文字列に変換してから、「"」を「""」に変換
		return replace(escapeNull(strArg), "\"", "\"\"");
	}

	/**
	 * CSV用のエスケープ処理を行います。
	 * <br>
	 * nullの場合は空文字列を返します。<br>
	 * 「,」, 「"」, 改行のいずれも含まれていない場合は何もしません。
	 * 「,」, 「"」, 改行のいずれかの文字が含まれている場合は、以下の順番で処理を行います。<br>
	 * <ol>
	 *  <li>escapeDoubleQuotation()を使って、「"」を「""」に変換</li>
	 *  <li>全体を「"」で囲む</li>
	 * </ol>
	 *
	 * @param strArg 変換したい文字列
	 * @return 変換後の文字列
	 */
	public static String stringToCSV(String strArg) {
		//結果を入れる文字列
		String resultStr = null;

		//nullを空文字列に変換
		resultStr = escapeNull(strArg);

		//「,」, 「"」, 改行のいずれかの文字が含まれている場合
		if (perl.match("/[,\"\n]/", resultStr)) {
			//「"」を「""」に変換して、さらに文字列の両端を「"」で囲む
			resultStr = "\"" + escapeDoubleQuotation(resultStr) + "\"";
		}

		//結果を返す
		return resultStr;
	}


	//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
	//金額用変換処理

	/**
	 * 数値の入った文字列を、３桁ごとに「,」で区切って返します。<br>
	 * 小数が含まれる場合は、小数点以下７桁まで有効です。<br>
	 * 変換できない不正な文字列が渡された場合は、空文字列を返します。<br>
	 *
	 * @param strArg 数値の入った文字列
	 * @return 「,」で区切られた文字列
	 */
	public static String setComma(String strArg) {
		try {
			//フォーマット変換して返す
			return decimalFormat.format(decimalFormat.parse(strArg));
		}
		//変換できなかった場合
		catch (Exception e) {
			//空文字列を返す
			return "";
		}
	}

	/**
	 * 文字列からカンマ「,」を取り除きます。<br>
	 *
	 * @param strArg 「,」の含まれる文字列
	 * @return 「,」を取り除いた文字列
	 */
	public static String removeComma(String strArg) {
		//「,」を空文字列に変換することによって取り除く
		return replace(strArg, ",", "");
	}


	//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
	//その他

	/**
	 * 与えられた文字列を「,」区切りで分割し、結果を文字列配列に格納して返します。<br>
	 * 最初と最後、「,」周辺の空白文字(半角スペースやタブ、ただし全角スペースは含まない)は無視します。<br>
	 * nullの場合は空の文字列配列を返します。<br>
	 *
	 * @param strArg 分割したい文字列
	 * @return 結果の格納された文字列配列(nullの場合は空の文字列配列)
	 */
	public static String[] split(String strArg) {
		//区切り文字に「,」を指定して、実際に処理を行うメソッドを呼び出す
		return split(strArg, ",");
	}

	/**
	 * 与えられた文字列を指定した区切り文字で分割し、結果を文字列配列に格納して返します。<br>
	 * 最初と最後、区切り文字周辺の空白文字(半角スペースやタブ、ただし全角スペースは含まない)は無視します。<br>
	 * nullの場合は空の文字列配列を返します。<br>
	 * <br>
	 * <strong>(注)正規表現を使って処理を行いますので、区切り文字に正規表現のメタキャラクタは渡さないで下さい。<br></strong>
	 *
	 * @param strArg 分割したい文字列
	 * @param delimArg 区切り文字
	 * @return 結果の格納された文字列配列(nullの場合は空の文字列配列)
	 */
	public static String[] split(String strArg, String delimArg) {
		//文字列がnullの場合
		if (strArg == null) {
			//空の文字列配列を返す
			return new String[0];
		}
		//文字列がnull以外の場合
		else {
			//分割のパターン(区切り文字周辺の空白文字は無視する)
			String pattern = "/\\s*" + delimArg + "\\s*/";

			//結果を入れるList
			List<String> list = new ArrayList<String>();

			//最初と最後のスペースを無視するためtrimをかけてから、正規表現を使って文字列を分割する
			perl.split(list, pattern, strArg.trim());

			//結果のListを文字列配列に変換して返す
			return list.toArray(new String[0]);
		}

	}

	/**
	 * 文字列を指定した文字数でカットします。<br>
	 * 指定した文字数よりも文字列が短い場合は、そのまま返します。<br>
	 *
	 * @param strArg 対象文字列
	 * @param lenArg 文字数
	 * @return 変換後の文字列
	 */
	public static String cutString(String strArg, int lenArg) {
		//対象文字列が指定した文字数よりも長い場合
		if (strArg.length() > lenArg) {
			//指定した文字数でカットして返す
			return strArg.substring(0, lenArg);
		}
		//それ以外の場合
		else {
			//対象文字列をそのまま返す
			return strArg;
		}
	}

	/**
	 * 文字列を指定した文字数でカットして、末尾に接尾子をつけて返します。<br>
	 * 指定した文字数よりも文字列が短い場合は、接尾子をつけずにそのまま返します。<br>
	 * このメソッドは、一定の文字数よりも長い場合に、末尾に「...」などをつけて省略して表示したい場合
	 * などに使用して下さい。<br>
	 *
	 * @param strArg 対象文字列
	 * @param lenArg 文字数
	 * @param suffixArg 末尾につける接尾子(「...」など)
	 * @return 変換後の文字列
	 */
	public static String cutString(String strArg, int lenArg, String suffixArg) {
		//対象文字列が指定した文字数よりも長い場合
		if (strArg.length() > lenArg) {
			//指定した文字数でカットして、さらに末尾に接尾子をつけて返す
			return strArg.substring(0, lenArg) + suffixArg;
		}
		//それ以外の場合
		else {
			//対象文字列をそのまま返す
			return strArg;
		}
	}

	/**
	 * 配列を文字列に変換します。<br>
	 * デバッグ時のログ出力に利用して下さい。<br>
	 * <br>
	 * <strong>(フォーマット)</strong><br>
	 * <pre>
	 * [01]要素1の文字列表現
	 * [02]要素2の文字列表現
	 * 　　　　　　　　・
	 * 　　　　　　　　・
	 * 　　　　　　　　・
	 * </pre>
	 * ↑配列自体がnullの場合は、「null」とだけ返します<br>
	 *
	 * @param objArrayArg 文字列に変換したい配列
	 * @return 文字列表現
	 */
	public static String arrayToString(Object[] objArrayArg) {
		//配列がnullの場合
		if (objArrayArg == null) {
			//「null」という文字列を返す
			return "null";
		}
		//配列がnullでない場合
		else {
			//作業用StringBuilder
			StringBuilder sb = new StringBuilder();

			//文字列の配列の全ての要素に対して処理を行う
			for (int i = 0; i < objArrayArg.length; i++) {
				//インデックス(1桁の場合は頭に0をつける)を[]で囲む
				sb.append("[").append(StringUtil.convertTwoDigitString(i + 1)).append("]");

				//現在の要素 + 改行を末尾に追加する
				sb.append(objArrayArg[i]).append("\n");
			}

			//文字列に変換して値を返す
			return sb.toString();
		}
	}

	/**
	 * Collectionを文字列に変換します。<br>
	 * デバッグ時のログ出力に利用して下さい。<br>
	 * <br>
	 * <strong>(フォーマット)</strong><br>
	 * <pre>
	 * [01]要素1の文字列表現
	 * [02]要素2の文字列表現
	 * 　　　　　　　　・
	 * 　　　　　　　　・
	 * 　　　　　　　　・
	 * </pre>
	 * ↑Collection自体がnullの場合は、「null」とだけ返します<br>
	 *
	 * @param collectionArg 文字列に変換したいCollection
	 * @return 文字列表現
	 */
	public static String collectionToString(Collection<?> collectionArg) {
		//Collectionがnullの場合
		if (collectionArg == null) {
			//「null」という文字列を返す
			return "null";
		}
		//Collectionがnullでない場合
		else {
			//作業用StringBuilder
			StringBuilder tempStringBuilder = new StringBuilder();

			//インデックス(1から始める)
			int index = 1;

			//文字列の配列の全ての要素に対して処理を行う
			for (Iterator ite = collectionArg.iterator(); ite.hasNext();) {
				//インデックス(1桁の場合は頭に0をつける)を[]で囲む
				tempStringBuilder.append("[").append(StringUtil.convertTwoDigitString(index)).append("]");

				//インデックスを進める
				index++;

				//現在の要素 + 改行を末尾に追加する
				tempStringBuilder.append(ite.next()).append("\n");
			}

			//文字列に変換して値を返す
			return tempStringBuilder.toString();
		}
	}

	/**
	 * 文字列から拡張子を抽出します。<br>
	 * 拡張子が存在しない場合は空文字列を返します。<br>
	 * 扱いやすいように、結果を小文字に変換してから返します。<br>
	 * <br>
	 * <strong>＜拡張子の定義＞</strong><br>
	 * 最後の「.」以降の文字列<br>
	 *
	 * @param strArg 対象文字列
	 * @return 拡張子(存在しない場合は空文字列)
	 */
	public static String getExtension(String strArg) {
		//小文字に変換するかどうかのフラグにtrueを指定して、実際に処理を行うメソッドを呼び出す
		return getExtension(strArg, true);
	}

	/**
	 * 文字列から拡張子を抽出します。<br>
	 * 拡張子が存在しない場合は空文字列を返します。<br>
	 * isToLowerArgにtrueが指定されている場合は、結果を小文字に変換してから返します。<br>
	 * <br>
	 * <strong>＜拡張子の定義＞</strong><br>
	 * 最後の「.」以降の文字列<br>
	 *
	 * @param strArg 対象文字列
	 * @param isToLowerArg 小文字に変換するかどうかのフラグ(true=変換する, false=変換しない)
	 * @return 拡張子(存在しない場合は空文字列)
	 */
	public static String getExtension(String strArg, boolean isToLowerArg) {
		//最後の「.」の位置を取得する
		int lastPeriodIndex = strArg.lastIndexOf('.');

		//「.」が見つからなかった場合
		if (lastPeriodIndex == -1) {
			//拡張子が存在しないので空文字列を返す
			return "";
		}
		//「.」が見つかった場合
		else {
			//最後の「.」以降の文字列を拡張子として取得
			String extension = strArg.substring(lastPeriodIndex + 1);

			//小文字に変換する場合
			if (isToLowerArg) {
				//取得した拡張子を小文字に変換して返す
				return extension.toLowerCase();
			}
			//小文字に変換しない場合
			else {
				//取得した拡張子をそのまま返す
				return extension;
			}
		}
	}

	/**
	 * 文字列の両側の半角・全角スペース・改行文字を削除します。<br>
	 *
	 * @param strArg 対象文字列
	 * @return 変換後の文字列
	 */
	public static String trim(String strArg) {
		//正規表現を使って、両側の半角・全角スペース・改行文字を空文字列に置き換えて削除
		return perl.substitute("s/(^\\s+)|(\\s+$)//g", strArg);
	}

	/**
	 * 文字列の左側の半角・全角スペース・改行文字を削除します。<br>
	 *
	 * @param strArg 対象文字列
	 * @return 変換後の文字列
	 */
	public static String ltrim(String strArg) {
		//正規表現を使って、左側の半角・全角スペース・改行文字を空文字列に置き換えて削除
		return perl.substitute("s/^\\s+//g", strArg);
	}

	/**
	 * 文字列の右側の半角・全角スペース・改行文字を削除します。<br>
	 *
	 * @param strArg 対象文字列
	 * @return 変換後の文字列
	 */
	public static String rtrim(String strArg) {
		//正規表現を使って、右側の半角・全角スペース・改行文字を空文字列に置き換えて削除
		return perl.substitute("s/\\s+$//g", strArg);
	}

	/**
	 * 例外のスタックトレースを文字列に変換して返します。<br>
	 *
	 * @param throwableArg 例外
	 * @return スタックトレースの文字列
	 */
	public static String convertStackTraceToString(Throwable throwableArg) {
		//文字ストリームを生成
		StringWriter sw = new StringWriter();

		//文字ストリームを元にしてテキスト出力ストリームを生成
		PrintWriter pw = new PrintWriter(new BufferedWriter(sw));

		//例外のスタックトレースをテキスト出力ストリームに出力
		throwableArg.printStackTrace(pw);

		//テキスト出力ストリームをフラッシュ
		pw.flush();

		//テキスト出力ストリームを閉じる
		pw.close();

		//文字ストリームの内容を文字列に変換して返す
		return sw.toString();
	}

	/**
	 * 数値の先頭にゼロ詰めを行って、指定した長さの文字列にします。<br>
	 * 指定された数値の長さがすでに指定した桁数以上の場合は、そのまま文字列に変換して返します。<br>
	 * <br>
	 *
	 * @param numberArg ゼロ詰めを行う数値
	 * @param lengthArg 長さ
	 * @return 結果の文字列
	 */
	public static String zeroPadding(long numberArg, int lengthArg) {
		//数値を文字列に変換して、実際に処理を行うメソッドを呼び出す
		return zeroPadding(Long.toString(numberArg), lengthArg);
	}

	/**
	 * 文字列の先頭にゼロ詰めを行って、指定した長さにします。<br>
	 * 指定された文字列の長さがすでに指定した桁数以上の場合は、指定された文字列をそのまま返します。<br>
	 * <br>
	 *
	 * @param strArg ゼロ詰めを行う文字列
	 * @param lengthArg 長さ
	 * @return 結果の文字列
	 */
	public static String zeroPadding(String strArg, int lengthArg) {
		//指定された文字列の長さがすでに指定した桁数以上の場合
		if (strArg.length() >= lengthArg) {
			//指定された文字列をそのまま返す
			return strArg;
		}

		//作業用StringBuilder
		StringBuilder sb = new StringBuilder(strArg);

		//指定された文字列の長さになるまでループをまわす
		while (sb.length() < lengthArg) {
			//先頭に「0」を挿入する
			sb.insert(0, "0");
		}

		//結果を文字列に変換して返す
		return sb.toString();
	}

	/**
	 * 文字列を１文字ずつ解析して、「～」などの文字化けの原因となる特殊なUnicode文字を、
	 * 文字化けしない文字コードに変換します。<br>
	 * 変換対象の文字は、「～」,「∥」,「－」,「￠」,「￡」,「￢」の６種類です。<br>
	 * <br>
	 * 以下の通りに変換します。<br>
	 * <table border="1">
	 *  <tr bgcolor="deepskyblue">
	 *      <td align="center"><strong>変換対象の文字</strong></td>
	 *      <td align="center"><strong>変換前の文字コード</strong></td>
	 *      <td align="center"><strong>変換後の文字コード</strong></td>
	 *  </tr>
	 *  <tr>
	 *      <td><code>～</code></td>
	 *      <td><code>0xFF5E</code></td>
	 *      <td><code>0x301C</code></td>
	 *  </tr>
	 *  <tr>
	 *      <td><code>∥</code></td>
	 *      <td><code>0x2225</code></td>
	 *      <td><code>0x2016</code></td>
	 *  </tr>
	 *  <tr>
	 *      <td><code>－</code></td>
	 *      <td><code>0xFF0D</code></td>
	 *      <td><code>0x2212</code></td>
	 *  </tr>
	 *  <tr>
	 *      <td><code>￠</code></td>
	 *      <td><code>0xFFE0</code></td>
	 *      <td><code>0x00A2</code></td>
	 *  </tr>
	 *  <tr>
	 *      <td><code>￡</code></td>
	 *      <td><code>0xFFE1</code></td>
	 *      <td><code>0x00A3</code></td>
	 *  </tr>
	 *  <tr>
	 *      <td><code>￢</code></td>
	 *      <td><code>0xFFE2</code></td>
	 *      <td><code>0x00AC</code></td>
	 *  </tr>
	 * </table>
	 * <br>
	 * なお、nullの場合はそのままnullを返します。<br>
	 *
	 * @param strArg 変換する文字列
	 * @return 変換された文字列
	 */
	public static String convertSpecialUnicodeCharacter(String strArg) {
		//nullの場合
		if (strArg == null) {
			//そのままnullを返す
			return null;
		}

		//文字列の長さを取得
		int length = strArg.length();

		//作業用のStringBuilderのインスタンスを生成
		StringBuilder sb = new StringBuilder(strArg.length());

		//文字列の長さに応じてループをまわす
		for (int i = 0; i < length; i++) {
			//文字コードを取得
			char c = strArg.charAt(i);

			//文字コードに応じて処理をわける
			switch (c) {
			//「～」の場合
			case '\uFF5E':
				sb.append('\u301C');
				break;

			//「∥」の場合
			case '\u2225':
				sb.append('\u2016');
				break;

			//「－」の場合
			case '\uFF0D':
				sb.append('\u2212');
				break;

			//「￠」の場合
			case '\uFFE0':
				sb.append('\u00A2');
				break;

			//「￡」の場合
			case '\uFFE1':
				sb.append('\u00A3');
				break;

			//「￢」の場合
			case '\uFFE2':
				sb.append('\u00AC');
				break;

			//どの特殊文字とも一致しなかった場合
			default:
				sb.append(c);
				break;
			}
		}

		//結果をStringに変換して返す
		return sb.toString();
	}

	/**
	 * 対象文字列がnullの場合、代わりの文字列を返します。<br>
	 * 対象文字列がnullでない場合は、対象文字列をそのまま返します。<br>
	 *
	 * @param targetStrArg 対象文字列
	 * @param replaceStrArg 対象文字列がnullの場合に代わりに返す文字列
	 * @return 対象文字列、または代わりの文字列
	 */
	public static String nvl(String targetStrArg, String replaceStrArg) {
		//対象文字列がnullの場合
		if (targetStrArg == null) {
			//代わりの文字列を返す
			return replaceStrArg;
		}
		//対象文字列がnullでない場合
		else {
			//対象文字列をそのまま返す
			return targetStrArg;
		}
	}

	/**
	 * 電話番号1, 2, 3を「-」で結合したフォーマットで返します。<br>
	 * 電話番号1, 2, 3のうち存在するものだけを抽出して、「-」区切りで結合します。<br>
	 * 電話番号1, 2, 3が全てnullまたは空文字列の場合は、空文字列を返します。<br>
	 * もし、電話番号として不正な形式の場合も、例外は発生しません。<br>
	 * <br>
	 * <strong>＜例＞</strong><br>
	 * <table border="1">
	 *   <tr bgcolor="deepskyblue">
	 *     <th>電話番号1</th>
	 *     <th>電話番号2</th>
	 *     <th>電話番号3</th>
	 *     <th>結果</th>
	 *   </tr>
	 *   <tr>
	 *     <td>01</td>
	 *     <td>2345</td>
	 *     <td>6789</td>
	 *     <td>01-2345-6789</td>
	 *   </tr>
	 *   <tr>
	 *     <td>012345</td>
	 *     <td>&nbsp;</td>
	 *     <td>6789</td>
	 *     <td>012345-6789</td>
	 *   </tr>
	 *   <tr>
	 *     <td>&nbsp;</td>
	 *     <td>&nbsp;</td>
	 *     <td>&nbsp;</td>
	 *     <td>(空文字列)</td>
	 *   </tr>
	 *   <tr>
	 *     <td>123</td>
	 *     <td>&nbsp;</td>
	 *     <td>&nbsp;</td>
	 *     <td>123</td>
	 *   </tr>
	 *   <tr>
	 *     <td>&nbsp;</td>
	 *     <td>123</td>
	 *     <td>&nbsp;</td>
	 *     <td>123</td>
	 *   </tr>
	 *   <tr>
	 *     <td>&nbsp;</td>
	 *     <td>&nbsp;</td>
	 *     <td>123</td>
	 *     <td>123</td>
	 *   </tr>
	 *   <tr>
	 *     <td>123</td>
	 *     <td>4567</td>
	 *     <td>&nbsp;</td>
	 *     <td>123-4567</td>
	 *   </tr>
	 *   <tr>
	 *     <td>&nbsp;</td>
	 *     <td>123</td>
	 *     <td>4567</td>
	 *     <td>123-4567</td>
	 *   </tr>
	 * </table>
	 *
	 * @param tel1Arg 電話番号1
	 * @param tel2Arg 電話番号2
	 * @param tel3Arg 電話番号3
	 * @return 電話番号1, 2, 3を「-」で結合した文字列
	 */
	public static String formatTel(String tel1Arg, String tel2Arg,
			String tel3Arg) {
		//作業用List
		List<String> list = new ArrayList<String>();

		//電話番号1がnullまたは空文字列でない場合
		if (!isBlank(tel1Arg)) {
			//Listに電話番号1を追加
			list.add(tel1Arg);
		}

		//電話番号2がnullまたは空文字列でない場合
		if (!isBlank(tel2Arg)) {
			//Listに電話番号2を追加
			list.add(tel2Arg);
		}

		//電話番号3がnullまたは空文字列でない場合
		if (!isBlank(tel3Arg)) {
			//Listに電話番号3を追加
			list.add(tel3Arg);
		}

		//Listの要素を「-」区切りで結合した文字列を返す
		return combineStringCollection(list, "-");
	}

	/**
	 * オブジェクトをデバッグに適した文字列に変換して返します。<br>
	 *
	 * @param objArg 対象オブジェクト
	 * @return デバッグに適した文字列
	 */
	public static String convertDebugString(Object objArg) {
		//nullの場合
		if (objArg == null) {
			//nullという文字を返す
			return "null";
		}
		//文字列配列の場合
		else if (objArg instanceof String[]) {
			//文字列配列を結合する処理を通してから返す
			return combineStringArray((String[]) objArg);
		}
		//オブジェクト配列の場合
		else if (objArg instanceof Object[]) {
			//オブジェクト配列を文字列に変換する処理を通してから返す
			return arrayToString((Object[]) objArg);
		}
		//コレクションの場合
		else if (objArg instanceof Collection) {
			//コレクションを文字列に変換する処理を通してから返す
			return collectionToString((Collection) objArg);
		}
		//例外の場合
		else if (objArg instanceof Throwable) {
			//例外のスタックトレースを文字列に変換する処理を通してから返す
			return convertStackTraceToString((Throwable) objArg);
		}
		//それ以外の場合
		else {
			//普通に文字列に変換して返す
			return objArg.toString();
		}
	}

}

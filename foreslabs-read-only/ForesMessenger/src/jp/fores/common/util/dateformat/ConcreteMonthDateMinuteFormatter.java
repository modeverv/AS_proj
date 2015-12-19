package jp.fores.common.util.dateformat;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Date;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import jp.fores.common.util.DateUtil;


/**
 * 実際に年・月、年・月・日、または年・月・日・時・分をフォーマット変換するクラス。<br>
 * <br>
 * コンストラクタに与えられたフォーマット形式に従って、日付のフォーマット変換を行います。<br>
 * フォーマット形式の指定方法については、<code>java.text.SimpleDateFormat</code>の説明を参照して下さい。<br>
 * 日付形式の文字列からDateオブジェクトを生成する際には、{@link DateUtil}.parseDate()を使用しますので、
 * 指定できる文字列の形式についてはそちらを参照して下さい。<br>
 *
 * @see MonthDateMinuteFormatterManager
 * @see DateUtil
 */
public class ConcreteMonthDateMinuteFormatter implements
		MonthDateMinuteFormatter {

	//==========================================================
	//定数

	/**
	 * ログ出力用インスタンス
	 */
	private static final Log log = LogFactory.getLog(ConcreteMonthDateMinuteFormatter.class);


	//==========================================================
	//フィールド

	//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
	//インスタンス変数

	/**
	 * 年・月の整形フォーマット
	 */
	protected final DateFormat monthFormat;

	/**
	 * 年・月・日の整形フォーマット
	 */
	protected final DateFormat dateFormat;

	/**
	 * 年・月・日・時・分の整形フォーマット
	 */
	protected final DateFormat minuteFormat;

	/**
	 * Dateオブジェクトがnullの場合に年・月として表示する文字列
	 */
	protected final String monthNullText;

	/**
	 * Dateオブジェクトがnullの場合に年・月・日として表示する文字列
	 */
	protected final String dateNullText;

	/**
	 * Dateオブジェクトがnullの場合に年・月・日・時・分として表示する文字列
	 */
	protected final String minuteNullText;


	//==========================================================
	//メソッド

	//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
	//コンストラクタ

	/**
	 * コンストラクタです。<br>
	 * 与えられた整形フォーマット用文字列からSimpleDateFormatのインスタンスを生成し、フィールドに設定します。<br>
	 * Dateオブジェクトがnullの場合の文字列には空文字列を設定します。<br>
	 *
	 * @param monthFormatArg 年・月の整形フォーマット用文字列<strong>(例:yyyy年MM月)</strong>
	 * @param dateFormatArg 年・月・日の整形フォーマット用文字列<strong>(例:yyyy年MM月dd日)</strong>
	 * @param minuteFormatArg 年・月・日・時・分の整形フォーマット用文字列<strong>(例:yyyy年MM月dd日 HH時mm分)</strong>
	 */
	public ConcreteMonthDateMinuteFormatter(String monthFormatArg,
			String dateFormatArg, String minuteFormatArg) {
		//全ての引数をとるコンストラクタを呼び出す(Dateオブジェクトがnullの場合の文字列には全て空文字列を渡す)
		this(monthFormatArg, dateFormatArg, minuteFormatArg, "", "", "");
	}

	/**
	 * コンストラクタです。<br>
	 * 与えられた整形フォーマット用文字列からSimpleDateFormatのインスタンスを生成し、フィールドに設定します。<br>
	 * Dateオブジェクトがnullの場合の文字列は、与えられた引数をそのままフィールドに設定します。<br>
	 *
	 * @param monthFormatArg 年・月の整形フォーマット用文字列<strong>(例:yyyy年MM月)</strong>
	 * @param dateFormatArg 年・月・日の整形フォーマット用文字列<strong>(例:yyyy年MM月dd日)</strong>
	 * @param minuteFormatArg 年・月・日・時・分の整形フォーマット用文字列<strong>(例:yyyy年MM月dd日 HH時mm分)</strong>
	 * @param monthNullTextArg Dateオブジェクトがnullの場合に年・月として表示する文字列<strong>(例:----年--月)</strong>
	 * @param dateNullTextArg Dateオブジェクトがnullの場合に年・月・日として表示する文字列<strong>(例:----年--月--日)</strong>
	 * @param minuteNullTextArg Dateオブジェクトがnullの場合に年・月・日・時・分として表示する文字列<strong>(例:----年--月--日 --時--分)</strong>
	 */
	public ConcreteMonthDateMinuteFormatter(String monthFormatArg,
			String dateFormatArg, String minuteFormatArg,
			String monthNullTextArg, String dateNullTextArg,
			String minuteNullTextArg) {
		//整形フォーマット用文字列からSimpleDateFormatのインスタンスを生成し、DateFormatを引数にとるコンストラクタを呼び出す
		this(new SimpleDateFormat(monthFormatArg),
				new SimpleDateFormat(dateFormatArg),
				new SimpleDateFormat(minuteFormatArg),
				monthNullTextArg,
				dateNullTextArg,
				minuteNullTextArg);
	}

	/**
	 * コンストラクタです。<br>
	 * 与えられた引数をそのままフィールドに設定します。<br>
	 * Dateオブジェクトがnullの場合の文字列には空文字列を設定します。<br>
	 *
	 * @param monthFormatArg 年・月の整形フォーマット
	 * @param dateFormatArg 年・月・日の整形フォーマット
	 * @param minuteFormatArg 年・月・日・時・分の整形フォーマット
	 */
	public ConcreteMonthDateMinuteFormatter(DateFormat monthFormatArg,
			DateFormat dateFormatArg, DateFormat minuteFormatArg) {
		//全ての引数をとるコンストラクタを呼び出す(Dateオブジェクトがnullの場合の文字列には全て空文字列を渡す)
		this(monthFormatArg, dateFormatArg, minuteFormatArg, "", "", "");
	}

	/**
	 * コンストラクタです。<br>
	 * 与えられた全ての引数をそのままフィールドに設定します。<br>
	 *
	 * @param monthFormatArg 年・月の整形フォーマット
	 * @param dateFormatArg 年・月・日の整形フォーマット
	 * @param minuteFormatArg 年・月・日・時・分の整形フォーマット
	 * @param monthNullTextArg Dateオブジェクトがnullの場合に年・月として表示する文字列<strong>(例:----年--月)</strong>
	 * @param dateNullTextArg Dateオブジェクトがnullの場合に年・月・日として表示する文字列<strong>(例:----年--月--日)</strong>
	 * @param minuteNullTextArg Dateオブジェクトがnullの場合に年・月・日・時・分として表示する文字列<strong>(例:----年--月--日 --時--分)</strong>
	 */
	public ConcreteMonthDateMinuteFormatter(DateFormat monthFormatArg,
			DateFormat dateFormatArg, DateFormat minuteFormatArg,
			String monthNullTextArg, String dateNullTextArg,
			String minuteNullTextArg) {
		//基底クラスのコンストラクタの呼び出し
		super();

		//==========================================================
		//引数をフィールドに設定
		this.monthFormat = monthFormatArg;
		this.dateFormat = dateFormatArg;
		this.minuteFormat = minuteFormatArg;
		this.monthNullText = monthNullTextArg;
		this.dateNullText = dateNullTextArg;
		this.minuteNullText = minuteNullTextArg;
	}


	//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
	//抽象メソッドの実装

	/**
	 * 与えられた年・月をフォーマット変換して返します。<br>
	 *
	 * @param yearArg 年
	 * @param monthArg 月
	 * @return フォーマット変換後の文字列
	 */
	public String getMonthString(int yearArg, int monthArg) {
		//与えられた年・月の情報で日付操作用インスタンスを生成(日には1を設定)
		DateUtil dateUtil = new DateUtil(yearArg, monthArg, 1);

		//日付操作用インスタンスからDateオブジェクトを取得して、実際に処理を行うメソッドを呼び出す
		return getMonthString(dateUtil.getDate());
	}

	/**
	 * 与えられた日付形式の文字列からDateオブジェクトを生成し、年・月をフォーマット変換して返します。<br>
	 *
	 * @param strArg 日付形式の文字列
	 * @return フォーマット変換後の文字列
	 */
	public String getMonthString(String strArg) {
		//文字列からDateオブジェクトを生成して、実際に処理を行うメソッドを呼び出す
		return getMonthString(DateUtil.parseDate(strArg));
	}

	/**
	 * 与えられたDateオブジェクトの年・月をフォーマット変換して返します。<br>
	 *
	 * @param dateArg 年・月の情報が設定されているDateオブジェクト
	 * @return フォーマット変換後の文字列
	 */
	public String getMonthString(Date dateArg) {
		//nullの場合
		if (dateArg == null) {
			//nullの場合の文字列を返す
			return monthNullText;
		}
		//nullでない場合
		else {
			//年・月をフォーマット変換して返す
			return monthFormat.format(dateArg);
		}
	}

	/**
	 * 与えられた年・月・日をフォーマット変換して返します。<br>
	 *
	 * @param yearArg 年
	 * @param monthArg 月
	 * @param dayArg 日
	 * @return フォーマット変換後の文字列
	 */
	public String getDateString(int yearArg, int monthArg, int dayArg) {
		//与えられた年・月・日の情報で日付操作用インスタンスを生成
		DateUtil dateUtil = new DateUtil(yearArg, monthArg, dayArg);

		//日付操作用インスタンスからDateオブジェクトを取得して、実際に処理を行うメソッドを呼び出す
		return getDateString(dateUtil.getDate());
	}

	/**
	 * 与えられた日付形式の文字列からDateオブジェクトを生成し、年・月・日をフォーマット変換して返します。<br>
	 *
	 * @param strArg 日付形式の文字列
	 * @return フォーマット変換後の文字列
	 */
	public String getDateString(String strArg) {
		//文字列からDateオブジェクトを生成して、実際に処理を行うメソッドを呼び出す
		return getDateString(DateUtil.parseDate(strArg));
	}

	/**
	 * 与えられたDateオブジェクトの年・月・日をフォーマット変換して返します。<br>
	 *
	 * @param dateArg 年・月・日の情報が設定されているDateオブジェクト
	 * @return フォーマット変換後の文字列
	 */
	public String getDateString(Date dateArg) {
		//nullの場合
		if (dateArg == null) {
			//nullの場合の文字列を返す
			return dateNullText;
		}
		//nullでない場合
		else {
			//年・月をフォーマット変換して返す
			return dateFormat.format(dateArg);
		}
	}

	/**
	 * 与えられた年・月・日・時・分をフォーマット変換して返します。<br>
	 *
	 * @param yearArg 年
	 * @param monthArg 月
	 * @param dayArg 日
	 * @param hourArg 時
	 * @param minuteArg 分
	 * @return フォーマット変換後の文字列
	 */
	public String getMinuteString(int yearArg, int monthArg, int dayArg,
			int hourArg, int minuteArg) {
		//与えられた年・月・日・時・分の情報で日付操作用インスタンスを生成
		DateUtil dateUtil = new DateUtil(yearArg,
				monthArg,
				dayArg,
				hourArg,
				minuteArg);

		//日付操作用インスタンスからDateオブジェクトを取得して、実際に処理を行うメソッドを呼び出す
		return getMinuteString(dateUtil.getDate());
	}

	/**
	 * 与えられた日付形式の文字列からDateオブジェクトを生成し、年・月・日・時・分をフォーマット変換して返します。<br>
	 *
	 * @param strArg 日付形式の文字列
	 * @return フォーマット変換後の文字列
	 */
	public String getMinuteString(String strArg) {
		//文字列からDateオブジェクトを生成して、実際に処理を行うメソッドを呼び出す
		return getMinuteString(DateUtil.parseDate(strArg));
	}

	/**
	 * 与えられたDateオブジェクトの年・月・日・時・分をフォーマット変換して返します。<br>
	 *
	 * @param dateArg 年・月・日・時・分の情報が設定されているDateオブジェクト
	 * @return フォーマット変換後の文字列
	 */
	public String getMinuteString(Date dateArg) {
		//nullの場合
		if (dateArg == null) {
			//nullの場合の文字列を返す
			return minuteNullText;
		}
		//nullでない場合
		else {
			//年・月をフォーマット変換して返す
			return minuteFormat.format(dateArg);
		}
	}

}
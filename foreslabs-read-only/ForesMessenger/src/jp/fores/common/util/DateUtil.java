package jp.fores.common.util;

import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.GregorianCalendar;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import jp.fores.common.exception.DateException;


/**
 * 日付操作用クラス。<br>
 * <i>(Adapterパターンを応用)</i><br>
 * <br>
 * このクラスでは、DateクラスでJDK1.1以降推奨されなくなった機能を、インター
 * フェースはほぼ保ったまま、実際の処理をGregorianCalendarオブジェクトに委譲
 * することによって実装しています。<br>
 * また、引数や戻り値にStringを使用できるようにしています。<br>
 * <br>
 * <strong>(注1)</strong><br>
 * 一部の機能については利便性を向上させるためにあえてインターフェー
 * スを変更している部分もあります。<br>
 * <i>(例)月の値を「0～11」から「1～12」に変更<br></i>
 * <br>
 * <strong>(注2)</strong><br>
 * このクラスの説明で用いているDateオブジェクトは、「java.util.Date」を指しています。<br>
 * 「java.sql.Date」を指す場合はその旨を明示しています。<br>
 * <br>
 * 細かいインターフェースについては、各メソッドの詳細を参照して下さい。<br>
 */
public final class DateUtil {

	//==========================================================
	//定数

	/**
	 * ログ出力用
	 */
	private static final Log log = LogFactory.getLog(DateUtil.class);

	/**
	 * String → Date 変換のパターン集
	 */
	private static final SimpleDateFormat[] sdfs;

	/**
	 * イニシャライザです。<br>
	 * String → Date 変換のパターン集を設定します。<br>
	 */
	static {
		sdfs = new SimpleDateFormat[] {
				new SimpleDateFormat("yyyy/MM/dd HH:mm:ss"),
				new SimpleDateFormat("yyyyMMddHHmmss"),
				new SimpleDateFormat("yyyy/MM/dd HH:mm"),
				new SimpleDateFormat("yyyyMMddHHMM"),
				new SimpleDateFormat("yyyy/MM/dd"),
				new SimpleDateFormat("yyyyMMdd"),
				new SimpleDateFormat("yyyy/MM"),
				new SimpleDateFormat("HH:mm:ss"), new SimpleDateFormat("HH:mm") };

		//時刻のチェックを厳密に行う
		for (int i = 0; i < sdfs.length; i++) {
			sdfs[i].setLenient(false);
		}
	}


	//==============================================================
	//フィールド

	//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
	//インスタンス変数

	/**
	 * 実際に日付操作を行うGregorianCalendarオブジェクト
	 */
	private GregorianCalendar gregCalendar = null;


	//==========================================================
	//メソッド

	//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
	//コンストラクタ

	/**
	 * コンストラクタです。<br>
	 * 現在の日付でインスタンスを生成します。<br>
	 */
	public DateUtil() {
		//基底クラスのコンストラクタの呼び出し
		super();

		//引数なしコンストラクタを呼び出す
		gregCalendar = new GregorianCalendar();
	}

	/**
	 * コンストラクタです。<br>
	 * 指定したDateオブジェクトでインスタンスを生成します。<br>
	 *
	 * @param dateArg Dateオブジェクト
	 */
	public DateUtil(Date dateArg) {
		//基底クラスのコンストラクタの呼び出し
		super();

		//引数なしコンストラクタを呼び出す
		gregCalendar = new GregorianCalendar();

		//Dateオブジェクトで日付を設定
		setDate(dateArg);
	}

	/**
	 * コンストラクタです。<br>
	 * 指定した文字列でインスタンスを生成します。<br>
	 * 変換には、parseDate()を使用します。<br>
	 *
	 * @param strArg 文字列
	 * @exception DateException Date型に変換できない場合
	 */
	public DateUtil(String strArg) throws DateException {
		//文字列をDateオブジェクトに変換して実際に処理を行うコンストラクタを呼び出す
		this(parseDate(strArg));
	}

	/**
	 * コンストラクタです。<br>
	 * 指定した年・月・日でインスタンスを生成します。<br>
	 * (不正な値の場合の動作は保証しません。)<br>
	 *
	 * @param yearArg 年
	 * @param monthArg 月(「1～12」)
	 * @param dayArg 日
	 */
	public DateUtil(int yearArg, int monthArg, int dayArg) {
		//基底クラスのコンストラクタの呼び出し
		super();

		//年・月・日を引数に持つコンストラクタを呼び出す
		gregCalendar = new GregorianCalendar(yearArg, monthArg - 1, dayArg);
	}

	/**
	 * コンストラクタです。<br>
	 * 指定した年・月・日でインスタンスを生成します。<br>
	 * (不正な値の場合の動作は保証しません。)<br>
	 *
	 * @param yearArg 年
	 * @param monthArg 月(「1～12」)
	 * @param dayArg 日
	 */
	public DateUtil(String yearArg, String monthArg, String dayArg) {
		//int型に変換して実際に処理を行うコンストラクタを呼び出す
		this(Integer.parseInt(yearArg),
				Integer.parseInt(monthArg),
				Integer.parseInt(dayArg));
	}

	/**
	 * コンストラクタです。<br>
	 * 指定した年・月・日・時・分でインスタンスを生成します。<br>
	 * (不正な値の場合の動作は保証しません。)<br>
	 *
	 * @param yearArg 年
	 * @param monthArg 月(「1～12」)
	 * @param dayArg 日
	 * @param hourArg 時間(「0～23」)
	 * @param minuteArg 分(「0～59」)
	 */
	public DateUtil(int yearArg, int monthArg, int dayArg, int hourArg,
			int minuteArg) {
		//基底クラスのコンストラクタの呼び出し
		super();

		//年・月・日・時・分を引数に持つコンストラクタを呼び出す
		gregCalendar = new GregorianCalendar(yearArg,
				monthArg - 1,
				dayArg,
				hourArg,
				minuteArg);
	}

	/**
	 * コンストラクタです。<br>
	 * 指定した年・月・日・時・分でインスタンスを生成します。<br>
	 * (不正な値の場合の動作は保証しません。)<br>
	 *
	 * @param yearArg 年
	 * @param monthArg 月(「1～12」)
	 * @param dayArg 日
	 * @param hourArg 時間(「0～23」)
	 * @param minuteArg 分(「0～59」)
	 */
	public DateUtil(String yearArg, String monthArg, String dayArg,
			String hourArg, String minuteArg) {
		//int型に変換して実際に処理を行うコンストラクタを呼び出す
		this(Integer.parseInt(yearArg),
				Integer.parseInt(monthArg),
				Integer.parseInt(dayArg),
				Integer.parseInt(hourArg),
				Integer.parseInt(minuteArg));
	}

	/**
	 * コンストラクタです。<br>
	 * 指定した年・月・日・時・分・秒でインスタンスを生成します。<br>
	 * (不正な値の場合の動作は保証しません。)<br>
	 *
	 * @param yearArg 年
	 * @param monthArg 月(「1～12」)
	 * @param dayArg 日
	 * @param hourArg 時間(「0～23」)
	 * @param minuteArg 分(「0～59」)
	 * @param secondArg 秒(「0～59」)
	 */
	public DateUtil(int yearArg, int monthArg, int dayArg, int hourArg,
			int minuteArg, int secondArg) {
		//基底クラスのコンストラクタの呼び出し
		super();

		//年・月・日・時・分・秒を引数に持つコンストラクタを呼び出す
		gregCalendar = new GregorianCalendar(yearArg,
				monthArg - 1,
				dayArg,
				hourArg,
				minuteArg,
				secondArg);
	}

	/**
	 * コンストラクタです。<br>
	 * 指定した年・月・日・時・分・秒でインスタンスを生成します。<br>
	 * (不正な値の場合の動作は保証しません。)<br>
	 *
	 * @param yearArg 年
	 * @param monthArg 月(「1～12」)
	 * @param dayArg 日
	 * @param hourArg 時間(「0～23」)
	 * @param minuteArg 分(「0～59」)
	 * @param secondArg 秒(「0～59」)
	 */
	public DateUtil(String yearArg, String monthArg, String dayArg,
			String hourArg, String minuteArg, String secondArg) {
		//int型に変換して実際に処理を行うコンストラクタを呼び出す
		this(Integer.parseInt(yearArg),
				Integer.parseInt(monthArg),
				Integer.parseInt(dayArg),
				Integer.parseInt(hourArg),
				Integer.parseInt(minuteArg),
				Integer.parseInt(secondArg));
	}


	//==============================================================
	//クラスメソッド

	/**
	 * 現在時刻のDateオブジェクトを取得します。<br>
	 *
	 * @return 現在時刻のDateオブジェクト
	 */
	public static Date getCurrentDate() {
		return Calendar.getInstance().getTime();
	}

	/**
	 * 指定した月の最終日を設定したDateオブジェクトを取得します。<br>
	 *
	 * @param dateArg 基準となる日付が設定されたDateオブジェクト
	 * @return 月の最終日が設定されたDateオブジェクト
	 */
	public static Date getMonthLastDate(Date dateArg) {
		//日付操作用インスタンスを生成
		DateUtil dateUtil = new DateUtil(dateArg);

		//==========================================================
		//次の月の最初の日から1日前に戻して最終日を求める

		//1月進める
		dateUtil.addMonth(1);

		//最初の日を設定する
		dateUtil.setDay(1);

		//1日戻す
		dateUtil.addDay(-1);

		//Dateで返す
		return dateUtil.getDate();
	}

	/**
	 * 文字列をDate型に変換します。<br>
	 * <br>
	 * <i>現在用意されている変換パターン</i>
	 * <ul>
	 *  <li>yyyy/MM/dd HH:mm:ss</li>
	 *  <li>yyyyMMddHHmmss</li>
	 *  <li>yyyy/MM/dd HH:mm →　秒は0</li>
	 *  <li>yyyy/MM/dd → 時:分:秒は0</li>
	 *  <li>yyyyMMdd → 時:分:秒は0</li>
	 *  <li>yyyy/MM → 日は1, 時:分:秒は0</li>
	 *  <li>HH:mm:ss → 年月日は 1970/1/1</li>
	 *  <li>HH:mm → 年月日は 1970/1/1, 秒は0</li>
	 * </ul><br>
	 *
	 * @param strArg Date型に変換したい文字列
	 * @return 変換されたDate型
	 * @exception DateException Date型に変換できない場合
	 */
	public static Date parseDate(String strArg) throws DateException {
		//登録されている全てのフォーマットパターンを試す
		for (int i = 0; i < sdfs.length; i++) {
			try {
				//変換に成功した場合はその値を返して終了
				return sdfs[i].parse(strArg);
			}
			//例外処理
			catch (Exception e) {
				//変換に失敗しても続けるので無視
			}
		}

		//==========================================================
		//どのパターンを使っても変換できなかった場合

		//例外を投げる
		throw new DateException("[" + strArg + "]はDate型に変換できません");
	}

	/**
	 * 生年月日と基準日から年齢を計算します。<br>
	 *
	 * @param birthDateArg 生年月日
	 * @param standardDateArg 生年月日と比較する基準となる日付
	 * @return 年齢(もし、生年月日が基準日よりも未来の場合はマイナスが返ります。)
	 */
	public static int calcAge(DateUtil birthDateArg, DateUtil standardDateArg) {
		//基準日の年から生年月日の年を引く
		int age = standardDateArg.getYear() - birthDateArg.getYear();

		//基準日の月が生年月日の月よりも未来の場合
		if (standardDateArg.getDayOfYear() > birthDateArg.getDayOfYear()) {
			//生年月日と基準日の年の差をそのまま返す
			return age;
		}

		//基準日の月が生年月日の月よりも昔の場合
		else if (standardDateArg.getMonth() < birthDateArg.getMonth()) {
			//まだその年の誕生日を迎えていないので、生年月日と基準日の年の差から1をひいて返す
			return age - 1;
		}

		//基準日の月と生年月日の月が同じ場合
		else {
			//基準日の日が生年月日の日と同じ、または未来の場合
			if (standardDateArg.getDay() >= birthDateArg.getDay()) {
				//生年月日と基準日の年の差をそのまま返す
				return age;
			}

			//基準日の日が生年月日の日よりも昔の場合
			else {
				//まだその年の誕生日を迎えていないので、生年月日と基準日の年の差から1をひいて返す
				return age - 1;
			}
		}
	}

	/**
	 * java.util.Dateオブジェクトをjava.sql.Dateオブジェクトに変換して返します。<br>
	 *
	 * @param dateArg java.util.Dateオブジェクト
	 * @return java.sql.Dateオブジェクト
	 */
	public static java.sql.Date convertToSQLDate(Date dateArg) {
		//Dateオブジェクトのミリ秒数を取得し、それでjava.sql.Dateオブジェクトを作成して返す
		return new java.sql.Date(dateArg.getTime());
	}

	/**
	 * java.util.Dateオブジェクトをjava.sql.Timestampオブジェクトに変換して返します。<br>
	 *
	 * @param dateArg java.util.Dateオブジェクト
	 * @return java.sql.Timestampオブジェクト
	 */
	public static java.sql.Timestamp convertToTimestamp(Date dateArg) {
		//Dateオブジェクトのミリ秒数を取得し、それでjava.sql.Dateオブジェクトを作成して返す
		return new java.sql.Timestamp(dateArg.getTime());
	}

	/**
	 * 指定された2つの日付の年月日が一致するかどうかを調べます。<br>
	 * 日付にnullが指定された場合も考慮します。<br>
	 * 時分秒の情報は無視されます。<br>
	 *
	 * @param date1Arg 比較対象の日付1
	 * @param date2Arg 比較対象の日付2
	 * @return true=年月日が一致する場合, false=年月日のいずれか1つでも異なる場合
	 */
	public static boolean equalsDate(Date date1Arg, Date date2Arg) {

		//日付1と日付2が両方ともnullの場合
		if ((date1Arg == null) && (date2Arg == null)) {
			//一致すると見なせるのでtrueを返す
			return true;
		}
		//日付1と日付2のどちらか一方がnullの場合
		else if ((date1Arg == null) || (date2Arg == null)) {
			//一致しないのでfalseを返す
			return false;
		}

		//引数の日付を元に日付操作用オブジェクトを生成
		DateUtil date1 = new DateUtil(date1Arg);
		DateUtil date2 = new DateUtil(date2Arg);

		//年月日が全て一致する場合
		if ((date1.getYear() == date2.getYear())
				&& (date1.getMonth() == date2.getMonth())
				&& (date1.getDay() == date2.getDay())) {
			//trueを返す
			return true;
		}
		//年月日のいずれか1つでも異なる場合
		else {
			//falseを返す
			return false;
		}
	}


	//==============================================================
	//Getter

	/**
	 * Dateオブジェクトを取得します。<br>
	 *
	 * @return Dateオブジェクト
	 */
	public Date getDate() {
		return gregCalendar.getTime();
	}

	/**
	 * java.sql.Dateオブジェクトを取得します。<br>
	 *
	 * @return java.sql.Dateオブジェクト
	 */
	public java.sql.Date getSQLDate() {
		//java.sql.Dateに変換するメソッドを呼び出して結果をそのまま返す
		return convertToSQLDate(gregCalendar.getTime());
	}

	/**
	 * java.sql.Timestampオブジェクトを取得します。<br>
	 *
	 * @return java.sql.Timestampオブジェクト
	 */
	public java.sql.Timestamp getTimestamp() {
		//java.sql.Timestampに変換するメソッドを呼び出して結果をそのまま返す
		return convertToTimestamp(gregCalendar.getTime());
	}

	/**
	 * 年を取得します。<br>
	 *
	 * @return 年
	 */
	public int getYear() {
		return gregCalendar.get(Calendar.YEAR);
	}

	/**
	 * 文字列の年を取得します。<br>
	 *
	 * @return 文字列の年
	 */
	public String getYearStr() {
		//文字列に変換して返す
		return Integer.toString(getYear());
	}

	/**
	 * 月を取得します。<br>
	 * 標準の「0～11」ではなく、「1～12」の値を返します。<br>
	 *
	 * @return 月(1～12)
	 */
	public int getMonth() {
		//取得した値に1を足してから返す
		return (gregCalendar.get(Calendar.MONTH) + 1);
	}

	/**
	 * 文字列の月を取得します。<br>
	 * 標準の「0～11」ではなく、「01～12」の値を返します。<br>
	 * (結果が1桁の場合は、2桁の文字列に変換します。)<br>
	 *
	 * @return 文字列の月(01～12)
	 */
	public String getMonthStr() {
		//2桁の文字列に変換して返す
		return StringUtil.convertTwoDigitString(getMonth());
	}

	/**
	 * 日を取得します。<br>
	 * 「1～31」の値を返します。<br>
	 *
	 * @return 日(1～31)
	 */
	public int getDay() {
		return gregCalendar.get(Calendar.DATE);
	}

	/**
	 * 文字列の日を取得します。<br>
	 * 「01～31」の値を返します。<br>
	 * (結果が1桁の場合は、2桁の文字列に変換します。)<br>
	 *
	 * @return 文字列の日(01～31)
	 */
	public String getDayStr() {
		//2桁の文字列に変換して返す
		return StringUtil.convertTwoDigitString(getDay());
	}

	/**
	 * 時間を取得します。<br>
	 * 「0～23」の値を返します。<br>
	 *
	 * @return 時間(0～23)
	 */
	public int getHour() {
		return gregCalendar.get(Calendar.HOUR_OF_DAY);
	}

	/**
	 * 文字列の時間を取得します。<br>
	 * 「00～23」の値を返します。<br>
	 * (結果が1桁の場合は、2桁の文字列に変換します。)<br>
	 *
	 * @return 文字列の時間(00～23)
	 */
	public String getHourStr() {
		//2桁の文字列に変換して返す
		return StringUtil.convertTwoDigitString(getHour());
	}

	/**
	 * 分を取得します。<br>
	 * 「0～59」の値を返します。<br>
	 *
	 * @return 分(0～59)
	 */
	public int getMinute() {
		return gregCalendar.get(Calendar.MINUTE);
	}

	/**
	 * 文字列の分を取得します。<br>
	 * 「00～59」の値を返します。<br>
	 * (結果が1桁の場合は、2桁の文字列に変換します。)<br>
	 *
	 * @return 文字列の分(00～59)
	 */
	public String getMinuteStr() {
		//2桁の文字列に変換して返す
		return StringUtil.convertTwoDigitString(getMinute());
	}

	/**
	 * 秒を取得します。<br>
	 * 「0～59」の値を返します。<br>
	 *
	 * @return 秒(0～59)
	 */
	public int getSecond() {
		return gregCalendar.get(Calendar.SECOND);
	}

	/**
	 * 文字列の秒を取得します。<br>
	 * 「00～59」の値を返します。<br>
	 * (結果が1桁の場合は、2桁の文字列に変換します。)<br>
	 *
	 * @return 文字列の秒(00～59)
	 */
	public String getSecondStr() {
		//2桁の文字列に変換して返す
		return StringUtil.convertTwoDigitString(getSecond());
	}

	/**
	 * 現在の年の何日目かを取得します。<br>
	 * 「1～366」の値を返します。<br>
	 *
	 * @return 現在の年の何日目か(1～366)
	 */
	public int getDayOfYear() {
		return gregCalendar.get(Calendar.DAY_OF_YEAR);
	}

	/**
	 * 曜日を取得します。<br>
	 * 曜日を表す定数(java.util.Calendar.SUNDAY 等)を返します。<br>
	 *
	 * @return 曜日(曜日を表す定数)
	 */
	public int getDayOfWeek() {
		return gregCalendar.get(Calendar.DAY_OF_WEEK);
	}


	//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
	//Setter

	/**
	 * 日付に現在日付を設定します。<br>
	 */
	public void setDate() {
		//現在日付を設定
		gregCalendar.setTime(getCurrentDate());
	}

	/**
	 * 指定したDateオブジェクトで日付を設定します。<br>
	 *
	 * @param dateArg Dateオブジェクト
	 */
	public void setDate(Date dateArg) {
		//Dateオブジェクトで日付を設定
		gregCalendar.setTime(dateArg);
	}

	/**
	 * 指定した文字列で日付を設定します。<br>
	 * 変換には、parseDate()を使用します。<br>
	 *
	 * @param strArg 文字列
	 * @exception DateException Date型に変換できない場合
	 */
	public void setDate(String strArg) throws DateException {
		//文字列をDateオブジェクトに変換して実際に処理を行うメソッドを呼び出す
		setDate(parseDate(strArg));
	}

	/**
	 * 指定した年・月・日で日付を設定します。<br>
	 * それ以外の情報は初期化します。<br>
	 * (不正な値の場合の動作は保証しません。)<br>
	 *
	 * @param yearArg 年
	 * @param monthArg 月(「1～12」)
	 * @param dayArg 日
	 */
	public void setDate(int yearArg, int monthArg, int dayArg) {
		//日付の初期化
		clear();

		//年・月・日で日付を設定
		gregCalendar.set(yearArg, monthArg - 1, dayArg);
	}

	/**
	 * 指定した年・月・日で日付を設定します。<br>
	 * それ以外の情報は初期化します。<br>
	 * (不正な値の場合の動作は保証しません。)<br>
	 *
	 * @param yearArg 年
	 * @param monthArg 月(「1～12」)
	 * @param dayArg 日
	 */
	public void setDate(String yearArg, String monthArg, String dayArg) {
		//int型に変換して実際に処理を行うメソッドを呼び出す
		setDate(Integer.parseInt(yearArg),
				Integer.parseInt(monthArg),
				Integer.parseInt(dayArg));
	}

	/**
	 * 指定した年・月・日・時・分で日付を設定します。<br>
	 * それ以外の情報は初期化します。<br>
	 * (不正な値の場合の動作は保証しません。)<br>
	 *
	 * @param yearArg 年
	 * @param monthArg 月(「1～12」)
	 * @param dayArg 日
	 * @param hourArg 時間(「0～23」)
	 * @param minuteArg 分(「0～59」)
	 */
	public void setDate(int yearArg, int monthArg, int dayArg, int hourArg,
			int minuteArg) {
		//日付の初期化
		clear();

		//年・月・日・時・分で日付を設定
		gregCalendar.set(yearArg, monthArg - 1, dayArg, hourArg, minuteArg);
	}

	/**
	 * 指定した年・月・日・時・分で日付を設定します。<br>
	 * それ以外の情報は初期化します。<br>
	 * (不正な値の場合の動作は保証しません。)<br>
	 *
	 * @param yearArg 年
	 * @param monthArg 月(「1～12」)
	 * @param dayArg 日
	 * @param hourArg 時間(「0～23」)
	 * @param minuteArg 分(「0～59」)
	 */
	public void setDate(String yearArg, String monthArg, String dayArg,
			String hourArg, String minuteArg) {
		//int型に変換して実際に処理を行うメソッドを呼び出す
		setDate(Integer.parseInt(yearArg),
				Integer.parseInt(monthArg),
				Integer.parseInt(dayArg),
				Integer.parseInt(hourArg),
				Integer.parseInt(minuteArg));
	}

	/**
	 * 指定した年・月・日・時・分・秒で日付を設定します。<br>
	 * (不正な値の場合の動作は保証しません。)<br>
	 *
	 * @param yearArg 年
	 * @param monthArg 月(「1～12」)
	 * @param dayArg 日
	 * @param hourArg 時間(「0～23」)
	 * @param minuteArg 分(「0～59」)
	 * @param secondArg 秒(「0～59」)
	 */
	public void setDate(int yearArg, int monthArg, int dayArg, int hourArg,
			int minuteArg, int secondArg) {
		//日付の初期化
		clear();

		//年・月・日・時・分・秒で日付を設定
		gregCalendar.set(yearArg,
				monthArg - 1,
				dayArg,
				hourArg,
				minuteArg,
				secondArg);
	}

	/**
	 * 指定した年・月・日・時・分・秒で日付を設定します。<br>
	 * それ以外の情報は初期化します。<br>
	 * (不正な値の場合の動作は保証しません。)<br>
	 *
	 * @param yearArg 年
	 * @param monthArg 月(「1～12」)
	 * @param dayArg 日
	 * @param hourArg 時間(「0～23」)
	 * @param minuteArg 分(「0～59」)
	 * @param secondArg 秒(「0～59」)
	 */
	public void setDate(String yearArg, String monthArg, String dayArg,
			String hourArg, String minuteArg, String secondArg) {
		//int型に変換して実際に処理を行うメソッドを呼び出す
		setDate(Integer.parseInt(yearArg),
				Integer.parseInt(monthArg),
				Integer.parseInt(dayArg),
				Integer.parseInt(hourArg),
				Integer.parseInt(minuteArg),
				Integer.parseInt(secondArg));
	}


	/**
	 * 年を指定された値に設定します。<br>
	 *
	 * @param yearArg 年
	 */
	public void setYear(int yearArg) {
		gregCalendar.set(Calendar.YEAR, yearArg);
	}

	/**
	 * 年を指定された値に設定します。<br>
	 *
	 * @param yearArg 年
	 */
	public void setYear(String yearArg) {
		//int型に変換して実際に処理を行うメソッドを呼び出す
		setYear(Integer.parseInt(yearArg));
	}

	/**
	 * 月を指定された値に設定します。<br>
	 * (「1～12」の値を指定して下さい。それ以外の場合の動作は保証しません。)<br>
	 *
	 * @param monthArg 月(「1～12」)
	 */
	public void setMonth(int monthArg) {
		gregCalendar.set(Calendar.MONTH, monthArg - 1);
	}

	/**
	 * 月を指定された値に設定します。<br>
	 * (「1～12」の値を指定して下さい。それ以外の場合の動作は保証しません。)<br>
	 *
	 * @param monthArg 月(「1～12」)
	 */
	public void setMonth(String monthArg) {
		//int型に変換して実際に処理を行うメソッドを呼び出す
		setMonth(Integer.parseInt(monthArg));
	}

	/**
	 * 日を指定された値に設定します。<br>
	 * (存在しない日を指定した場合の動作は保証しません。)<br>
	 *
	 * @param dayArg 日
	 */
	public void setDay(int dayArg) {
		gregCalendar.set(Calendar.DATE, dayArg);
	}

	/**
	 * 日を指定された値に設定します。<br>
	 * (存在しない日を指定した場合の動作は保証しません。)<br>
	 *
	 * @param dayArg 日
	 */
	public void setDay(String dayArg) {
		//int型に変換して実際に処理を行うメソッドを呼び出す
		setDay(Integer.parseInt(dayArg));
	}

	/**
	 * 時間を指定された値に設定します。<br>
	 * (「0～23」の値を指定して下さい。それ以外の場合の動作は保証しません。)<br>
	 *
	 * @param hourArg 時間(「0～23」)
	 */
	public void setHour(int hourArg) {
		gregCalendar.set(Calendar.HOUR_OF_DAY, hourArg);
	}

	/**
	 * 時間を指定された値に設定します。<br>
	 * (「0～23」の値を指定して下さい。それ以外の場合の動作は保証しません。)<br>
	 *
	 * @param hourArg 時間(「0～23」)
	 */
	public void setHour(String hourArg) {
		//int型に変換して実際に処理を行うメソッドを呼び出す
		setHour(Integer.parseInt(hourArg));
	}

	/**
	 * 分を指定された値に設定します。<br>
	 * (「0～59」の値を指定して下さい。それ以外の場合の動作は保証しません。)<br>
	 *
	 * @param minuteArg 分(「0～59」)
	 */
	public void setMinute(int minuteArg) {
		gregCalendar.set(Calendar.MINUTE, minuteArg);
	}

	/**
	 * 分を指定された値に設定します。<br>
	 * (「0～59」の値を指定して下さい。それ以外の場合の動作は保証しません。)<br>
	 *
	 * @param minuteArg 分(「0～59」)
	 */
	public void setMinute(String minuteArg) {
		//int型に変換して実際に処理を行うメソッドを呼び出す
		setMinute(Integer.parseInt(minuteArg));
	}

	/**
	 * 秒を指定された値に設定します。<br>
	 * (「0～59」の値を指定して下さい。それ以外の場合の動作は保証しません。)<br>
	 *
	 * @param secondArg 秒(「0～59」)
	 */
	public void setSecond(int secondArg) {
		gregCalendar.set(Calendar.SECOND, secondArg);
	}

	/**
	 * 秒を指定された値に設定します。<br>
	 * (「0～59」の値を指定して下さい。それ以外の場合の動作は保証しません。)<br>
	 *
	 * @param secondArg 秒(「0～59」)
	 */
	public void setSecond(String secondArg) {
		//int型に変換して実際に処理を行うメソッドを呼び出す
		setSecond(Integer.parseInt(secondArg));
	}


	//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
	//adder

	/**
	 * 指定した年数だけ日付を進めます。<br>
	 * (戻したい場合は、マイナスの値を指定して下さい。)<br>
	 *
	 * @param yearArg 進めたい（戻したい）年数
	 */
	public void addYear(int yearArg) {
		gregCalendar.add(Calendar.YEAR, yearArg);
	}


	/**
	 * 指定した月数だけ日付を進めます。<br>
	 * (戻したい場合は、マイナスの値を指定して下さい。)<br>
	 *
	 * @param monthArg 進めたい（戻したい）月数
	 */
	public void addMonth(int monthArg) {
		gregCalendar.add(Calendar.MONTH, monthArg);
	}

	/**
	 * 指定した日数だけ日付を進めます。<br>
	 * (戻したい場合は、マイナスの値を指定して下さい。)<br>
	 *
	 * @param dayArg 進めたい（戻したい）日数
	 */
	public void addDay(int dayArg) {
		gregCalendar.add(Calendar.DATE, dayArg);
	}

	/**
	 * 指定した時間数だけ日付を進めます。<br>
	 * (戻したい場合は、マイナスの値を指定して下さい。)<br>
	 *
	 * @param hourArg 進めたい（戻したい）時間数
	 */
	public void addHour(int hourArg) {
		gregCalendar.add(Calendar.HOUR_OF_DAY, hourArg);
	}

	/**
	 * 指定した分数だけ日付を進めます。<br>
	 * (戻したい場合は、マイナスの値を指定して下さい。)<br>
	 *
	 * @param minuteArg 進めたい（戻したい）分数
	 */
	public void addMinute(int minuteArg) {
		gregCalendar.add(Calendar.MINUTE, minuteArg);
	}

	/**
	 * 指定した秒数だけ日付を進めます。<br>
	 * (戻したい場合は、マイナスの値を指定して下さい。)<br>
	 *
	 * @param secondArg 進めたい（戻したい）秒数
	 */
	public void addSecond(int secondArg) {
		gregCalendar.add(Calendar.SECOND, secondArg);
	}


	//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
	//その他

	/**
	 * 日付を初期化します。<br>
	 */
	public void clear() {
		gregCalendar.clear();
	}


	//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
	//オーバーライドするメソッド

	/**
	 * このオブジェクトと他のオブジェクトが等しいかどうかを示します。
	 * 比較対象がDateオブジェクトの場合は、getDate()で取得したDateオブジェクトと比較します。 <br>
	 *
	 * @param objArg 比較対象のオブジェクト
	 * @return true=等しい, false=等しくない
	 */
	public boolean equals(Object objArg) {
		//比較対象がDateオブジェクトの場合
		if (objArg instanceof Date) {
			//getDate()で取得したDateオブジェクトのequals()を呼び出して結果をそのまま返す
			return getDate().equals(objArg);
		}
		//それ以外の場合
		else {
			//基底クラスのequals()を呼び出して結果をそのまま返す
			return super.equals(objArg);
		}

	}

	/**
	 * Dateオブジェクトの文字列表現を返します。<br>
	 *
	 * @return Dateオブジェクトの文字列表現
	 */
	public String toString() {
		//Dateオブジェクトの文字列表現を返す
		return getDate().toString();
	}

}

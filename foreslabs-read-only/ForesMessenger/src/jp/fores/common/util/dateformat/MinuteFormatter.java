package jp.fores.common.util.dateformat;

import java.util.Date;


/**
 * 年・月・日・時・分をフォーマット変換するインターフェース。<br>
 */
public interface MinuteFormatter {

	//==========================================================
	//メソッド

	//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
	//抽象メソッド

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
	public abstract String getMinuteString(int yearArg, int monthArg,
			int dayArg, int hourArg, int minuteArg);

	/**
	 * 与えられた日付形式の文字列からDateオブジェクトを生成し、年・月・日・時・分をフォーマット変換して返します。<br>
	 *
	 * @param strArg 日付形式の文字列
	 * @return フォーマット変換後の文字列
	 */
	public abstract String getMinuteString(String strArg);

	/**
	 * 与えられたDateオブジェクトの年・月・日・時・分をフォーマット変換して返します。<br>
	 *
	 * @param dateArg 年・月・日・時・分の情報が設定されているDateオブジェクト
	 * @return フォーマット変換後の文字列
	 */
	public abstract String getMinuteString(Date dateArg);

}

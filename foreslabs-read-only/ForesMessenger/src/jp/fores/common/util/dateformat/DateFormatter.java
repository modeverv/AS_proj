package jp.fores.common.util.dateformat;

import java.util.Date;


/**
 * 年・月・日をフォーマット変換するインターフェース。<br>
 */
public interface DateFormatter {

	//==========================================================
	//メソッド

	//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
	//抽象メソッド

	/**
	 * 与えられた年・月・日をフォーマット変換して返します。<br>
	 *
	 * @param yearArg 年
	 * @param monthArg 月
	 * @param dayArg 日
	 * @return フォーマット変換後の文字列
	 */
	public abstract String getDateString(int yearArg, int monthArg, int dayArg);

	/**
	 * 与えられた日付形式の文字列からDateオブジェクトを生成し、年・月・日をフォーマット変換して返します。<br>
	 *
	 * @param strArg 日付形式の文字列
	 * @return フォーマット変換後の文字列
	 */
	public abstract String getDateString(String strArg);

	/**
	 * 与えられたDateオブジェクトの年・月・日をフォーマット変換して返します。<br>
	 *
	 * @param dateArg 年・月・日の情報が設定されているDateオブジェクト
	 * @return フォーマット変換後の文字列
	 */
	public abstract String getDateString(Date dateArg);

}

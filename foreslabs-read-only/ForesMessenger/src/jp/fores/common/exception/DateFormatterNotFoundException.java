package jp.fores.common.exception;

import jp.fores.common.util.dateformat.MonthDateMinuteFormatter;
import jp.fores.common.util.dateformat.MonthDateMinuteFormatterManager;


/**
 * 日付フォーマット変換用インスタンスの取得に失敗した場合に投げられる例外。<br>
 * (RuntimeExceptionを継承しているので、必ずしもtry～catchで補足する必要はありません。)<br>
 *
 * @see MonthDateMinuteFormatterManager
 * @see MonthDateMinuteFormatter
 */
public class DateFormatterNotFoundException extends NotFoundException {

	//==========================================================
	//メソッド

	//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
	//コンストラクタ

	/**
	 * 指定された詳細メッセージを持つ Exception を構築します。<br>
	 *
	 * @param strArg 詳細メッセージ
	 */
	public DateFormatterNotFoundException(String strArg) {
		//基底クラスの引数付きコンストラクタをそのまま呼び出す
		super(strArg);
	}

	/**
	 * 指定された詳細メッセージと子例外を持つ Exception を構築します。<br>
	 *
	 * @param strArg 詳細メッセージ
	 * @param childExceptionArg 子例外
	 */
	public DateFormatterNotFoundException(String strArg,
			Throwable childExceptionArg) {
		//基底クラスの引数付きコンストラクタの呼び出し
		super(strArg, childExceptionArg);
	}
}

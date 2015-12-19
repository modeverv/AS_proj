package jp.fores.common.exception;


/**
 * 不正な形式のデータを検出した場合に投げられる例外。<br>
 * (RuntimeExceptionを継承しているので、必ずしもtry～catchで補足する必要はありません。)<br>
 */
public class ValidationException extends RuntimeException {

	//==========================================================
	//メソッド

	//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
	//コンストラクタ

	/**
	 * 指定された詳細メッセージを持つ Exception を構築します。<br>
	 *
	 * @param strArg 詳細メッセージ
	 */
	public ValidationException(String strArg) {
		//基底クラスの引数付きコンストラクタをそのまま呼び出す
		super(strArg);
	}

	/**
	 * 指定された詳細メッセージと子例外を持つ Exception を構築します。<br>
	 *
	 * @param strArg 詳細メッセージ
	 * @param childExceptionArg 子例外
	 */
	public ValidationException(String strArg, Throwable childExceptionArg) {
		//基底クラスの引数付きコンストラクタの呼び出し
		super(strArg, childExceptionArg);
	}
}

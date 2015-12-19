package jp.fores.common.exception;


/**
 * セッションの値の取得に失敗した場合に投げられる例外。<br>
 * (RuntimeExceptionを継承しているので、必ずしもtry～catchで補足する必要はありません。)<br>
 */
public class SessionNotFoundException extends NotFoundException {

	//==========================================================
	//メソッド

	//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
	//コンストラクタ

	/**
	 * 指定された詳細メッセージを持つ Exception を構築します。<br>
	 *
	 * @param strArg 詳細メッセージ
	 */
	public SessionNotFoundException(String strArg) {
		//基底クラスの引数付きコンストラクタをそのまま呼び出す
		super(strArg);
	}

	/**
	 * 指定された詳細メッセージと子例外を持つ Exception を構築します。<br>
	 *
	 * @param strArg 詳細メッセージ
	 * @param childExceptionArg 子例外
	 */
	public SessionNotFoundException(String strArg, Throwable childExceptionArg) {
		//基底クラスの引数付きコンストラクタの呼び出し
		super(strArg, childExceptionArg);
	}
}

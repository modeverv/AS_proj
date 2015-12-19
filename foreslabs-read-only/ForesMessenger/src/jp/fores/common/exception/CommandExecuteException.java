package jp.fores.common.exception;

import jp.fores.common.util.CommandExecuter;


/**
 * コマンドの終了コードが不正な場合に投げられる例外。<br>
 *
 * @see CommandExecuter
 */
public class CommandExecuteException extends Exception {

	//==========================================================
	//メソッド

	//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
	//コンストラクタ

	/**
	 * 指定された詳細メッセージを持つ Exception を構築します。<br>
	 *
	 * @param strArg 詳細メッセージ
	 */
	public CommandExecuteException(String strArg) {
		//基底クラスの引数付きコンストラクタをそのまま呼び出す
		super(strArg);
	}

	/**
	 * 指定された詳細メッセージと子例外を持つ Exception を構築します。<br>
	 *
	 * @param strArg 詳細メッセージ
	 * @param childExceptionArg 子例外
	 */
	public CommandExecuteException(String strArg, Throwable childExceptionArg) {
		//基底クラスの引数付きコンストラクタの呼び出し
		super(strArg, childExceptionArg);
	}
}

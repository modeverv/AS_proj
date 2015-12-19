package jp.fores.common.exception;



/**
 * DBの整合性チェックにひっかかった場合に投げられる例外。<br>
 */
public class DBException extends Exception {

	//==========================================================
	//フィールド

	//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
	//インスタンス変数

	/**
	 * メッセージID
	 */
	private final String messageID;

	
	//==========================================================
	//メソッド

	//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
	//コンストラクタ

	/**
	 * 指定されたメッセージIDを持つ Exception を構築します。<br>
	 *
	 * @param messageIDArg メッセージID
	 */
	public DBException(String messageIDArg) {
		//基底クラスのコンストラクタの呼び出し
		super();

		//==========================================================
		//引数をフィールドに設定

		//メッセージID
		this.messageID = messageIDArg;
	}

	/**
	 * 指定されたメッセージIDと子例外を持つ Exception を構築します。<br>
	 *
	 * @param messageIDArg メッセージID
	 * @param childExceptionArg 子例外
	 */
	public DBException(String messageIDArg, Throwable childExceptionArg) {
		//基底クラスの引数付きコンストラクタの呼び出し
		super(childExceptionArg);

		//==========================================================
		//引数をフィールドに設定

		//メッセージID
		this.messageID = messageIDArg;
	}

	
	//==============================================================
	//通常のメソッド

	/**
	 * メッセージIDを返します。<br>
	 *
	 * @return メッセージID
	 */
	public String getMessageID() {
		//フィールドのメッセージIDの値をそのまま返す
		return this.messageID;
	}
}

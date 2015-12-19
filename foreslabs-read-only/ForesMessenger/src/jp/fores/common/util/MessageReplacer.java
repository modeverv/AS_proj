package jp.fores.common.util;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;


/**
 * メッセージ置換クラス。<br>
 * <br>
 * 置換要素をあらかじめ設定したメッセージに、動的に値を埋め込みます。<br>
 * データベースやプロパティファイルにメッセージを定義しておいて、出力直前に実際の値を埋め込むといった使い方を想定しています。<br>
 */
public final class MessageReplacer {

	//==========================================================
	//定数

	/**
	 * ログ出力用
	 */
	private static final Log log = LogFactory.getLog(MessageReplacer.class);


	//==========================================================
	//メソッド

	//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
	//コンストラクタ

	/**
	 * コンストラクタです。<br>
	 * (クラスメソッドのみのユーティリティークラスなので、privateにしてインスタンスを作成できないようにしています。)<br>
	 */
	private MessageReplacer() {
		//基底クラスのコンストラクタの呼び出し
		super();
	}


	//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
	//クラスメソッド

	/**
	 * メッセージの置換対象の部分を、文字列配列の内容に置き換えます。<br>
	 * メッセージに埋め込む置換対象の部分は、例えば「@」が置換対象の文字列の場合「@1」「@2」のように連番で指定して下さい。<br>
	 * 連番が２桁になるとおかしくなるので、置換対象の最大数は9です。<br>
	 * <br>
	 * <strong>(例)</strong><br>
	 * <code>replaceMessage("@1は@2です。", new String[] {"foo", "bar"}, "@") → "fooはbarです。" </code><br>
	 * <code>replaceMessage("%1は%2です。また、%1は%3です。", new String[] {"foo", "bar", "hoge"}, "%") → "fooはbarです。また、fooはhogeです。" </code><br>
	 *
	 * @param messageArg メッセージ
	 * @param replaceMessageArrayArg 置換する文字列配列
	 * @param replaceMessageTargetArg 置換対象の文字列
	 * @return 変換後のメッセージ
	 * @exception IllegalArgumentException メッセージがnullの場合、置換する文字列配列がnullの場合、置換する文字列配列の要素数が1～9の間でない場合、置換対象の文字列がnullまたは空文字列の場合
	 */
	public static String replaceMessage(String messageArg,
			String[] replaceMessageArrayArg, String replaceMessageTargetArg)
			throws IllegalArgumentException {
		//==========================================================
		//引数のチェック

		//メッセージがnullの場合
		if (messageArg == null) {
			//例外を投げる
			throw new IllegalArgumentException("メッセージにnullを指定することはできません");
		}

		//置換する文字列配列がnullの場合
		if (replaceMessageArrayArg == null) {
			//例外を投げる
			throw new IllegalArgumentException("置換する文字列配列にnullを指定することはできません");
		}

		//置換する文字列配列の要素数が1～9の間でない場合
		if (!((replaceMessageArrayArg.length >= 1) && (replaceMessageArrayArg.length <= 9))) {
			//例外を投げる
			throw new IllegalArgumentException("置換する文字列配列には、要素数が1～9のものしか指定できません");
		}

		//置換対象の文字列がnullまたは空文字列の場合
		if (StringUtil.isBlank(replaceMessageTargetArg)) {
			//例外を投げる
			throw new IllegalArgumentException("置換対象の文字列にnullまたは空文字列を指定することはできません");
		}


		//==========================================================
		//置換実行

		//結果を入れる変数
		String result = messageArg;

		//置換する文字列配列の要素数に応じてループをまわす
		for (int i = 0; i < replaceMessageArrayArg.length; i++) {
			//メッセージの「置換する文字 + インデックス」という部分を、配列の現在の要素で置換する
			result = StringUtil.replace(result, replaceMessageTargetArg
					+ Integer.toString(i + 1), replaceMessageArrayArg[i]);
		}

		//結果を返す
		return result;
	}

	/**
	 * メッセージの置換対象の部分を、文字列配列の内容に置き換えます。<br>
	 * 置換する文字には「@」を使用します。<br>
	 * メッセージに埋め込む置換対象の部分は、「@1」「@2」のように連番で指定して下さい。<br>
	 * 連番が２桁になるとおかしくなるので、置換対象の最大数は9です。<br>
	 * <br>
	 * <strong>(例)</strong><br>
	 * <code>replaceMessage("@1は@2です。", new String[] {"foo", "bar"}) → "fooはbarです。" </code><br>
	 * <code>replaceMessage("@1は@2です。また、@1は@3です。", new String[] {"foo", "bar", "hoge"}) → "fooはbarです。また、fooはhogeです。" </code><br>
	 *
	 * @param messageArg メッセージ
	 * @param replaceMessageArrayArg 置換する文字列配列
	 * @return 変換後のメッセージ
	 * @exception IllegalArgumentException メッセージがnullの場合、置換する文字列配列がnullの場合、置換する文字列配列の要素数が1～9の間でない場合
	 */
	public static String replaceMessage(String messageArg,
			String[] replaceMessageArrayArg) throws IllegalArgumentException {
		//置換する文字に「@」を指定して実際に処理を行うメソッドを呼び出す
		return replaceMessage(messageArg, replaceMessageArrayArg, "@");
	}

	/**
	 * メッセージの置換対象の部分を、指定した文字列の内容に置き換えます。<br>
	 * このメソッドは、置換する部分が1つしかない場合に使用します。<br>
	 * 置換する部分には、例えば「@」が置換対象の文字列の場合「@1」と指定して下さい。<br>
	 * <br>
	 * <strong>(例)</strong><br>
	 * <code>replaceMessage("@1です。", "foo", "@") → "fooです。" </code><br>
	 * <code>replaceMessage("%1です。", "foo", "%") → "fooです。" </code><br>
	 *
	 * @param messageArg メッセージ
	 * @param replaceMessageStringArg 置換する文字列
	 * @param replaceMessageTargetArg 置換対象の文字列
	 * @return 変換後のメッセージ
	 * @exception IllegalArgumentException メッセージがnullの場合、置換する文字列がnullの場合、置換対象の文字列がnullまたは空文字列の場合
	 */
	public static String replaceMessage(String messageArg,
			String replaceMessageStringArg, String replaceMessageTargetArg)
			throws IllegalArgumentException {
		//==========================================================
		//引数のチェック

		//置換する文字列がnullの場合
		if (replaceMessageStringArg == null) {
			//例外を投げる
			throw new IllegalArgumentException("置換する文字列にnullを指定することはできません");
		}


		//==========================================================
		//置換実行

		//置換する文字列配列に置換する文字列のみを設定した配列を指定して、実際に処理を行うメソッドを呼び出す
		return replaceMessage(messageArg,
				new String[] { replaceMessageStringArg },
				replaceMessageTargetArg);
	}

	/**
	 * メッセージの置換対象の部分を、指定した文字列の内容に置き換えます。<br>
	 * 置換する文字には「@」を使用します。<br>
	 * このメソッドは、置換する部分が1つしかない場合に使用します。<br>
	 * 置換する部分には「@1」と指定して下さい。<br>
	 * <br>
	 * <strong>(例)</strong><br>
	 * <code>replaceMessage("@1です。", "foo") → "fooです。" </code><br>
	 *
	 * @param messageArg メッセージ
	 * @param replaceMessageStringArg 置換する文字列
	 * @return 変換後のメッセージ
	 * @exception IllegalArgumentException メッセージがnullの場合、置換する文字列がnullの場合
	 */
	public static String replaceMessage(String messageArg,
			String replaceMessageStringArg) throws IllegalArgumentException {
		//置換する文字に「@」を指定して実際に処理を行うメソッドを呼び出す
		return replaceMessage(messageArg, replaceMessageStringArg, "@");
	}

}

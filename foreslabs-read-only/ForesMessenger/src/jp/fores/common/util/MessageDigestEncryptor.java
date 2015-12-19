package jp.fores.common.util;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;


/**
 * メッセージダイジェストを使用して文字列の暗号化を行うユーティリティクラス。<br>
 * <i>(FacadeパターンのFacade役)</i><br>
 * <br>
 * java.security.MessageDigestを使って、文字列の暗号化及び認証を行います。<br>
 * メッセージダイジェストの特性として、暗号化された文字列から元の文字列を取得することはできません。<br>
 * 標準で使用できるダイジェストアルゴリズムは「MD5」と「SHA」で、そのうちの「SHA」をデフォルトとして使用します。<br>
 * メッセージダイジェスト、「MD5」、「SHA」等の詳細については、専門の文献を参照して下さい。<br>
 * <br>
 * ダイジェストのバイト配列から文字列への変換にはBase64形式を使用します。<br>
 * 
 * @see Base64Util
 */
public final class MessageDigestEncryptor {

	//==========================================================
	//定数

	/**
	 * ログ出力用
	 */
	private static final Log log = LogFactory.getLog(MessageDigestEncryptor.class);

	/**
	 * ダイジェストアルゴリズム「MD5」
	 */
	public static final String MD5 = "MD5";

	/**
	 * ダイジェストアルゴリズム「SHA」
	 */
	public static final String SHA = "SHA";

	/**
	 * デフォルトのダイジェストアルゴリズム(「SHA」)
	 */
	public static final String DEFAULT_ALGORITHM = SHA;


	//==========================================================
	//メソッド

	//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
	//コンストラクタ

	/**
	 * コンストラクタです。<br>
	 * (クラスメソッドのみのユーティリティークラスなので、privateにしてインスタンスを作成できないようにしています。)<br>
	 */
	private MessageDigestEncryptor() {
		//基底クラスのコンストラクタの呼び出し
		super();
	}


	//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
	//クラスメソッド

	/**
	 * デフォルトのダイジェストアルゴリズムを使って暗号化を行います。<br>
	 * ダイジェストのバイト配列から文字列への変換には、Base64を使用します。<br>
	 * 暗号化された文字列の長さは28文字になります。<br>
	 *
	 * @param keyArg 暗号化する文字列
	 * @return 暗号化された文字列
	 * @exception NoSuchAlgorithmException デフォルトのアルゴリズムが呼び出し側の環境で使用可能でない場合
	 */
	public static String encode(String keyArg) throws NoSuchAlgorithmException {
		//デフォルトのダイジェストアルゴリズムを指定して、実際に処理を行うメソッドを呼び出して、結果をそのまま返す
		return encode(keyArg, DEFAULT_ALGORITHM);
	}

	/**
	 * 指定されたメッセージダイジェストを使ってハッシュ化を行います。<br>
	 * ダイジェストのバイト配列から文字列への変換には、Base64を使用します。<br>
	 * 暗号化された文字列の長さはアルゴリズムによって決まっています。<br>
	 * MD5の場合は24文字、SHAの場合は28文字になります。<br>
	 *
	 * @param keyArg 暗号化する文字列
	 * @param algorithmArg ダイジェストアルゴリズム
	 * @return 暗号化された文字列
	 * @exception NoSuchAlgorithmException 指定されたアルゴリズムが呼び出し側の環境で使用可能でない場合
	 */
	public static String encode(String keyArg, String algorithmArg)
			throws NoSuchAlgorithmException {
		//指定されたダイジェストアルゴリズムでメッセージダイジェストを生成する
		MessageDigest messageDigest = MessageDigest.getInstance(algorithmArg);

		//生成したメッセージダイジェストを指定して、実際に処理を行うメソッドを呼び出して、結果をそのまま返す
		return encode(keyArg, messageDigest);
	}

	/**
	 * 指定されたメッセージダイジェストを使ってハッシュ化を行います。<br>
	 * ダイジェストのバイト配列から文字列への変換には、Base64を使用します。<br>
	 * 暗号化された文字列の長さはアルゴリズムによって決まっています。<br>
	 * MD5の場合は24文字、SHAの場合は28文字になります。<br>
	 *
	 * @param keyArg 暗号化する文字列
	 * @param messageDigestArg メッセージダイジェスト
	 * @return 暗号化された文字列
	 */
	public static String encode(String keyArg, MessageDigest messageDigestArg) {
		//再利用のためにダイジェストをリセット
		messageDigestArg.reset();

		//指定されたメッセージダイジェストを使って暗号化を行う
		byte[] encData = messageDigestArg.digest(keyArg.getBytes());

		//バイト配列をBase64にエンコードして返す
		return Base64Util.encodeBase64(encData);
	}


	/**
	 * デフォルトのダイジェストアルゴリズムを使って、
	 * 暗号化されていない文字列と暗号化されている文字列が一致するか認証します。<br>
	 * 単純に比較対象の暗号化されていない文字列を暗号化した結果が、比較対象の暗号化されている文字列と一致するか調べます。<br>
	 *
	 * @param normalStrArg 比較対象の暗号化されていない文字列
	 * @param encodeStrArg 比較対象の暗号化されている文字列
	 * @return true=一致する, false=一致しない
	 * @exception NoSuchAlgorithmException デフォルトのアルゴリズムが呼び出し側の環境で使用可能でない場合
	 */
	public static boolean certify(String normalStrArg, String encodeStrArg)
			throws NoSuchAlgorithmException {
		//デフォルトのダイジェストアルゴリズムを指定して、実際に処理を行うメソッドを呼び出して、結果をそのまま返す
		return certify(normalStrArg, encodeStrArg, DEFAULT_ALGORITHM);
	}

	/**
	 * 指定されたダイジェストアルゴリズムを使って、
	 * 暗号化されていない文字列と暗号化されている文字列が一致するか認証します。<br>
	 * 単純に比較対象の暗号化されていない文字列を暗号化した結果が、比較対象の暗号化されている文字列と一致するか調べます。<br>
	 *
	 * @param normalStrArg 比較対象の暗号化されていない文字列
	 * @param encodeStrArg 比較対象の暗号化されている文字列
	 * @param algorithmArg ダイジェストアルゴリズム
	 * @return true=一致する, false=一致しない
	 * @exception NoSuchAlgorithmException 指定されたアルゴリズムが呼び出し側の環境で使用可能でない場合
	 */
	public static boolean certify(String normalStrArg, String encodeStrArg,
			String algorithmArg) throws NoSuchAlgorithmException {
		//指定されたダイジェストアルゴリズムでメッセージダイジェストを生成する
		MessageDigest messageDigest = MessageDigest.getInstance(algorithmArg);

		//生成したメッセージダイジェストを指定して、実際に処理を行うメソッドを呼び出して、結果をそのまま返す
		return certify(normalStrArg, encodeStrArg, messageDigest);
	}

	/**
	 * 指定されたメッセージダイジェストを使って、
	 * 暗号化されていない文字列と暗号化されている文字列が一致するか認証します。<br>
	 * 単純に比較対象の暗号化されていない文字列を暗号化した結果が、比較対象の暗号化されている文字列と一致するか調べます。<br>
	 *
	 * @param normalStrArg 比較対象の暗号化されていない文字列
	 * @param encodeStrArg 比較対象の暗号化されている文字列
	 * @param messageDigestArg メッセージダイジェスト
	 * @return true=一致する, false=一致しない
	 */
	public static boolean certify(String normalStrArg, String encodeStrArg,
			MessageDigest messageDigestArg) {
		//比較対象の暗号化されていない文字列を暗号化した結果が、比較対象の暗号化されている文字列と一致するか調べて、結果をそのまま返す
		return encodeStrArg.equals(encode(normalStrArg, messageDigestArg));
	}

}

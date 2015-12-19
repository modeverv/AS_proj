package jp.fores.common.util;

import javax.crypto.Cipher;
import javax.crypto.spec.SecretKeySpec;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import jp.fores.common.exception.EncryptionException;


/**
 * 共通鍵暗号方式を使用して文字列の暗号化を行うユーティリティクラス。<br>
 * <i>(FacadeパターンのFacade役)</i><br>
 * <br>
 * 共通鍵暗号方式を使って、文字列の暗号化及び復号化を行います。<br>
 * 標準で使用できる暗号化アルゴリズムは「AES」, 「DES」, 「DESede」(トリプルDES), 
 * 「Blowfish」の4種類で、そのうちの「AES」をデフォルトとして使用します。<br>
 * 共通鍵暗号方式、各暗号化アルゴリズムの詳細については、専門の文献を参照して下さい。<br>
 * 暗号化した結果のバイト配列から文字列への変換にはBase64形式を使用します。<br>
 * <br>
 * <strong>(注)</strong>
 * 指定できる秘密鍵の長さはそれぞれの暗号化アルゴリズムに応じて決められていますが、
 * このクラスでは指定された鍵の長さが規定の長さと一致しない場合も、
 * 内部で自動的に補正してエラーが発生しないようにしています。<br>
 * ただし、その副作用として規定以上の長さを持つ秘密鍵が指定された場合は、
 * それ以降の情報は無効となりますので注意して下さい。<br>
 * 
 * @see Base64Util
 */
public class SecretKeyEncryptor {

	//==========================================================
	//定数

	/**
	 * ログ出力用
	 */
	private static final Log log = LogFactory.getLog(SecretKeyEncryptor.class);

	/**
	 * 暗号化アルゴリズム「AES」<br>
	 * (鍵長:16バイト固定)
	 */
	public static final String AES = "AES";

	/**
	 * 暗号化アルゴリズム「DES」<br>
	 * (鍵長:8バイト固定)
	 */
	public static final String DES = "DES";

	/**
	 * 暗号化アルゴリズム「DESede」(トリプルDES)<br>
	 * (鍵長:24バイト固定)
	 */
	public static final String DESede = "DESede";

	/**
	 * 暗号化アルゴリズム「Blowfish」<br>
	 * (鍵長:1～16バイト)
	 */
	public static final String Blowfish = "Blowfish";

	/**
	 * デフォルトの暗号化アルゴリズム(「AES」)
	 */
	public static final String DEFAULT_ALGORITHM = AES;


	//==========================================================
	//メソッド

	//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
	//コンストラクタ

	/**
	 * コンストラクタです。<br>
	 * (クラスメソッドのみのユーティリティークラスなので、privateにしてインスタンスを作成できないようにしています。)<br>
	 */
	private SecretKeyEncryptor() {
		//基底クラスのコンストラクタの呼び出し
		super();
	}


	//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
	//クラスメソッド

	/**
	 * デフォルトの暗号化アルゴリズムを使用して、文字列の暗号化を行います。<br>
	 *
	 * @param keyArg 暗号化に使用する秘密鍵
	 * @param targetStrArg 暗号化する文字列
	 * @return 暗号化した結果の文字列
	 * @throws EncryptionException 暗号化に失敗した場合
	 */
	public static String encrypt(String keyArg, String targetStrArg)
			throws EncryptionException {

		//暗号化アルゴリズムの種類にデフォルトの値を指定して、
		//実際に処理を行うメソッドを呼び出し、結果をそのまま返す
		return encrypt(keyArg, targetStrArg, DEFAULT_ALGORITHM);
	}

	/**
	 * 指定された暗号化アルゴリズムを使用して、文字列の暗号化を行います。<br>
	 *
	 * @param keyArg 暗号化に使用する秘密鍵
	 * @param targetStrArg 暗号化する文字列
	 * @param algorithmArg 暗号化アルゴリズムの種類
	 * @return 暗号化した結果の文字列
	 * @throws EncryptionException 暗号化に失敗した場合
	 */
	public static String encrypt(String keyArg, String targetStrArg,
			String algorithmArg) throws EncryptionException {

		//鍵の文字列をバイト配列に変換して、実際に処理を行うメソッドを呼び出す
		byte[] result = encrypt(keyArg.getBytes(), targetStrArg, algorithmArg);

		//結果のバイト配列をBase64にエンコードして返す
		return Base64Util.encodeBase64(result);
	}

	/**
	 * デフォルトの暗号化アルゴリズムを使用して、文字列の暗号化を行います。<br>
	 *
	 * @param keyArg 暗号化に使用する秘密鍵のバイト配列
	 * @param targetStrArg 暗号化する文字列
	 * @return 暗号化した結果のバイト配列
	 * @throws EncryptionException 暗号化に失敗した場合
	 */
	public static byte[] encrypt(byte[] keyArg, String targetStrArg)
			throws EncryptionException {

		//暗号化アルゴリズムの種類にデフォルトの値を指定して、
		//実際に処理を行うメソッドを呼び出し、結果をそのまま返す
		return encrypt(keyArg, targetStrArg, DEFAULT_ALGORITHM);
	}

	/**
	 * 指定された暗号化アルゴリズムを使用して、文字列の暗号化を行います。<br>
	 *
	 * @param keyArg 暗号化に使用する秘密鍵のバイト配列
	 * @param targetStrArg 暗号化する文字列
	 * @param algorithmArg 暗号化アルゴリズムの種類
	 * @return 暗号化した結果のバイト配列
	 * @throws EncryptionException 暗号化に失敗した場合
	 */
	public static byte[] encrypt(byte[] keyArg, String targetStrArg,
			String algorithmArg) throws EncryptionException {
		try {
			//暗号化アルゴリズムの種類に応じて、鍵のバイト配列の長さを補正する
			byte[] correctKey = correctKeyLength(keyArg, algorithmArg);

			//暗号化アルゴリズムの種類に応じた秘密鍵を構築
			SecretKeySpec skSpec = new SecretKeySpec(correctKey, algorithmArg);

			//暗号化アルゴリズムの種類に応じた暗号化クラスのインスタンスを取得
			Cipher cipher = Cipher.getInstance(algorithmArg);

			//先ほど構築した秘密鍵を元にして、暗号化モードで初期化
			cipher.init(Cipher.ENCRYPT_MODE, skSpec);

			//暗号化を実行して、結果を返す
			return cipher.doFinal(targetStrArg.getBytes());
		}
		//==============================================================
		//例外処理
		catch (Exception e) {
			//細かい例外の種類まで気にしても仕方がないので、
			//発生した例外を暗号化失敗用の例外に詰め直して投げる
			throw new EncryptionException("復号化に失敗しました", e);
		}
	}

	/**
	 * デフォルトの暗号化アルゴリズムを使用して、暗号化された文字列の復号化を行います。<br>
	 * 秘密鍵には、必ず暗号化する際に使用したもの同じ値を指定するようにして下さい。<br>
	 *
	 * @param keyArg 暗号化する際に使用した秘密鍵
	 * @param encryptedStrArg 暗号化された文字列(Base64形式)
	 * @return 復号化した結果の文字列
	 * @throws EncryptionException 復号化に失敗した場合
	 */
	public static String decrypt(String keyArg, String encryptedStrArg)
			throws EncryptionException {

		//暗号化アルゴリズムの種類にデフォルトの値を指定して、
		//実際に処理を行うメソッドを呼び出し、結果をそのまま返す
		return decrypt(keyArg, encryptedStrArg, DEFAULT_ALGORITHM);
	}

	/**
	 * 指定された暗号化アルゴリズムを使用して、暗号化された文字列の復号化を行います。<br>
	 * 秘密鍵と暗号化アルゴリズムには、必ず暗号化する際に使用したもの同じ値を指定するようにして下さい。<br>
	 *
	 * @param keyArg 暗号化する際に使用した秘密鍵
	 * @param encryptedStrArg 暗号化された文字列(Base64形式)
	 * @param algorithmArg 暗号化アルゴリズムの種類
	 * @return 復号化した結果の文字列
	 * @throws EncryptionException 復号化に失敗した場合
	 */
	public static String decrypt(String keyArg, String encryptedStrArg,
			String algorithmArg) throws EncryptionException {

		//鍵の文字列をバイト配列に変換し、さらに復号化する文字列をBase64デコードして
		//実際に処理を行うメソッドを呼び出す
		byte[] result = decrypt(keyArg.getBytes(),
				Base64Util.decodeBase64(encryptedStrArg),
				algorithmArg);

		//結果のバイト配列を文字列に変換して返す
		return new String(result);
	}

	/**
	 * デフォルトの暗号化アルゴリズムを使用して、暗号化された文字列の復号化を行います。<br>
	 * 秘密鍵には、必ず暗号化する際に使用したもの同じ値を指定するようにして下さい。<br>
	 *
	 * @param keyArg 暗号化する際に使用した秘密鍵のバイト配列
	 * @param encryptedArg 暗号化されたバイト配列
	 * @return 復号化した結果のバイト配列
	 * @throws EncryptionException 復号化に失敗した場合
	 */
	public static byte[] decrypt(byte[] keyArg, byte[] encryptedArg)
			throws EncryptionException {

		//暗号化アルゴリズムの種類にデフォルトの値を指定して、
		//実際に処理を行うメソッドを呼び出し、結果をそのまま返す
		return decrypt(keyArg, encryptedArg, DEFAULT_ALGORITHM);
	}

	/**
	 * 指定された暗号化アルゴリズムを使用して、暗号化された文字列の復号化を行います。<br>
	 * 秘密鍵と暗号化アルゴリズムには、必ず暗号化する際に使用したもの同じ値を指定するようにして下さい。<br>
	 *
	 * @param keyArg 暗号化する際に使用した秘密鍵のバイト配列
	 * @param encryptedArg 暗号化されたバイト配列
	 * @param algorithmArg 暗号化アルゴリズムの種類
	 * @return 復号化した結果のバイト配列
	 * @throws EncryptionException 復号化に失敗した場合
	 */
	public static byte[] decrypt(byte[] keyArg, byte[] encryptedArg,
			String algorithmArg) throws EncryptionException {

		try {
			//暗号化アルゴリズムの種類に応じて、鍵のバイト配列の長さを補正する
			byte[] correctKey = correctKeyLength(keyArg, algorithmArg);

			//暗号化アルゴリズムの種類に応じた秘密鍵を構築
			SecretKeySpec skSpec = new SecretKeySpec(correctKey, algorithmArg);

			//暗号化アルゴリズムの種類に応じた暗号化クラスのインスタンスを取得
			Cipher cipher = Cipher.getInstance(algorithmArg);

			//先ほど構築した秘密鍵を元にして、復号化モードで初期化
			cipher.init(Cipher.DECRYPT_MODE, skSpec);

			//復号化を実行して、結果を返す
			return cipher.doFinal(encryptedArg);
		}
		//==============================================================
		//例外処理
		catch (Exception e) {
			//細かい例外の種類まで気にしても仕方がないので、
			//発生した例外を暗号化失敗用の例外に詰め直して投げる
			throw new EncryptionException("復号化に失敗しました", e);
		}
	}


	//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
	//内部処理用

	/**
	 * 暗号化アルゴリズムの種類に応じて、鍵のバイト配列の長さを補正して返します。<br>
	 * 
	 * @param keyArg 鍵のバイト配列
	 * @param algorithmArg 暗号化アルゴリズム
	 * @return 補正されたバイト配列
	 */
	private static byte[] correctKeyLength(byte[] keyArg, String algorithmArg) {

		//アルゴリズムが「AES」の場合
		if (AES.equalsIgnoreCase(algorithmArg)) {
			//鍵のバイト配列の長さを16バイト固定になるように補正して返す
			return fixByteArrayLength(keyArg, 16);
		}
		//アルゴリズムが「DES」の場合
		else if (DES.equalsIgnoreCase(algorithmArg)) {
			//鍵のバイト配列の長さを8バイト固定になるように補正して返す
			return fixByteArrayLength(keyArg, 8);
		}
		//アルゴリズムが「DESede」の場合
		else if (DESede.equalsIgnoreCase(algorithmArg)) {
			//鍵のバイト配列の長さを24バイト固定になるように補正して返す
			return fixByteArrayLength(keyArg, 24);
		}
		//アルゴリズムが「Blowfish」の場合
		else if (Blowfish.equalsIgnoreCase(algorithmArg)) {
			//鍵のバイト配列の長さが1から16バイトの場合
			//(Blowfishのみ鍵は固定長ではなく、1から16バイトの可変長を許容する)
			if ((keyArg.length >= 1) && (keyArg.length <= 16)) {
				//補正する必要がないので、引数の鍵のバイト配列をそのまま返す
				return keyArg;
			}
			//それ以外の場合
			else {
				//鍵のバイト配列の長さを16バイト固定になるように補正して返す
				return fixByteArrayLength(keyArg, 16);
			}
		}
		//それ以外の場合
		else {
			//補正しようがないので、とりあえず引数の鍵のバイト配列をそのまま返す
			return keyArg;
		}
	}

	/**
	 * バイト配列の長さを固定長に補正して返します。<br>
	 * (内部処理用のメソッドですが、他のクラスからも使用できるようにあえてpublicにしています。)<br>
	 * 
	 * @param byteArrayArg バイト配列
	 * @param lengthArg 長さ
	 * @return 補正されたバイト配列
	 */
	public static byte[] fixByteArrayLength(byte[] byteArrayArg, int lengthArg) {

		//引数のバイト配列の長さを取得
		int arrayLength = byteArrayArg.length;


		//バイト配列の長さが指定された長さと一致する場合
		if (arrayLength == lengthArg) {
			//引数のバイト配列をそのまま返す
			return byteArrayArg;
		}
		//バイト配列の長さが指定された長さより大きい場合
		else if (arrayLength > lengthArg) {
			//指定された長さのバイト配列を生成
			byte[] work = new byte[lengthArg];

			//指定された長さの分だけ引数のバイト配列からコピーする
			System.arraycopy(byteArrayArg, 0, work, 0, lengthArg);

			//作成した配列を返す
			return work;
		}
		//バイト配列の長さが指定された長さより小さい場合
		else {
			//指定された長さのバイト配列を生成
			byte[] work = new byte[lengthArg];

			//引数のバイト配列の長さの分だけコピーする
			System.arraycopy(byteArrayArg, 0, work, 0, arrayLength);

			//作成した配列を返す
			return work;
		}
	}
}

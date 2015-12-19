package jp.fores.common.util;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.io.OutputStream;

import javax.mail.internet.MimeUtility;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;


/**
 * Base64のエンコード・デコードを行うユーティリティクラス。<br>
 * <i>(FacadeパターンのFacade役)</i><br>
 * <br>
 * <code>javax.mail.internet.MimeUtility</code>を使って、
 * 文字列やバイト配列をBase64にエンコード・デコードします。<br>
 */
public final class Base64Util {

	//==========================================================
	//定数

	/**
	 * ログ出力用
	 */
	private static final Log log = LogFactory.getLog(Base64Util.class);


	//==========================================================
	//メソッド

	//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
	//コンストラクタ

	/**
	 * コンストラクタです。<br>
	 * (クラスメソッドのみのユーティリティークラスなので、privateにしてインスタンスを作成できないようにしています。)<br>
	 */
	private Base64Util() {
		//基底クラスのコンストラクタの呼び出し
		super();
	}


	//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
	//クラスメソッド

	/**
	 * 文字列をBase64にエンコードします。<br>
	 * 
	 * @param strArg エンコード対象の文字列
	 * @return Base64にエンコードした結果の文字列
	 */
	public static String encodeBase64(String strArg) {

		//文字列をバイト配列に変換して、実際に処理を行うメソッドを呼び出し、結果をそのまま返す
		return encodeBase64(strArg.getBytes());
	}

	/**
	 * バイト配列をBase64にエンコードします。<br>
	 * 
	 * @param byteArrayArg エンコード対象のバイト配列
	 * @return Base64にエンコードした結果の文字列
	 */
	public static String encodeBase64(byte[] byteArrayArg) {

		try {
			//バイト配列出力ストリームを生成
			ByteArrayOutputStream bao = new ByteArrayOutputStream();

			//先ほど生成したバイト配列出力ストリームにBase64のエンコーダをラップ
			OutputStream out = MimeUtility.encode(bao, "base64");

			//引数のバイト配列をエンコード用の出力ストリームに書き込む
			out.write(byteArrayArg);

			//出力ストリームを閉じる
			out.close();

			//結果をiso-8859-1(ASCII文字)に変換して返す
			return bao.toString("iso-8859-1");
		}
		//==============================================================
		//例外処理
		catch (Exception e) {
			//内部エラーなので通常は発生しないが、一応発生した例外をRuntimeExceptionに詰め直して投げる
			throw new RuntimeException("Base64のエンコードに失敗しました", e);
		}
	}

	/**
	 * Base64文字列をデコードします。<br>
	 * 
	 * @param strArg デコード対象のBase64文字列
	 * @return デコードした結果のバイト配列
	 */
	public static byte[] decodeBase64(String strArg) {

		//文字列をバイト配列に変換して、実際に処理を行うメソッドを呼び出し、結果をそのまま返す
		return decodeBase64(strArg.getBytes());
	}

	/**
	 * Base64バイト配列をデコードします。<br>
	 * 
	 * @param byteArrayArg デコード対象のBase64バイト配列
	 * @return デコードした結果のバイト配列
	 */
	public static byte[] decodeBase64(byte[] byteArrayArg) {

		try {
			//バイト配列入力ストリームにBase64のデコーダをラップ
			InputStream in = MimeUtility.decode(new ByteArrayInputStream(byteArrayArg),
					"base64");

			//データ読み込みバッファ用のバイト配列を生成
			byte[] buf = new byte[1024];

			//バイト配列出力ストリームを生成
			ByteArrayOutputStream out = new ByteArrayOutputStream();

			//読み込んだバイト数
			int len;

			//Base64デコード用の入力ストリームを読み終わるまでループをまわし、
			//出力ストリームに内容を全て書き込む
			while ((len = in.read(buf)) != -1) {
				out.write(buf, 0, len);
			}

			//入力ストリームを閉じる
			in.close();

			//出力ストリームを閉じる
			out.close();

			//結果のバイト配列を返す
			return out.toByteArray();
		}
		//==============================================================
		//例外処理
		catch (Exception e) {
			//内部エラーなので通常は発生しないが、一応発生した例外をRuntimeExceptionに詰め直して投げる
			throw new RuntimeException("Base64のデコードに失敗しました", e);
		}
	}
}
package jp.fores.common.util;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;


/**
 * ファイル操作用ユーティリティクラス。<br>
 * <br>
 * ファイルのコピーやダウンロードなどの機能を提供します。<br>
 * <br>
 * <strong>＜download()メソッドを使うときの注意＞</strong><br>
 * donwload()メソッドを使ってファイルをダウンロードする際、Internet Explorerではダウンロードされたファイルの処理を選択するダイアログが２回開かれてしまうことがあります。<br>
 * この現象は、ダイアログで「開く」を選択した場合に発生します。(バージョンによって文言は多少異なります。)<br>
 * 「保存」を選択した場合は発生しません。<br>
 * なお、Netscapeでは「開く」を選択しても、この現象は発生しません。<br>
 * <br>
 * この現象が発生する原因は、FileUtil, CSVUtilのdownload()メソッドのデフォルトの動作では、ファイルをダウンロードする際、ヘッダの「Content-Disposition」という項目に「attachment」を指定しているためです。<br>
 * もう１つの方式である「inline」を指定した場合は発生しないことは、確認済みです。<br>
 * <br>
 * では、何故わざわざ不都合が発生する方式をデフォルトにしているかというと理由があります。<br>
 * それは、「inline」を指定している場合は、ContentTypeによってはブラウザのプラグインが作動する可能性があるからです。<br>
 * 例えば、CSVファイルをダウンロードすると、ブラウザ上でExcelが勝手に起動してしまうといった現象が発生する恐れがあります。(クライアントマシンの環境に依存します。)<br>
 * このとき、ブラウザやOS自体がフリーズする可能性があります。<br>
 * このような致命的な現象に比べると、「開く」を選択するとダイアログが２回開かれるという現象は、機能的には別に支障がないので影響度ははるかに小さいと考えて、
 * こちらをデフォルトにしています。<br>
 * <br>
 * Content-Dispositionのタイプによって発生する可能性がある現象をまとめると、以下の表のようになります。<br>
 * ファイルダウンロード機能を使用する場合は、このような現象が発生するということをあらかじめ理解して、状況に応じて適切な方式を選択して下さい。<br>
 * <table border="1">
 *  <tr bgcolor="deepskyblue">
 *      <td align="center"><strong>Content-Dispositionのタイプ</strong></td>
 *      <td align="center"><strong>IEでダイアログが２回開かれる</strong></td>
 *      <td align="center"><strong>ブラウザのプラグインが作動する</strong></td>
 *  </tr>
 *      <td>attachment</td>
 *      <td align="center">○</td>
 *      <td align="center">×</td>
 *  <tr>
 *      <td>inline</td>
 *      <td align="center">×</td>
 *      <td align="center">○</td>
 *  </tr>
 * </table>
 * <br>
 *
 * @see StringUtil
 */
public final class FileUtil {

	//==========================================================
	//定数

	/**
	 * ログ出力用
	 */
	private static final Log log = LogFactory.getLog(FileUtil.class);

	/**
	 * 確実にダウンロードするためのダミーのContentType(「application/dummy-type」)
	 */
	public static final String DUMMY_CONTENT_TYPE = "application/dummy-type";

	/**
	 * 1Kバイトのファイルサイズ
	 */
	public static final long FILE_SIZE_K = 1024;

	/**
	 * 1Mバイトのファイルサイズ
	 */
	public static final long FILE_SIZE_M = FILE_SIZE_K * FILE_SIZE_K;

	/**
	 * 1Gバイトのファイルサイズ
	 */
	public static final long FILE_SIZE_G = FILE_SIZE_M * FILE_SIZE_K;

	/**
	 * 1Tバイトのファイルサイズ
	 */
	public static final long FILE_SIZE_T = FILE_SIZE_G * FILE_SIZE_K;

	/**
	 * 1Pバイトのファイルサイズ
	 */
	public static final long FILE_SIZE_P = FILE_SIZE_T * FILE_SIZE_K;

	/**
	 * バイトの文字列表現
	 */
	public static final String BYTE_STR = "B";


	//==========================================================
	//メソッド

	//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
	//コンストラクタ

	/**
	 * コンストラクタです。<br>
	 * <i>(クラスメソッドのみのユーティリティークラスなので、privateにしてインスタンスを作成できないようにしています。)</i><br>
	 */
	private FileUtil() {
		//基底クラスのコンストラクタの呼び出し
		super();
	}


	//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
	//クラスメソッド

	/**
	 * ファイルをコピーします。<br>
	 * ファイル名はコピー元のファイル名をそのまま使用します。<br>
	 * コピー先に同じファイルがある場合は、上書きします。<br>
	 *
	 * @param originalfileNameArg コピー元のファイル名(パスも含む)
	 * @param newDirNameArg コピー先のディレクトリ名
	 * @return 作成したコピー先のファイル
	 * @exception FileNotFoundException ファイルが見つからなかった場合
	 * @exception IOException 入出力例外
	 */
	public static File copy(String originalfileNameArg, String newDirNameArg)
			throws FileNotFoundException, IOException {
		//コピー元のファイルオブジェクトの生成
		File originalFile = new File(originalfileNameArg);

		//コピー先のファイル名にコピー元のファイル名を指定して、実際に処理を行うメソッドを呼び出し結果をそのまま返す
		return copy(originalfileNameArg, newDirNameArg, originalFile.getName());
	}

	/**
	 * ファイルをコピーします。<br>
	 * ファイル名は元のファイル名をそのまま使用します。<br>
	 * コピー先に同じファイルがある場合は、上書きします。<br>
	 *
	 * @param originalfileNameArg コピー元のファイル名(パスも含む)
	 * @param newDirNameArg コピー先のディレクトリ名
	 * @param newFileNameArg コピー先のファイル名
	 * @return 作成したコピー先のファイル
	 * @exception FileNotFoundException ファイルが見つからなかった場合
	 * @exception IOException 入出力例外
	 */
	public static File copy(String originalfileNameArg, String newDirNameArg,
			String newFileNameArg) throws FileNotFoundException, IOException {
		//==========================================================
		//ファイルオブジェクトの生成

		//コピー先のディレクトリのファイルオブジェクトを生成
		File dir = new File(newDirNameArg);

		//ディレクトリが存在しない場合
		if (!dir.exists()) {
			//親ディレクトリも含めて作成する
			dir.mkdirs();
		}

		//コピー先のファイルオブジェクトの生成(引数のファイル名使用する)
		File copyFile = new File(dir, newFileNameArg);

		//==========================================================
		//出力

		//入力ストリームにコピー元のファイルを設定
		BufferedInputStream in = new BufferedInputStream(new FileInputStream(originalfileNameArg));

		//出力ストリームにコピー先のファイルを設定
		BufferedOutputStream out = new BufferedOutputStream(new FileOutputStream(copyFile));

		//作業用変数
		int temp = -1;

		//入力ストリームを読み終えるまで
		while ((temp = in.read()) != -1) {
			//出力ストリームにバッファリングする
			out.write(temp);
		}

		//バッファリングされた出力ストリームをフラッシュ
		out.flush();

		//出力ストリームを閉じる
		out.close();

		//入力ストリームを閉じる
		in.close();

		//==========================================================
		//作成したコピー先のファイルオブジェクトを返す
		return copyFile;
	}

	/**
	 * ファイル・ディレクトリを削除します。<br>
	 * ディレクトリの場合は配下のファイル・ディレクトリも再帰的に削除します。<br>
	 *
	 * @param fileArg 削除したいファイル・ディレクトリ
	 * @return true=成功, false=失敗
	 */
	public static boolean deleteFileRecursive(File fileArg) {
		//配下のファイル・ディレクトリを取得
		String[] subFiles = fileArg.list();

		//ディレクトリの場合(ファイルの場合はnull)
		if (subFiles != null) {
			//配下のファイル・ディレクトリの要素数に応じてループをまわす
			for (int i = 0; i < subFiles.length; i++) {
				//このメソッドを再帰的に呼び出して、配下のファイル・ディレクトリを削除する
				if (!deleteFileRecursive(new File(fileArg, subFiles[i]))) {
					//配下のファイル・ディレクトリの削除に失敗した場合はfalseを返す
					return false;
				}
			}
		}

		//ファイル・ディレクトリを削除する
		boolean result = fileArg.delete();

		//結果を返す
		return result;
	}

	/**
	 * 絶対パスからファイル名だけを取得します。<br>
	 *
	 * @param absolutePathArg 絶対パス
	 * @return ファイル名
	 */
	public static String getFileNameFromAbsolutePath(String absolutePathArg) {
		//最後の「/」または「\」の位置を取得(大きい方が有効になる)
		int slash = Math.max(absolutePathArg.lastIndexOf('/'), absolutePathArg.lastIndexOf('\\'));

		//「/」または「\」が存在する場合
		if (slash != -1) {
			//最後の「/」または「\」以降の真のファイル名を取得する
			return absolutePathArg.substring(slash + 1);
		} else {
			//引数の絶対パスをそのまま返す
			return absolutePathArg;
		}
	}

	/**
	 * 指定したテキストファイルの内容をデフォルトの文字コードで全て読み込んで、文字列として返します。<br>
	 * <br>
	 * <strong>(注)</strong><br>
	 * このメソッドはあくまでも、比較的小さなテキストファイルを簡単に読み込むためのものです。<br>
	 * ファイルの内容を一括して読み込んで文字列を作成するので、巨大なファイルを読み込んだ場合メモリを大量に使用して
	 * OutOfMemoryErrorを引き起こす恐れがあります。<br>
	 * また、バイナリファイルを読み込むことはできません。<br>
	 * 巨大なファイルやバイナリファイルを扱いたい場合は、Javaの通常の入出力クラスを使って下さい。<br>
	 *
	 * @param fileArg 読み込みたいファイル
	 * @return ファイルの内容の文字列
	 * @exception IOException 入出力例外
	 */
	public static String readTextFile(File fileArg) throws IOException {
		//文字コードにnullを指定して、実際に処理を行うメソッドを呼び出して、結果をそのまま返す
		return readTextFile(fileArg, null);
	}

	/**
	 * 指定したテキストファイルの内容を指定した文字コードで全て読み込んで、文字列として返します。<br>
	 * 文字コードがnullの場合はデフォルトの文字コードを使用します。<br>
	 * <br>
	 * <strong>(注)</strong><br>
	 * このメソッドはあくまでも、比較的小さなテキストファイルを簡単に読み込むためのものです。<br>
	 * ファイルの内容を一括して読み込んで文字列を作成するので、巨大なファイルを読み込んだ場合メモリを大量に使用して
	 * OutOfMemoryErrorを引き起こす恐れがあります。<br>
	 * また、バイナリファイルを読み込むことはできません。<br>
	 * 巨大なファイルやバイナリファイルを扱いたい場合は、Javaの通常の入出力クラスを使って下さい。<br>
	 *
	 * @param fileArg 読み込みたいファイル
	 * @param charCodeArg 文字コード
	 * @return ファイルの内容の文字列
	 * @exception IOException 入出力例外
	 */
	public static String readTextFile(File fileArg, String charCodeArg)
			throws IOException {
		//バッファリング文字入力ストリーム
		BufferedReader br;

		//文字コードの指定がない場合
		if (charCodeArg == null) {
			//デフォルトの文字コードを使う
			br = new BufferedReader(new InputStreamReader(new FileInputStream(fileArg)));
		}
		//文字コードの指定がある場合
		else {
			//指定された文字コードを使う
			br = new BufferedReader(new InputStreamReader(new FileInputStream(fileArg), charCodeArg));
		}

		//作業用StringBuilder
		StringBuilder sb = new StringBuilder();

		//作業用変数
		int temp = -1;

		//ファイルの最後まで読み終わるまでループをまわす
		while ((temp = br.read()) != -1) {
			//読み込んだ文字をStringBuilderに追加する
			sb.append((char) temp);
		}

		//入力ストリームを閉じる
		br.close();

		//結果の文字列を返す
		return sb.toString();
	}

	/**
	 * 指定したファイル名のテキストファイルの内容をデフォルトの文字コードで全て読み込んで、文字列として返します。<br>
	 * <br>
	 * <strong>(注)</strong><br>
	 * このメソッドはあくまでも、比較的小さなテキストファイルを簡単に読み込むためのものです。<br>
	 * ファイルの内容を一括して読み込んで文字列を作成するので、巨大なファイルを読み込んだ場合メモリを大量に使用して
	 * OutOfMemoryErrorを引き起こす恐れがあります。<br>
	 * また、バイナリファイルを読み込むことはできません。<br>
	 * 巨大なファイルやバイナリファイルを扱いたい場合は、Javaの通常の入出力クラスを使って下さい。<br>
	 *
	 * @param fileNameArg 読み込みたいファイル名
	 * @return ファイルの内容の文字列
	 * @exception IOException 入出力例外
	 */
	public static String readTextFile(String fileNameArg) throws IOException {
		//文字コードにnullを指定して、実際に処理を行うメソッドを呼び出して、結果をそのまま返す
		return readTextFile(fileNameArg, null);
	}

	/**
	 * 指定したファイル名のテキストファイルの内容を指定した文字コードで全て読み込んで、文字列として返します。<br>
	 * 文字コードがnullの場合はデフォルトの文字コードを使用します。<br>
	 * <br>
	 * <strong>(注)</strong><br>
	 * このメソッドはあくまでも、比較的小さなテキストファイルを簡単に読み込むためのものです。<br>
	 * ファイルの内容を一括して読み込んで文字列を作成するので、巨大なファイルを読み込んだ場合メモリを大量に使用して
	 * OutOfMemoryErrorを引き起こす恐れがあります。<br>
	 * また、バイナリファイルを読み込むことはできません。<br>
	 * 巨大なファイルやバイナリファイルを扱いたい場合は、Javaの通常の入出力クラスを使って下さい。<br>
	 *
	 * @param fileNameArg 読み込みたいファイル名
	 * @param charCodeArg 文字コード
	 * @return ファイルの内容の文字列
	 * @exception IOException 入出力例外
	 */
	public static String readTextFile(String fileNameArg, String charCodeArg)
			throws IOException {
		//指定したファイル名でファイルオブジェクトを生成する
		File file = new File(fileNameArg);

		//実際に処理を行うメソッドを呼び出して、結果をそのまま返す
		return readTextFile(file, charCodeArg);
	}

	/**
	 * 指定した文字列を指定したファイルにデフォルトの文字コードで書き込みます。<br>
	 * ディレクトリが存在しない場合は、先にディレクトリを作成します。<br>
	 * 既にファイルが存在する場合は上書きします。<br>
	 * <br>
	 * <strong>(注)</strong><br>
	 * このメソッドはあくまでも、比較的小さなテキストファイルを簡単に作成するためのものです。<br>
	 * ファイルに書き込む内容を一度文字列として作成する必要があるので、巨大なファイルを作成する場合メモリを大量に使用して
	 * OutOfMemoryErrorを引き起こす恐れがあります。<br>
	 * また、バイナリファイルを作成することはできません。<br>
	 * 巨大なファイルやバイナリファイルを扱いたい場合は、Javaの通常の入出力クラスを使って下さい。<br>
	 *
	 * @param strArg ファイルに書き込む文字列
	 * @param fileArg 書き込むファイル
	 * @exception IOException 入出力例外
	 */
	public static void writeTextFile(String strArg, File fileArg)
			throws IOException {
		//文字コードにnullを指定して、実際に処理を行うメソッドを呼び出す
		writeTextFile(strArg, fileArg, null);
	}

	/**
	 * 指定した文字列を指定したファイルに指定した文字コードで書き込みます。<br>
	 * 文字コードがnullの場合はデフォルトの文字コードを使用します。<br>
	 * ディレクトリが存在しない場合は、先にディレクトリを作成します。<br>
	 * 既にファイルが存在する場合は上書きします。<br>
	 * <br>
	 * <strong>(注)</strong><br>
	 * このメソッドはあくまでも、比較的小さなテキストファイルを簡単に作成するためのものです。<br>
	 * ファイルに書き込む内容を一度文字列として作成する必要があるので、巨大なファイルを作成する場合メモリを大量に使用して
	 * OutOfMemoryErrorを引き起こす恐れがあります。<br>
	 * また、バイナリファイルを作成することはできません。<br>
	 * 巨大なファイルやバイナリファイルを扱いたい場合は、Javaの通常の入出力クラスを使って下さい。<br>
	 *
	 * @param strArg ファイルに書き込む文字列
	 * @param fileArg 書き込むファイル
	 * @param charCodeArg 文字コード
	 * @exception IOException 入出力例外
	 */
	public static void writeTextFile(String strArg, File fileArg,
			String charCodeArg) throws IOException {
		//==========================================================
		//ディレクトリが存在しない場合は先に作成

		//親ディレクトリを取得
		File dir = fileArg.getParentFile();

		//ディレクトリが存在しない場合
		if (!dir.exists()) {
			//親ディレクトリも含めて作成する
			dir.mkdirs();
		}
		//==========================================================


		//テキスト出力ストリーム
		PrintWriter pw;

		//文字コードの指定がない場合
		if (charCodeArg == null) {
			//デフォルトの文字コードを使う
			pw = new PrintWriter(new BufferedWriter(new OutputStreamWriter(new FileOutputStream(fileArg))));
		}
		//文字コードの指定がある場合
		else {
			//指定された文字コードを使う
			pw = new PrintWriter(new BufferedWriter(new OutputStreamWriter(new FileOutputStream(fileArg), charCodeArg)));
		}

		//引数の文字列をそのまま出力する
		pw.print(strArg);

		//出力ストリームをフラッシュ
		pw.flush();

		//出力ストリームを閉じる
		pw.close();
	}

	/**
	 * 指定した文字列を指定したファイル名のファイルにデフォルトの文字コードで書き込みます。<br>
	 * ディレクトリが存在しない場合は、先にディレクトリを作成します。<br>
	 * 既にファイルが存在する場合は上書きします。<br>
	 * <br>
	 * <strong>(注)</strong><br>
	 * このメソッドはあくまでも、比較的小さなテキストファイルを簡単に作成するためのものです。<br>
	 * ファイルに書き込む内容を一度文字列として作成する必要があるので、巨大なファイルを作成する場合メモリを大量に使用して
	 * OutOfMemoryErrorを引き起こす恐れがあります。<br>
	 * また、バイナリファイルを作成することはできません。<br>
	 * 巨大なファイルやバイナリファイルを扱いたい場合は、Javaの通常の入出力クラスを使って下さい。<br>
	 *
	 * @param strArg ファイルに書き込む文字列
	 * @param fileNameArg 書き込むファイル名
	 * @return 作成したファイル
	 * @exception IOException 入出力例外
	 */
	public static File writeTextFile(String strArg, String fileNameArg)
			throws IOException {
		//文字コードにnullを指定して、実際に処理を行うメソッドを呼び出して、結果をそのまま返す
		return writeTextFile(strArg, fileNameArg, null);
	}

	/**
	 * 指定した文字列を指定したファイル名のファイルに指定した文字コードで書き込みます。<br>
	 * 文字コードがnullの場合はデフォルトの文字コードを使用します。<br>
	 * ディレクトリが存在しない場合は、先にディレクトリを作成します。<br>
	 * 既にファイルが存在する場合は上書きします。<br>
	 * <br>
	 * <strong>(注)</strong><br>
	 * このメソッドはあくまでも、比較的小さなテキストファイルを簡単に作成するためのものです。<br>
	 * ファイルに書き込む内容を一度文字列として作成する必要があるので、巨大なファイルを作成する場合メモリを大量に使用して
	 * OutOfMemoryErrorを引き起こす恐れがあります。<br>
	 * また、バイナリファイルを作成することはできません。<br>
	 * 巨大なファイルやバイナリファイルを扱いたい場合は、Javaの通常の入出力クラスを使って下さい。<br>
	 *
	 * @param strArg ファイルに書き込む文字列
	 * @param fileNameArg 書き込むファイル名
	 * @param charCodeArg 文字コード
	 * @return 作成したファイル
	 * @exception IOException 入出力例外
	 */
	public static File writeTextFile(String strArg, String fileNameArg,
			String charCodeArg) throws IOException {
		//指定したファイル名でファイルオブジェクトを生成する
		File file = new File(fileNameArg);

		//実際に処理を行うメソッドを呼び出す
		writeTextFile(strArg, file, charCodeArg);

		//作成したファイルを返す
		return file;
	}

	/**
	 * ファイル名から拡張子を抽出します。<br>
	 * 拡張子が存在しない場合は空文字列を返します。<br>
	 * 扱いやすいように、結果を小文字に変換してから返します。<br>
	 * ({@link StringUtil#getExtension(String)}に処理を委譲します。)<br>
	 *
	 * @param fileArg 対象ファイル
	 * @return 拡張子(存在しない場合は空文字列)
	 */
	public static String getExtension(File fileArg) {
		//StringUtil.getExtension()の引数にファイル名を指定して呼び出す
		return StringUtil.getExtension(fileArg.getName());
	}

	/**
	 * ファイル名から拡張子を抽出します。<br>
	 * 拡張子が存在しない場合は空文字列を返します。<br>
	 * isToLowerArgにtrueが指定されている場合は、結果を小文字に変換してから返します。<br>
	 * ({@link StringUtil#getExtension(String, boolean)}に処理を委譲します。)<br>
	 *
	 * @param fileArg 対象ファイル
	 * @param isToLowerArg 小文字に変換するかどうかのフラグ(true=変換する, false=変換しない)
	 * @return 拡張子(存在しない場合は空文字列)
	 */
	public static String getExtension(File fileArg, boolean isToLowerArg) {
		//StringUtil.getExtension()の引数にファイル名を指定して呼び出す
		return StringUtil.getExtension(fileArg.getName(), isToLowerArg);
	}

	/**
	 * 必要な親ディレクトリを含めて、ディレクトリを安全に作成します。<br>
	 * すでにディレクトリが存在する場合は何も行いません。<br>
	 *
	 * @param dirArg ディレクトリ
	 * @exception IOException ディレクトリと同じ名前のファイルが存在した場合、ディレクトリの作成に失敗した場合
	 */
	public static void safetyMkdirs(File dirArg) throws IOException {
		//すでにファイル・またはディレクトリが存在する場合
		if (dirArg.exists()) {
			//ファイルだった場合
			if (dirArg.isFile()) {
				//例外を投げる
				throw new IOException("ディレクトリと同じ名前のファイルが存在します:" + dirArg);
			}
			//ディレクトリだった場合
			else {
				//何も行わずに終了
				return;
			}
		}

		//必要な親ディレクトリも含めてディレクトリを作成
		boolean result = dirArg.mkdirs();

		//ディレクトリの作成に失敗した場合
		if (!result) {
			//例外を投げる
			throw new IOException("ディレクトリの作成に失敗しました:" + dirArg);
		}

		//デバッグログが有効な場合
		if (log.isDebugEnabled()) {
			//ログ出力
			log.debug("ディレクトリの作成に成功しました:" + dirArg);
		}
	}

	/**
	 * 必要な親ディレクトリを含めて、ディレクトリを安全に作成します。<br>
	 * すでにディレクトリが存在する場合は何も行いません。<br>
	 *
	 * @param strArg ディレクトリ名
	 * @exception IOException ディレクトリの作成に失敗した場合
	 */
	public static void safetyMkdirs(String strArg) throws IOException {
		//ディレクトリ名からFileオブジェクトを生成し、実際に処理を行うメソッドを呼び出す
		safetyMkdirs(new File(strArg));
	}

	/**
	 * 安全にファイルを移動します。<br>
	 * 移動先のディレクトリが存在しない場合は、先に作成します。<br>
	 * 移動先のファイルがすでに存在する場合は、上書きします。<br>
	 *
	 * @param originalFileNameArg 移動元のファイル名
	 * @param newDirNameArg 移動先のディレクトリ名
	 * @param newFileNameArg 新しいファイル名
	 * @return 移動先のファイル
	 * @exception FileNotFoundException 移動元のファイルが存在しない場合
	 * @exception IllegalArgumentException 移動元のファイルにディレクトリを指定した場合
	 * @exception IOException ファイルの移動に失敗した場合
	 */
	public static File safetyMove(String originalFileNameArg,
			String newDirNameArg, String newFileNameArg)
			throws FileNotFoundException, IllegalArgumentException, IOException {
		//ファイル名からFileオブジェクトを作成して、実際に処理を行うメソッドを呼び出す
		return safetyMove(new File(originalFileNameArg), new File(newDirNameArg), newFileNameArg);
	}

	/**
	 * 安全にファイルを移動します。<br>
	 * 移動先のディレクトリが存在しない場合は、先に作成します。<br>
	 * 移動先のファイルがすでに存在する場合は、上書きします。<br>
	 *
	 * @param originalFileArg 移動元のファイル
	 * @param newDirArg 移動先のディレクトリ
	 * @param newFileNameArg 新しいファイル名
	 * @return 移動先のファイル
	 * @exception FileNotFoundException 移動元のファイルが存在しない場合
	 * @exception IllegalArgumentException 移動元のファイルにディレクトリを指定した場合
	 * @exception IOException ファイルの移動に失敗した場合
	 */
	public static File safetyMove(File originalFileArg, File newDirArg,
			String newFileNameArg) throws FileNotFoundException,
			IllegalArgumentException, IOException {
		//移動先のディレクトリと新しいファイル名から移動先のファイルを作成して、実際に処理を行うメソッドを呼び出す
		return safetyMove(originalFileArg, new File(newDirArg, newFileNameArg));
	}

	/**
	 * 安全にファイルを移動します。<br>
	 * 移動先のディレクトリが存在しない場合は、先に作成します。<br>
	 * 移動先のファイルがすでに存在する場合は、上書きします。<br>
	 *
	 * @param originalFileNameArg 移動元のファイル名
	 * @param newFileNameArg 移動先のファイル名
	 * @return 移動先のファイル
	 * @exception FileNotFoundException 移動元のファイルが存在しない場合
	 * @exception IllegalArgumentException 移動元のファイルにディレクトリを指定した場合
	 * @exception IOException ファイルの移動に失敗した場合
	 */
	public static File safetyMove(String originalFileNameArg,
			String newFileNameArg) throws FileNotFoundException,
			IllegalArgumentException, IOException {
		//ファイル名からFileオブジェクトを作成して、実際に処理を行うメソッドを呼び出す
		return safetyMove(new File(originalFileNameArg), new File(newFileNameArg));
	}

	/**
	 * 安全にファイルを移動します。<br>
	 * 移動先のディレクトリが存在しない場合は、先に作成します。<br>
	 * 移動先のファイルがすでに存在する場合は、上書きします。<br>
	 *
	 * @param originalFileArg 移動元のファイル
	 * @param newFileArg 移動先のファイル
	 * @return 移動先のファイル
	 * @exception FileNotFoundException 移動元のファイルが存在しない場合
	 * @exception IllegalArgumentException 移動元のファイルにディレクトリを指定した場合
	 * @exception IOException ファイルの移動に失敗した場合
	 */
	public static File safetyMove(File originalFileArg, File newFileArg)
			throws FileNotFoundException, IllegalArgumentException, IOException {
		//移動元と移動先のファイルが同じ場合
		if (originalFileArg.equals(newFileArg)) {
			//何もしないで、移動先のファイルだけを返す
			return newFileArg;
		}

		//移動元のファイルが存在しない場合
		if (!originalFileArg.exists()) {
			//例外を投げる
			throw new FileNotFoundException("移動元のファイルが存在しません:"
					+ originalFileArg);
		}

		//移動元のファイルがディレクトリだった場合
		if (newFileArg.isDirectory()) {
			//例外を投げる
			throw new IllegalArgumentException("移動元のファイルにディレクトリを指定することはできません:"
					+ newFileArg);
		}

		//移動先のディレクトリを安全に作成
		safetyMkdirs(newFileArg.getParentFile());

		//移動先のファイルがすでに存在した場合
		if (newFileArg.exists()) {
			//移動先のファイルを削除
			boolean result = newFileArg.delete();

			//移動先のファイルの削除に失敗した場合
			if (!result) {
				//例外を投げる
				throw new IOException("移動先のファイルの削除に失敗しました:" + newFileArg);
			}
		}


		//==========================================================
		//ファイルを移動
		//(Linuxでは、File.renameTo()で移動しようとしてもなぜか失敗してしまうので、コピー＆削除で代用)

		//ファイルをコピー
		FileUtil.copy(originalFileArg.getAbsolutePath(), newFileArg.getParent(), newFileArg.getName());

		//元のファイルを削除
		originalFileArg.delete();

		//ファイルの移動に失敗した場合
		//(コピー先のファイルが存在しない場合)
		if (!newFileArg.exists()) {
			//例外を投げる
			throw new IOException("ファイルの移動に失敗しました:移動元「" + originalFileArg
					+ "」, 移動先「" + newFileArg + "」");
		}

		//デバッグログが有効な場合
		if (log.isDebugEnabled()) {
			//ログ出力
			log.debug("ファイル「" + originalFileArg + "」を「" + newFileArg
					+ "」に移動しました");
		}

		//移動先のファイルを返す
		return newFileArg;
	}

	/**
	 * 元のファイル名のまま、安全にファイルを移動します。<br>
	 * 移動先のディレクトリが存在しない場合は、先に作成します。<br>
	 * 移動先のファイルがすでに存在する場合は、上書きします。<br>
	 *
	 * @param originalFileNameArg 移動元のファイル名
	 * @param newDirNameArg 移動先のディレクトリ名
	 * @return 移動先のファイル
	 * @exception FileNotFoundException 移動元のファイルが存在しない場合
	 * @exception IllegalArgumentException 移動元のファイルにディレクトリを指定した場合
	 * @exception IOException ファイルの移動に失敗した場合
	 */
	public static File safetyMoveWithoutRename(String originalFileNameArg,
			String newDirNameArg) throws FileNotFoundException,
			IllegalArgumentException, IOException {
		//ファイル名からFileオブジェクトを作成して、実際に処理を行うメソッドを呼び出す
		return safetyMoveWithoutRename(new File(originalFileNameArg), new File(newDirNameArg));
	}

	/**
	 * 元のファイル名のまま、安全にファイルを移動します。<br>
	 * 移動先のディレクトリが存在しない場合は、先に作成します。<br>
	 * 移動先のファイルがすでに存在する場合は、上書きします。<br>
	 *
	 * @param originalFileArg 移動元のファイル
	 * @param newDirArg 移動先のディレクトリ
	 * @return 移動先のファイル
	 * @exception FileNotFoundException 移動元のファイルが存在しない場合
	 * @exception IllegalArgumentException 移動元のファイルにディレクトリを指定した場合
	 * @exception IOException ファイルの移動に失敗した場合
	 */
	public static File safetyMoveWithoutRename(File originalFileArg,
			File newDirArg) throws FileNotFoundException,
			IllegalArgumentException, IOException {
		//移動先のディレクトリと移動元のファイルのファイル名から移動先のファイルを作成して、実際に処理を行うメソッドを呼び出す
		return safetyMove(originalFileArg, new File(newDirArg, originalFileArg.getName()));
	}


	/**
	 * ディレクトリ配下の全てのファイルサイズの合計を再帰的に計算します。<br>
	 * ファイルの場合は、単純にファイルサイズを返します。<br>
	 *
	 * @param fileArg ファイルまたはディレクトリ
	 * @return ファイルサイズの合計
	 */
	public static long getFileSizeRecursive(File fileArg) {
		//==========================================================
		//ディレクトリの場合
		if (fileArg.isDirectory()) {
			//ファイルサイズの合計
			long total = 0;

			//ディレクトリ内のファイルを取得
			File[] files = fileArg.listFiles();

			//ファイルの数に応じてループをまわす
			for (int i = 0; i < files.length; i++) {
				//このメソッドを再帰的に呼び出し、結果をファイルサイズの合計に加える
				total += getFileSizeRecursive(files[i]);
			}

			//結果を返す
			return total;
		}
		//==========================================================
		//ファイルの場合
		else {
			//単純にファイルサイズを返す
			return fileArg.length();
		}
	}

	/**
	 * UNIXのcpコマンドを別プロセスで起動して、ファイルをコピーします。<br>
	 *
	 * @param inputFileArg 入力ファイル
	 * @param outputFileArg 出力ファイル
	 * @exception IOException 入出力例外(cpコマンド自体が存在しない場合も含む)
	 * @exception InterruptedException プロセスの実行中に割り込みが発生した場合
	 * @exception UnsupportedOperationException cpコマンドの実行結果が不正な場合
	 */
	public static void unixCopy(File inputFileArg, File outputFileArg)
			throws IOException, InterruptedException,
			UnsupportedOperationException {
		//==========================================================
		//引数の値をコマンドライン引数として設定

		//コマンドライン引数を格納する文字列配列
		String[] commandArray = new String[3];

		//作業用インデックス
		int index = 0;

		//「cp」コマンド自体を設定
		commandArray[index++] = "cp";

		//入力ファイルの絶対パスを設定
		commandArray[index++] = inputFileArg.getAbsolutePath();

		//出力ファイルの絶対パスを設定
		commandArray[index++] = outputFileArg.getAbsolutePath();


		//==========================================================
		//指定されたコマンドを実行
		Process process = Runtime.getRuntime().exec(commandArray);

		//プロセスが終了するまで待つ
		int result = process.waitFor();

		//戻り値が0以外の場合
		if (result != 0) {
			//例外を投げる
			throw new UnsupportedOperationException("cpコマンドの実行に失敗しました。戻り値:"
					+ result);
		}
	}

	/**
	 * UNIXのcpコマンドを別プロセスで起動して、ファイルをコピーします。<br>
	 *
	 * @param inputFileNameArg 入力ファイル名
	 * @param outputFileNameArg 出力ファイル名
	 * @exception IOException 入出力例外(cpコマンド自体が存在しない場合も含む)
	 * @exception InterruptedException プロセスの実行中に割り込みが発生した場合
	 * @exception UnsupportedOperationException cpコマンドの実行結果が不正な場合
	 */
	public static void unixCopy(String inputFileNameArg,
			String outputFileNameArg) throws IOException, InterruptedException,
			UnsupportedOperationException {
		//ファイル名からFileオブジェクトを作成して、実際に処理を行うメソッドを呼び出す
		unixCopy(new File(inputFileNameArg), new File(outputFileNameArg));
	}

	/**
	 * ファイルサイズを文字列表現で取得します。<br>
	 * 
	 * @param fileSizeArg ファイルサイズ
	 * @return ファイルサイズの文字列表現
	 */
	public static String getFileSizeStr(long fileSizeArg) {
		//ファイルサイズが1Pバイト以上の場合
		if (fileSizeArg >= FILE_SIZE_P) {
			//ファイルサイズをPバイト単位に換算した文字列を返す
			return (fileSizeArg / FILE_SIZE_P) + "P" + BYTE_STR;
		}
		//ファイルサイズが1Tバイト以上の場合
		else if (fileSizeArg >= FILE_SIZE_T) {
			//ファイルサイズをTバイト単位に換算した文字列を返す
			return (fileSizeArg / FILE_SIZE_T) + "T" + BYTE_STR;
		}
		//ファイルサイズが1Gバイト以上の場合
		else if (fileSizeArg >= FILE_SIZE_G) {
			//ファイルサイズをGバイト単位に換算した文字列を返す
			return (fileSizeArg / FILE_SIZE_G) + "G" + BYTE_STR;
		}
		//ファイルサイズが1Mバイト以上の場合
		else if (fileSizeArg >= FILE_SIZE_M) {
			//ファイルサイズをMバイト単位に換算した文字列を返す
			return (fileSizeArg / FILE_SIZE_M) + "M" + BYTE_STR;
		}
		//ファイルサイズが1Kバイト以上の場合
		else if (fileSizeArg >= FILE_SIZE_K) {
			//ファイルサイズをMバイト単位に換算した文字列を返す
			return (fileSizeArg / FILE_SIZE_K) + "K" + BYTE_STR;
		}
		//それ以外の場合
		else {
			//ファイルサイズをバイト単位に換算した文字列を返す
			return fileSizeArg + BYTE_STR;
		}
	}

	/**
	 * 入力ストリームの内容をbyteの配列として返します。<br>
	 * 
	 * @param isArg 入力ストリーム
	 * @return byteの配列
	 * @throws IOException 入出力例外
	 */
	public static byte[] inputStreamToByteArray(InputStream isArg)
			throws IOException {
		//byteの配列を出力するストリームを生成
		ByteArrayOutputStream bs = new ByteArrayOutputStream();

		//入力ストリームに引数のストリームを設定
		BufferedInputStream in = new BufferedInputStream(isArg);

		//出力ストリームにbyteの配列を出力するストリームを設定
		BufferedOutputStream out = new BufferedOutputStream(bs);

		//作業用変数
		int temp = -1;

		//入力ストリームを読み終えるまで
		while ((temp = in.read()) != -1) {
			//出力ストリームにバッファリングする
			out.write(temp);
		}

		//バッファリングされた出力ストリームをフラッシュ
		out.flush();

		//出力ストリームを閉じる
		out.close();

		//入力ストリームを閉じる
		in.close();

		//結果のbyteの配列を返す
		return bs.toByteArray();
	}
}

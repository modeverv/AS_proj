package jp.fores.common.util;

import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.Writer;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import jp.fores.common.exception.CommandExecuteException;


/**
 * 指定されたコマンドを別プロセスで実行するためのユーティリティクラス。<br>
 * <i>(FacadeパターンのFacade役)</i><br>
 * <br>
 * このクラスは、<code>java.lang.Runtime</code> クラスの <code>exec()</code> メソッドを扱いやすくしたクラスです。<br>
 * ただし、このクラスではプロセスが終了するまで待つという点が、<code>java.lang.Runtime</code> クラスの <code>exec()</code> メソッドとは異なります。<br>
 * もし、プロセスが終了するまで待たずに非同期に実行したい場合は、このクラスではなくオリジナルのクラスを使用して下さい。<br>
 * <br>
 * <code>execute()</code> メソッドおよび <code>executeWithResultCheck()</code> メソッドで、
 * 指定されたコマンドを新しいプロセスで実行し、プロセスが終了するまで待ちます。<br>
 * 両者の違いは、コマンドの終了コードのチェックをするかどうかです。<br>
 * <code>execute()</code> メソッドは終了コードをそのまま返しますが、
 * <code>executeWithResultCheck()</code> メソッドは終了コードが 0 以外の場合は、異常終了と見なして例外を投げます。<br>
 * これらのメソッドの基本部分は、次のコードとほぼ同じです。<br>
 * <pre>
 *    //指定されたコマンドを実行
 *    Process process = Runtime.getRuntime().exec(･･･);
 *
 *    //プロセスが終了するまで待つ
 *    int result = process.waitFor();
 * </pre>
 * それぞれのメソッドは、実行するコマンド, 環境変数設定, 作業ディレクトリの3つの引数をとります。<br>
 * このうちの、環境変数設定, 作業ディレクトリについては省略することもできます。<br>
 * 実行するコマンドについては、コマンドと引数を両方とも１つの文字列に結合して渡す形式と、文字列配列に分割して渡す形式の2種類があります。<br>
 * どの形式のメソッドでも処理内容は同じなので、状況に応じて最も呼び出しやすい形式のものを使用して下さい。<br>
 * <br>
 * また、コマンドの実行結果の標準出力を、デバッグログや指定した <code>Writer</code> に出力することができます。<br>
 * この機能は、<code>UNIX</code> の <code>ls</code> や <code>grep</code> など、実行結果として標準出力に文字列を出力するコマンドを扱う場合を想定しています。<br>
 * 標準出力を書き込むための <code>Writer</code> は、コンストラクタまたは <code>setStdoutWriter()</code> メソッドで設定することができます。<br>
 */
public class CommandExecuter {

	//==========================================================
	//定数

	/**
	 * ログ出力用
	 */
	private static final Log log = LogFactory.getLog(CommandExecuter.class);


	//==========================================================
	//フィールド

	//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
	//インスタンス変数

	/**
	 * 標準出力を書き込むための <code>Writer</code>
	 */
	protected Writer stdoutWriter = null;


	//==========================================================
	//メソッド

	//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
	//コンストラクタ

	/**
	 * デフォルトのコンストラクタです。<br>
	 * 標準出力を書き込むための <code>Writer</code> は指定しません。<br>
	 */
	public CommandExecuter() {
		//標準出力を書き込むためのWriterにnullを指定して、実際に処理を行うコンストラクタを呼び出す
		this(null);
	}

	/**
	 * 標準出力を書き込むための <code>Writer</code> を指定するタイプのコンストラクタです。<br>
	 * <code>UNIX</code> の <code>ls</code> や <code>grep</code> など、実行結果として標準出力に文字列を出力するコマンドを扱うときに使用して下さい。<br>
	 * なお、<code>Writer</code> に <code>java.io.StringWriter</code> を指定すれば、結果を文字列としてそのまま取得できるので便利です。<br>
	 * <br>
	 * <strong>＜注＞</strong><br>
	 * コマンドを実行し終わっても、このクラスでは <code>Writer</code> は閉じません。<br>
	 * <code>Writer.close()</code> メソッドの呼び出しは呼び出し元のクラスで責任を持って行って下さい。</code>
	 *
	 * @param stdoutWriterArg 標準出力を書き込むための <code>Writer</code>
	 */
	public CommandExecuter(Writer stdoutWriterArg) {
		//基底クラスのコンストラクタの呼び出し
		super();

		//==========================================================
		//引数をフィールドに設定

		//標準出力を書き込むためのWriter
		this.stdoutWriter = stdoutWriterArg;
	}


	//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
	//Setter

	/**
	 * 標準出力を書き込むための <code>Writer</code> を設定します。<br>
	 * <code>UNIX</code> の <code>ls</code> や <code>grep</code> など、実行結果として標準出力に文字列を出力するコマンドを扱うときに使用して下さい。<br>
	 * なお、<code>Writer</code> に <code>java.io.StringWriter</code> を指定すれば、結果を文字列としてそのまま取得できるので便利です。<br>
	 * <br>
	 * <strong>＜注＞</strong><br>
	 * コマンドを実行し終わっても、このクラスでは <code>Writer</code> は閉じません。<br>
	 * <code>Writer.close()</code> メソッドの呼び出しは呼び出し元のクラスで責任を持って行って下さい。</code>
	 *
	 * @param stdoutWriterArg 標準出力を書き込むための <code>Writer</code>
	 */
	public void setStdoutWriter(Writer stdoutWriterArg) {
		//フィールドに引数の値をそのまま設定
		this.stdoutWriter = stdoutWriterArg;
	}


	//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
	//Getter

	/**
	 * 標準出力を書き込むための <code>Writer</code> を取得します。<br>
	 *
	 * @return 標準出力を書き込むための <code>Writer</code>
	 */
	public Writer getStdoutWriter() {
		//フィールドの値をそのまま返す
		return this.stdoutWriter;
	}


	//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
	//通常のメソッド

	/**
	 * 指定された文字列コマンドを、独立したプロセスで実行し、プロセスが終了するまで待ちます。<br>
	 * 標準出力を書き込むための <code>Writer</code> が指定されている場合は、そこに標準出力の内容を出力します。<br>
	 * 実行するコマンド, 標準出力の内容, 終了コードはデバッグログにも出力します。<br>
	 * <br>
	 * このメソッドは、指定されたコマンドを実行するための新しいプロセスを作成します。<br>
	 * <br>
	 * サブプロセスは現在のプロセスの環境設定を継承します。<br>
	 * サブプロセスの作業ディレクトリは、現在のプロセスの現在の作業ディレクトリを継承します。<br>
	 * このメソッドは、<code>execute(String commandArg, null)</code> と全く同じです。<br>
	 *
	 * @param commandArg 実行するコマンドと引数を含む文字列
	 * @return コマンドの終了コード。0 は正常終了を示す
	 * @exception SecurityException セキュリティマネージャが存在し、その <code>checkExec</code> メソッドがサブプロセスの作成を許可しない場合
	 * @exception IOException 入出力エラーが発生した場合
	 * @exception InterruptedException 現在のスレッドが待機中にほかのスレッドによって割り込まれた場合
	 */
	public int execute(String commandArg) throws SecurityException,
			IOException, InterruptedException {
		//実際に処理を行うメソッドを呼び出し、結果をそのまま返す
		return execute(commandArg, null);
	}

	/**
	 * 指定された文字列コマンドを、指定された環境を持つ独立したプロセスで実行し、プロセスが終了するまで待ちます。<br>
	 * 標準出力を書き込むための <code>Writer</code> が指定されている場合は、そこに標準出力の内容を出力します。<br>
	 * 実行するコマンド, 標準出力の内容, 終了コードはデバッグログにも出力します。<br>
	 * <br>
	 * 文字列コマンド <code>commandArg</code>、および環境変数の設定を表す文字列の配列 <code>envArrayArg</code> を指定すると、
	 * このメソッドは指定されたコマンドを実行するための新しいプロセスを作成します。<br>
	 * <br>
	 * <code>envArrayArg</code> が null の場合、サブプロセスは現在のプロセスの環境設定を継承します。<br>
	 * <br>
	 * サブプロセスの作業ディレクトリは、現在のプロセスの現在の作業ディレクトリを継承します。<br>
	 * このメソッドは、<code>execute(String commandArg, String[] envArrayArg, null)</code> と全く同じです。<br>
	 *
	 * @param commandArg 実行するコマンドと引数を含む文字列
	 * @param envArrayArg 文字列の配列。配列の各要素は、<i>name</i>=<i>value</i> という形式で環境変数設定を保持する
	 * @return コマンドの終了コード。0 は正常終了を示す
	 * @exception SecurityException セキュリティマネージャが存在し、その <code>checkExec</code> メソッドがサブプロセスの作成を許可しない場合
	 * @exception IOException 入出力エラーが発生した場合
	 * @exception InterruptedException 現在のスレッドが待機中にほかのスレッドによって割り込まれた場合
	 */
	public int execute(String commandArg, String[] envArrayArg)
			throws SecurityException, IOException, InterruptedException {
		//実際に処理を行うメソッドを呼び出し、結果をそのまま返す
		return execute(commandArg, envArrayArg, null);
	}

	/**
	 * 指定された文字列コマンドを、指定された環境と作業ディレクトリを持つ独立したプロセスで実行し、プロセスが終了するまで待ちます。<br>
	 * 標準出力を書き込むための <code>Writer</code> が指定されている場合は、そこに標準出力の内容を出力します。<br>
	 * 実行するコマンド, 標準出力の内容, 終了コードはデバッグログにも出力します。<br>
	 * <br>
	 * 文字列コマンド <code>commandArg</code>、および環境変数の設定を表す文字列の配列 <code>envArrayArg</code> を指定すると、
	 * このメソッドは指定されたコマンドを実行するための新しいプロセスを作成します。<br>
	 * <br>
	 * <code>envArrayArg</code> が null の場合、サブプロセスは現在のプロセスの環境設定を継承します。<br>
	 * <br>
	 * サブプロセスの作業ディレクトリは <code>dirArg</code> で指定します。<br>
	 * <code>dirArg</code> が null の場合は、サブプロセスは現在のプロセスの現在の作業ディレクトリを継承します。<br>
	 *
	 * @param commandArg 実行するコマンドと引数を含む文字列
	 * @param envArrayArg 文字列の配列。配列の各要素は、<i>name</i>=<i>value</i> という形式で環境変数設定を保持する
	 * @param dirArg サブプロセスの作業ディレクトリ(サブプロセスが現在のプロセスの作業ディレクトリを継承する場合は null)
	 * @return コマンドの終了コード。0 は正常終了を示す
	 * @exception SecurityException セキュリティマネージャが存在し、その <code>checkExec</code> メソッドがサブプロセスの作成を許可しない場合
	 * @exception IOException 入出力エラーが発生した場合
	 * @exception InterruptedException 現在のスレッドが待機中にほかのスレッドによって割り込まれた場合
	 */
	public int execute(String commandArg, String[] envArrayArg, File dirArg)
			throws SecurityException, IOException, InterruptedException {
		//実行するコマンドの文字列をスペース区切りで配列に分割
		//(オリジナルではStringTokenizerを使用しているが、処理内容は同じなのでここではStringUtil.split()を使う)
		String[] commandArray = StringUtil.split(commandArg, " ");

		//実際に処理を行うメソッドを呼び出し、結果をそのまま返す
		return execute(commandArray, envArrayArg, dirArg);
	}

	/**
	 * 指定されたコマンドと引数を、独立したプロセスで実行し、プロセスが終了するまで待ちます。<br>
	 * 標準出力を書き込むための <code>Writer</code> が指定されている場合は、そこに標準出力の内容を出力します。<br>
	 * 実行するコマンド, 標準出力の内容, 終了コードはデバッグログにも出力します。<br>
	 * <br>
	 * このメソッドは、指定されたコマンド行のトークンを表す文字列の配列を実行するための新しいプロセスを作成します。<br>
	 * <br>
	 * サブプロセスは現在のプロセスの環境設定を継承します。<br>
	 * サブプロセスの作業ディレクトリは、現在のプロセスの現在の作業ディレクトリを継承します。<br>
	 * このメソッドは、<code>execute(String[] commandArrayArg, null)</code> と全く同じです。<br>
	 *
	 * @param commandArrayArg 実行するコマンドと引数を含む配列
	 * @return コマンドの終了コード。0 は正常終了を示す
	 * @exception SecurityException セキュリティマネージャが存在し、その <code>checkExec</code> メソッドがサブプロセスの作成を許可しない場合
	 * @exception NullPointerException <code>commandArrayArg</code> が null の場合
	 * @exception IndexOutOfBoundsException <code>commandArrayArg</code> が長さが 0 の空の配列の場合
	 * @exception IOException 入出力エラーが発生した場合
	 * @exception InterruptedException 現在のスレッドが待機中にほかのスレッドによって割り込まれた場合
	 */
	public int execute(String[] commandArrayArg) throws SecurityException,
			NullPointerException, IndexOutOfBoundsException, IOException,
			InterruptedException {
		//実際に処理を行うメソッドを呼び出し、結果をそのまま返す
		return execute(commandArrayArg, null);
	}

	/**
	 * 指定されたコマンドと引数を、指定された環境を持つ独立したプロセスで実行し、プロセスが終了するまで待ちます。<br>
	 * 標準出力を書き込むための <code>Writer</code> が指定されている場合は、そこに標準出力の内容を出力します。<br>
	 * 実行するコマンド, 標準出力の内容, 終了コードはデバッグログにも出力します。<br>
	 * <br>
	 * コマンド行のトークンを表す文字列の配列 <code>commandArrayArg</code>、および環境変数の設定を表す文字列の配列 <code>envArrayArg</code> を指定すると、
	 * このメソッドは指定されたコマンドを実行するための新しいプロセスを作成します。<br>
	 * <br>
	 * <code>envArrayArg</code> が null の場合、サブプロセスは現在のプロセスの環境設定を継承します。<br>
	 * <br>
	 * サブプロセスの作業ディレクトリは、現在のプロセスの現在の作業ディレクトリを継承します。<br>
	 * このメソッドは、<code>execute(String[] commandArrayArg, String[] envArrayArg, null)</code> と全く同じです。<br>
	 *
	 * @param commandArrayArg 実行するコマンドと引数を含む配列
	 * @param envArrayArg 文字列の配列。配列の各要素は、<i>name</i>=<i>value</i> という形式で環境変数設定を保持する
	 * @return コマンドの終了コード。0 は正常終了を示す
	 * @exception SecurityException セキュリティマネージャが存在し、その <code>checkExec</code> メソッドがサブプロセスの作成を許可しない場合
	 * @exception NullPointerException <code>commandArrayArg</code> が null の場合
	 * @exception IndexOutOfBoundsException <code>commandArrayArg</code> が長さが 0 の空の配列の場合
	 * @exception IOException 入出力エラーが発生した場合
	 * @exception InterruptedException 現在のスレッドが待機中にほかのスレッドによって割り込まれた場合
	 */
	public int execute(String[] commandArrayArg, String[] envArrayArg)
			throws SecurityException, NullPointerException,
			IndexOutOfBoundsException, IOException, InterruptedException {
		//実際に処理を行うメソッドを呼び出し、結果をそのまま返す
		return execute(commandArrayArg, envArrayArg, null);
	}

	/**
	 * 指定されたコマンドと引数を、指定された環境と作業ディレクトリを持つ独立したプロセスで実行し、プロセスが終了するまで待ちます。<br>
	 * 標準出力を書き込むための <code>Writer</code> が指定されている場合は、そこに標準出力の内容を出力します。<br>
	 * 実行するコマンド, 標準出力の内容, 終了コードはデバッグログにも出力します。<br>
	 * <br>
	 * コマンド行のトークンを表す文字列の配列 <code>commandArrayArg</code>、および環境変数の設定を表す文字列の配列 <code>envArrayArg</code> を指定すると、
	 * このメソッドは指定されたコマンドを実行するための新しいプロセスを作成します。<br>
	 * <br>
	 * <code>envArrayArg</code> が null の場合、サブプロセスは現在のプロセスの環境設定を継承します。<br>
	 * <br>
	 * サブプロセスの作業ディレクトリは <code>dirArg</code> で指定します。<br>
	 * <code>dirArg</code> が null の場合は、サブプロセスは現在のプロセスの現在の作業ディレクトリを継承します。<br>
	 *
	 * @param commandArrayArg 実行するコマンドと引数を含む配列
	 * @param envArrayArg 文字列の配列。配列の各要素は、<i>name</i>=<i>value</i> という形式で環境変数設定を保持する
	 * @param dirArg サブプロセスの作業ディレクトリ(サブプロセスが現在のプロセスの作業ディレクトリを継承する場合は null)
	 * @return コマンドの終了コード。0 は正常終了を示す
	 * @exception SecurityException セキュリティマネージャが存在し、その <code>checkExec</code> メソッドがサブプロセスの作成を許可しない場合
	 * @exception NullPointerException <code>commandArrayArg</code> が null の場合
	 * @exception IndexOutOfBoundsException <code>commandArrayArg</code> が長さが 0 の空の配列の場合
	 * @exception IOException 入出力エラーが発生した場合
	 * @exception InterruptedException 現在のスレッドが待機中にほかのスレッドによって割り込まれた場合
	 */
	public int execute(String[] commandArrayArg, String[] envArrayArg,
			File dirArg) throws SecurityException, NullPointerException,
			IndexOutOfBoundsException, IOException, InterruptedException {
		//デバッグログが有効な場合
		if (log.isDebugEnabled()) {
			//==========================================================
			//実行するコマンドをログ出力
			log.debug("★★★ コマンド「"
					+ StringUtil.combineStringArray(commandArrayArg, " ")
					+ "」を実行します ★★★");


			//==========================================================
			//環境変数設定をログ出力

			//環境変数設定が指定されている場合
			if ((envArrayArg != null) && (envArrayArg.length != 0)) {
				//環境変数設定を「,」区切りでログ出力
				log.debug("　＞環境変数設定:"
						+ StringUtil.combineStringArray(envArrayArg));
			}
			//環境変数設定が指定されていない場合
			else {
				//「指定なし」をログ出力
				log.debug("　＞環境変数設定:指定なし");
			}


			//==========================================================
			//作業ディレクトリをログ出力

			//作業ディレクトリが指定されている場合
			if (dirArg != null) {
				//作業ディレクトリを絶対パスでログ出力
				log.debug("　＞作業ディレクトリ:" + dirArg.getAbsolutePath());
			}
			//作業ディレクトリが指定されていない場合
			else {
				//「指定なし」をログ出力
				log.debug("　＞作業ディレクトリ:指定なし");
			}

		}


		//指定されたコマンドを実行
		Process process = Runtime.getRuntime().exec(commandArrayArg,
				envArrayArg,
				dirArg);


		//==========================================================
		//実行したコマンドの標準出力を取得

		//デバッグログが有効な場合
		if (log.isDebugEnabled()) {
			log.debug("＝＝＝ コマンドの標準出力 開始 ＝＝＝");
		}


		//プロセスの標準出力を読み込むバッファリング入力ストリームを生成
		BufferedReader br = new BufferedReader(new InputStreamReader(process.getInputStream()));

		//作業用StringBuilder
		StringBuilder sb = new StringBuilder();

		//作業用変数
		int temp = -1;

		//ストリームを最後まで読み終わるまでループをまわす
		while ((temp = br.read()) != -1) {
			//読み込んだ文字をStringBuilderに追加する
			sb.append((char) temp);
		}

		//入力ストリームを閉じる
		br.close();


		//標準出力を書き込むためのWriterが指定されている場合
		if (stdoutWriter != null) {
			//結果を文字列に変換してストリームに書き込む
			stdoutWriter.write(sb.toString());

			//ストリームををフラッシュ
			stdoutWriter.flush();
		}


		//デバッグログが有効な場合
		if (log.isDebugEnabled()) {
			//結果を文字列に変換してログ出力
			log.debug(sb);
			log.debug("＝＝＝ コマンドの標準出力 終了 ＝＝＝");
		}
		//==========================================================


		//プロセスが終了するまで待つ
		int result = process.waitFor();

		//デバッグログが有効な場合
		if (log.isDebugEnabled()) {
			//ログ出力
			log.debug("★★★ コマンドが終了しました ★★★");

			//コマンドの終了コードをログ出力
			log.debug("コマンドの終了コード:" + result);
		}


		//コマンドの終了コードを返す
		return result;
	}

	/**
	 * 指定された文字列コマンドを、独立したプロセスで実行し、プロセスが終了するまで待ちます(終了コードチェック付き)。<br>
	 * コマンドの終了コードが 0 以外の場合は、異常終了と見なして例外を投げます。<br>
	 * 標準出力を書き込むための <code>Writer</code> が指定されている場合は、そこに標準出力の内容を出力します。<br>
	 * 実行するコマンド, 標準出力の内容, 終了コードはデバッグログにも出力します。<br>
	 * <br>
	 * このメソッドは、指定されたコマンドを実行するための新しいプロセスを作成します。<br>
	 * <br>
	 * サブプロセスは現在のプロセスの環境設定を継承します。<br>
	 * サブプロセスの作業ディレクトリは、現在のプロセスの現在の作業ディレクトリを継承します。<br>
	 * このメソッドは、<code>executeWithResultCheck(String commandArg, null)</code> と全く同じです。<br>
	 *
	 * @param commandArg 実行するコマンドと引数を含む文字列
	 * @exception SecurityException セキュリティマネージャが存在し、その <code>checkExec</code> メソッドがサブプロセスの作成を許可しない場合
	 * @exception IOException 入出力エラーが発生した場合
	 * @exception InterruptedException 現在のスレッドが待機中にほかのスレッドによって割り込まれた場合
	 * @exception CommandExecuteException 終了コードが0以外の場合
	 */
	public void executeWithResultCheck(String commandArg)
			throws SecurityException, IOException, InterruptedException,
			CommandExecuteException {
		//実際に処理を行うメソッドを呼び出す
		executeWithResultCheck(commandArg, null);
	}

	/**
	 * 指定された文字列コマンドを、指定された環境を持つ独立したプロセスで実行し、プロセスが終了するまで待ちます(終了コードチェック付き)。<br>
	 * コマンドの終了コードが 0 以外の場合は、異常終了と見なして例外を投げます。<br>
	 * 標準出力を書き込むための <code>Writer</code> が指定されている場合は、そこに標準出力の内容を出力します。<br>
	 * 実行するコマンド, 標準出力の内容, 終了コードはデバッグログにも出力します。<br>
	 * <br>
	 * 文字列コマンド <code>commandArg</code>、および環境変数の設定を表す文字列の配列 <code>envArrayArg</code> を指定すると、
	 * このメソッドは指定されたコマンドを実行するための新しいプロセスを作成します。<br>
	 * <br>
	 * <code>envArrayArg</code> が null の場合、サブプロセスは現在のプロセスの環境設定を継承します。<br>
	 * <br>
	 * サブプロセスの作業ディレクトリは、現在のプロセスの現在の作業ディレクトリを継承します。<br>
	 * このメソッドは、<code>executeWithResultCheck(String commandArg, String[] envArrayArg, null)</code> と全く同じです。<br>
	 *
	 * @param commandArg 実行するコマンドと引数を含む文字列
	 * @param envArrayArg 文字列の配列。配列の各要素は、<i>name</i>=<i>value</i> という形式で環境変数設定を保持する
	 * @exception SecurityException セキュリティマネージャが存在し、その <code>checkExec</code> メソッドがサブプロセスの作成を許可しない場合
	 * @exception IOException 入出力エラーが発生した場合
	 * @exception InterruptedException 現在のスレッドが待機中にほかのスレッドによって割り込まれた場合
	 * @exception CommandExecuteException 終了コードが0以外の場合
	 */
	public void executeWithResultCheck(String commandArg, String[] envArrayArg)
			throws SecurityException, IOException, InterruptedException,
			CommandExecuteException {
		//実際に処理を行うメソッドを呼び出す
		executeWithResultCheck(commandArg, envArrayArg, null);
	}

	/**
	 * 指定された文字列コマンドを、指定された環境と作業ディレクトリを持つ独立したプロセスで実行し、プロセスが終了するまで待ちます(終了コードチェック付き)。<br>
	 * コマンドの終了コードが 0 以外の場合は、異常終了と見なして例外を投げます。<br>
	 * 標準出力を書き込むための <code>Writer</code> が指定されている場合は、そこに標準出力の内容を出力します。<br>
	 * 実行するコマンド, 標準出力の内容, 終了コードはデバッグログにも出力します。<br>
	 * <br>
	 * 文字列コマンド <code>commandArg</code>、および環境変数の設定を表す文字列の配列 <code>envArrayArg</code> を指定すると、
	 * このメソッドは指定されたコマンドを実行するための新しいプロセスを作成します。<br>
	 * <br>
	 * <code>envArrayArg</code> が null の場合、サブプロセスは現在のプロセスの環境設定を継承します。<br>
	 * <br>
	 * サブプロセスの作業ディレクトリは <code>dirArg</code> で指定します。<br>
	 * <code>dirArg</code> が null の場合は、サブプロセスは現在のプロセスの現在の作業ディレクトリを継承します。<br>
	 *
	 * @param commandArg 実行するコマンドと引数を含む文字列
	 * @param envArrayArg 文字列の配列。配列の各要素は、<i>name</i>=<i>value</i> という形式で環境変数設定を保持する
	 * @param dirArg サブプロセスの作業ディレクトリ(サブプロセスが現在のプロセスの作業ディレクトリを継承する場合は null)
	 * @exception SecurityException セキュリティマネージャが存在し、その <code>checkExec</code> メソッドがサブプロセスの作成を許可しない場合
	 * @exception IOException 入出力エラーが発生した場合
	 * @exception InterruptedException 現在のスレッドが待機中にほかのスレッドによって割り込まれた場合
	 * @exception CommandExecuteException 終了コードが0以外の場合
	 */
	public void executeWithResultCheck(String commandArg, String[] envArrayArg,
			File dirArg) throws SecurityException, IOException,
			InterruptedException, CommandExecuteException {
		//実際に処理を行うメソッドを呼び出して、終了コードを取得
		int result = execute(commandArg, envArrayArg, dirArg);

		//終了コードの正当性をチェックする
		returnCodeCheck(result);
	}

	/**
	 * 指定されたコマンドと引数を、独立したプロセスで実行し、プロセスが終了するまで待ちます(終了コードチェック付き)。<br>
	 * コマンドの終了コードが 0 以外の場合は、異常終了と見なして例外を投げます。<br>
	 * 標準出力を書き込むための <code>Writer</code> が指定されている場合は、そこに標準出力の内容を出力します。<br>
	 * 実行するコマンド, 標準出力の内容, 終了コードはデバッグログにも出力します。<br>
	 * <br>
	 * このメソッドは、指定されたコマンド行のトークンを表す文字列の配列を実行するための新しいプロセスを作成します。<br>
	 * <br>
	 * サブプロセスは現在のプロセスの環境設定を継承します。<br>
	 * サブプロセスの作業ディレクトリは、現在のプロセスの現在の作業ディレクトリを継承します。<br>
	 * このメソッドは、<code>executeWithResultCheck(String[] commandArrayArg, null)</code> と全く同じです。<br>
	 *
	 * @param commandArrayArg 実行するコマンドと引数を含む配列
	 * @exception SecurityException セキュリティマネージャが存在し、その <code>checkExec</code> メソッドがサブプロセスの作成を許可しない場合
	 * @exception NullPointerException <code>commandArrayArg</code> が null の場合
	 * @exception IndexOutOfBoundsException <code>commandArrayArg</code> が長さが 0 の空の配列の場合
	 * @exception IOException 入出力エラーが発生した場合
	 * @exception InterruptedException 現在のスレッドが待機中にほかのスレッドによって割り込まれた場合
	 * @exception CommandExecuteException 終了コードが0以外の場合
	 */
	public void executeWithResultCheck(String[] commandArrayArg)
			throws SecurityException, NullPointerException,
			IndexOutOfBoundsException, IOException, InterruptedException,
			CommandExecuteException {
		//実際に処理を行うメソッドを呼び出す
		executeWithResultCheck(commandArrayArg, null);
	}

	/**
	 * 指定されたコマンドと引数を、指定された環境を持つ独立したプロセスで実行し、プロセスが終了するまで待ちます(終了コードチェック付き)。<br>
	 * コマンドの終了コードが 0 以外の場合は、異常終了と見なして例外を投げます。<br>
	 * 標準出力を書き込むための <code>Writer</code> が指定されている場合は、そこに標準出力の内容を出力します。<br>
	 * 実行するコマンド, 標準出力の内容, 終了コードはデバッグログにも出力します。<br>
	 * <br>
	 * コマンド行のトークンを表す文字列の配列 <code>commandArrayArg</code>、および環境変数の設定を表す文字列の配列 <code>envArrayArg</code> を指定すると、
	 * このメソッドは指定されたコマンドを実行するための新しいプロセスを作成します。<br>
	 * <br>
	 * <code>envArrayArg</code> が null の場合、サブプロセスは現在のプロセスの環境設定を継承します。<br>
	 * <br>
	 * サブプロセスの作業ディレクトリは、現在のプロセスの現在の作業ディレクトリを継承します。<br>
	 * このメソッドは、<code>executeWithResultCheck(String[] commandArrayArg, String[] envArrayArg, null)</code> と全く同じです。<br>
	 *
	 * @param commandArrayArg 実行するコマンドと引数を含む配列
	 * @param envArrayArg 文字列の配列。配列の各要素は、<i>name</i>=<i>value</i> という形式で環境変数設定を保持する
	 * @exception SecurityException セキュリティマネージャが存在し、その <code>checkExec</code> メソッドがサブプロセスの作成を許可しない場合
	 * @exception NullPointerException <code>commandArrayArg</code> が null の場合
	 * @exception IndexOutOfBoundsException <code>commandArrayArg</code> が長さが 0 の空の配列の場合
	 * @exception IOException 入出力エラーが発生した場合
	 * @exception InterruptedException 現在のスレッドが待機中にほかのスレッドによって割り込まれた場合
	 * @exception CommandExecuteException 終了コードが0以外の場合
	 */
	public void executeWithResultCheck(String[] commandArrayArg,
			String[] envArrayArg) throws SecurityException,
			NullPointerException, IndexOutOfBoundsException, IOException,
			InterruptedException, CommandExecuteException {
		//実際に処理を行うメソッドを呼び出す
		executeWithResultCheck(commandArrayArg, envArrayArg, null);
	}

	/**
	 * 指定されたコマンドと引数を、指定された環境と作業ディレクトリを持つ独立したプロセスで実行し、プロセスが終了するまで待ちます(終了コードチェック付き)。<br>
	 * コマンドの終了コードが 0 以外の場合は、異常終了と見なして例外を投げます。<br>
	 * 標準出力を書き込むための <code>Writer</code> が指定されている場合は、そこに標準出力の内容を出力します。<br>
	 * 実行するコマンド, 標準出力の内容, 終了コードはデバッグログにも出力します。<br>
	 * <br>
	 * コマンド行のトークンを表す文字列の配列 <code>commandArrayArg</code>、および環境変数の設定を表す文字列の配列 <code>envArrayArg</code> を指定すると、
	 * このメソッドは指定されたコマンドを実行するための新しいプロセスを作成します。<br>
	 * <br>
	 * <code>envArrayArg</code> が null の場合、サブプロセスは現在のプロセスの環境設定を継承します。<br>
	 * <br>
	 * サブプロセスの作業ディレクトリは <code>dirArg</code> で指定します。<br>
	 * <code>dirArg</code> が null の場合は、サブプロセスは現在のプロセスの現在の作業ディレクトリを継承します。<br>
	 *
	 * @param commandArrayArg 実行するコマンドと引数を含む配列
	 * @param envArrayArg 文字列の配列。配列の各要素は、<i>name</i>=<i>value</i> という形式で環境変数設定を保持する
	 * @param dirArg サブプロセスの作業ディレクトリ(サブプロセスが現在のプロセスの作業ディレクトリを継承する場合は null)
	 * @exception SecurityException セキュリティマネージャが存在し、その <code>checkExec</code> メソッドがサブプロセスの作成を許可しない場合
	 * @exception NullPointerException <code>commandArrayArg</code> が null の場合
	 * @exception IndexOutOfBoundsException <code>commandArrayArg</code> が長さが 0 の空の配列の場合
	 * @exception IOException 入出力エラーが発生した場合
	 * @exception InterruptedException 現在のスレッドが待機中にほかのスレッドによって割り込まれた場合
	 * @exception CommandExecuteException 終了コードが0以外の場合
	 */
	public void executeWithResultCheck(String[] commandArrayArg,
			String[] envArrayArg, File dirArg) throws SecurityException,
			NullPointerException, IndexOutOfBoundsException, IOException,
			InterruptedException, CommandExecuteException {
		//実際に処理を行うメソッドを呼び出して、終了コードを取得
		int result = execute(commandArrayArg, envArrayArg, dirArg);

		//終了コードの正当性をチェックする
		returnCodeCheck(result);
	}


	//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
	//内部処理用

	/**
	 * 終了コードの正当性をチェックします。<br>
	 * 終了コードが0以外の場合は、例外を投げます。<br>
	 *
	 * @param returnCodeArg 終了コード
	 * @exception CommandExecuteException 終了コードが0以外の場合
	 */
	private void returnCodeCheck(int returnCodeArg)
			throws CommandExecuteException {
		//終了コードが0以外の場合
		if (returnCodeArg != 0) {
			//例外を投げる
			throw new CommandExecuteException("コマンドの終了コードが不正です:"
					+ returnCodeArg);
		}
	}

}

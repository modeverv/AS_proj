package jp.fores.common.util;

import java.io.File;
import java.net.URI;

import javax.servlet.http.HttpSessionBindingEvent;
import javax.servlet.http.HttpSessionBindingListener;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * 自動削除機能を追加したファイルクラス。<br>
 * <br>
 * ファイルが存在する場合、ガベージコレクションされたタイミング、
 * またはセッションから切り離されたタイミングで自動的に削除します。
 * アプリケーションサーバが停止するときも、先にセッションの解放処理は行われるので、
 * File.deleteOnExit() メソッドを使うよりも確実にファイルは削除されます。<br>
 * ただし、対象がファイルではなくディレクトリの場合は削除しません。<br>
 */
public class AutoDeleteFile extends File implements HttpSessionBindingListener {

	//==========================================================
	//定数

	/**
	 * ログ出力用
	 */
	private static final Log log = LogFactory.getLog(AutoDeleteFile.class);


	//==========================================================
	//メソッド

	//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
	//コンストラクタ
	//(全て親のコンストラクタをそのまま呼び出す)

	public AutoDeleteFile(File originalFile) throws NullPointerException {
		super(originalFile.getAbsolutePath());
	}

	public AutoDeleteFile(String pathname) throws NullPointerException {
		super(pathname);
	}

	public AutoDeleteFile(String parent, String child)
			throws NullPointerException {
		super(parent, child);
	}

	public AutoDeleteFile(File parent, String child)
			throws NullPointerException {
		super(parent, child);
	}

	public AutoDeleteFile(URI uri) throws NullPointerException {
		super(uri);
	}


	//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
	//インターフェースの実装

	/**
	 * セッションに関連付けられた場合の処理を行います。<br>
	 * このクラスでは、何も行いません。<br>
	 *
	 * @param eventArg イベント
	 */
	public void valueBound(HttpSessionBindingEvent eventArg) {
		//何もしない
	}

	/**
	 * セッションから切り離された場合の処理を行います。<br>
	 * ファイルが存在する場合に削除します。<br>
	 * もしファイルの削除に失敗しても無視するので、例外は発生させません。<br>
	 *
	 * @param eventArg イベント
	 */
	public void valueUnbound(HttpSessionBindingEvent eventArg) {
		//デバッグログが有効な場合
		if (log.isDebugEnabled()) {
			//ログ出力
			log.debug("自動削除機能を追加したファイルクラスがセッションから切り離されました");
		}

		//ファイルが存在する場合に削除
		deleteFile();
	}


	//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
	//オーバーライドするメソッド

	/**
	 * 終了処理を行います。<br>
	 * ファイルが存在する場合に削除します。<br>
	 * 
	 * @throws Throwable 例外
	 */
	@Override
	protected void finalize() throws Throwable {
		//ファイルが存在する場合に削除
		deleteFile();
	}


	//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
	//内部処理用

	/**
	 * ファイルが存在する場合に削除します。<br>
	 * 存在しない場合や、ディレクトリの場合は何もしません。<br>
	 */
	private void deleteFile() {
		//ファイルが存在し、ディレクトリではなくファイルの場合
		if (exists() && isFile()) {
			//デバッグログが有効な場合
			if (log.isDebugEnabled()) {
				//ログ出力
				log.debug("ファイル「" + getAbsolutePath() + "」が存在するので削除します");
			}

			//ファイルを削除
			//(失敗しても無視)
			delete();
		}

	}
}

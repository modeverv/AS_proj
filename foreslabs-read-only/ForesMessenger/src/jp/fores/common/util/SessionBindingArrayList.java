package jp.fores.common.util;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Iterator;

import javax.servlet.http.HttpSessionBindingEvent;
import javax.servlet.http.HttpSessionBindingListener;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;


/**
 * <code>HttpSessionBindingListener</code>イベント通知機能付きArrayList。<br>
 * <br>
 * このクラスは通常の<code>ArrayList</code>に、セッションにバインドされたとき、
 * セッションから切り離されたときに、このListに含まれているオブジェクトにまでイベントを通知する機能を追加したものです。<br>
 * それ以外は、オリジナルの<code>ArrayList</code>と全く同じです。<br>
 * <code>HttpSessionBindingListener</code>を実装したクラスのオブジェクトを複数まとめて扱う場合に使用して下さい。<br>
 */
public class SessionBindingArrayList<E> extends ArrayList<E> implements
		HttpSessionBindingListener {

	//==========================================================
	//定数

	/**
	 * ログ出力用
	 */
	private static final Log log = LogFactory.getLog(SessionBindingArrayList.class);


	//==========================================================
	//メソッド

	//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
	//コンストラクタ

	/**
	 * 指定された初期サイズで空のリストを作成します。<br>
	 *
	 * @param initialCapacity リストの初期容量
	 * @exception IllegalArgumentException 指定された初期容量が負の場合
	 */
	public SessionBindingArrayList(int initialCapacity)
			throws IllegalArgumentException {
		//基底クラスのコンストラクタをそのまま呼び出す
		super(initialCapacity);
	}

	/**
	 * 初期容量 10 で空のリストを作成します。<br>
	 */
	public SessionBindingArrayList() {
		//基底クラスのコンストラクタをそのまま呼び出す
		super();
	}

	/**
	 * 指定されたコレクションの要素を含むリストを作成します。
	 * これらの要素は、コレクションの反復子が返す順序で格納されます。
	 * <code>SessionBindingArrayList</code> のインスタンスの初期サイズは、指定されたコレクションのサイズの 110% です。 <br>
	 *
	 * @param c 要素がリストに配置されるコレクション
	 * @exception NullPointerException 指定されたコレクションが null である場合
	 */
	public SessionBindingArrayList(Collection<E> c) throws NullPointerException {
		//基底クラスのコンストラクタをそのまま呼び出す
		super(c);
	}


	//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
	//インターフェースの実装

	/**
	 * セッションに関連付けられた場合の処理を行います。<br>
	 * このListに含まれているオブジェクトが、<code>HttpSessionBindingListener</code>を実装しているオブジェクトの場合、
	 * そのオブジェクトに対しても<code>valueBound()</code>メソッドを呼び出します。<br>
	 *
	 * @param eventArg イベント
	 */
	public void valueBound(HttpSessionBindingEvent eventArg) {
		//デバッグログが有効な場合
		if (log.isDebugEnabled()) {
			//ログ出力
			log.debug("SessionBindingArrayListがセッションにバインドされました");
		}

		//このListに含まれている全ての要素に対して処理を行う
		for (Iterator ite = iterator(); ite.hasNext();) {
			//現在の要素を取得
			Object obj = ite.next();

			//HttpSessionBindingListenerを実装しているオブジェクトの場合
			if (obj instanceof HttpSessionBindingListener) {
				//valueBound()メソッドを呼び出す
				((HttpSessionBindingListener) obj).valueBound(eventArg);
			}
		}
	}

	/**
	 * セッションから切り離された場合の処理を行います。<br>
	 * このListに含まれているオブジェクトが、<code>HttpSessionBindingListener</code>を実装しているオブジェクトの場合、
	 * そのオブジェクトに対しても<code>valueUnbound()</code>メソッドを呼び出します。<br>
	 *
	 * @param eventArg イベント
	 */
	public void valueUnbound(HttpSessionBindingEvent eventArg) {
		//デバッグログが有効な場合
		if (log.isDebugEnabled()) {
			//ログ出力
			log.debug("SessionBindingArrayListがセッションから切り離されました");
		}

		//このListに含まれている全ての要素に対して処理を行う
		for (Iterator ite = iterator(); ite.hasNext();) {
			//現在の要素を取得
			Object obj = ite.next();

			//HttpSessionBindingListenerを実装しているオブジェクトの場合
			if (obj instanceof HttpSessionBindingListener) {
				//valueBound()メソッドを呼び出す
				((HttpSessionBindingListener) obj).valueUnbound(eventArg);
			}
		}
	}

}

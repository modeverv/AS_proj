package jp.fores.common.util.comparator;

import java.io.Serializable;


/**
 * GenericComparatorの内部処理用のソート方法指定用オブジェクト。
 * (Immutableオブジェクト)<br>
 * (内部処理用のクラスなので、わざとパッケージスコープで定義しています)
 */
final class GenericComparatorCondition implements Serializable {

	//==============================================================
	//フィールド

	//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
	//インスタンス変数

	/**
	 * キー
	 */
	private final String key;

	/**
	 * ソート順(true=昇順, false=降順)
	 */
	private final boolean order;


	//==============================================================
	//メソッド

	//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
	//コンストラクタ

	/**
	 * コンストラクタです。
	 * 引数をフィールドに設定します。
	 * 
	 * @param key キー
	 * @param order ソート順
	 */
	public GenericComparatorCondition(String key, boolean order) {
		//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
		//引数をフィールドに設定

		//キー
		this.key = key;

		//ソート順
		this.order = order;
	}


	//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
	//Getter

	/**
	 * キーを取得します。<br>
	 *
	 * @return キー
	 */
	public String getKey() {
		//フィールドの値をそのまま返す
		return this.key;
	}

	/**
	 * ソート順を取得します。<br>
	 *
	 * @return ソート順(true=昇順, false=降順)
	 */
	public boolean getOrder() {
		//フィールドの値をそのまま返す
		return this.order;
	}

}

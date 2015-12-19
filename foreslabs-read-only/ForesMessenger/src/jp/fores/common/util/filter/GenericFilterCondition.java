package jp.fores.common.util.filter;

import java.io.Serializable;

/**
 * GenericFilterの内部処理用の条件指定用オブジェクト。
 * (Immutableオブジェクト)<br>
 * (内部処理用のクラスなので、わざとパッケージスコープで定義しています)
 */
final class GenericFilterCondition implements Serializable {

	//==============================================================
	//フィールド

	//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
	//インスタンス変数

	/**
	 * キー
	 */
	private final String key;

	/**
	 * 値
	 */
	private final Object value;

	/**
	 * 正規表現を使用するかどうかのフラグ(true=使用する, false=使用しない)
	 */
	private final boolean isUseRegExp;

	/**
	 * nullと空文字列を同じとみなすかどうかのフラグ(true=同じとみなす, false=別物とみなす)
	 */
	private final boolean isEqualNullBlank;

	/**
	 * 文字列による検索かどうかのフラグ(true=文字列による検索, false=文字列による検索でない)
	 */
	private final boolean isStringSearch;


	//==============================================================
	//メソッド

	//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
	//コンストラクタ

	/**
	 * 全ての引数を取る内部処理用のキャッチオールコンストラクタです。<br>
	 * 
	 * @param key キー
	 * @param value 値
	 * @param isUseRegExp 正規表現を使用するかどうかのフラグ(true=使用する, false=使用しない)
	 * @param isEqualNullBlank nullと空文字列を同じとみなすかどうかのフラグ(true=同じとみなす, false=別物とみなす)
	 * @param isStringSearch 文字列による検索かどうかのフラグ
	 */
	private GenericFilterCondition(String key, Object value,
			boolean isUseRegExp, boolean isEqualNullBlank,
			boolean isStringSearch) {
		//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
		//引数をフィールドに設定

		//キー
		this.key = key;

		//値
		this.value = value;

		//正規表現を使用するかどうかのフラグ
		this.isUseRegExp = isUseRegExp;

		//nullと空文字列を同じとみなすかどうかのフラグ
		this.isEqualNullBlank = isEqualNullBlank;

		//文字列による検索かどうかのフラグ(内部処理用)
		this.isStringSearch = isStringSearch;
	}

	/**
	 * 値に文字列を指定するタイプの最も一般的なコンストラクタです。<br>
	 * 正規表現は使用せず、nullと空文字列は別物とみなします。<br>
	 * 
	 * @param key キー
	 * @param value 文字列の値
	 */
	public GenericFilterCondition(String key, String value) {
		//他のコンストラクタに処理を委譲する
		//(正規表現を使用するかどうかのフラグと、nullと空文字列を同じとみなすかどうかのフラグにはfalseを渡す)
		this(key, value, false, false);
	}

	/**
	 * 値に文字列を指定し、正規表現を使用するかどうかのフラグと、nullと空文字列を同じとみなすかどうかのフラグも指定するタイプの最も一般的なコンストラクタです。<br>
	 * 
	 * @param key キー
	 * @param value 文字列の値
	 * @param isUseRegExp 正規表現を使用するかどうかのフラグ(true=使用する, false=使用しない)
	 * @param isEqualNullBlank nullと空文字列を同じとみなすかどうかのフラグ(true=同じとみなす, false=別物とみなす)
	 */
	public GenericFilterCondition(String key, String value,
			boolean isUseRegExp, boolean isEqualNullBlank) {
		//キャッチオールコンストラクタに処理を委譲する
		//(文字列による検索かどうかのフラグにはtrueを渡す)
		this(key, value, isUseRegExp, isEqualNullBlank, true);
	}

	/**
	 * 値にオブジェクトを指定するタイプのコンストラクタです。<br>
	 * 文字列による検索ではないので、正規表現は使用せず、nullと空文字列は別物とみなします。<br>
	 * 
	 * @param key キー
	 * @param value 値
	 */
	public GenericFilterCondition(String key, Object value) {
		//キャッチオールコンストラクタに処理を委譲する
		//(キーと値以外はfalseを渡す)
		this(key, value, false, false, false);
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
	 * 値を取得します。<br>
	 *
	 * @return 値
	 */
	public Object getValue() {
		//フィールドの値をそのまま返す
		return this.value;
	}

	/**
	 * 正規表現を使用するかどうかのフラグを取得します。<br>
	 *
	 * @return 正規表現を使用するかどうかのフラグ(true=使用する, false=使用しない)
	 */
	public boolean isUseRegExp() {
		//フィールドの値をそのまま返す
		return this.isUseRegExp;
	}

	/**
	 * nullと空文字列を同じとみなすかどうかのフラグを取得します。<br>
	 *
	 * @return nullと空文字列を同じとみなすかどうかのフラグ(true=同じとみなす, false=別物とみなす)
	 */
	public boolean isEqualNullBlank() {
		//フィールドの値をそのまま返す
		return this.isEqualNullBlank;
	}

	/**
	 * 文字列による検索かどうかのフラグを取得します。<br>
	 *
	 * @return 文字列による検索かどうかのフラグ(true=文字列による検索, false=文字列による検索でない)
	 */
	public boolean isStringSearch() {
		//フィールドの値をそのまま返す
		return this.isStringSearch;
	}

}

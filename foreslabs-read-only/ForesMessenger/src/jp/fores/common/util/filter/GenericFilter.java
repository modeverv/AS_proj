package jp.fores.common.util.filter;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

import jp.fores.common.util.ExtendPropertyUtils;


/**
 * JavaBeanおよびMapから条件に合うものだけを抽出するための汎用フィルタ。<br>
 * (Immutableオブジェクト)<br>
 */
public final class GenericFilter implements Serializable {

	//==========================================================
	//フィールド

	//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
	//インスタンス変数

	/**
	 * 条件指定用オブジェクトのリスト
	 */
	private List<GenericFilterCondition> filterConditionList = new ArrayList<GenericFilterCondition>();


	//==========================================================
	//メソッド

	//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
	//コンストラクタ

	/**
	 * コンストラクタです。<br>
	 * 特に何も行いません。<br>
	 */
	public GenericFilter() {
		//特に何も行わない
	}

	//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
	//通常のメソッド

	/**
	 * 指定されたオブジェクトが条件に一致するかどうかを返します。<br>
	 * 
	 * @param obj 対象のオブジェクト
	 * @return true=条件に一致する, false=条件に一致しない
	 */
	public boolean match(Object obj) {
		//フィールドの条件指定用オブジェクトのリストの全ての要素に対して処理を行う
		for (GenericFilterCondition filterCondition : this.filterConditionList) {
			//オブジェクトの現在の条件のキーに対応する値
			Object objValue = null;

			try {
				//オブジェクトから現在の条件のキーに一致する値を取得
				objValue = ExtendPropertyUtils.getProperty(obj, filterCondition.getKey());
			}
			//値が取得できなかった場合
			catch (Exception e) {
				//仕方がないのでnullと同じとみなす
				objValue = null;
			}

			//現在の条件が文字列による検索の場合
			if (filterCondition.isStringSearch()) {
				//オブジェクトの値の文字列表現
				String GenericStrValue = null;

				//オブジェクトの値がnullでない場合
				if (objValue != null) {
					//オブジェクトの値を文字列として取得
					GenericStrValue = objValue.toString();
				}

				//現在の条件の値を文字列にキャストして取得
				String conditionStrValue = (String) filterCondition.getValue();

				//現在の条件がnullと空文字列を同じとみなす場合
				if (filterCondition.isEqualNullBlank()) {
					//オブジェクトの値が空文字列の場合
					if ("".equals(GenericStrValue)) {
						//オブジェクトの値にnullを設定する
						GenericStrValue = null;
					}

					//現在の条件の値が空文字列の場合
					if ("".equals(conditionStrValue)) {
						//現在の条件の値にnullを設定する
						conditionStrValue = null;
					}
				}

				//オブジェクトの値と条件の値がどちらもnullでない場合
				if ((GenericStrValue != null) && (conditionStrValue != null)) {
					//現在の条件が正規表現を使用する場合
					if (filterCondition.isUseRegExp()) {
						//現在の条件を正規表現のパターンに指定してマッチしない場合
						if (!GenericStrValue.matches(conditionStrValue)) {
							//条件に一致しないのでfalseを返す
							return false;
						}
					}
					//現在の条件が正規表現を使用しない場合
					else {
						//オブジェクトの値と条件の値が異なる場合
						//(普通にequals()を使ってチェック)
						if (!GenericStrValue.equals(conditionStrValue)) {
							//条件に一致しないのでfalseを返す
							return false;
						}
					}
				}
				//オブジェクトの値と条件の値のどちらか一方でもnullの場合
				else {
					//オブジェクトの値と条件の値のどちらか一方がnullでない場合
					if ((GenericStrValue != null)
							|| (conditionStrValue != null)) {
						//条件に一致しないのでfalseを返す
						return false;
					}
				}
			}
			//現在の条件がオブジェクトによる検索の場合
			else {
				//現在の条件の値をオブジェクトのまま取得
				Object conditionValue = filterCondition.getValue();

				//オブジェクトの値と条件の値がどちらもnullでない場合
				if ((objValue != null) && (conditionValue != null)) {
					//オブジェクトの値と条件の値が異なる場合
					if (!objValue.equals(conditionValue)) {
						//条件に一致しないのでfalseを返す
						return false;
					}
				}
				//オブジェクトの値と条件の値のどちらか一方でもnullの場合
				else {
					//オブジェクトの値と条件の値のどちらか一方がnullでない場合
					if ((objValue != null) || (conditionValue != null)) {
						//条件に一致しないのでfalseを返す
						return false;
					}
				}
			}
		}

		//最後まで条件に一致したのでtrueを返す
		return true;
	}

	/**
	 * 指定されたオブジェクトのリストから条件に一致するものだけを抽出して返します。<br>
	 * 
	 * @param objList 対象のオブジェクトのリスト
	 * @return 条件に一致するものだけを抽出したリスト
	 */
	public List<Object> filter(List objList) {
		//結果を格納するリストのインスタンスを生成
		List<Object> resultList = new ArrayList<Object>();

		//引数のGenericのリストの全ての要素に対して処理を行う
		for (Object obj : objList) {
			//条件に一致するオブジェクトだった場合
			if (match(obj)) {
				//結果のリストに追加
				resultList.add(obj);
			}
		}

		//結果のリストを返す
		return resultList;
	}

	/**
	 * 抽出条件を追加します。<br>
	 * 値に文字列を指定するタイプの最も一般的な抽出条件の指定方法です。<br>
	 * 正規表現は使用せず、nullと空文字列は別物とみなします。<br>
	 * 
	 * @param key キー
	 * @param value 文字列の値
	 */
	public void addCondition(String key, String value) {
		//条件指定用のオブジェクトを生成して、フィールドのリストに追加する
		this.filterConditionList.add(new GenericFilterCondition(key, value));
	}

	/**
	 * 抽出条件を追加します。<br>
	 * 値に文字列を指定し、正規表現を使用するかどうかのフラグと、nullと空文字列を同じとみなすかどうかのフラグも指定するタイプの抽出条件の指定方法です。<br>
	 * 
	 * @param key キー
	 * @param value 文字列の値
	 * @param isUseRegExp 正規表現を使用するかどうかのフラグ(true=使用する, false=使用しない)
	 * @param isEqualNullBlank nullと空文字列を同じとみなすかどうかのフラグ(true=同じとみなす, false=別物とみなす)
	 */
	public void addCondition(String key, String value, boolean isUseRegExp,
			boolean isEqualNullBlank) {
		//条件指定用のオブジェクトを生成して、フィールドのリストに追加する
		this.filterConditionList.add(new GenericFilterCondition(key, value, isUseRegExp, isEqualNullBlank));
	}

	/**
	 * 抽出条件を追加します。<br>
	 * 値にオブジェクトを指定するタイプの抽出条件の指定方法です。<br>
	 * 文字列による検索ではないので、正規表現は使用せず、nullと空文字列は別物とみなします。<br>
	 * 
	 * @param key キー
	 * @param value 値
	 */
	public void addCondition(String key, Object value) {
		//条件指定用のオブジェクトを生成して、フィールドのリストに追加する
		this.filterConditionList.add(new GenericFilterCondition(key, value));
	}

	/**
	 * 抽出条件をクリアします。<br>
	 */
	public void clear() {
		//フィールドの条件指定用オブジェクトのリストをクリアする
		this.filterConditionList.clear();
	}

}

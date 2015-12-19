package jp.fores.common.util.comparator;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;

import jp.fores.common.util.ExtendPropertyUtils;


/**
 * JavaBeanおよびMapをソートするための汎用Comparator。<br>
 * (Immutableオブジェクト)<br>
 */
public final class GenericComparator implements Comparator<Object>,
		Serializable {

	//==============================================================
	//フィールド

	//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
	//インスタンス変数

	/**
	 * ソート方法指定用オブジェクトのリスト
	 */
	private final List<GenericComparatorCondition> sortOrderList;

	/**
	 * キーに対応する要素が存在しない場合も許可するかどうかのフラグ(true=許可する, false=エラーにする)
	 */
	private final boolean nullAccept;

	/**
	 * キーに対応する要素が存在しない場合のソート順(true=存在しない要素の方が大きいとみなす, false=存在しない要素の方が小さいとみなす)
	 */
	private final boolean nullOrder;


	//==============================================================
	//メソッド

	//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
	//コンストラクタ

	/**
	 * 全ての引数を取る内部処理用のキャッチオールコンストラクタです。<br>
	 * 
	 * @param sortOrderList ソート方法指定用オブジェクトのリスト
	 * @param nullAccept キーに対応する要素が存在しない場合も許可するかどうかのフラグ(true=許可する, false=エラーにする)
	 * @param nullOrder キーに対応する要素が存在しない場合のソート順(true=存在しない要素の方が大きいとみなす, false=存在しない要素の方が小さいとみなす)
	 */
	private GenericComparator(List<GenericComparatorCondition> sortOrderList,
			boolean nullAccept, boolean nullOrder) {
		//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
		//引数をフィールドに設定

		//ソート方法指定用オブジェクトのリスト
		this.sortOrderList = sortOrderList;

		//キーに対応する要素が存在しない場合も許可するかどうかのフラグ
		this.nullAccept = nullAccept;

		//キーに対応する要素が存在しない場合のソート順
		this.nullOrder = nullOrder;
	}

	/**
	 * ソート順のみを指定するタイプの最もシンプルなコンストラクタです。<br>
	 * キーに対応する要素が存在しない場合も許可し、存在しない要素の方が大きいとみなします。<br>
	 * 
	 * @param sortOrderStr ソート順を指定した文字列
	 */
	public GenericComparator(String sortOrderStr) {
		//他のコンストラクタに処理を委譲する
		//(キーに対応する要素が存在しない場合も許可するかどうかのフラグと、キーに対応する要素が存在しない場合のソート順にはtrueを指定する)
		this(sortOrderStr, true, true);
	}

	/**
	 * ソート順, キーに対応する要素が存在しない場合のソート順を指定するタイプのコンストラクタです。<br>
	 * キーに対応する要素が存在しない場合も許可します。<br>
	 * 
	 * @param sortOrderStr ソート順を指定した文字列
	 * @param nullOrder キーに対応する要素が存在しない場合のソート順(true=存在しない要素の方が大きいとみなす, false=存在しない要素の方が小さいとみなす)
	 */
	public GenericComparator(String sortOrderStr, boolean nullOrder) {
		//他のコンストラクタに処理を委譲する
		//(キーに対応する要素が存在しない場合も許可するかどうかのフラグにはtrueを指定する)
		this(sortOrderStr, true, nullOrder);
	}

	/**
	 * ソート順, キーに対応する要素が存在しない場合も許可するかどうか, キーに対応する要素が存在しない場合のソート順を指定するタイプのコンストラクタです。<br>
	 * 
	 * @param sortOrderStr ソート順を指定した文字列
	 * @param nullAccept キーに対応する要素が存在しない場合も許可するかどうかのフラグ(true=許可する, false=エラーにする)
	 * @param nullOrder キーに対応する要素が存在しない場合のソート順(true=存在しない要素の方が大きいとみなす, false=存在しない要素の方が小さいとみなす)
	 */
	public GenericComparator(String sortOrderStr, boolean nullAccept,
			boolean nullOrder) {
		//キャッチオールコンストラクタに処理を委譲する
		//(ソート方法指定用オブジェクトのリストには、ソート順を指定した文字列を解析した結果を渡す)
		this(parseSortOrderString(sortOrderStr), nullAccept, nullOrder);
	}


	//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
	//抽象メソッドの実装

	/**
	 * 順序付けのために 2 つの引数を比較します。<br>
	 * 最初の引数が 2 番目の引数より小さい場合は負の整数、
	 * 両方が等しい場合は 0、
	 * 最初の引数が 2 番目の引数より大きい場合は正の整数を返します。<br>
	 * 
	 * @param o1 比較対象の最初のオブジェクト
	 * @param o2 比較対象の 2 番目のオブジェクト
	 * @return 最初の引数が 2 番目の引数より小さい場合は負の整数、両方が等しい場合は 0、最初の引数が 2 番目の引数より大きい場合は正の整数
	 */
	@SuppressWarnings("unchecked")
	public int compare(Object o1, Object o2) {
		//フィールドのソート方法指定用オブジェクトのリストの全ての要素に対してループをまわす
		for (GenericComparatorCondition compCondition : this.sortOrderList) {

			//最初の引数のオブジェクトのキーに対応する値
			Comparable value1 = null;

			try {
				//最初の引数のオブジェクトのキーに対応する値を取得
				value1 = (Comparable) ExtendPropertyUtils.getProperty(o1, compCondition.getKey());

				//値が空文字列の場合
				if ("".equals(value1)) {
					//nullと同じとみなす
					value1 = null;
				}
			}
			//値が取得できなかった場合
			catch (Exception e) {
				//仕方がないのでnullと同じとみなす
				value1 = null;
			}

			//2番目の引数のオブジェクトのキーに対応する値
			Comparable value2 = null;

			try {
				//2番目の引数のオブジェクトのキーに対応する値を取得
				value2 = (Comparable) ExtendPropertyUtils.getProperty(o2, compCondition.getKey());

				//値が空文字列の場合
				if ("".equals(value2)) {
					//nullと同じとみなす
					value2 = null;
				}
			}
			//値が取得できなかった場合
			catch (Exception e) {
				//仕方がないのでnullと同じとみなす
				value2 = null;
			}

			//現在のキーに対応する値を比較した結果を格納する変数
			int result = 0;

			//どちらのMapから取得した値もnullでない場合
			if ((value1 != null) && (value2 != null)) {
				//Mapから取得した値同士をcompareTo()で比較する
				result = value1.compareTo(value2);
			}
			//どちらか一方でもnullの場合
			else {
				//キーに対応する要素が存在しない場合を許可しない設定になっている場合
				if (!this.nullAccept) {
					//例外を投げる
					throw new IllegalArgumentException("キーに対応する要素が存在しない場合を許可しない設定になっています。キー="
							+ compCondition.getKey());
				}

				//最初の引数のMapから取得した値がnullで、
				//2番目の引数のMapから取得した値がnullでない場合
				if ((value1 == null) && (value2 != null)) {
					//存在しない要素の方が大きいとみなす設定になっている場合
					if (this.nullOrder) {
						//最初の引数のMapの方が大きいとみなすので、結果に正の整数(1)を設定する
						result = 1;
					}
					//存在しない要素の方が小さいとみなす設定になっている場合
					else {
						//最初の引数のMapの方が小さいとみなすので、結果に負の整数(-1)を設定する
						result = -1;
					}
				}
				//最初の引数のMapから取得した値がnullで、
				//2番目の引数のMapから取得した値がnullでない場合
				else if ((value1 != null) && (value2 == null)) {
					//存在しない要素の方が大きいとみなす設定になっている場合
					if (this.nullOrder) {
						//最初の引数のMapの方が小さいとみなすので、結果に負の整数(-1)を設定する
						result = -1;
					}
					//存在しない要素の方が小さいとみなす設定になっている場合
					else {
						//最初の引数のMapの方が大きいとみなすので、結果に正の整数(1)を設定する
						result = 1;
					}
				}
				//最初の引数のMapから取得した値と、
				//2番目の引数のMapから取得した値が両方ともnullの場合
				else {
					//同じ値とみなすので、結果に0を設定する
					result = 0;
				}
			}

			//現在のキーに対応する値を比較した結果が異なる場合
			if (result != 0) {
				//ソート順が降順の場合
				if (!compCondition.getOrder()) {
					//結果の値の符号を反転する
					result *= -1;
				}

				//結果を返す
				return result;
			}
		}

		//ここに来るのはソート対象のキーの値が全て同じ場合なので、0を返す
		return 0;
	}


	//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
	//内部処理用

	/**
	 * ソート順を指定した文字列を解析し、ソート方法指定用オブジェクトのリストに変換して返します。<br>
	 * 
	 * @param sortOrderStr ソート順を指定した文字列
	 * @return ソート方法指定用オブジェクトのリスト
	 */
	private static List<GenericComparatorCondition> parseSortOrderString(
			String sortOrderStr) {
		//結果を格納するリストを生成
		List<GenericComparatorCondition> resultList = new ArrayList<GenericComparatorCondition>();

		//引数の文字列を「,」区切りで分割して、文字列配列を取得
		String[] commaSplitArray = sortOrderStr.split(",");

		//「,」区切りで分割した文字列配列の全ての要素に対して処理を行う
		for (String targetStr : commaSplitArray) {
			//前後の空白文字を取り除く
			targetStr = targetStr.trim();

			//前後の空白文字を取り除いた結果、空文字列になった場合
			if ("".equals(targetStr)) {
				//例外を投げる
				throw new IllegalArgumentException("ソート順の指定方法が不正です");
			}

			//キー
			String key = null;

			//ソート順(デフォルトは昇順)
			boolean order = true;

			//文字列中の最後の半角スペースの位置を取得する
			int lastSpaceIndex = targetStr.lastIndexOf(' ');

			//文字列中に半角スペースが含まれていない場合
			if (lastSpaceIndex == -1) {
				//キーに対象文字列をそのまま設定する
				key = targetStr;
			}
			//文字列中に半角スペースが含まれている場合
			else {
				//最後の半角スペース以降の文字列を取得する
				String lastToken = targetStr.substring(lastSpaceIndex + 1);

				//最後の半角スペース以降の文字列が「ASC」(昇順)の場合
				//(大文字・小文字は区別しない)
				if ("ASC".equalsIgnoreCase(lastToken)) {
					//最後の半角スペースの前までの文字列を取得し、キーに指定する
					key = targetStr.substring(0, lastSpaceIndex);
				}
				//最後の半角スペース以降の文字列が「DESC」(降順)の場合
				//(大文字・小文字は区別しない)
				else if ("DESC".equalsIgnoreCase(lastToken)) {
					//最後の半角スペースの前までの文字列を取得し、キーに指定する
					key = targetStr.substring(0, lastSpaceIndex);

					//ソート順に降順を指定する
					order = false;
				}
				//それ以外の場合
				//(半角スペースは含まれているが、昇順・降順は特に指定されていない場合)
				else {
					//キーに対象文字列をそのまま設定する
					key = targetStr;
				}
			}

			//決定したキーとソート順を元にソート方法指定用オブジェクトを作成し、リストに追加する
			resultList.add(new GenericComparatorCondition(key, order));
		}

		//結果のリストを返す
		return resultList;
	}
}

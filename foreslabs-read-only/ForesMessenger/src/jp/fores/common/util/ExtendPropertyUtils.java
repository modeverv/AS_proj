package jp.fores.common.util;

import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;
import java.util.TreeSet;

import org.apache.commons.beanutils.BeanUtils;
import org.apache.commons.beanutils.PropertyUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;


/**
 * Jakarta Commons の BeanUtils の <code>org.apache.commons.beanutils.PropertyUtils</code> を
 * 改良したユーティリティクラス。<br>
 * <br>
 * getter, setter以外に、publicなフィールドも扱えるようにしています。<br>
 * 主に大文字・小文字の違いや、ハイフンやアンダーバーの有無など、少々の違いがあっても
 * プロパティを参照できるようにしています。<br>
 * また、値の設定には <code>org.apache.commons.beanutils.BeanUtils</code> を使っているので、
 * プロパティと値の型が多少違っても自動的に補正します。<br>
 * このクラスに無いメソッドは、オリジナルの <code>PropertyUtils</code> から呼び出すようにして下さい。<br>
 * <br>
 * また、便宜的にキーが文字列であるMapも透過的に扱えるようになっています。<br>
 * JavaBeanがMapのインスタンスだった場合は、Mapの要素に対して処理が行われます。<br>
 */
public final class ExtendPropertyUtils {

	//==========================================================
	//定数

	/**
	 * ログ出力用
	 */
	private static final Log log = LogFactory.getLog(ExtendPropertyUtils.class);


	//==========================================================
	//メソッド

	//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
	//コンストラクタ

	/**
	 * コンストラクタです。<br>
	 * (クラスメソッドのみのユーティリティークラスなので、privateにしてインスタンスを作成できないようにしています。)<br>
	 */
	private ExtendPropertyUtils() {
		//基底クラスのコンストラクタの呼び出し
		super();
	}


	//==============================================================
	//メソッド

	//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
	//クラスメソッド

	/**
	 * JavaBeanの指定されたプロパティに値を設定します。<br>
	 * プロパティと値の型が多少違っても自動的に補正します。<br>
	 * オリジナルのものとは違って、同じ名前と見なされるプロパティを探し出してから値を設定します。<br>
	 * 
	 * @param beanArg 対象のJavaBean
	 * @param nameArg プロパティ名
	 * @param valueArg プロパティに設定する値
	 * @throws NoSuchMethodException 同じ名前と見なせるプロパティが存在しない場合
	 * @throws Exception 例外
	 */
	@SuppressWarnings("unchecked")
	public static void setProperty(Object beanArg, String nameArg,
			Object valueArg) throws NoSuchMethodException, Exception {
		//対象のJavaBeanがMapの場合
		if (beanArg instanceof Map) {
			//対象のJavaBeanをMapにキャスト
			Map map = (Map) beanArg;

			//引数のプロパティ名をキーにしてMapに引数の値を設定
			map.put(nameArg, valueArg);
		}
		//対象のJavaBeanがMapでない場合
		else {
			//JavaBeanから引数のプロパティ名と名前が同じと見なせるプロパティの名前を取得
			String propertyName = getSamePropertyName(beanArg, nameArg);

			//プロパティが存在しない場合
			if (propertyName == null) {
				//例外を投げる
				throw new NoSuchMethodException("JavaBean ["
						+ beanArg.getClass().getName() + "] には「" + nameArg
						+ "」によく似た名前のプロパティが見つかりませんでした");
			}

			try {
				try {
					//プロパティ名に対応するフィールドを取得
					Field field = beanArg.getClass().getField(propertyName);

					//フィールドに値を設定する
					field.set(beanArg, valueArg);
				}
				//フィールドが存在しない場合
				catch (NoSuchFieldException e) {
					//取得した正式なプロパティの名前を使って、プロパティに値を設定する
					PropertyUtils.setProperty(beanArg, propertyName, valueArg);
				}
			}
			//型違いのため値を設定できなかった場合
			catch (IllegalArgumentException e2) {
				//PropertyUtilsではなくBeanUtilsのメソッドを使ってもう一度試してみる
				BeanUtils.setProperty(beanArg, propertyName, valueArg);
			}
		}
	}

	/**
	 * JavaBeanの指定されたプロパティの値を取得します。<br>
	 * オリジナルのものとは違って、同じ名前と見なされるプロパティを探し出してから値を取得します。<br>
	 * 
	 * @param beanArg 対象のJavaBean
	 * @param nameArg プロパティ名
	 * @return 対象のJavaBeanの名前が同じと見なせるプロパティの値
	 * @throws NoSuchMethodException 同じ名前と見なせるプロパティが存在しない場合
	 * @throws Exception 例外
	 */
	public static Object getProperty(Object beanArg, String nameArg)
			throws NoSuchMethodException, Exception {
		//対象のJavaBeanがMapの場合
		if (beanArg instanceof Map) {
			//対象のJavaBeanをMapにキャスト
			Map map = (Map) beanArg;

			//引数のプロパティ名をキーにしてMapから値を取得
			Object value = map.get(nameArg);

			//値が取得できなかった場合
			if (value == null) {
				//例外を投げる
				throw new NoSuchMethodException("JavaBean ["
						+ beanArg.getClass().getName() + "] には「" + nameArg
						+ "」によく似た名前のプロパティが見つかりませんでした");
			}

			//取得した値を返す
			return value;
		}
		//対象のJavaBeanがMapでない場合
		else {
			//JavaBeanから引数のプロパティ名と名前が同じと見なせるプロパティの名前を取得
			String propertyName = getSamePropertyName(beanArg, nameArg);

			//プロパティが存在しない場合
			if (propertyName == null) {
				//例外を投げる
				throw new NoSuchMethodException("JavaBean ["
						+ beanArg.getClass().getName() + "] には「" + nameArg
						+ "」によく似た名前のプロパティが見つかりませんでした");
			}

			try {
				//プロパティ名に対応するフィールドを取得
				Field field = beanArg.getClass().getField(propertyName);

				//フィールドの値を返す
				return field.get(beanArg);
			}
			//フィールドが存在しない場合
			catch (NoSuchFieldException e) {
				//取得した正式なプロパティの名前を使って、プロパティの値を取得する
				return PropertyUtils.getProperty(beanArg, propertyName);
			}

		}
	}

	/**
	 * JavaBeanの指定されたプロパティの値を文字列として取得します。<br>
	 * 同じ名前と見なされるプロパティを探し出してから値を取得します。<br>
	 * 
	 * @param beanArg 対象のJavaBean
	 * @param nameArg プロパティ名
	 * @return 対象のJavaBeanの名前が同じと見なせるプロパティの値の文字列表現
	 * @throws NoSuchMethodException 同じ名前と見なせるプロパティが存在しない場合
	 * @throws Exception 例外
	 */
	public static String getPropertyAsString(Object beanArg, String nameArg)
			throws NoSuchMethodException, Exception {

		//JavaBeanの指定されたプロパティの値を取得
		Object value = getProperty(beanArg, nameArg);

		//取得した値がnullではない場合
		if (value != null) {
			//文字列に変換して返す
			return value.toString();
		}
		//取得した値がnullの場合
		else {
			//nullを返す
			return null;
		}
	}

	/**
	 * コピー元のJavaBeanからコピー先のJavaBeanに指定された指定されたプロパティの値だけコピーします。<br>
	 * オリジナルのものとは違って、同じ名前と見なされるプロパティを探し出してから値を設定します。<br>
	 * コピー元にないプロパティ名を指定した場合は例外を投げます。<br>
	 * コピー元にはあって、コピー先には存在しないプロパティは単に無視します。<br>
	 * GetterのみでSetterが存在しないプロパティは無視します。<br>
	 * コピー元とコピー先のプロパティの値の型が多少違っても自動的に補正します。<br>
	 * 
	 * @param destBeanArg コピー先のJavaBean
	 * @param srcBeanArg コピー元のJavaBean
	 * @param nameArg コピー対象のプロパティ名
	 * @throws NoSuchMethodException コピー元のJavaBeanに同じ名前と見なせるプロパティが存在しない場合
	 * @throws Exception 例外
	 */
	public static void copyProperty(Object destBeanArg, Object srcBeanArg,
			String nameArg) throws NoSuchMethodException, Exception {

		//コピー元のJavaBeanから引数のプロパティ名と名前が同じと見なせるプロパティの名前を取得
		String srcPropertyName = getSamePropertyName(srcBeanArg, nameArg);

		//コピー元のJavaBeanにプロパティが存在しない場合
		if (srcPropertyName == null) {
			//例外を投げる
			throw new NoSuchMethodException("コピー元のJavaBean ["
					+ srcBeanArg.getClass().getName() + "] には「" + nameArg
					+ "」によく似た名前のプロパティが見つかりませんでした");
		}

		//コピー先のJavaBeanからコピー元のプロパティ名と名前が同じと見なせるプロパティの名前を取得
		String destPropertyName = getSamePropertyName(destBeanArg, srcPropertyName);

		//コピー先のJavaBeanにもプロパティが存在する場合
		if (destPropertyName != null) {
			//取得した正式なプロパティの名前を使って、コピー元のJavaBeanからプロパティの値を取得する
			Object srcValue = PropertyUtils.getProperty(srcBeanArg, srcPropertyName);

			//デバッグログが有効な場合
			if (log.isDebugEnabled()) {
				//デバッグログ出力
				log.debug("【JavaBeanのコピー】コピー元:" + srcPropertyName + ", コピー先:"
						+ destPropertyName + ", 値:" + srcValue);
			}

			try {
				//取得した正式なプロパティの名前を使って、プロパティに値を設定する
				PropertyUtils.setProperty(destBeanArg, destPropertyName, srcValue);
			}
			//Setterが見つからなかった場合
			catch (NoSuchMethodException e) {
				//デバッグログが有効な場合
				if (log.isDebugEnabled()) {
					//デバッグログ出力
					log.debug(destPropertyName + "のSetterが見つからなかったので無視します");
				}
			}
			//型違いのため値を設定できなかった場合
			catch (IllegalArgumentException e) {
				//PropertyUtilsではなくBeanUtilsのメソッドを使ってもう一度試してみる
				BeanUtils.setProperty(destBeanArg, destPropertyName, srcValue);
			}
		}
		//コピー先のJavaBeanにプロパティが存在しない場合
		else {
			//デバッグログが有効な場合
			if (log.isDebugEnabled()) {
				//デバッグログ出力
				log.debug("【JavaBeanのコピー】コピー先のプロパティが見つかりませんでした。 コピー元:"
						+ srcPropertyName);
			}
		}

	}

	/**
	 * コピー元のJavaBeanからコピー先のJavaBeanに指定されたプロパティの値だけコピーします。<br>
	 * オリジナルのものとは違って、同じ名前と見なされるプロパティを探し出してから値を設定します。<br>
	 * コピー元にないプロパティ名を指定した場合は例外を投げます。<br>
	 * コピー元にはあって、コピー先には存在しないプロパティは単に無視します。<br>
	 * GetterのみでSetterが存在しないプロパティは無視します。<br>
	 * コピー元とコピー先のプロパティの値の型が多少違っても自動的に補正します。<br>
	 * 
	 * @param destBeanArg コピー先のJavaBean
	 * @param srcBeanArg コピー元のJavaBean
	 * @param namesArg コピー対象のプロパティ名の配列
	 * @throws NoSuchMethodException コピー元のJavaBeanに同じ名前と見なせるプロパティが存在しない場合
	 * @throws Exception 例外
	 */
	public static void copyProperties(Object destBeanArg, Object srcBeanArg,
			String[] namesArg) throws NoSuchMethodException, Exception {

		//コピー対象のプロパティ名の配列の全ての要素に対して処理を行う
		for (int i = 0; i < namesArg.length; i++) {
			//1つのプロパティだけをコピーするメソッドを呼び出す
			copyProperty(destBeanArg, srcBeanArg, namesArg[i]);
		}
	}

	/**
	 * コピー元のJavaBeanからコピー先のJavaBeanに全てのプロパティの値だけコピーします。<br>
	 * オリジナルのものとは違って、同じ名前と見なされるプロパティを探し出してから値を設定します。<br>
	 * コピー元にはあって、コピー先には存在しないプロパティは単に無視します。<br>
	 * GetterのみでSetterが存在しないプロパティは無視します。<br>
	 * コピー元とコピー先のプロパティの値の型が多少違っても自動的に補正します。<br>
	 * 
	 * @param destBeanArg コピー先のJavaBean
	 * @param srcBeanArg コピー元のJavaBean
	 * @throws Exception 例外
	 */
	public static void copyAllProperties(Object destBeanArg, Object srcBeanArg)
			throws Exception {

		//コピー元のJavaBeanの全てのプロパティ名を取得して、実際に処理を行うメソッドを呼び出す
		copyProperties(destBeanArg, srcBeanArg, getPropertyNames(srcBeanArg));
	}

	/**
	 * JavaBeanに引数のプロパティ名と名前が同じと見なせるプロパティが存在するかチェックし、
	 * 存在する場合はそのプロパティ名を返します。<br>
	 * 名前が同じと見なせるプロパティが存在しない場合はnullを返します。<br>
	 * 
	 * @param beanArg 対象のJavaBean
	 * @param nameArg プロパティ名
	 * @return 対象のJavaBeanの名前が同じと見なせるプロパティの名前
	 * @throws Exception 例外
	 */
	public static String getSamePropertyName(Object beanArg, String nameArg)
			throws Exception {
		//JavaBeanの全てのプロパティ名が入ったSetを取得
		Set set = getPropertyNamesBySet(beanArg);

		//引数のプロパティ名と完全に一致する要素が見つかった場合
		if (set.contains(nameArg)) {
			//引数のプロパティ名をそのまま返す
			return nameArg;
		}

		//プロパティのSetの全ての要素に対して処理を行う
		for (Iterator ite = set.iterator(); ite.hasNext();) {

			//現在の要素の値(JavaBeanのプロパティ名)を取得
			String value = (String) ite.next();

			//現在の要素の値と引数のプロパティ名が同じ名前と見なせる場合
			if (isSameName(value, nameArg)) {
				//現在のキーの値を返す
				return value;
			}
		}

		//最後まで見つからなかったのでnullを返す
		return null;
	}

	/**
	 * 2つの文字列が同じ名前と見なせるかどうかを返します。<br>
	 * (内部処理用のメソッドですが、他のクラスからも使用できるようにあえてpublicにしています。)<br>
	 * 
	 * @param str1Arg 比較対象の文字列1
	 * @param str2Arg 比較対象の文字列2
	 * @return true=同じと見なせる, false=同じと見なせない
	 */
	public static boolean isSameName(String str1Arg, String str2Arg) {
		//==============================================================
		//nullチェック

		//両方ともnullの場合
		if ((str1Arg == null) && (str2Arg == null)) {
			//同じと見なせるのでtrueを返す
			return true;
		}

		//どちらか一方がnullの場合
		if ((str1Arg == null) || (str2Arg == null)) {
			//同じでないのでfalseを返す
			return false;
		}


		//==============================================================
		//普通の比較
		//(ただし、大文字・小文字は区別しない)
		if (str1Arg.equalsIgnoreCase(str2Arg)) {
			//同じと見なせるのでtrueを返す
			return true;
		}


		//==============================================================
		//ハイフンとアンダーバーを除去して、さらに大文字・小文字を区別しないで比較

		//対象文字列1からハイフンとアンダーバーを除去
		String tempStr1 = str1Arg.replaceAll("-", "").replaceAll("_", "");

		//対象文字列2からハイフンとアンダーバーを除去
		String tempStr2 = str2Arg.replaceAll("-", "").replaceAll("_", "");

		//大文字と小文字を区別しないで比較
		if (tempStr1.equalsIgnoreCase(tempStr2)) {
			//同じと見なせるのでtrueを返す
			return true;
		}


		//最後まで一致する候補が見つからなかったのでfalseを返す
		return false;
	}


	/**
	 * JavaBeanの全てのプロパティ名が入った文字列配列を取得します。<br>
	 * ただし、対象となるプロパティはpublicなGetterが定義されているもののみとします。<br>
	 * 
	 * @param beanArg 対象のJavaBean
	 * @return 全てのプロパティ名が入った文字列配列
	 * @throws Exception 例外
	 */
	public static String[] getPropertyNames(Object beanArg) throws Exception {

		//結果をSetで取得するメソッドを呼び出す
		Set<String> set = getPropertyNamesBySet(beanArg);

		//Setを文字列配列に変換して返す
		return set.toArray(new String[0]);
	}

	/**
	 * JavaBeanの全てのプロパティ名が入ったSetを取得します。<br>
	 * ただし、対象となるプロパティはpublicなGetterが定義されているもののみとします。<br>
	 * (内部処理用のメソッドですが、他のクラスからも使用できるようにあえてpublicにしています。)<br>
	 * 
	 * @param beanArg 対象のJavaBean
	 * @return 全てのプロパティ名が入ったSet
	 * @throws Exception 例外
	 */
	public static Set<String> getPropertyNamesBySet(Object beanArg)
			throws Exception {

		//結果を格納するためのSet
		Set<String> set = new HashSet<String>();

		//対象のJavaBeanがMapの場合
		if (beanArg instanceof Map) {
			//対象のJavaBeanをMapにキャスト
			Map map = (Map) beanArg;

			//Mapのキーセットを取得する
			Set keySet = map.keySet();

			//Mapのキーセットを一応全て文字列に変換して結果を格納するためのSetにつめる
			for (Object keyObj : keySet) {
				set.add(keyObj.toString());
			}
		}
		//対象のJavaBeanがMapでない場合
		else {
			//すべてのpublicなフィールドに対して処理を行う
			for (Field field : beanArg.getClass().getFields()) {
				//フィールド名をSetに追加する
				set.add(field.getName());
			}

			//すべてのpublicなメソッドに対して処理を行う
			for (Method method : beanArg.getClass().getMethods()) {
				//メソッド名を取得
				String methodName = method.getName();

				//メソッド名が「get」から始まり、かつ4文字以上ある場合
				if (methodName.startsWith("get") && (methodName.length() >= 4)) {

					//getの次の文字を小文字にして取得
					String propertyName = methodName.substring(3, 4).toLowerCase();

					//メソッド名が5文字以上ある場合
					if (methodName.length() >= 5) {
						//getの次の次の文字以降をそのまま取得
						propertyName += methodName.substring(4);
					}

					//取得したプロパティ名をSetに追加する
					set.add(propertyName);
				}

			}

			//「class」も結果に含まれているが、これはプロパティではないので除外する
			set.remove("class");
		}

		//作成したSetを返す
		return set;
	}

	/**
	 * JavaBeanの内容を読みやすい形式の文字列に変換して返します。<br>
	 * デバッグ時のログ出力などに使用して下さい。<br>
	 * 
	 * @param beanArg 対象のJavaBean
	 * @return JavaBeanの内容の読みやすい形式の文字列
	 * @throws Exception 例外
	 */
	public static String beanToString(Object beanArg) throws Exception {
		//作業用StringBuilder
		StringBuilder sb = new StringBuilder();

		//==========================================================
		//ヘッダ部分

		//クラス名@ハッシュコード値 + 改行
		sb.append(beanArg.getClass().getName()).append("@").append(beanArg.hashCode()).append("\n");

		//{ + 改行
		sb.append("{\n");


		//==========================================================
		//プロパティの名前と値

		//JavaBeanの全てのプロパティ名が入ったSetを取得
		Set<String> set = getPropertyNamesBySet(beanArg);

		//Setを見やすいようにソートする
		Set<String> sortedSet = new TreeSet<String>(set);

		//インデックス
		int index = 0;

		//件数の桁数を取得
		int length = String.valueOf(set.size()).length();

		//ソートしたSetの全ての要素に対して処理を行う
		for (Iterator ite = sortedSet.iterator(); ite.hasNext();) {

			//現在のSetの値(Beanのプロパティ名)を取得
			String name = (String) ite.next();

			//インデックスを進める
			index++;

			//最初の空白
			sb.append("    ");

			//インデックス(桁数に応じて先頭をゼロ詰めする)
			sb.append("[").append(StringUtil.zeroPadding(index, length)).append("]");

			//プロパティ名 = '値'
			sb.append(name).append(" = ");

			try {
				//プロパティの値を取得
				Object value = getProperty(beanArg, name);

				//値が文字列でない場合
				if (!(value instanceof String)) {
					//値をデバッグに適した文字列に変換して出力する
					sb.append(StringUtil.convertDebugString(value));
				}
				//値が文字列の場合
				else {
					//値を「'」で囲む
					sb.append(StringUtil.quoting((String) value));
				}
			}
			//プロパティの値を取得する際に例外が発生した場合
			catch (Exception e) {
				//警告のメッセージを出力する
				sb.append("*** 警告:このプロパティの値を取得する際に例外が発生しました ***");
			}

			//改行
			sb.append("\n");

		}
		//==============================================================


		//} + 改行
		sb.append("}\n");

		//結果を文字列に変換して返す
		return sb.toString();
	}
}

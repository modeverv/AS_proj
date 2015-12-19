package jp.fores.common.util;

import java.util.Random;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.oro.text.perl.Perl5Util;


/**
 * 乱数操作用ユーティリティクラス。<br>
 * <br>
 * java.util.Random クラスを使った乱数操作用のメソッドを提供します。<br>
 * テストデータを作成するときなどに活用して下さい。<br>
 * <br>
 *
 * @see DateUtil
 */
public final class RandomUtil {

	//==========================================================
	//定数

	/**
	 * ログ出力用
	 */
	private static final Log log = LogFactory.getLog(RandomUtil.class);

	/**
	 * 乱数操作クラスのインスタンス
	 * (定数にして同じインスタンスを共有しています。)
	 */
	private static final Random random = new Random();

	/**
	 * Perl5互換正規表現ユーティリティクラスのインスタンス
	 * (matchのみを使用するので、定数にして同じインスタンスを共有しています。)
	 */
	private static final Perl5Util perl = new Perl5Util();

	/**
	 * パスワードに使用される文字からなる文字列
	 * (全ての半角英数字と記号)
	 */
	private static final String PASSWORD_STR = "1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ!\"#$%&'()*+,-./:;<=>?@[\\]^_`{|}~";


	//==========================================================
	//コンストラクタ

	/**
	 * コンストラクタです。<br>
	 * (クラスメソッドのみのユーティリティークラスなので、privateにしてインスタンスを作成できないようにしています。)<br>
	 */
	private RandomUtil() {
		//基底クラスのコンストラクタの呼び出し
		super();
	}


	//==============================================================
	//クラスメソッド

	/**
	 * 0 ～ n-1 までの間の乱数を返します。<br>
	 * (単純に、java.util.Random.nextInt(int n)を呼び出しているだけです。)
	 *
	 * @param n 発生させたい乱数の上限値
	 * @return 0 ～ n-1 までの間の乱数
	 * @exception IllegalArgumentException 正の値以外を指定した場合
	 */
	public static int nextInt(int n) throws IllegalArgumentException {
		//RandomのnextInt()を呼び出して、結果をそのまま返す
		return random.nextInt(n);
	}

	/**
	 * 指定したオブジェクト配列の中の１つの要素をランダムに抽出します。<br>
	 *
	 * @param objArrayArg オブジェクト配列
	 * @return オブジェクト配列の中の１つの要素
	 */
	public static Object getRandomObject(Object[] objArrayArg) {
		//配列の要素数に応じた乱数を発生させて、それに対応する要素を返す
		return objArrayArg[nextInt(objArrayArg.length)];
	}

	/**
	 * 指定した文字列配列の中の１つの要素をランダムに抽出します。<br>
	 *
	 * @param strArrayArg 文字列配列
	 * @return 文字列配列の中の１つの要素
	 */
	public static String getRandomString(String[] strArrayArg) {
		//オブジェクトの配列を引数にとるメソッドを呼び出して、結果を文字列に変換して返す
		return (String) getRandomObject(strArrayArg);
	}

	/**
	 * 開始年と終了年の間のランダムな日付を持つ、日付操作用オブジェクトを生成します。<br>
	 * 月には1～12、日には1～28が設定されます。(29日から31日は設定されません。)<br>
	 *
	 * @param startYearArg 開始年
	 * @param endYearArg 終了年
	 * @return 日付操作用オブジェクト
	 * @exception IllegalArgumentException 正の値以外を指定した場合、開始年の値が終了年の値よりも大きい場合
	 */
	public static DateUtil getRandomDate(int startYearArg, int endYearArg)
			throws IllegalArgumentException {
		//正の値以外を指定した場合
		if ((startYearArg <= 0) || (endYearArg <= 0)) {
			//例外を投げる
			throw new IllegalArgumentException("正の値以外は指定できません");
		}

		//開始年の値が終了年の値よりも大きい場合
		if (startYearArg > endYearArg) {
			//例外を投げる
			throw new IllegalArgumentException("開始年の値が終了年の値よりも大きいです");
		}

		//終了年 - 開始年までの値の乱数を生成
		int yearRandom = nextInt((endYearArg + 1) - startYearArg);

		//年月日で日付操作用オブジェクトを生成(月=1～12, 日=1～28)
		return new DateUtil(startYearArg + yearRandom,
				nextInt(12) + 1,
				nextInt(28) + 1);
	}

	/**
	 * n分の1の確率でtrueを返します。<br>
	 *
	 * @param n 確率
	 * @return n分の1の確率でtrue, n分のn-1の確率でfalse
	 * @exception IllegalArgumentException 正の値以外を指定した場合
	 */
	public static boolean getRandomBoolean(int n)
			throws IllegalArgumentException {
		//0 ～ n-1 までの間の乱数を発生して、結果が0の場合のみtrueを返す
		return (nextInt(n) == 0);
	}

	/**
	 * nパーセントの確率でtrueを返します。<br>
	 *
	 * @param n 確率(パーセント)
	 * @return nパーセントの確率でtrue, 100-nパーセントの確率でfalse
	 * @exception IllegalArgumentException 0～100以外の値を指定した場合
	 */
	public static boolean getRandomBooleanPercent(int n)
			throws IllegalArgumentException {
		//0～100以外の値を指定した場合
		if ((n < 0) || (n > 100)) {
			//例外を投げる
			throw new IllegalArgumentException("0～100以外の値は指定できません");
		}

		//指定した確率が0～99までの乱数よりも大きい場合
		if (n > nextInt(100)) {
			return true;
		}
		//それ以外の場合
		else {
			return false;
		}
	}

	/**
	 * パスワード用に、指定した長さの半角英数字(大文字・小文字は別扱い)及び記号からなるランダムな文字列を作成します。<br>
	 * アルファベットと数字が混在したパスワードができるまで内部で処理を繰り返します。<br>
	 *
	 * @param lengthArg 文字列の長さ
	 * @return 指定した長さの半角英数字及び記号からなるランダムな文字列
	 * @exception IllegalArgumentException 正の値以外を指定した場合
	 */
	public static String makePassword(int lengthArg)
			throws IllegalArgumentException {
		//正の値以外を指定した場合
		if (lengthArg <= 0) {
			//例外を投げる
			throw new IllegalArgumentException("正の値以外は指定できません");
		}

		//アルファベットと数字が混在したパスワードができるまでループをまわす
		while (true) {
			//作業用StringBuilder
			StringBuilder sb = new StringBuilder();

			//指定された文字列の長さ分だけループをまわす
			for (int i = 0; i < lengthArg; i++) {
				//パスワードに使用される文字からなる文字列(半角英数字)からランダムで1文字抜き出してStringBuilderに追加する
				sb.append(PASSWORD_STR.charAt(nextInt(PASSWORD_STR.length())));
			}

			//作成したパスワードを文字列に変換する
			String password = sb.toString();

			//パスワードが2文字以上の場合
			//(このチェックは、2文字以上ないとアルファベットと数字を混在させようがないため行っている)
			if (password.length() >= 2) {
				//作成したパスワードにアルファベットが1つ以上と、半角数字が1つ以上含まれていない場合
				if (!perl.match("/[A-Za-z]+/", password)
						|| !perl.match("/\\d+/", password)) {

					//デバッグログが有効な場合
					if (log.isDebugEnabled()) {
						//デバッグログ出力
						log.debug("作成したパスワードはアルファベットと数字が混在していないので、作成し直します:"
								+ password);
					}

					//パスワードを作成し直す
					continue;
				}
			}

			//作成したパスワードを返す
			return password;
		}
	}

}

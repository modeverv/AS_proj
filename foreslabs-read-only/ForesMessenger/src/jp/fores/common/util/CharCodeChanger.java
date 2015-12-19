package jp.fores.common.util;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;


/**
 * 文字コード変換用ユーティリティークラス。<br>
 * 全角→半角変換や、ひらがな→カタカナ変換などのメソッドを実装しています。<br>
 */
public final class CharCodeChanger {

	//==========================================================
	//定数

	/**
	 * ログ出力用
	 */
	private static final Log log = LogFactory.getLog(CharCodeChanger.class);

	/**
	 * カナ変換用のテーブル<br>
	 * (#は該当する文字が存在しないことを表す)<br>
	 */
	private static final String KANA_TABLE[] = { " 　##", "｡。##", "｢「##",
			"｣」##", "･・##", "､、##", "ｦヲ##", "ｧァ##", "ｨィ##", "ｩゥ##", "ｪェ##",
			"ｫォ##", "ｬャ##", "ｭュ##", "ｮョ##", "ｯッ##", "ｰー##", "ｱア##", "ｲイ##",
			"ｳウヴ#", "ｴエ##", "ｵオ##", "ｶカガ#", "ｷキギ#", "ｸクグ#", "ｹケゲ#", "ｺコゴ#",
			"ｻサザ#", "ｼシジ#", "ｽスズ#", "ｾセゼ#", "ｿソゾ#", "ﾀタダ#", "ﾁチヂ#", "ﾂツヅ#",
			"ﾃテデ#", "ﾄトド#", "ﾅナ##", "ﾆニ##", "ﾇヌ##", "ﾈネ##", "ﾉノ##", "ﾊハバパ",
			"ﾋヒビピ", "ﾌフブプ", "ﾍヘベペ", "ﾎホボポ", "ﾏマ##", "ﾐミ##", "ﾑム##", "ﾒメ##",
			"ﾓモ##", "ﾔヤ##", "ﾕユ##", "ﾖヨ##", "ﾗラ##", "ﾘリ##", "ﾙル##", "ﾚレ##",
			"ﾛロ##", "ﾜワ##", "ﾝン##", "ﾞ゛##", "ﾟ゜##" };


	//==========================================================
	//メソッド

	//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
	//コンストラクタ

	/**
	 * コンストラクタです。<br>
	 * (クラスメソッドのみのユーティリティークラスなので、privateにしてインスタンスを作成できないようにしています。)<br>
	 */
	private CharCodeChanger() {
		//基底クラスのコンストラクタの呼び出し
		super();
	}


	//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
	//クラスメソッド

	/**
	 * 半角カナを全角カナに変換します。<br>
	 * 濁点・半濁点は可能なら１文字にまとめます。<br>
	 * 例:「ﾊﾞ」→「バ」(「ハ゛」とならない)<br>
	 *
	 * @param strArg 半角カナの含まれた文字列
	 * @return 半角カナが全角カナに変換された文字列
	 */
	public static String hanToZenKana(String strArg) {
		//半角カナが含まれていない場合
		if (ValidationChecker.isHalfKana(strArg)) {
			//何もしないで引数の文字列をそのまま返す
			return strArg;
		}

		//作業用StringBuilder
		StringBuilder sb = new StringBuilder();

		//元の文字列の長さ
		int length = strArg.length();

		//前の文字の文字種
		int prevBase = 0;


		//１文字ずつ変換する
		for (int i = 0; i < length; i++) {
			//現在の文字の文字コードを取得
			char code = strArg.charAt(i);

			//半角カナでない場合
			if (ValidationChecker.isHalfKana(String.valueOf(code))) {
				//そのまま追加する
				sb.append(code);

				//前の文字の文字種をリセットする
				prevBase = 0;
			}
			//半角カナの場合
			else {
				//現在の文字が濁点で、前の文字が濁点の付く可能性のある文字の場合
				if ((code == 'ﾞ') && (KANA_TABLE[prevBase].charAt(2) != '#')) {
					//前の文字を削除する
					sb.deleteCharAt(sb.length() - 1);

					//前の文字の文字種の濁点つき全角カナを追加する
					sb.append(KANA_TABLE[prevBase].charAt(2));

					//前の文字の文字種をリセットする
					prevBase = 0;

					//次の文字の評価に進む
					continue;
				}
				//現在の文字が半濁点で、前の文字が半濁点の付く可能性のある文字の場合
				else if ((code == 'ﾟ')
						&& (KANA_TABLE[prevBase].charAt(3) != '#')) {
					//前の文字を削除する
					sb.deleteCharAt(sb.length() - 1);

					//前の文字の文字種の半濁点つき全角カナを追加する
					sb.append(KANA_TABLE[prevBase].charAt(3));

					//前の文字の文字種をリセットする
					prevBase = 0;

					//次の文字の評価に進む
					continue;
				}

				//全ての文字種に対してループをまわす
				for (int j = 0; j < KANA_TABLE.length; j++) {
					//一致する文字が見つかった場合
					if (code == KANA_TABLE[j].charAt(0)) {
						//見つかった文字の文字種の全角カナを追加する
						sb.append(KANA_TABLE[j].charAt(1));

						//前の文字の文字種として見つかった文字の文字種を設定する
						prevBase = j;

						//ループを抜ける
						break;
					}
				}
			}
		}

		//結果を文字列に変換して返す
		return sb.toString();
	}

	/**
	 * 半角英数記号を全角に変換します。<br>
	 * 利便性を向上させるため、以下の文字は特殊な変換をします。<br>
	 * <ul>
	 *  <li>"(0x22) → ”(0x201d)</li>
	 *  <li>'(0x27) → ’(0x2019)</li>
	 *  <li>半角スペース(0x20) → 全角スペース(0x3000)</li>
	 *  <li>\(0x5c) → ￥(0xffe5)</li>
	 * </ul><br>
	 *
	 * @param strArg 半角英数記号を含む文字列
	 * @return 全角英数記号が全角に変換された文字列
	 */
	public static String hanToZenAscii(String strArg) {
		//作業用StringBuilder
		StringBuilder sb = new StringBuilder();

		//作業用文字列に引数の文字列を設定
		String tempStr = strArg;

		//==========================================================
		//特殊な文字を先に変換
		//(1文字だけの変換なのでStringUtil.replace()ではなくString.replace()を使う)

		//「"」→「”」
		tempStr = tempStr.replace('"', '”');

		//「'」→「’」
		tempStr = tempStr.replace('\'', '’');

		//「\」→「￥」
		tempStr = tempStr.replace('\\', '￥');

		//半角スペース → 全角スペース
		tempStr = tempStr.replace(' ', '　');


		//==========================================================
		//文字コードを元にした変換

		//文字列の長さ
		int length = tempStr.length();

		//１文字ずつ変換する
		for (int i = 0; i < length; i++) {
			//現在の文字の文字コードを取得
			char code = tempStr.charAt(i);

			//半角英数記号の場合
			if ((code >= 0x21) && (code <= 0x7e)) {
				//全角に変換して追加する
				sb.append((char) (code + 0xfee0));
			}
			//半角英数記号以外の場合
			else {
				//そのまま追加する
				sb.append(code);
			}
		}

		//結果を文字列に変換して返す
		return sb.toString();
	}

	/**
	 * 半角文字を可能なかぎり全角に変換します。<br>
	 *
	 * @param strArg 半角文字を含む文字列
	 * @return 半角文字が全角に変換された文字列
	 */
	public static String hanToZen(String strArg) {
		//半角英数記号→全角英数記号、半角カナ → 全角カナ変換を連続して行って結果をそのまま返す
		return hanToZenKana(hanToZenAscii(strArg));
	}

	/**
	 * 全角英数記号を半角に変換します。<br>
	 * 利便性を向上させるため、以下の文字は特殊な変換をします。<br>
	 * <ul>
	 *  <li>”(0x201d) → "(0x22)</li>
	 *  <li>’(0x2019) → '(0x27)</li>
	 *  <li>￥(0xffe5) → \(0x5c)</li>
	 *  <li>全角スペース(0x3000) → 半角スペース(0x20)</li>
	 * </ul><br>
	 *
	 * @param strArg 全角英数記号を含む文字列
	 * @return 全角英数記号が半角に変換された文字列
	 */
	public static String zenToHanAscii(String strArg) {
		//作業用StringBuilder
		StringBuilder sb = new StringBuilder();

		//作業用文字列に引数の文字列を設定
		String tempStr = strArg;

		//==========================================================
		//特殊な文字を先に変換
		//(1文字だけの変換なのでStringUtil.replace()ではなくString.replace()を使う)

		//「”」→「"」
		tempStr = tempStr.replace('”', '"');

		//「’」→「'」
		tempStr = tempStr.replace('’', '\'');

		//「￥」→「\」
		tempStr = tempStr.replace('￥', '\\');

		//全角スペース → 半角スペース
		tempStr = tempStr.replace('　', ' ');


		//==========================================================
		//文字コードを元にした変換

		//文字列の長さ
		int length = tempStr.length();

		//１文字ずつ変換する
		for (int i = 0; i < length; i++) {
			//現在の文字の文字コードを取得
			char code = tempStr.charAt(i);

			//全角英数記号の場合
			if ((code >= 0xff01) && (code <= 0xff5e)) {
				//半角に変換して追加する
				sb.append((char) (code - 0xfee0));
			}
			//全角英数記号以外の場合
			else {
				//そのまま追加する
				sb.append(code);
			}
		}

		//結果を文字列に変換して返す
		return sb.toString();
	}

	/**
	 * 全角カナを半角カナに変換します。<br>
	 * 濁点・半濁点が含まれる場合は、２文字に展開されます。<br>
	 * 例:「バ」→「ﾊﾞ」<br>
	 *
	 * @param strArg 全角カナを含む文字列
	 * @return 全角カナが半角カナに変換された文字列
	 */
	public static String zenToHanKana(String strArg) {
		//作業用StringBuilder
		StringBuilder sb = new StringBuilder();

		//元の文字列の長さ
		int length = strArg.length();

		//１文字ずつ変換する
		for (int i = 0; i < length; i++) {
			//現在の文字の文字コードを取得
			char code = strArg.charAt(i);

			//ベースとなる文字種
			int base = -1;

			//タイプ(1=全角カナ, 2=濁点つき全角カナ, 3=半濁点つき全角カナ)
			int type = -1;

			//「#」以外の文字の場合(「#」はメタ文字なので特別扱い)
			if (code != '#') {
				//タイプを調べるためにループをまわす
				for (int t = 1; t <= 3; t++) {
					//全ての文字種に対してループをまわす
					for (int j = 0; j < KANA_TABLE.length; j++) {
						//一致する文字が見つかった場合
						if (code == KANA_TABLE[j].charAt(t)) {
							//ベースとなる文字種を設定
							base = j;

							//タイプを設定
							type = t;

							//ループを抜ける
							break;
						}
					}

					//一致する文字がすでに見つかっている場合
					if (type != -1) {
						//ループを抜ける
						break;
					}
				}
			}

			//タイプに応じて処理を分岐する
			switch (type) {
			//全角カナの場合
			case 1:
				//半角カナを追加する
				sb.append(KANA_TABLE[base].charAt(0));
				break;

			//濁点つき全角カナの場合
			case 2:
				//半角カナ + 「ﾞ」(半角濁点)を追加する
				sb.append(KANA_TABLE[base].charAt(0)).append('ﾞ');
				break;

			//半濁点つき全角カナの場合
			case 3:
				//半角カナ + 「ﾟ」(半角半濁点)を追加する
				sb.append(KANA_TABLE[base].charAt(0)).append('ﾟ');
				break;

			//それ以外の場合
			default:
				//そのまま追加する
				sb.append(code);
				break;
			}
		}

		//結果を文字列に変換して返す
		return sb.toString();
	}

	/**
	 * 全角文字を可能なかぎり半角に変換します。<br>
	 *
	 * @param strArg 全角文字を含む文字列
	 * @return 全角文字が半角に変換された文字列
	 */
	public static String zenToHan(String strArg) {
		//全角英数記号→半角英数記号、全角カナ → 半角カナ変換を連続して行って結果をそのまま返す
		return zenToHanKana(zenToHanAscii(strArg));
	}

	/**
	 * ひらがなを全角カタカナに変換します。<br>
	 *
	 * @param strArg ひらがなを含む文字列
	 * @return ひらがなが全角カタカナに変換された文字列
	 */
	public static String hiraToKata(String strArg) {
		//作業用StringBuilder
		StringBuilder sb = new StringBuilder();

		//元の文字列の長さ
		int length = strArg.length();

		//１文字ずつ変換する
		for (int i = 0; i < length; i++) {
			//現在の文字の文字コードを取得
			char code = strArg.charAt(i);

			//ひらがなの場合
			if ((code >= 0x3041) && (code <= 0x3093)) {
				//全角カタカナに変換して追加する
				sb.append((char) (code + 0x60));
			}
			//ひらがな以外の場合
			else {
				//そのまま追加する
				sb.append(code);
			}
		}

		//結果を文字列に変換して返す
		return sb.toString();
	}

	/**
	 * 全角カタカナをひらがなに変換します。<br>
	 * ただし、次の文字は対応する文字がひらがなに存在しないため変換できません。
	 * <ul>
	 *  <li>ヴ(0x30f4)</li>
	 *  <li>ヵ(0x30f5)</li>
	 *  <li>ヶ(0x30f6)</li>
	 * </ul><br>
	 *
	 * @param strArg 全角カタカナを含む文字列
	 * @return 全角カタカナがひらがなに変換された文字列
	 */
	public static String kataToHira(String strArg) {
		//作業用StringBuilder
		StringBuilder sb = new StringBuilder();

		//元の文字列の長さ
		int length = strArg.length();

		//１文字ずつ変換する
		for (int i = 0; i < length; i++) {
			//現在の文字の文字コードを取得
			char code = strArg.charAt(i);

			//全角カタカナの場合
			if ((code >= 0x30a1) && (code <= 0x30f3)) {
				//ひらがなに変換して追加する
				sb.append((char) (code - 0x60));
			}
			//全角カタカナ以外の場合
			else {
				//そのまま追加する
				sb.append(code);
			}
		}

		//結果を文字列に変換して返す
		return sb.toString();
	}

}

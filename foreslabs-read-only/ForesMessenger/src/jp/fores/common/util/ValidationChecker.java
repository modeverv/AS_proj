package jp.fores.common.util;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.oro.text.perl.Perl5Util;


/**
 * 入力チェック用ユーティリティクラス。<br>
 */
public final class ValidationChecker {

	//==========================================================
	//定数

	/**
	 * ログ出力用
	 */
	private static final Log log = LogFactory.getLog(StringUtil.class);

	/**
	 * Perl5互換正規表現ユーティリティクラスのインスタンス
	 * (matchのみを使用するので、定数にして同じインスタンスを共有しています。)
	 */
	private static final Perl5Util perl = new Perl5Util();

	/**
	 * 作業用のSimpleDateFormat
	 */
	private static final SimpleDateFormat sdf;

	/**
	 * イニシャライザです。<br>
	 * 作業用のSimpleDateFormatを初期化します。<br>
	 */
	static {
		//フォーマットに「年/月/日」を設定する
		sdf = new SimpleDateFormat("yyyy/MM/dd");

		//チェックを厳密に行う
		sdf.setLenient(false);
	}


	//==========================================================
	//メソッド

	//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
	//コンストラクタ

	/**
	 * コンストラクタです。<br>
	 * (クラスメソッドのみのユーティリティークラスなので、privateにしてインスタンスを作成できないようにしています。)<br>
	 */
	private ValidationChecker() {
		//基底クラスのコンストラクタの呼び出し
		super();
	}


	//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
	//クラスメソッド

	/**
	 * 日付の順序が正しいかどうか判断します。<br>
	 *
	 * @param startDateArg 開始日付
	 * @param endDateArg 終了日付
	 * @return 1=終了日付の方が後, 0=同じ日付, -1=終了日付の方が前
	 */
	public static int isDateOrder(Date startDateArg, Date endDateArg) {
		//終了日の方のインスタンスのcompareTo()を呼び出して結果をそのまま返す
		return endDateArg.compareTo(startDateArg);
	}

	/**
	 * 空文字列かどうかを判断します。<br>
	 * (注)正常系の場合にtrueを返しますので、空文字列の場合はfalseを返します。<br>
	 * <br>
	 * <strong>＜空文字列の定義＞</strong><br>
	 * 文字数が０、または半角・全角スペース・改行のみからなる文字列、またはnull<br>
	 *
	 * @param strArg チェックする文字列
	 * @return true=空文字列でない, false=空文字列
	 */
	public static boolean isEmpty(String strArg) {
		//nullの場合
		if (strArg == null) {
			//空文字列とみなすのでfalseを返す
			return false;
		}

		//正規表現を使って半角・全角スペース・改行以外の文字が１つでも含まれているかチェックする
		return perl.match("/[^ 　\n\f\r]+/", strArg);
	}

	/**
	 * 文字列の文字数が指定した文字数以下かどうかを判断します。<br>
	 *
	 * @param strArg チェックする文字列
	 * @param lengthArg 文字数
	 * @return true=指定した文字数以内, false=指定した文字数より多い
	 */
	public static boolean isShort(String strArg, int lengthArg) {
		//文字列の文字数が指定した文字数以下の場合
		if (strArg.length() <= lengthArg) {
			return true;
		}
		//文字列の文字数が指定した文字数より多い場合
		else {
			return false;
		}
	}

	/**
	 * 文字列の文字数が指定した文字数以上かどうかを判断します。<br>
	 *
	 * @param strArg チェックする文字列
	 * @param lengthArg 文字数
	 * @return true=指定した文字数以上,false=指定した文字数より少ない
	 */
	public static boolean isLong(String strArg, int lengthArg) {
		//文字列の文字数が指定した文字数以上の場合
		if (strArg.length() >= lengthArg) {
			return true;
		}
		//文字列の文字数が指定した文字数より少ない場合
		else {
			return false;
		}
	}

	/**
	 * 文字列のバイト数が指定したバイト数以下かどうかを判断します。<br>
	 *
	 * @param strArg チェックする文字列
	 * @param lengthArg バイト数
	 * @return true=指定したバイト数以内, false=指定したバイト数より多い
	 */
	public static boolean isByteShort(String strArg, int lengthArg) {
		//文字列のバイト数が指定したバイト数以下の場合
		if (strArg.getBytes().length <= lengthArg) {
			return true;
		}
		//文字列のバイト数が指定したバイト数より多い場合
		else {
			return false;
		}
	}

	/**
	 * 文字列のバイト数が指定したバイト数以上かどうかを判断します。<br>
	 *
	 * @param strArg チェックする文字列
	 * @param lengthArg バイト数
	 * @return true=指定したバイト数以上,false=指定したバイト数より少ない
	 */
	public static boolean isByteLong(String strArg, int lengthArg) {
		//文字列のバイト数が指定したバイト数以上の場合
		if (strArg.getBytes().length >= lengthArg) {
			return true;
		}
		//文字列のバイト数が指定したバイト数より少ない場合
		else {
			return false;
		}
	}

	/**
	 * 半角英字のみで構成されているかどうかを判断します。<br>
	 * <br>
	 * <strong>＜半角英字の定義＞</strong><br>
	 * 文字コードが「A」～「Z」、または「a」～「z」の間の文字<br>
	 *
	 * @param strArg チェックする文字列
	 * @return true=半角英字のみで構成されている, false=半角英字以外が含まれている
	 */
	public static boolean isAlphabet(String strArg) {
		//正規表現を使って最初から最後まで半角英字で構成されているかチェックする
		return perl.match("/^[A-Za-z]*$/", strArg);
	}

	/**
	 * 半角英数字のみで構成されているかどうかを判断します。<br>
	 * <br>
	 * <strong>＜半角英数字の定義＞</strong><br>
	 * 文字コードが「0」～「9」、「A」～「Z」、または「a」～「z」の間の文字<br>
	 *
	 * @param strArg チェックする文字列
	 * @return true=半角英数字のみで構成されている, false=半角英数字以外が含まれている
	 */
	public static boolean isAlphaNumber(String strArg) {
		//正規表現を使って最初から最後まで半角英数字で構成されているかチェックする
		return perl.match("/^[0-9A-Za-z]*$/", strArg);
	}

	/**
	 * 半角数字のみで構成されているかどうかを判断します。<br>
	 * <br>
	 * <strong>＜半角数字の定義＞</strong><br>
	 * 文字コードが「0」～「9」の間の文字<br>
	 *
	 * @param strArg チェックする文字列
	 * @return true=半角数字のみで構成されている, false=半角数字以外が含まれている
	 */
	public static boolean isNumber(String strArg) {
		//正規表現を使って最初から最後まで半角数字で構成されているかチェックする
		return perl.match("/^[0-9]*$/", strArg);
	}

	/**
	 * 指定された最小値と最大値の間の半角数字であるかどうか判断します。<br>
	 *
	 * @param strArg チェックする文字列
	 * @param minArg 最小値
	 * @param maxArg 最大値
	 * @return true=指定された最小値と最大値の間の半角数字, false=指定された最小値と最大値の間の半角数字でない
	 */
	public static boolean isIntegerRange(String strArg, int minArg, int maxArg) {
		//サイズが0でなく、半角数字のみで構成されていてかつ、指定された最小値と最大値の間のとき
		if ((strArg.length() != 0) && isNumber(strArg)
				&& (Integer.parseInt(strArg) >= minArg)
				&& (Integer.parseInt(strArg) <= maxArg)) {
			return true;
		}
		//それ以外の場合
		else {
			return false;
		}
	}

	/**
	 * 全角カナのみで構成されているかどうかを判断します。<br>
	 * (システムの都合上、純粋な全角カナだけでなく濁点や全角英数字なども許容します)<br>
	 * <br>
	 * <strong>＜全角カナの定義＞</strong><br>
	 * 文字コードが「ァ」～「ヶ」の間の文字、<br>
	 * または「　」(全角スペース),「゛」「゜」「・」「ー」「ヽ」「ヾ」のいずれかの文字、<br>
	 * または文字コードが「０」～「９」の間の文字、<br>
	 * または文字コードが「ａ」～「ｚ」の間の文字、<br>
	 * または文字コードが「Ａ」～「Ｚ」の間の文字<br>
	 *
	 * @param strArg チェックする文字列
	 * @return true=全角カナのみで構成されている, false=全角カナ以外が含まれている
	 */
	public static boolean isKana(String strArg) {
		//正規表現を使って全角カナ以外の文字が含まれていないかチェックする
		return !perl.match("/[^ァ-ヶ　゛゜・ーヽヾ０-９ａ-ｚＡ-Ｚ]/", strArg);
	}

	/**
	 * 半角英数記号のみで構成されているかどうかを判断します。<br>
	 * <br>
	 * <strong>＜半角英数記号の定義＞</strong><br>
	 * 文字コードが「 」(半角スペース)～「~」の間の文字<br>
	 *
	 * @param strArg チェックする文字列
	 * @return true=半角英数記号のみで構成されている, false=半角英数記号以外が含まれている
	 */
	public static boolean isAscii(String strArg) {
		//正規表現を使って最初から最後まで半角英数記号で構成されているかチェックする
		return perl.match("/^[ -~]*$/", strArg);
	}

	/**
	 * 半角カナが含まれているかどうかチェックします。<br>
	 * (注)正常系の場合にtrueを返しますので、半角カナが含まれている場合はfalseを返します。<br>
	 * <br>
	 * <strong>＜半角カナの定義＞</strong><br>
	 * 文字コードが「｡」～「ﾟ」の間の文字<br>
	 *
	 * @param strArg チェックする文字列
	 * @return true=半角カナが含まれていない, false=半角カナが含まれている
	 */
	public static boolean isHalfKana(String strArg) {
		//正規表現を使って半角カナが含まれていないかチェックする
		return !perl.match("/[｡-ﾟ]/", strArg);
	}

	/**
	 * 全角ひらがなのみで構成されているかどうかを判断します。<br>
	 * <br>
	 * <strong>＜全角ひらがなの定義＞</strong><br>
	 * 文字コードが「ぁ」～「ゞ」の間の文字、または「ー」,「 」(半角スペース),「　」(全角スペース)<br>
	 *
	 * @param strArg チェックする文字列
	 * @return true=全角ひらがなのみで構成されている, false=全角ひらがな以外が含まれている
	 */
	public static boolean isHira(String strArg) {
		//正規表現を使って全角ひらがな以外の文字が含まれていないかチェックする
		return !perl.match("/[^ぁ-ゞー 　]/", strArg);
	}

	/**
	 * 半角英数記号及びスペース(改行・タブ等)のみで構成されているかどうかを判断します。<br>
	 * <br>
	 * <strong>＜半角英数記号及びスペースの定義＞</strong><br>
	 * 文字コードが「 」(半角スペース)～「~」の間の文字、または「\f」、「\n」、「\r」、「\t」、「\v」のいずれかの文字<br>
	 * (全角スペースは含まない)<br>
	 *
	 * @param strArg チェックする文字列
	 * @return true=半角英数記号及びスペースのみで構成されている, false=半角英数記号及びスペース以外が含まれている
	 */
	public static boolean isAsciiSpace(String strArg) {
		//正規表現を使って最初から最後まで半角英数記号及びスペースで構成されているかチェックする
		//(\sを使うと全角スペースもマッチしてしまうので使わない)
		return perl.match("/^[ -~\\f\\n\\r\\t\\v]*$/", strArg);
	}

	/**
	 * メールアドレスに使用できる文字列かどうかを判断します。<br>
	 * 未入力の場合を考慮して、空文字列の場合もtrueを返します。<br>
	 * <br>
	 * <strong>＜メールアドレスに使用できる文字の定義＞</strong><br>
	 * ①使用可能文字は A～Z および a～z および 0～9 および !#$%&'*+-/=?^_`{|}~ および .@<br>
	 * ② @ の前に少なくとも１文字以上の文字（※１）が存在すること。<br>
	 * ③先頭文字が . ではないこと。<br>
	 * ④ . が使用された場合、 . の後ろに文字（※１）が存在すること。<br>
	 * ⑤ @ の後ろに少なくとも１文字以上の文字（※１）が存在すること。<br>
	 * ⑥ @ の直後が . ではないこと。<br>
	 * ⑦ @ が１つのみ存在すること。<br>
	 * ※１： A～Z または a～z または 0～9 または !#$%&'*+-/=?^_`{|}~<br>
	 *
	 * @param strArg チェックする文字列
	 * @return true=メールアドレスに使用できる文字列, false=メールアドレスに使用できる文字列でない
	 */
	public static boolean isEmail(String strArg) {
		//空文字列の場合
		if (!isEmpty(strArg)) {
			//trueを返す
			return true;
		}

		//正規表現を使って最初から最後までメールアドレスに使用できる文字で構成されているかチェックする
		return perl.match("/^[A-Za-z0-9!#\\$%&'\\*\\+\\-\\/=\\?\\^_`\\{\\|\\}~](\\.?[A-Za-z0-9!#\\$%&'\\*\\+\\-\\/=\\?\\^_`\\{\\|\\}~])*@[A-Za-z0-9!#\\$%&'\\*\\+\\-\\/=\\?\\^_`\\{\\|\\}~](\\.?[A-Za-z0-9!#\\$%&'\\*\\+\\-\\/=\\?\\^_`\\{\\|\\}~])*$/",
				strArg);
	}

	/**
	 * 機種依存文字が含まれているかどうかチェックします。<br>
	 * (注)正常系の場合にtrueを返しますので、機種依存文字が含まれている場合はfalseを返します。<br>
	 * <br>
	 * <strong>＜機種依存文字の定義＞</strong><br>
	 * 半角カナ(文字コードが「｡」～「ﾟ」の間の文字) および <br>
	 * №℡ⅠⅡⅢⅣⅤⅥⅦⅧⅨⅩⅰⅱⅲⅳⅴⅵⅶⅷⅸⅹ∑√∟∠∥∩∪∫∮∵≒≡⊥⊿
	 * ①②③④⑤⑥⑦⑧⑨⑩⑪⑫⑬⑭⑮⑯⑰⑱⑲⑳〝〟㈱㈲㈹㊤㊥㊦㊧㊨㌃㌍㌔㌘㌢㌣
	 * ㌦㌧㌫㌶㌻㍉㍊㍍㍑㍗㍻㍼㍽㍾㎎㎏㎜㎝㎞㎡㏄㏍丨仡仼仼伀伃伹佖侊侒侔侚俉俍
	 * 俿倞倢偀偂偆偰傔僘僴兊兤冝冾凬刕劜劦劯勀勛匀匇匤卲厓厲叝咊咜咩哿喆坙坥垬
	 * 埇埈增墲夋奓奛奝奣妤妺孖寀寘寬尞岦岺峵崧嵂嵓嵭嶸嶹巐弡弴彅彧德忞恝悅悊惕
	 * 惞惲愑愠愰愷憘戓抦揵摠撝擎敎昀昉昕昞昤昮昱昻晗晙晥晳暙暠暲暿曺曻朎杦枻柀
	 * 栁桄桒棈棏楨榘槢樰橆橫橳橾櫢櫤毖氿汜汯沆泚洄浯涇涖涬淏淲淸淼渧渹渼湜溿澈
	 * 澵濵瀅瀇瀨瀨炅炫炻焄焏煆煇煜燁燾犱犾猤獷玽珉珒珖珣珵琇琦琩琪琮瑢璉璟甁甯
	 * 畯皂皛皜皞皦睆砡硎硤硺礰禔禛竑竧竫箞絈絜綠綷緖繒纊罇羡茁荢荿菇菶葈蒴蓜蕓
	 * 蕙蕫薰蠇裵褜訒訷詹誧誾諟諶譓譿賰賴贒赶軏遧郞鄕鄧釗釚釞釤釥釭釮鈆鈊鈐鈹鈺
	 * 鈼鉀鉎鉑鉙鉧鉷鉸銈銧鋐鋓鋕鋗鋙鋠鋧鋹鋻鋿錂錝錞錡錥鍈鍗鍰鎤鏆鏞鏸鐱鑅鑈閒
	 * 隝隯霳霻靃靍靏靑靕顗顥餧馞驎髙髜魲魵鮏鮱鮻鰀鵫鵰鸙黑朗隆﨎﨎﨏塚﨑晴﨓﨔
	 * 凞猪益礼神祥福靖精羽﨟蘒﨡諸﨣﨤逸都﨧﨨﨩飯飼館鶴
	 *
	 * @param strArg チェックする文字列
	 * @return true=機種依存文字が含まれていない, false=機種依存文字が含まれている
	 */
	public static boolean isModelDependence(String strArg) {
		//正規表現を使って機種依存文字が含まれていないかチェックする
		return !perl.match("/[｡-ﾟ№℡ⅠⅡⅢⅣⅤⅥⅦⅧⅨⅩⅰⅱⅲⅳⅴⅵⅶⅷⅸⅹ∑√∟∠∥∩∪∫∮∵≒≡⊥⊿①②③④⑤⑥⑦⑧⑨⑩⑪⑫⑬⑭⑮⑯⑰⑱⑲⑳〝〟㈱㈲㈹㊤㊥㊦㊧㊨㌃㌍㌔㌘㌢㌣㌦㌧㌫㌶㌻㍉㍊㍍㍑㍗㍻㍼㍽㍾㎎㎏㎜㎝㎞㎡㏄㏍丨仡仼仼伀伃伹佖侊侒侔侚俉俍俿倞倢偀偂偆偰傔僘僴兊兤冝冾凬刕劜劦劯勀勛匀匇匤卲厓厲叝咊咜咩哿喆坙坥垬埇埈增墲夋奓奛奝奣妤妺孖寀寘寬尞岦岺峵崧嵂嵓嵭嶸嶹巐弡弴彅彧德忞恝悅悊惕惞惲愑愠愰愷憘戓抦揵摠撝擎敎昀昉昕昞昤昮昱昻晗晙晥晳暙暠暲暿曺曻朎杦枻柀栁桄桒棈棏楨榘槢樰橆橫橳橾櫢櫤毖氿汜汯沆泚洄浯涇涖涬淏淲淸淼渧渹渼湜溿澈澵濵瀅瀇瀨瀨炅炫炻焄焏煆煇煜燁燾犱犾猤獷玽珉珒珖珣珵琇琦琩琪琮瑢璉璟甁甯畯皂皛皜皞皦睆砡硎硤硺礰禔禛竑竧竫箞絈絜綠綷緖繒纊罇羡茁荢荿菇菶葈蒴蓜蕓蕙蕫薰蠇裵褜訒訷詹誧誾諟諶譓譿賰賴贒赶軏遧郞鄕鄧釗釚釞釤釥釭釮鈆鈊鈐鈹鈺鈼鉀鉎鉑鉙鉧鉷鉸銈銧鋐鋓鋕鋗鋙鋠鋧鋹鋻鋿錂錝錞錡錥鍈鍗鍰鎤鏆鏞鏸鐱鑅鑈閒隝隯霳霻靃靍靏靑靕顗顥餧馞驎髙髜魲魵鮏鮱鮻鰀鵫鵰鸙黑朗隆﨎﨎﨏塚﨑晴﨓﨔凞猪益礼神祥福靖精羽﨟蘒﨡諸﨣﨤逸都﨧﨨﨩飯飼館鶴]/",
				strArg);
	}

	/**
	 * 電話番号に使用できる文字列かどうかを判断します。<br>
	 * 未入力の場合を考慮して、空文字列の場合もtrueを返します。<br>
	 * <br>
	 * <strong>＜電話番号に使用できる文字の定義＞</strong><br>
	 * 半角数字が1～5文字 + 「-」 + 半角数字が1～5文字 + 「-」 + 半角数字が1～4文字
	 *
	 * @param strArg チェックする文字列
	 * @return true=電話番号に使用できる文字列, false=電話番号に使用できる文字列でない
	 */
	public static boolean isTel(String strArg) {
		//空文字列の場合
		if (!isEmpty(strArg)) {
			//trueを返す
			return true;
		}

		//正規表現を使って最初から最後まで電話番号に使用できる文字で構成されているかチェックする
		return perl.match("/^[0-9]{1,5}\\-[0-9]{1,5}\\-[0-9]{1,4}$/", strArg);
	}

	/**
	 * 数値の順序が正しいかどうか判断します。<br>
	 * 金額の場合も考慮して、「,」を取り除いてから判断します。<br>
	 * どちらか一方でも空文字列の場合は「1」を返します。<br>
	 * (注)このメソッドを呼び出す前に、必ずisNumber()関数で数値の正当性をチェックして下さい。<br>
	 *
	 * @param strStartArg 開始値
	 * @param strEndArg 終了値
	 * @return 1=終了値の方が大きい、またはどちらか一方でも空文字列の場合, 0=同じ数値の場合, -1=終了値の方が小さいの場合
	 */
	public static int isNumberOrder(String strStartArg, String strEndArg) {
		//==========================================================
		//空文字列チェック

		//どちらか一方でも空文字列の場合
		if (!isEmpty(strStartArg) || !isEmpty(strEndArg)) {
			return 1;
		}


		//==========================================================
		//文字列を「,」を取り除いてから数値に変換

		//開始値
		int intStart = Integer.parseInt(StringUtil.removeComma(strStartArg));

		//終了値
		int intEnd = Integer.parseInt(StringUtil.removeComma(strEndArg));


		//==========================================================
		//順序チェック

		//開始値よりも終了値の方が大きい場合
		if (intStart < intEnd) {
			return 1;
		}

		//同じ数値の場合
		else if (intStart == intEnd) {
			return 0;
		}

		//開始値よりも終了値の方が小さい場合
		else {
			return -1;
		}

	}


	/**
	 * 「,」区切りの半角英数字かどうかチェックします。<br>
	 * 半角英数字以外に「_」も許容します。<br>
	 * 最初と最後、「,」周辺の空白文字(半角スペースやタブ、全角スペース)も許容します。<br>
	 * <br>
	 * <strong>＜「,」区切りの半角英数字の定義＞</strong><br>
	 * 以下の正規表現が表す文字列<br>
	 * <code>^\s*[0-9A-Za-z_]+(\s*,\s*[0-9A-Za-z_]+)*\s*$</code>
	 *
	 * @param strArg チェックする文字列
	 * @return true=「,」区切りの半角英数字, false=「,」区切りの半角英数字でない
	 */
	public static boolean isCommaPauseAlphaNumber(String strArg) {
		//正規表現を使って「,」区切りの半角英数字かチェックする
		return perl.match("/^\\s*[0-9A-Za-z_]+(\\s*,\\s*[0-9A-Za-z_]+)*\\s*$/",
				strArg);
	}

	/**
	 * 指定した年月日が存在する日付かどうかチェックします。<br>
	 *
	 * @param yearArg 年
	 * @param monthArg 月
	 * @param dayArg 日
	 * @return true=存在する日付, false=存在する日付でない
	 */
	public static boolean isExistDate(int yearArg, int monthArg, int dayArg) {
		//intを文字列に変換して、実際に処理を行うメソッドを呼び出す
		return isExistDate(Integer.toString(yearArg),
				Integer.toString(monthArg),
				Integer.toString(dayArg));
	}

	/**
	 * 指定した年月日が存在する日付かどうかチェックします。<br>
	 *
	 * @param yearArg 年
	 * @param monthArg 月
	 * @param dayArg 日
	 * @return true=存在する日付, false=存在する日付でない
	 */
	public static boolean isExistDate(String yearArg, String monthArg,
			String dayArg) {
		try {
			//引数を「年/月/日」形式の文字列に結合して、Dateに変換する
			//(変換できるかどうかをチェックするだけなので戻り値は使用しない)
			sdf.parse(yearArg + "/" + monthArg + "/" + dayArg);

			//例外が発生しないということは正しい日付ということなのでtrueを返す
			return true;
		}
		//例外が発生した場合
		catch (ParseException e) {
			//正しい日付ではなかったのでfalseを返す
			return false;
		}
	}

	/**
	 * URLに使用できる文字列かどうかを判断します。<br>
	 * <br>
	 * <strong>＜URLに使用できる文字の定義＞</strong><br>
	 * 文字コードが「0」～「9」、「A」～「Z」、「a」～「z」の間の文字、または「.」、「-」、「*」、「_」のいずれかの文字<br>
	 *
	 * @param strArg チェックする文字列
	 * @return true=URLに使用できる文字列, false=URLに使用できる文字列でない
	 */
	public static boolean isURL(String strArg) {
		//正規表現を使って最初から最後までURLに使用できる文字で構成されているかチェックする
		return perl.match("/^[0-9A-Za-z.\\-*_]*$/", strArg);
	}

	/**
	 * 正しい形式のクラス名かどうかを判断します。<br>
	 * <br>
	 * <strong>＜クラス名の定義＞</strong><br>
	 * <ol>
	 *   <li>先頭の文字の文字コードが「a」～「z」、「A」～「Z」の間の文字、または「$」、「_」のいずれかの文字</li>
	 *   <li>先頭以外の文字の文字コードが「a」～「z」、「A」～「Z」、「0」～「9」の間の文字、または「$」、「_」のいずれかの文字</li>
	 * </ol>
	 *
	 * @param strArg チェックする文字列
	 * @return true=正しい形式のクラス名, false=正しい形式のクラス名でない
	 */
	public static boolean isClassName(String strArg) {
		//正規表現を使って正しい形式のクラス名かチェックする
		return perl.match("/^[$_a-zA-Z][$_a-zA-Z0-9]*$/", strArg);
	}

	/**
	 * 正しい形式のパッケージ名を含むクラス名かどうかを判断します。<br>
	 * <br>
	 * <strong>＜パッケージ名を含むクラス名の定義＞</strong><br>
	 * (パッケージ名 + 「.」)が０個以上 + クラス名<br>
	 * <br>
	 * <strong>＜パッケージ名の定義＞</strong><br>
	 * クラス名の定義と同じ<br>
	 *
	 * @param strArg チェックする文字列
	 * @return true=正しい形式のパッケージ名を含むクラス名, false=正しい形式のパッケージ名を含むクラス名でない
	 */
	public static boolean isClassNameWithPackage(String strArg) {
		//正規表現を使って正しい形式のパッケージ名を含むクラス名かチェックする
		return perl.match("/^([$_a-zA-Z][$_a-zA-Z0-9]*\\.)*[$_a-zA-Z][$_a-zA-Z0-9]*$/",
				strArg);
	}

	/**
	 * 文字列のバイト数が指定したバイト数の間かどうかを判断します。<br>
	 *
	 * @param strArg チェックする文字列
	 * @param minLengthArg 最小バイト数
	 * @param maxLengthArg 最大バイト数
	 * @return true=指定したバイト数の間, false=指定したバイト数の間でない
	 */
	public static boolean isLengthRange(String strArg, int minLengthArg,
			int maxLengthArg) {
		//文字列のバイト数を取得
		int byteLength = strArg.getBytes().length;

		//文字列のバイト数が指定したバイト数の間の場合
		if ((byteLength >= minLengthArg) && (byteLength <= maxLengthArg)) {
			return true;
		}
		//文字列のバイト数が指定したバイト数の間でない場合
		else {
			return false;
		}
	}
}

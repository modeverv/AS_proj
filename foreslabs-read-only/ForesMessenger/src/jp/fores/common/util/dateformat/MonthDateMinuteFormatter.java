package jp.fores.common.util.dateformat;

/**
 * 年・月、年・月・日、または年・月・日・時・分をフォーマット変換するサブインターフェース。<br>
 * <br>
 * ３つのインターフェースを統合しているだけで、このインターフェース自体では何も定義していません。<br>
 *
 * @see MonthDateMinuteFormatterManager
 */
public interface MonthDateMinuteFormatter extends MonthFormatter,
		DateFormatter, MinuteFormatter {
}

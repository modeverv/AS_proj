package jp.fores.common.utils
{
	import mx.controls.dataGridClasses.DataGridColumn;
	import mx.formatters.DateFormatter;
	import mx.formatters.NumberFormatter;
	
	/**
	 * 文字列操作用ユーティリティクラス。
	 */
	public class StringUtil
	{
		//==========================================================
		//フィールド
		
		//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
		//クラスフィールド
		
		/**
		 * URLをリンクにする場合の色
		 * (外部からも変更できるようにするため、定数ではなくpublicな変数にしている)
		 */
		public static var linkColor :String = "#0000FF";
		
		/**
		 * URLを抽出するための正規表現
		 */
		private static var urlRegExp :RegExp = /(https?:\/\/[0-9a-z-\/._?=&%\[\]~;]+)/ig;
		
		
		//==========================================================
		//メソッド
	
		//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
		//クラスメソッド
	
		/**
		 * 指定されたパターンを文字列と照合し、新しい文字列を返します。<br>
		 * パターンと最初に一致した部分が置換する文字列に置き換えられます。<br>
		 *
		 * @param strArg 元の文字列
		 * @param petternStrArg 照合するパターンの文字列
		 * @param replaceStrArg 置換する文字列
		 * @return 置換後の文字列
		 */
		public static function replaceAll(strArg :String, petternStrArg :String, replaceStrArg :String) :String
		{
			//照合するパターンのRegExpを生成する際に「g」フラグ(全て置換)を指定して、Stringのreplace()メソッドを呼び出す
			return strArg.replace(new RegExp(petternStrArg, "g"), replaceStrArg);
		}
		
		/**
		 * 引数の文字列がnullまたは空文字列かどうかを返します。
		 *
		 * @param strArg チェックする文字列
		 * @return true=nullまたは空文字列の場合, false=それ以外の場合
		 */
		public static function isBlank(strArg :String) :Boolean
		{
			//nullまたは空文字列の場合
			if((strArg == null) || (strArg === ""))
			{
				//trueを返す
				return true;
			}
			//それ以外の場合
			else
			{
				//falseを返す
				return false;
			}
		}
		
		/**
		 * 引数のオブジェクトがnullの場合、空文字列を返します。
		 * null以外の場合はオブジェクトの文字列表現を返します。
		 *
		 * @param objArg 対象のオブジェクト
		 * @return nullの場合は空文字列、null以外の場合はオブジェクトの文字列表現
		 */
		public static function escapeNull(objArg :Object) :String
		{
			//nullの場合
			if(objArg == null)
			{
				//空文字列を返す
				return "";
			}
			//null以外の場合
			else
			{
				//オブジェクトの文字列表現を返す
				return objArg.toString();
			}
		}
	
		/**
		 * 引数の文字列がnulまたは空文字列の場合はnullを返します。
		 * それ以外の場合はそのままの文字列を返します。
		 *
		 * @param strArg 変換したい文字列
		 * @return nullまたは空文字列の場合はnull、それ以外の場合はそのままの文字列
		 */
		public static function blankToNull(strArg :String) :String
		{
			//nullまたは空文字列の場合
			if(StringUtil.isBlank(strArg))
			{
				//nullを返す
				return null;
			}
			//それ以外の場合
			else
			{
				//そのままの文字列を返す
				return strArg;
			}
	
		}
	
		/**
		 * 配列の内容を結合して、指定された区切り文字の文字列を返します。
		 * 
		 * @param arrayArg 配列
		 * @param delimiterArg 区切り文字(省略可能, デフォルト=「,」)
		 * @return 結合した文字列
		 */
		public static function combineArrayString(arrayArg :Array, delimiterArg :String = ",") :String 
		{
			//配列がnullまたは空配列の場合
			if((arrayArg == null) || (arrayArg.length == 0))
			{
				//空文字列を返す
				return "";
			}
			
			//作業用文字列
			var str :String = "";
			
			//配列の要素数に応じてループをまわす
			for(var i :int = 0; i < arrayArg.length; i++)
			{
				//最初以外の場合
				if(i != 0)
				{
					//区切り文字を追加
					str += delimiterArg;
				}
				
				//配列の現在の要素の文字列表現を追加
				str += arrayArg[i].toString();
			}
			
			//結果の文字列を返す
			return str;
		}

		/**
		 * 「\」を「\\」に変換して返します。
		 * nullの場合は空文字列を返します。
		 *
		 * @param strArg 変換したい文字列
		 * @return 変換後の文字列
		 */
		public static function escapeBackSlash(strArg :String) :String
		{
			//nullを空文字列に変換してから、「\」を「\\」に変換して返す
			return StringUtil.replaceAll(StringUtil.escapeNull(strArg), "\\", "\\\\");
		}
	
		/**
		 * 「'」を「''」に変換して返します。
		 * nullの場合は空文字列を返します。
		 *
		 * @param strArg 変換したい文字列
		 * @return 変換後の文字列
		 */
		public static function escapeQuotation(strArg :String) :String
		{
			//nullを空文字列に変換してから、「'」を「''」に変換して返す
			return StringUtil.replaceAll(StringUtil.escapeNull(strArg), "'", "''");
		}
	
		/**
		 * 「"」を「""」に変換して返します。
		 * nullの場合は空文字列を返します。
		 *
		 * @param strArg 変換したい文字列
		 * @return 変換後の文字列
		 */
		public static function escapeDoubleQuotation(strArg :String) :String
		{
			//nullを空文字列に変換してから、「"」を「""」に変換して返す
			return StringUtil.replaceAll(StringUtil.escapeNull(strArg), "\"", "\"\"");
		}
	
		/**
		 * 改行・タブを半角スペースに変換して返します。
		 * nullの場合は空文字列を返します。
		 *
		 * @param strArg 変換したい文字列
		 * @return 変換後の文字列
		 */
		public static function escapeWhiteSpace(strArg :String) :String
		{
			//結果を入れる文字列
			var resultStr:String = StringUtil.escapeNull(strArg);
			
			//改行・タブを半角スペースに変換する
			resultStr = StringUtil.replaceAll(resultStr, "\r\n", " ");
			resultStr = StringUtil.replaceAll(resultStr, "\n", " ");
			resultStr = StringUtil.replaceAll(resultStr, "\r", " ");
			resultStr = StringUtil.replaceAll(resultStr, "\t", " ");
	
			//結果の文字列を返す
			return resultStr;
		}
	
		/**
		 * XMLの特殊文字をエスケープして返します。<br>
		 * <br>
		 * 以下の通りに変換します。<br>
		 * <table border="1">
		 *  <tr bgcolor="deepskyblue">
		 *      <td align="center"><strong>特殊文字</strong></td>
		 *      <td align="center"><strong>変換後の文字列</strong></td>
		 *  </tr>
		 *  <tr>
		 *      <td><code>&amp;</code></td>
		 *      <td><code>&amp;amp;</code></td>
		 *  </tr>
		 *  <tr>
		 *      <td><code>&lt;</code></td>
		 *      <td><code>&amp;lt;</code></td>
		 *  </tr>
		 *  <tr>
		 *      <td><code>&gt;</code></td>
		 *      <td><code>&amp;gt;</code></td>
		 *  </tr>
		 *  <tr>
		 *      <td><code>&quot;</code></td>
		 *      <td><code>&amp;quot;</code></td>
		 *  </tr>
		 * </table>
		 * <br>
		 * なお、nullの場合は空文字列に変換します。<br>
		 *
		 * @param strArg 変換したい文字列
		 * @return 変換後の文字列
		 */
		public static function escapeXML(strArg :String) :String
		{
			//結果を入れる文字列
			var resultStr:String = StringUtil.escapeNull(strArg);
			
			//特殊文字の変換
			resultStr = StringUtil.replaceAll(resultStr, "&", "&amp;");
			resultStr = StringUtil.replaceAll(resultStr, "<", "&lt;");
			resultStr = StringUtil.replaceAll(resultStr, ">", "&gt;");
			resultStr = StringUtil.replaceAll(resultStr, "\"", "&quot;");
	
			//結果の文字列を返す
			return resultStr;
		}
	
		/**
		 * 与えられた文字列を「'」で囲んで返します。
		 * nullの場合は「''」という文字列を返します。
		 *
		 * @param strArg 「'」で囲みたい文字列
		 * @return 「'」で囲まれた文字列(nullの場合は「''」という文字列)
		 */
		public static function quoting(strArg :String) :String
		{
			//nullの場合
			if(strArg == null)
			{
				//「''」という文字列を返す
				return "''";
			}
			//nullでない場合
			else
			{
				//「'」で囲んで返す
				return "'" + strArg + "'";
			}
		}
	
		/**
		 * 与えられた文字列を指定した文字数でカットします。
		 * 接尾子が指定されている場合は、カットした文字列の末尾に接尾子をつけて返します。
		 * 指定した文字数よりも文字列が短い場合は、そのまま返します。
		 * 接尾子は、一定の文字数よりも長い場合に、末尾に「...」などをつけて省略して表示したい場合
		 * などに指定して下さい。
		 *
		 * @param strArg 対象文字列
		 * @param lengthArg 文字数
		 * @param suffixArg 末尾につける接尾子(「...」など)(省略可能)
		 * @return 変換後の文字列
		 */
		public static function cutString(strArg :String, lengthArg :Number, suffixArg :String) :String
		{
			//対象文字列が指定した文字数よりも長い場合
			if(strArg.length > lengthArg)
			{
				//接尾子が指定されている場合
				if(suffixArg != null)
				{
					//指定した文字数でカットして、さらに末尾に接尾子をつけて返す
					return strArg.substring(0, lengthArg) + suffixArg;
				}
				else
				{
					//指定した文字数でカットして返す
					return strArg.substring(0, lengthArg);
				}
			}
			//それ以外の場合
			else
			{
				//対象文字列をそのまま返す
				return strArg;
			}
		}
		
		/**
		 * 文字列から拡張子を抽出します。
		 * 拡張子が存在しない場合は空文字列を返します。
		 * 小文字に変換するかどうかのフラグが省略されている場合またはtrueが指定されている場合は、
		 * 結果を小文字に変換してから返します。
		 * 
		 * ＜拡張子の定義＞
		 * 最後の「.」以降の文字列
		 *
		 * @param strArg 対象文字列
		 * @param isToLowerArg 小文字に変換するかどうかのフラグ(true=変換する, false=変換しない)(省略可能, デフォルト=true)
		 * @return 拡張子(存在しない場合は空文字列)
		 */
		public static function getExtension(strArg :String, isToLowerArg :Boolean = true) :String
		{
			//最後の「.」の位置を取得する
			var lastPeriodIndex:Number = strArg.lastIndexOf('.');
	
			//「.」が見つからなかった場合
			if(lastPeriodIndex === -1)
			{
				//拡張子が存在しないので空文字列を返す
				return "";
			}
			//「.」が見つかった場合
			else
			{
				//最後の「.」以降の文字列を拡張子として取得
				var extension:String = strArg.substring(lastPeriodIndex + 1);
	
				//小文字に変換するかどうかのフラグにtrueが指定されている場合
				//(小文字に変換する場合)
				if(isToLowerArg)
				{
					//取得した拡張子を小文字に変換して返す
					return extension.toLowerCase();
				}
				//小文字に変換しない場合
				else
				{
					//取得した拡張子をそのまま返す
					return extension;
				}
			}
		}
		
		/**
		 * 数値の先頭にゼロ詰めを行って、指定した長さの文字列にします。
		 * 指定された数値の長さがすでに指定した桁数以上の場合は、そのまま文字列に変換して返します。
		 * 
		 *
		 * @param numberArg ゼロ詰めを行う数値
		 * @param lengthArg 長さ
		 * @return 結果の文字列
		 */
		public static function zeroPadding(numberArg :Number, lengthArg :Number) :String
		{
			//引数の数値を文字列に変換
			var str:String = String(numberArg);
			
			//指定された文字列の長さになるまでループをまわす
			while(str.length < lengthArg)
			{
				//先頭に「0」を挿入する
				str = "0" + str;
			}
	
			//結果の文字列を返す
			return str;
		}
		
		/**
		 * 対象文字列がnullの場合、代わりの文字列を返します。
		 * 対象文字列がnullでない場合は、対象文字列をそのまま返します。
		 *
		 * @param targetStrArg 対象文字列
		 * @param replaceStrArg 対象文字列がnullの場合に代わりに返す文字列
		 * @return 対象文字列、または代わりの文字列
		 */
		public static function nvl(targetStrArg :String, replaceStrArg :String) :String
		{
			//対象文字列がnullの場合
			if(targetStrArg == null)
			{
				//代わりの文字列を返す
				return replaceStrArg;
			}
			//対象文字列がnullでない場合
			else
			{
				//対象文字列をそのまま返す
				return targetStrArg;
			}
		}
		
		/**
		 * 数値の整数部分の桁数を取得します。
		 * 便宜上、「0」の桁数は1、負数の桁数は同じ絶対値の正数の桁数に「-」をつけたものとします。
		 * 極大・極小の値が指定された場合は誤差が生じることもあります。
		 *
		 * (このメソッドは数値のみを扱うので本当はこのクラスにはふさわしくないのですが、
		 *	zeroPadding()メソッドと併せて使用されることが多いので、便宜上このクラスに定義しています。)
		 *
		 * @param numberArg 対象の数値
		 * @return 桁数
		 */
		public static function getKeta(numberArg :Number) :Number
		{
			//正数の場合
			if(numberArg >= 0)
			{
				//小数点以下を切り捨てて文字列に変換し、文字列の長さを返す
				return String(Math.floor(numberArg)).length;
			}
			//負数の場合
			else
			{
				//対象の数値の符号を反転させてこのメソッドを再び呼び出し、結果の符号を反転させてマイナスにしてから返す
				return -(StringUtil.getKeta(-numberArg));
			}
		}
		
		/**
		 * 数値、または数値の入った文字列を、３桁ごとに「,」で区切って返します。<br>
		 * 変換できない不正な値が渡された場合は、「0」を返します。<br>
		 *
		 * @param valueArg 数値、数値の入った文字列
		 * @return 「,」で区切られた文字列
		 */
		public static function setComma(valueArg :Object) :String
		{
			//引数がnullの場合
			if(valueArg == null)
			{
				//「0」を返す
				return "0";
			}
			
			//数値フォーマット用のインスタンスを生成
			var formatter :NumberFormatter = new NumberFormatter();
			
			//フォーマットした結果を返す
			return formatter.format(valueArg);
		}
		
		/**
		 * 数値、または数値の入った文字列を、３桁ごとに「,」で区切って返します。(DataGridのlabelFunction用)<br>
		 * 変換できない不正な値が渡された場合は、「0」を返します。<br>
		 *
		 * @param itemArg DataGridアイテムオブジェクト
		 * @param columnArg DataGrid列
		 * @return 「,」で区切られた文字列
		 */
		public static function setCommaForDataGrid(itemArg :Object, columnArg :DataGridColumn) :String
		{
			//実際に処理を行うメソッドを呼び出す
			return setComma(itemArg[columnArg.dataField]);
		}
		
		/**
		 * 文字列中に含まれるURLをリンクに変換して返します。
		 * nullの場合は空文字列を返します。
		 *
		 * @param strArg 変換したい文字列
		 * @return 変換後の文字列
		 */
		public static function convertURLToLink(strArg :String) :String
		{
			//nullを空文字列に変換してから、URLをリンクに変換して返す
			//(置換は文字列で直接置換することが難しいので、置換用の関数によって行う)
			return StringUtil.escapeNull(strArg).replace(urlRegExp, urlToLinkReplaceFunction);
		}

		/**
		 * 日時を表示用に整形した文字列を返します。
		 * 
		 * @param dateArg 日時
		 * @param formatStringArg フォーマット用文字列(デフォルト値="YYYY/MM/DD J:NN:SS")
		 * @return 表示用に整形した文字列
		 */
		public static function formatTime(dateArg :Date, formatStringArg :String = "YYYY/MM/DD J:NN:SS") :String
		{
			//日付フォーマット変換用のオブジェクトを設定
			var dateFormatter :DateFormatter = new DateFormatter();
			dateFormatter.formatString = formatStringArg;
			
			//引数の日時をフォーマット変換して返す
			return dateFormatter.format(dateArg);
		}

		/**
		 * 秒を「分:秒」形式の文字列に整形して返します。
		 * 
		 * @param secondArg 秒
		 * @return 整形した文字列
		 */
		public static function formatSecondToMinuteSecond(secondArg :int) :String
		{
			//分を2桁にゼロ詰めした文字列として取得
			var minuteStr :String = zeroPadding(Math.floor(secondArg / 60), 2);
			
			//秒を2桁にゼロ詰めした文字列として取得
			var secondStr :String = zeroPadding(secondArg % 60, 2);

			//「分:秒」形式の文字列に整形して返す
			return minuteStr + ":" + secondStr;
		}
		
		/**
		 * 秒を「分:秒」形式の文字列に整形して返します。(DataGridのlabelFunction用)<br>
		 *
		 * @param itemArg DataGridアイテムオブジェクト
		 * @param columnArg DataGrid列
		 * @return 「,」で区切られた文字列
		 */
		public static function formatSecondToMinuteSecondForDataGrid(itemArg :Object, columnArg :DataGridColumn) :String
		{
			//実際に処理を行うメソッドを呼び出す
			return formatSecondToMinuteSecond(int(itemArg[columnArg.dataField]));
		}
		
		/**
		 * 秒を「時:分:秒」形式の文字列に整形して返します。
		 * 
		 * @param secondArg 秒
		 * @return 整形した文字列
		 */
		public static function formatSecondToHourMinuteSecond(secondArg :int) :String
		{
			//時間を2桁にゼロ詰めした文字列として取得
			var hourStr :String = zeroPadding(Math.floor(secondArg / 3600), 2);
			
			//分を2桁にゼロ詰めした文字列として取得
			var minuteStr :String = zeroPadding(Math.floor((secondArg % 3600) / 60), 2);
			
			//秒を2桁にゼロ詰めした文字列として取得
			var secondStr :String = zeroPadding(secondArg % 60, 2);

			//「時:分:秒」形式の文字列に整形して返す
			return hourStr + ":" + minuteStr + ":" + secondStr;
		}
		
		/**
		 * 秒を「時:分:秒」形式の文字列に整形して返します。(DataGridのlabelFunction用)<br>
		 *
		 * @param itemArg DataGridアイテムオブジェクト
		 * @param columnArg DataGrid列
		 * @return 「,」で区切られた文字列
		 */
		public static function formatSecondToHourMinuteSecondForDataGrid(itemArg :Object, columnArg :DataGridColumn) :String
		{
			//実際に処理を行うメソッドを呼び出す
			return formatSecondToHourMinuteSecond(int(itemArg[columnArg.dataField]));
		}
		
		/**
		 * ファイル名に使用できない文字を取り除いて正規化します。
		 * 
		 * @param fileNameArg ファイル名
		 * @return ファイル名に使用できない文字を取り除いて正規化した文字列
		 */
		public static function normalizeFileName(fileNameArg :String) :String
		{
			//結果を入れる文字列
			var resultStr:String = StringUtil.escapeNull(fileNameArg);
			
			//ファイル名に使用できない文字を空文字列に変換することにより削除する
			resultStr = StringUtil.replaceAll(resultStr, "\\", "");
			resultStr = StringUtil.replaceAll(resultStr, ":", "");
			resultStr = StringUtil.replaceAll(resultStr, "/", "");
			resultStr = StringUtil.replaceAll(resultStr, "*", "");
			resultStr = StringUtil.replaceAll(resultStr, "?", "");
			resultStr = StringUtil.replaceAll(resultStr, "\"", "");
			resultStr = StringUtil.replaceAll(resultStr, "<", "");
			resultStr = StringUtil.replaceAll(resultStr, ">", "");
			resultStr = StringUtil.replaceAll(resultStr, "|", "");
	
			//結果の文字列を返す
			return resultStr;
		}
		
		
		//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
		//内部処理用

		/**
		 * 正規表現でマッチしたURLをリンクに変換するための置換関数です。
		 * 
		 * @param matchedSubStringArg 文字列内の正規表現に一致した部分全体の文字列
		 * @param capturedMatchArg1 正規表現のグループ化括弧によってキャプチャされる一致した文字列その1
		 * @param indexArg 文字列内で一致部分が始まる場所のインデックス
		 * @param strArg 正規表現の検索対象文字列全体
		 * @return 変換後の文字列
		 */
		private static function urlToLinkReplaceFunction(matchedSubStringArg :String, capturedMatchArg1 :String, indexArg :int, strArg :String) :String
		{
			//リンクのURLに指定する文字列
			//(「&」が「&amp;」にエスケープされたままだとおかしくなってしまうので、逆変換して元に戻す)
			var linkURL :String = StringUtil.replaceAll(capturedMatchArg1, "&amp;", "&");
			
			//リンクのテキスト部分に指定する文字列
			//(マッチした部分そのまま)
			var linkText :String = capturedMatchArg1;
			
			//単純な<a>タグではなく、下線付きの文字になるようなHTMLを返す
			//(リンクの色にはstaticな変数の値を指定)
			return "<u><font color=\"" + linkColor + "\"><a href=\"" + linkURL + "\" target=\"_blank\">" + linkText + "</a></font></u>";
		}

	}
}

package jp.fores.foresmessenger.dto
{
	import flash.filesystem.File;
	import flash.utils.ByteArray;
	
	import jp.fores.common.utils.StringUtil;
	
	/**
	 * 添付ファイル情報用Dtoクラス。
	 */
	[Bindable]
	public class AttachmentFileDto
	{
		//==========================================================
		//フィールド
		
		/**
		 * ファイルのフルパス
		 */
		public var fullPath :String = null;
		
		/**
		 * ファイル名
		 */
		public var fileName :String = null;
		
		/**
		 * ファイルサイズ
		 */
		public var fileSize :int = -1;
		
		/**
		 * ファイルを保存済みかどうかのフラグ
		 */
		public var isSaved :Boolean = false;
		
		/**
		 * ファイルのバイナリデータ
		 */
		public var fileData :ByteArray = null;

		/**
		 * テンポラリファイル
		 * (ドラッグ処理で何度もファイルが生成されないようにするため)
		 */
		public var tempFile :File = null;


		//==========================================================
		//Getter
		
		/**
		 * ファイルサイズを表示用に整形した文字列を返します。
		 * 
		 * @return ファイルサイズを表示用に整形した文字列
		 */
		public function get formattedFileSize() :String
		{
			//ファイルサイズをフォーマット用のメソッドで変換した結果を返す
			return StringUtil.formatFileSize(this.fileSize);
		}

		/**
		 * ファイルサイズを３桁ごとに「,」で区切った文字列を返します。
		 * 
		 * @return ファイルサイズを３桁ごとに「,」で区切った文字列
		 */
		public function get commaSeparatedFileSize() :String
		{
			//ファイルサイズをフォーマット用のメソッドで変換した結果を返す
			return StringUtil.setComma(this.fileSize);
		}

	}
}
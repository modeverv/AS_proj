package jp.fores.common.utils
{
	import flash.errors.IOError;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	
	/**
	 * ファイル操作用ユーティリティクラス。
	 */
	public class FileUtil
	{
		//==========================================================
		//メソッド
		
		//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
		//クラスメソッド
		
		/**
		 * 同期モードで指定されたファイルの内容を読み込んでByteArrayとして取得します。<br>
		 * 
		 * @param file 読み込むファイル
		 * @return 結果のByteArray
		 */
		public static function readFileToByteArray(file :File) :ByteArray
		{
			//ファイルが存在しない場合
			if(!file.exists)
			{
				//例外を投げる
				throw new IOError("ファイルが存在しません。" + file.nativePath);
			}
			
			//ディレクトリの場合
			if(file.isDirectory)
			{
				//例外を投げる
				throw new IOError("ディレクトリは指定できません。" + file.nativePath);
			}
			
			
			//FileStreamクラスのインスタンスを生成
			var stream :FileStream = new FileStream();

			//読み込んだデータを格納するByteArrayのインスタンスを生成
			var byteArray :ByteArray = new ByteArray();
				
			try
			{
				//対象ファイルへのストリームを読み取り専用モードでオープン
				stream.open(file, FileMode.READ);
				
				//ストリームの内容を一気にByteArrayに読み込む
				stream.readBytes(byteArray);
				
			}
			//終了処理
			finally
			{
				//ストリームを閉じる
				stream.close();
			}

			//結果のByteArrayを返す
			return byteArray;
		}

		/**
		 * 同期モードで指定されたファイルの内容を読み込んで文字列として取得します。<br>
		 * 
		 * @param file 読み込むファイル
		 * @param charset 文字セット(デフォルト値=null, nullが指定された場合はOS標準の文字セットを使用する)
		 * @return 結果の文字列
		 */
		public static function readFileToString(file :File, charset :String = null) :String
		{
			//ファイルが存在しない場合
			if(!file.exists)
			{
				//例外を投げる
				throw new IOError("ファイルが存在しません。" + file.nativePath);
			}
			
			//ディレクトリの場合
			if(file.isDirectory)
			{
				//例外を投げる
				throw new IOError("ディレクトリは指定できません。" + file.nativePath);
			}
			
			
			//FileStreamクラスのインスタンスを生成
			var stream :FileStream = new FileStream();

			//読み込んだデータを格納する文字列
			var str :String = null;
				
			try
			{
				//文字セットが指定されていない場合
				if(StringUtil.isBlank(charset))
				{
					//OS標準の文字セットを使用する
					charset = File.systemCharset;
				}
				
				//対象ファイルへのストリームを読み取り専用モードでオープン
				stream.open(file, FileMode.READ);
				
				//ファイルの内容を一気に指定された文字セットの文字列として読み込む
				str = stream.readMultiByte(file.size, charset);
			}
			//終了処理
			finally
			{
				//ストリームを閉じる
				stream.close();
			}

			//結果の文字列を返す
			return str;
		}

		/**
		 * 同期モードでByteArrayの内容を指定されたファイルに出力します。<br>
		 * 親ディレクトリがまだ存在しない場合は自動的に作成します。<br>
		 * 
		 * @param byteArray 対象のByteArray
		 * @param file 出力先のファイル
		 * @param isAppend 追記モードで書き込むかどうかのフラグ(デフォルト値=false)
		 */
		public static function writeByteArrayToFile(byteArray :ByteArray, file :File, isAppend :Boolean = false) :void
		{
			//ディレクトリの場合
			if(file.isDirectory)
			{
				//例外を投げる
				throw new IOError("ディレクトリは指定できません。" + file.nativePath);
			}
			
			//親ディレクトリがまだ存在しない場合もあるので、念のため作成しておく
			//(すでに存在する場合は何もしない)
			file.parent.createDirectory();
			
			//FileStreamクラスのインスタンスを生成
			var stream :FileStream = new FileStream();

			try
			{
				//追記モードで書き込むかどうかのフラグがたっている場合
				if(isAppend)
				{
					//対象ファイルへのストリームを追記モードでオープン
					stream.open(file, FileMode.APPEND);
				}
				//それ以外の場合
				else
				{
					//対象ファイルへのストリームを書き込み専用モードでオープン
					stream.open(file, FileMode.WRITE);
				}
				
				//ByteArrayの内容を一気にストリームに書き込む
				stream.writeBytes(byteArray);
			}
			//終了処理
			finally
			{
				//ストリームを閉じる
				stream.close();
			}
		}
		
		/**
		 * 同期モードで文字列の内容を指定されたファイルに出力します。<br>
		 * 親ディレクトリがまだ存在しない場合は自動的に作成します。<br>
		 * 
		 * @param str 対象の文字列
		 * @param file 出力先のファイル
		 * @param isAppend 追記モードで書き込むかどうかのフラグ(デフォルト値=false)
		 * @param charset 文字セット(デフォルト値=null, nullが指定された場合はOS標準の文字セットを使用する)
		 */
		public static function writeStringToFile(str :String, file :File, isAppend :Boolean = false, charset :String = null) :void
		{
			//ディレクトリの場合
			if(file.isDirectory)
			{
				//例外を投げる
				throw new IOError("ディレクトリは指定できません。" + file.nativePath);
			}
			
			//親ディレクトリがまだ存在しない場合もあるので、念のため作成しておく
			//(すでに存在する場合は何もしない)
			file.parent.createDirectory();
			
			//FileStreamクラスのインスタンスを生成
			var stream :FileStream = new FileStream();

			try
			{
				//文字セットが指定されていない場合
				if(StringUtil.isBlank(charset))
				{
					//OS標準の文字セットを使用する
					charset = File.systemCharset;
				}
				
				//追記モードで書き込むかどうかのフラグがたっている場合
				if(isAppend)
				{
					//対象ファイルへのストリームを追記モードでオープン
					stream.open(file, FileMode.APPEND);
				}
				//それ以外の場合
				else
				{
					//対象ファイルへのストリームを書き込み専用モードでオープン
					stream.open(file, FileMode.WRITE);
				}
				
				//文字列の内容を指定された文字セットで一気にストリームに書き込む
				stream.writeMultiByte(str, charset);
			}
			//終了処理
			finally
			{
				//ストリームを閉じる
				stream.close();
			}
		}
	}
}
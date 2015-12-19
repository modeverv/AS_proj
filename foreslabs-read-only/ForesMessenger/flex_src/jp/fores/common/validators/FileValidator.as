package jp.fores.common.validators
{
	import flash.filesystem.File;
	
	import jp.fores.common.utils.ArrayUtil;
	import jp.fores.common.utils.StringUtil;
	
	import mx.validators.StringValidator;
	import mx.validators.ValidationResult;
	
	/**
	 * ファイルパスの入力チェックを行うカスタムバリデータークラス。
	 */
	[Bindable]
	public class FileValidator extends StringValidator
	{
		//==========================================================
		//フィールド
		
		/**
		 * ファイルしか許可しないようにするかどうかのフラグ
		 * (デフォルト値=false)
		 */
		[Inspectable(defaultValue="false")]
		public var isOnlyFile :Boolean = false;
		
		/**
		 * ディレクトリしか許可しないようにするかどうかのフラグ
		 * (デフォルト値=false)
		 */
		[Inspectable(defaultValue="false")]
		public var isOnlyDirectory :Boolean = false;
		
		/**
		 * 存在するファイルしか許可しないようにするかどうかのフラグ
		 * (デフォルト値=false)
		 */
		[Inspectable(defaultValue="false")]
		public var isOnlyExistFile :Boolean = false;
		
		/**
		 * ファイルのパスが不正な場合に表示されるエラーメッセージ
		 */
		public var illegalFilePathError :String = "ファイルのパスが不正です";
		
		/**
		 * ファイルしか許可しないのにディレクトリのパスが指定された場合に表示されるエラーメッセージ
		 */
		public var onlyFileError :String = "ディレクトリではなく、ファイルのパスを指定して下さい";
		
		/**
		 * ディレクトリしか許可しないのにファイルのパスが指定された場合に表示されるエラーメッセージ
		 */
		public var onlyDirectoryError :String = "ファイルではなく、ディレクトリのパスを指定して下さい";
		
		/**
		 * 存在しないファイルのパスが指定された場合に表示されるエラーメッセージ
		 */
		public var notExistsFileError :String = "ファイルが存在しません";
		
		
		
		//==========================================================
		//メソッド
		
		//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
		//クラスメソッド
		
		/**
		 * バリデータを呼び出す上で便利なメソッドです。
		 * 
		 * @param validator FileValidator インスタンスを表します。
		 * @param value 検証するフィールドを表します。
		 * @param baseField value パラメータで指定したサブフィールドのテキスト表現です。 例えば、value パラメータで value.mystring を指定する場合、baseField の値は "mystring" です。
		 * @return ValidationResult オブジェクトの配列です。このオブジェクトは、検証が行われるフィールドごとに 1 つ含まれます。
		 */
		public static function validateFile(validator :FileValidator, value :Object, baseField:String = null) :Array
		{
			//引数のvalueの値を文字列に変換
			var str :String = StringUtil.escapeNull(value);
			
			//ファイルオブジェクトを生成
			var file :File = new File();

			try
			{
				//ファイルオブジェクトのネイティブパスにを生成
				file.nativePath = str;
			}
			//例外が発生した場合
			//(ファイルパスが不正な場合)
			catch(e :ArgumentError)
			{
				//ファイルのパスが不正な場合のエラーの結果オブジェクトを作成して、配列として返す
				return [new ValidationResult(true, baseField, "illegalFilePath", validator.illegalFilePathError)];
			}
			
			//ファイルしか許可しない場合に、ファイルオブジェクトの指す内容がディレクトリの場合
			if(validator.isOnlyFile && file.isDirectory)
			{
				//ファイルしか許可しないのにディレクトリのパスが指定された場合のエラーの結果オブジェクトを作成して、配列として返す
				return [new ValidationResult(true, baseField, "onlyFile", validator.onlyFileError)];
			}

			//ディレクトリしか許可しない場合に、ファイルオブジェクトの指す内容がファイルの場合
			if(validator.isOnlyDirectory && !file.isDirectory)
			{
				//ディレクトリしか許可しないのにファイルのパスが指定された場合のエラーの結果オブジェクトを作成して、配列として返す
				return [new ValidationResult(true, baseField, "onlyDirectory", validator.onlyDirectoryError)];
			}

			//存在するファイルしか許可しない場合に、ファイルオブジェクトの指す内容が存在しないファイルの場合
			if(validator.isOnlyExistFile && !file.exists)
			{
				//存在しないファイルのパスが指定された場合のエラーの結果オブジェクトを作成して、配列として返す
				return [new ValidationResult(true, baseField, "notExistsFile", validator.notExistsFileError)];
			}

	
			//最後までエラーがなかったので、空配列を返す
			return new Array();
		}


		//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
		//オーバーライドするメソッド
		
		/**
		 * 実際にバリデート処理を行うメソッドをオーバーライドします。
		 * 
		 * @param value 検証する値
		 * @return 無効な結果における ValidationResult オブジェクトの配列です。このオブジェクトは、検証に失敗したバリデータで検証が行われる各フィールドごとに 1 つ含まれます。
		 */
		override protected function doValidation(value :Object) :Array
		{
			//親クラスの処理を先に呼び出す
			var results :Array = super.doValidation(value);
			
			//親クラスの処理ですでにエラーが見つかった場合
			if(!ArrayUtil.isBlank(results))
			{
				//親クラスのメソッドの呼び出しから戻ってきた値をそのまま返す
				return results;
			}
			
			//引数のvalueの値を文字列に変換
			var str :String = StringUtil.escapeNull(value);

			//必須チェックを行わない場合に、検証する値がnullまたは空文字列の場合
			if(!super.required && StringUtil.isBlank(str))
			{
				//空配列を返す
				return new Array();
			}
			
			//このバリデーターの独自のチェック処理を呼び出し、結果をそのまま返す
			return validateFile(this, value, null);
		}

	}
}
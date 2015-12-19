package utils
{
	import flash.filesystem.*;

	public class AppUtil
	{
		public var file:File;
		public var currentVersion:String = "a0.1";
		
		public function AppUtil()	{}
		public static function system extension():void {
			file = File.applicationStorageDirectory;
			file = file.resolvePath("Preferences/version.txt");
			trace(file.nativePath);
			if(file.exists) {
				checkVersion();
			} else {
				firstRun();
			}
		}
		private static function checkVersion():void {
			var stream:FileStream = new FileStream();
			stream.open(file, FileMode.READ);
			var reversion:String = stream.readUTFBytes(stream.bytesAvailable);
			stream.close();
			if (reversion != currentVersion) {
				log.text = "You have updated to version " + currentVersion + ".\n";
			} else {
				saveFile();
			}
			log.text += "Welcome to the application.";
		}
		private static function firstRun():void {
			log.text = "Thank you for installing the application. \n"
				+ "This is the first time you have run it.";
			saveFile();
		}
		private static function saveFile():void {
			var stream:FileStream = new FileStream();
			stream.open(file, FileMode.WRITE);
			stream.writeUTFBytes(currentVersion);
			stream.close();
		}		
	}
}
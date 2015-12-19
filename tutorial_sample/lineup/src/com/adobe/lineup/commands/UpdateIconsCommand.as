package com.adobe.lineup.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.adobe.lineup.model.ModelLocator;
	
	import flash.desktop.NativeApplication;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	public class UpdateIconsCommand implements ICommand
	{
		public function execute(ce:CairngormEvent):void
		{
			var ml:ModelLocator = ModelLocator.getInstance();

			// Build app icons

			// Create an icon with the current date in it.
			var dateSprite:Sprite = new Sprite();
			dateSprite.width = 64;
			dateSprite.height = 64;
			
			var dateText:TextField = new TextField();
			dateText.width = 64;
			dateText.height = 64;
			dateText.autoSize = TextFieldAutoSize.CENTER;
			var textFormat:TextFormat = new TextFormat("Arial", 61, 0x2d2d2d, true);
			dateText.text = String(new Date().date);
			dateText.setTextFormat(textFormat);
			dateSprite.addChild(dateText);
			var dateData:BitmapData = new BitmapData(64, 64, true, 0x00000000);
			dateData.draw(dateSprite);
			var appData:BitmapData = new ml.appIconClass().bitmapData;
			appData.copyPixels(dateData,
							   new Rectangle(0, 0, dateData.width, dateData.height),
							   new Point(32, 36),
							   null, null, true);
			var appIcon:Bitmap = new Bitmap(appData);
			ml.appIcon = new Bitmap(appData);

			// Create notification icon
			var scaledAlert:BitmapData;

			var alertTmp:Bitmap = new ml.alertIconClass();
			alertTmp.scaleX = 64 / alertTmp.width;
			alertTmp.scaleY = 64 / alertTmp.height;

			scaledAlert = new BitmapData(alertTmp.width, alertTmp.height, true, 0xffffff);
			scaledAlert.draw(alertTmp, alertTmp.transform.matrix, null, null, null, true);

			var appBitmapData:BitmapData = ml.appIcon.bitmapData.clone();
			
			appBitmapData.copyPixels(scaledAlert,
								     new Rectangle(0, 0, scaledAlert.width, scaledAlert.height),
							   		 new Point(appBitmapData.width-scaledAlert.width, 0),
							   		 null, null, true);

			ml.notificationIcon = new Bitmap(appBitmapData);

			// If Windows, scale the app icon down.
			if (NativeApplication.supportsSystemTrayIcon)
			{
				ml.appIcon.scaleX = 16 / ml.appIcon.width;
				ml.appIcon.scaleY = 16 / ml.appIcon.height;
				var scaledApp:BitmapData = new BitmapData(ml.appIcon.width, ml.appIcon.height, true, 0xffffff);
				scaledApp.draw(ml.appIcon, ml.appIcon.transform.matrix, null, null, null, true);
				ml.appIcon = new Bitmap(scaledApp);
			}

			// Set the app icon.
			ml.purr.setIcons([ml.appIcon]);

			// Set up alert icons.
			if (NativeApplication.supportsDockIcon)
			{
				ml.alertIcon = new Bitmap(appBitmapData);
			}
			else if (NativeApplication.supportsSystemTrayIcon)  // Only need to do this once.
			{
				ml.alertIcon = new ml.alertIconClass();
				ml.alertIcon.scaleX = 16 / ml.alertIcon.width;
				ml.alertIcon.scaleY = 16 / ml.alertIcon.height;
				scaledAlert = new BitmapData(ml.alertIcon.width, ml.alertIcon.height, true, 0xffffff);
				//scaledAlert.draw(ml.alertIcon, ml.appIcon.transform.matrix, null, null, null, true);
				scaledAlert.draw(ml.alertIcon, ml.alertIcon.transform.matrix, null, null, null, true);
				ml.alertIcon = new Bitmap(scaledAlert);
			}
		}
	}
}

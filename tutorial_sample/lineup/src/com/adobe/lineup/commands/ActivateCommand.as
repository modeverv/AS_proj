package com.adobe.lineup.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.adobe.lineup.model.ModelLocator;
	
	public class ActivateCommand implements ICommand
	{
		public function execute(ce:CairngormEvent):void
		{
			var ml:ModelLocator = ModelLocator.getInstance();
			ml.purr.setIcons([ml.appIcon]);
		}
	}
}

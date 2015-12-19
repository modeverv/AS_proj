/*
ADOBE SYSTEMS INCORPORATED
 Copyright 2007 Adobe Systems Incorporated
 All Rights Reserved.
 
NOTICE:  Adobe permits you to use, modify, and distribute this file in accordance with the 
terms of the Adobe license agreement accompanying it.  If you have received this file from a 
source other than Adobe, then your use, modification, or distribution of it requires the prior 
written permission of Adobe.
*/

//spry command hack (to avoid eval)
Spry.Data.Region.behaviorAttrs["spry:command"] =
{
	attach: function(rgn, node, value)
	{
		var spryCommand = null;
		try { spryCommand = node.attributes.getNamedItem("spry:command").value; } catch (e) {}
		if (!spryCommand)
			spryCommand = "selected";

		Spry.Utils.addEventListener(node, "click", function(event) { doCmd(spryCommand, node); event.cancelBubble=true; }, false);
		
	}
};
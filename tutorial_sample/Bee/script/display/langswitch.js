/*
ADOBE SYSTEMS INCORPORATED
 Copyright 2007 Adobe Systems Incorporated
 All Rights Reserved.
 
NOTICE:  Adobe permits you to use, modify, and distribute this file in accordance with the 
terms of the Adobe license agreement accompanying it.  If you have received this file from a 
source other than Adobe, then your use, modification, or distribution of it requires the prior 
written permission of Adobe.
*/

function doMouseOver(elem, tip, e){
	if(!config['noShowTip'])
		Tip(tip, BALLOON, true, ABOVE, false, OFFSETX, -10, WIDTH, 120, TEXTALIGN, 'left', FADEIN, 600, FADEOUT, 300, PADDING, 8)
}


function attachMouseHandlers(elem, tip){
	elem.addEventListener('mouseover', function(e){
		doMouseOver(elem, tip, e);
	} );
}

function setLangAttr(e, p1, p2){
	
	if((typeof lang[p1])=='undefined'){ 
	
			if(p2)
			{
				var attr = e.attributes.getNamedItem(p2);
				if(!attr)
				{
					attr = document.createAttribute(p2);
					e.attributes.setNamedItem(attr);
					attr.value = p1;
					
				}
				
				
			}else{
				
				//if(e.innerHTML==''){
					
					//e.innerHTML = p1;
					
				//}
				
			}	
			return   p1 + "\n";			
	}
				
	if(p2)
	{
		var attr = e.attributes.getNamedItem(p2);
		if(!attr)
		{
			attr = document.createAttribute(p2);
			e.attributes.setNamedItem(attr);
		}
		attr.value = lang[p1];
	}
	else e.innerHTML = lang[p1];
	
	return '';
	
}
function parseDom(e)
{
	var str = "";
	while(e)
	{	
		if(e.nodeType==1)
		{
			var tip = null;
			var local = e.attributes.getNamedItem('local');
			if(local)
			{
				var local = local.value;
				
				var ps = local.split(':');
				
				var p1 = ps[0]; var p2 = ps[1];
				
				str+=setLangAttr(e, p1, p2);
				tip = p1;
			}
			
			for(var i=0;i<e.attributes.length;i++){
				var attr = e.attributes[i];
				if(attr.name.indexOf(':')!=-1){
					var ps = attr.name.split(':');
					
					if((typeof ps[1])!='undefined'&&ps[0]=='local')
					   {
						str+=setLangAttr(e, attr.value, ps[1]);
						if(!tip) tip = p1;
					   }
				}
									
			}
			if(tip && tooltips[tip])
				attachMouseHandlers(e, tooltips[tip]);
				
			if(e.firstChild) str+=parseDom(e.firstChild);
		}
		e = e.nextSibling;
	}
	return str;
}

function langRefreshUi()
{	

	window.lang = Bee.Application.getLang();
	
	
	// Access the page's DOM
	var str = parseDom(document.firstChild);
	
		if(str.length){
			str = "Undefiend language references in file "+document.location+":\n"+str;
			
			Bee.Application.traceErr(str);
		}
	
}


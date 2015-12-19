/*
ADOBE SYSTEMS INCORPORATED
 Copyright 2007 Adobe Systems Incorporated
 All Rights Reserved.
 
NOTICE:  Adobe permits you to use, modify, and distribute this file in accordance with the 
terms of the Adobe license agreement accompanying it.  If you have received this file from a 
source other than Adobe, then your use, modification, or distribution of it requires the prior 
written permission of Adobe.
*/
//spry eval-hack
eval = function(e){
	try{
	if(e[0]=='$'||(e[0]=='!'&&e[1]!='=')){
		var i = e.indexOf('(');
		var func = e.substr(1, i-1);
	
		var args = e.substr(i+1, e.length-i-2);
		
		if(e[0]=='$')
			return window[func].apply(null, args.split(','));
		else
			return ! (window[func].apply(null, args.split(',')));
	}else
	if(e.indexOf('==')!=-1)
	{
		var params =  e.split(/\=\=/);
		var p1 = (params[0]).replace(/^\s+|\s+$/g,"");
		var p2 =  (params[1]).replace(/^\s+|\s+$/g,"");
		return p1 == p2;
	}else	if(e.indexOf('!=')!=-1)
	{
		var params =  e.split(/\!\=/);
		var p1 = (params[0]).replace(/^\s+|\s+$/g,"");
		var p2 =  (params[1]).replace(/^\s+|\s+$/g,"");
		return p1 != p2;
	}
	return window[e];}catch(err){print_o(err, 'alert'); air.trace(e);}
}

/*
 * Copyright 2007-2008. Adobe Systems Incorporated.
 * All rights reserved.
 */

(function(){

	window._T = function(){
		var args = arguments;             
		var o = new Object;
		o.toString = function(){
			if(args.length>=3){ return air.Localizer.localizer.getString.apply(air.Localizer.localizer, args); }
			return "<span local_innerHTML='"+args[0]+"."+args[1]+"'>"+air.Localizer.localizer.getString.apply(air.Localizer.localizer, args)+"</span>";
		} 
		return o;
	};
	
	window._F = function(){
		var args = arguments;             
		var o = new Object;
		o.toString = function(){
				return air.Localizer.localizer.getFile.apply(air.Localizer.localizer, args);
		}
		return o;
	}
	
	window.getSupportedLocales = function(){
		return ['cs','de','en','es','fr','it','ja','ko', 'nl', 'pl', 'pt','ro','ru', 'sv', 'tr', 'zh_Hans','zh_Hant'];
	}
		
	window.setLocaleChain = function(locale){
		var newChain;
		if( locale == "default" ){
			newChain = air.Localizer.sortLanguagesByPreference( getSupportedLocales(), air.Capabilities.languages, 'en', true);
		}else{
			newChain = [ locale ];
		}
		
		air.Localizer.localizer.setLocaleChain( newChain );
		var lang = newChain[0];
		var scriptElement = document.createElement('script');
		scriptElement.charset = "utf-8";
		scriptElement.src = 'extjs/js/locale/ext-lang-'+lang+'.js';
		scriptElement.onload = function(){
			//refresh grid list
			try{
				if(Fresh.Reader.mainPanel.grid.store.getCount())
					Fresh.Reader.mainPanel.grid.store.reload();
			}catch(e){ 
					; //do nothing
				 }
		}
		document.body.appendChild(scriptElement);
	}
	 
	Ext.util.Format.localeDate = function(v, format){
		return Ext.util.Format.date(v, format);
	}
	
	
	//precompile formatting
	
	window.precompileDateFormating  = function(){
		var parsers = ['Y-m-d\\TH:i:sO', 'Y-m-d\\TH:i:s', 'Y-m-d', 
					  "y/m/d", "Y/m/d", "m/d/Y", "n/j/Y", "n/j/y", "m/j/y", "n/d/y", "m/j/Y", "n/d/Y", "m-d-y", "m-d-Y", "m/d", "m-d", "md", "mdy", "mdY", "d", "Y-m-d", "y年m月d日", "d.m.y", "d/m/Y", "d-m-y", "d-m-Y", "d/m", "d-m", "dm", "dmy", "dmY", "d.m.Y", "m/d/y", "d/m/y", "j/m/Y",  
						'D M j, Y, g:i a', 'g:i A', 'M j, Y', 'M j, Y, g:i a'
					  ];
		
		for(var i=0,l=parsers.length-1; i<l; i++ ){
			var parserItems = parsers[i].split('|');
			for(var j=0,k=parserItems.length;j<k;j++){
				Date.parseDate("2006", parserItems[j]);
				(new Date()).dateFormat( parserItems[j] );
			}
		}
	}
	
}());
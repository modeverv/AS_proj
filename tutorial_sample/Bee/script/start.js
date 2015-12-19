/**
 * @author achicu
 */
//wordpress didn't accept jsolait's xmlrpc date 
Date.prototype.toXmlRpc = function() {
        var padd = function(s, p) {
            s = p + s;
            return s.substring(s.length - p.length);
        };
        var y = padd(this.getUTCFullYear(), "0000");
        var m = padd(this.getUTCMonth() + 1, "00");
        var d = padd(this.getUTCDate(), "00");
        var h = padd(this.getUTCHours(), "00");
        var min = padd(this.getUTCMinutes(), "00");
        var s = padd(this.getUTCSeconds(), "00");
        //removed milliseconds in order to make wordpress happy
       // var ms = padd(this.getUTCMilliseconds(), "000");
        var isodate = y + m + d + "T" + h + ":" + min + ":" + s ;
        return "<dateTime.iso8601>" + isodate + "</dateTime.iso8601>";
    };


String.prototype.replaceAll = function(v1,v2)
{
	var _this = this;
	var i = _this.indexOf(v1);
	while(i > -1)
	{
		_this = _this.replace(v1, v2);
		i = _this.indexOf(v1, i + v2.length );
	}
	return _this;
}

Number.prototype.to2Chars = function(){
	if(this>=10) return this.toString();
	return "0"+this.toString();
}

function HTMLParser(){


}

HTMLParser.prototype.parseFromString = function(src, callback){
	var htmlControl = new air.HTMLLoader();
//	htmlControl.load(new air.URLRequest(url));
	htmlControl.loadString(src);
	htmlControl.addEventListener(air.Event.HTML_DOM_INITIALIZE   ,
		function (e){
			htmlControl.window.alert = function (e){
			}
		}
	);
	
	htmlControl.addEventListener(air.Event.COMPLETE  ,
		function(e){
			callback(htmlControl.window.document);
		}
	)
} 
 

 

 
 function getSecureStore(key){
	try{
 		var res = air.EncryptedLocalStore.getItem(key);
 		if(!res) return '';
		return res.readUTFBytes(res.length); 
	}catch(e){
		runtime.trace(e);
		resetStore();
		return '';
	}
 }
 
 function setSecureStore(key, value){
	try{
	 	var ba = new air.ByteArray();
	 	ba.writeUTFBytes(value);
	 	air.EncryptedLocalStore.setItem(key, ba, false);
	}catch(e){
		runtime.trace(e);
		resetStore();
	}
 }
 
 
 
 
var xmlRpc = imprt("xmlrpc");
 
xmlRpc._unmarshall = function(xml) {
        if (xml.blank())
            return {};
        return this.unmarshall('<?xml version="1.0" encoding="UTF-8"?><methodResponse><params><param><value>'+xml+'</value></param></params></methodResponse>');
}





String.prototype.trim = function() { return this.replace(/^\s+|\s+$/, ''); };
 function initConfig(){
	
	
	var ms = air.Screen.mainScreen;
	var rect = ms.visibleBounds;
	var spWidth = 472;
	var spHeight = 332;
	var splashRect = new air.Rectangle(
		(rect.left+rect.right-spWidth)/2, 
		(rect.top+rect.bottom-spHeight)/2,
		spWidth,
		spHeight 
	);
	var opt = new air.NativeWindowInitOptions();
	
	//with(opt){  -- aptana thinks this is wrong.. 
//	 	opt.appearsInWindowMenu = false;
// 	 	opt.hasMenu = false;
 	 	opt.maximizable = false;
 	 	opt.minimizable = false;
 	 	opt.resizable = false;
 	 	opt.systemChrome = 'none';
 	 	opt.transparent = 'true';
	//} 
	splash = air.HTMLLoader.createRootWindow(true, opt, false, splashRect);
	splash.window.nativeWindow.alwaysInFront  = true;
	splash.load(new air.URLRequest('splash.htm'));
	
	config = {
		langName : 'english',
		noShowTip : false,
		noShowStart : false,
		noMinimize : false,
		minWidth : 910,
		minHeight : 790,
		width:910,
		height:790,
		firstRun:true, 
		version:0.2, 
		x:0,
		y:0,
		firstConfig:true
	};
	
	config.x = (rect.left+rect.right-config.width)/2;
	config.y = (rect.top+rect.bottom-config.height)/2;
}


function readConfig(){
	var file = new air.File("app-storage:/config.xml");
	if(file.exists){
		try{
			var fileStream = new air.FileStream();
			fileStream.open(file, air.FileMode.READ);
			var xmlconfig = fileStream.readUTFBytes(file.size);
			fileStream.close();
			Object.extend(config, xmlRpc._unmarshall(xmlconfig));
			config.firstConfig = false;
		}catch(e){
			air.trace('readConfig:'+e);
		}
	}
}

function writeConfig(){
	var file = new air.File("app-storage:/config.xml");
	try{
		var fileStream = new air.FileStream();
		fileStream.open(file, air.FileMode.WRITE);
		var xmlconfig = xmlRpc.marshall(config);
		fileStream.writeUTFBytes(xmlconfig);
		fileStream.close();
	}catch(e){
		air.trace('writeConfig:'+e);
	}
}

initConfig();
readConfig();


function resetStore(){
	alert('Due to some incompatibility changes between Beta 2 and Beta 3 the application needs to reset your credentials, so you are required to log in again You can set up your blog/photo password again from Tools/Settings menu.');
	air.EncryptedLocalStore.reset();
}

config.firstRun = false;

 
 var _stripLt = /</gi;
 var _stripGt = />/gi
 function stripTags(str){
 	return str.replace(_stripLt, '&lt;').replace(_stripGt, '&gt;');
 }
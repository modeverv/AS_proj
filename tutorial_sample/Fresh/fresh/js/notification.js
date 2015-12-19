/*
 * Copyright 2007-2008. Adobe Systems Incorporated.
 * All rights reserved.
 */


function effect(startPixel, stopPixel, duration, callback, finish){
	var fps = 30;
	var transition = 0;
	var transitionEffect = function(pos){ return Math.pow(pos,2.5); }
	var currentEffect  = 0;
	var step = 1/(duration*fps);
	var currentPixel = startPixel;
	
	var interval = setInterval(function(){
		transition+=step; 
		if(transition>1) transition = 1;
		currentEffect = transitionEffect(transition);
		currentPixel = currentEffect * stopPixel + (1-currentEffect) * startPixel;
		
		if(nativeWindow.closed || callback(currentPixel)||transition>=1){
			 clearInterval(interval);
			 interval = null; 
			 if(finish) finish();
		}
	}, 1000/fps);
}


function onMouseMove() {
	//remove timeout
	if(timeout){
		clearTimeout(timeout);
		timeout = null;
	}
}

function onMouseOut() {
	//reenable timeout
	if(!timeout)
		timeout = setTimeout(closeFade, 800);
}

function popupFade(){
	document.body.style.opacity = 0;
	
	nativeWindow.height = 100;
	nativeWindow.width = 200;

	htmlLoader.addEventListener(runtime.flash.events.MouseEvent.MOUSE_MOVE, onMouseMove);
	htmlLoader.addEventListener(runtime.flash.events.MouseEvent.MOUSE_OUT, onMouseOut);
	
	var rect = air.Screen.mainScreen.visibleBounds;
	nativeWindow.x = air.NativeApplication.supportsDockIcon ? rect.right - nativeWindow.width - 20 : rect.right - nativeWindow.width;
	
	var yStart = air.NativeApplication.supportsDockIcon ? rect.top : rect.bottom; 
	var yEnd = air.NativeApplication.supportsDockIcon ? rect.top + 20 : rect.bottom - nativeWindow.height;
	effect(yStart, yEnd, 0.5, function(e){
			nativeWindow.y = e;
	});
	
	effect(0, 1, 0.4, function(e){
		document.body.style.opacity = e;
	});
	
	nativeWindow.notifyUser(air.NotificationType.INFORMATIONAL);
}

function closeFade(){
	effect(1, 0, 2, function(e){
			if(timeout)
				document.body.style.opacity = e;
			else 
				return true;
		},
		function(){
			if(timeout) {
				nativeWindow.close();
			}
			else {
				document.body.style.opacity = 1;
			}
		}
	);
}

function doLoad(){
	popupFade();
	setTimeout(function (){ window.nativeWindow.visible = true; }, 0);
	timeout = setTimeout(closeFade, 3000);
}

function doUnload() {
	htmlLoader.removeEventListener(runtime.flash.events.MouseEvent.MOUSE_MOVE, onMouseMove);
	htmlLoader.removeEventListener(runtime.flash.events.MouseEvent.MOUSE_OUT, onMouseOut);	
}

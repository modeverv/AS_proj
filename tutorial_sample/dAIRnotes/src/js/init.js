/**
 * CLASS
 *   $init
 * DESCRIPTION
 *   Handles dAIRnotes application instantiation.
 * USAGE
 *   N/A (internal use only)
 * @class
 * @private
 */
(function $init() {
	/**
	 * Flag to set true when we want debugging capabilities. Causes the
	 * AIRIntrospector to be loaded and initialized. The value of 
	 * 'debugMode' will only be checked at load time.
	 * @field
	 * @private
	 */
	var debugMode = false;
	
	/**
	 * Overwrite with your own initialization code.
	 * Note:
	 * You must replace the actual code, this cannot be altered at runtime.
	 * @method
	 * @private
	 */
	function initializeApplication () {
		dojo.require("dojo.parser");
		dojo.require("dijit.layout.ContentPane");
		dojo.require("dijit.layout.LayoutContainer");
		dojo.require("dijit.layout.SplitContainer");
		dojo.require("dijit.layout.ContentPane");
		dojo.require("dijit.TitlePane");
		dojo.require("dijit.layout.ContentPane");
		dojo.require("dijit.layout.TabContainer");
		dojo.require("dijit.form.Button");
		dojo.require("dijit.Editor");
		dojo.require("dijit.layout.AccordionContainer");
		dojo.require("dojox.storage.AirEncryptedLocalStorageProvider");
		dojo.require("dijit.form.CheckBox");
		dojo.require("dijit.form.CheckBox");
		dojo.require("dijit.form.NumberSpinner");
		dojo.require("dijit.form.ComboBox");
		dojo.require("dijit.form.TextBox");
		dojo.require("dijit.form.ValidationTextBox");
		dojo.require("dijit.form.Button");
		dojo.require("dijit.Dialog");
		dojo.require("dojox.storage.AirDBStorageProvider");
		dojo.require("dojox.storage.AirEncryptedLocalStorageProvider");
		dojo.require("dojox.storage.AirFileStorageProvider");
		dojo.require("dijit._Calendar")
        var main = Main.getDefault();
        main.run();
    }

	/**
	 * The path to load the debugger code from.
	 * @field
	 * @private
	 */
	var debugScriptPath = "AIRIntrospector/AIRIntrospector.js";
	
    /**
     * Holds a reference to the 'head' HTML Element in the page.
     * @field
     * @private
     */
    var headElement = null;

    /**
     * Retrieves a reference to the 'head' HTML Element in the page, if loaded 
     * so far.
     * @method
     * @private
     */
    function getHead() {
    	var headEl = document.getElementsByTagName("head")[0];
    	return headEl || null;
    }

    /**
     * Pings the DOM until the 'head' element gets loaded.
     * @method
     * @private
     * @param callback { Function }
     *      An application initialization function that needs to only run 
     *      *after* the AIRIntrospector is loaded, so that it is able to, say, 
     *      log initial XHR requests.
     */
    function pingHeadReady(callback) {
    	var head = getHead();
    	if(head) {
    		headElement = head;
    		if(callback instanceof Function) {callback.apply(this)}; 
    		return;
    	}
		window.setTimeout(pingHeadReady, 10);
    }

    /**
     * Inserts the debugger's code into the page's 'head' element.
     * @method
     * @private
     * @param callback { Function }
     *      Function that is to be run after the debugger's code gets loaded and
     *      evaluated.
     */
    function insertDebuggerCode(onLoadCallback) {
        var scriptElement = document.createElement('script');
        scriptElement.id = "debuggerScript";
        scriptElement.type = "text/javascript";
        scriptElement.src = "app:" + debugScriptPath;
        if(onLoadCallback instanceof Function) {
        	var that = this;
	    	scriptElement.onload = function() {
			    window.addEventListener('load', function() {
			    	onLoadCallback.apply(that, arguments);
			    }, false)		
	    	};
        }
        headElement.appendChild(scriptElement);
    }

    /**
     * Externalizes calls to the debugger's APIs.
     * @method
     * @private
     */
    function initializeDebugger() {
        window['log'] = air.Introspector.Console.log;
        window['warn'] = air.Introspector.Console.warn;
        window['info'] = air.Introspector.Console.info;
        window['error'] = air.Introspector.Console.error;
        window['dump'] = air.Introspector.Console.dump;
        info('AIR INtrospector ready.');
    }

    /**
     * Actually performs the initialization.
     * @method
     * @private
     */
    if(debugMode) {
    	pingHeadReady(function(){
    		insertDebuggerCode(function(){
    			initializeDebugger();
    			initializeApplication();
    		});
    	});
    } else {
        window.addEventListener('load', function() {
            initializeApplication();
        }, false)
    }
})();
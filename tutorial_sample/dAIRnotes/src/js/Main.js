/**
 * CLASS
 * 		Main
 * DESCRIPTION
 * 		Main class of the dAIRnotes application.
 * USAGE
 * 		var main = Main.getDefault();
 * 		main.run();
 * @class
 * @public
 */
Main = function() {
	throw(new Error(
			"You cannot instantiate the 'Main' class. " +
			"Instead, use 'Main.getDefault()' to retrieve the " +
			"class' unique instance."
	));
}
Main.getDefault = function() {
	var context = arguments.callee;
	if (context.instance) { return context.instance };
	function _main() {
		
		/**
		 * Let private methods see the class' instance.
		 * @field
		 * @private
		 */
        var that = this;
        
        /**
         * Convenience shortcuts. 
         * @field
         * @private
         */
        var wt = WidgetTools;
        var get;

		/**
		 * The main class' entry point.
		 * @method
		 * @public
		 */
		this.run = function() {
            unHideUI();
            StatusBar.getDefault().setMessage('Initializing UI...');
            initializeDojoWidgets();
            fixOnCloseTabsCrash();
            hideUnimplementedUI();
            hideLicenseTab();
            showAppToolbar();
            UIConector.getDefault().connectAllUI();
            Logout.getDefault().doLogout();
            window.setTimeout(function() {
                showAppBody();
            }, 500);
		}
        /**
         * Holds an array with all Dojo widgets defined by this application.
         * @field
         * @private
         */
		var dojoWidgets = {};
		
		/**
		 * Returns a dojo widget object given its ID.
		 * @method
		 * @public
		 * @param widgetId { String }
		 *    The ID of the widget to retrieve.
		 * @return { Object }
		 *    The associated Dojo widget, or null if it cannot be found
		 */
		this.getWidget = function(widgetId) {
			return dojoWidgets[widgetId] || null;
		}
		get = this.getWidget;
		
		/**
		 * Adds a widget declared programmatically to our hash of widgets.
		 * @method
		 * @public
		 * @param widgetId { String }
		 *    The id of the newly created widget. Must be unique, or else an 
		 *    error is being thrown.
		 * @param widgetObject { Object }
		 *    A reference to the newly created widget object.
		 */
		this.addDeclaredWidget = function(widgetId, widgetObject) {
			if(!dojoWidgets[widgetId]) {
				dojoWidgets[widgetId] = widgetObject;
			} else {
				throw(new Error("Cannot add declared widget. Provided id '"+
				    widgetId+ "' already exists."));
			}
		}

		 /**
		  * Parses and then patches all Dojo widgets used by the application
		  * in order to make them able to work under AIR.
		  * @method
		  * @private
		  */
		function initializeDojoWidgets() {
		    dojoWidgets = onDemandParseDojoWidgets();
		}

        /**
         * Unhides the application's UI.
         * @method
         * @private
         */        
        function unHideUI() {
            var ui = dojo.byId('content');
            ui.style.visibility = 'visible';
        }

        /**
         * Shows the application's toolbar.
         * @method
		 * @private
         */
        function showAppToolbar() {
            var tb = dojo.byId('toolbarRecipient');
            tb.style.visibility = 'visible';
        }

       /**
        * Shows the application's body.
        * @method
        * @private
        */
        function showAppBody() {
            var sc = dojo.byId('splitContainerParent');
            sc.style.visibility = 'visible';
        }

		/**
		 * Helps accessing Dijits programmatically, although they have been 
		 * created declarativelly.
		 * @method
		 * @private
		 * @return { Object }
		 *		A hash holding all the parsed dojo widgets, indexed by their 
		 *		unique IDs.
		 */
		function onDemandParseDojoWidgets() {
		     var uiRec = dojo.byId('UI');
		     var ret = {};
		     if(uiRec) {
		         var res = dojo.parser.parse(uiRec);
		         for(var i=0; i<res.length; i++) {
		         	var widget = res[i];
		         	ret[widget.id] = widget;
		         }
		     }
		     return ret;
		}
		
		/**
		 * Hides UI elements related to features not yet implemented in this 
		 * version.
		 * @method
		 * @private
		 */
		function hideUnimplementedUI() {
			showAppToolbar = function(){};
			wt.hide(get("appSettingsPane"));
			wt.hide(get("searchToolPage"));
			wt.hide(get("exportToolPage"));
			wt.hide(get("previewToolPage"));
			wt.hide(get("task2"));
			dojo.byId("task2Label").style.display = "none";
			wt.hide(get("task4"));
			dojo.byId("task4Label").style.display = "none";
			wt.hide(get("task5"));
			dojo.byId("task5Label").style.display = "none";
			wt.hide(get("users3"));
			dojo.byId("users3Label").style.display = "none";
		}
		
		/**
		 * Hides the 'License' tab.
		 * @method
		 * @private
		 */
		function hideLicenseTab() {
            var tabContainer = get("tabsWidget");
            WidgetTools.deactivate(tabContainer, 2);
		}

		/**
		 * Fixes crash on closing tab pages.
		 * TODO: submit bug to Dojo.
		 * @method
		 * @private
		 */
		function fixOnCloseTabsCrash() {
			var tabs = get("tabsWidget");
			var getChildIndex = function(child) {
				var children = tabs.getChildren();
				for(var i=0; i<children.length; i++) {
					if(children[i] === child) { return i };
				}
			}
			var _closeChild = function(child) {
				var childIndex = getChildIndex(child);
				wt.deactivate(tabs, childIndex);
				if(child.onClose){
					child.onClose.apply(child);
				}
			}
			tabs.closeChild = _closeChild;
		}
	}
	context.instance = new _main();
	return context.instance;
}
/**
 * CLASS
 *      Logout
 * DESCRIPTION
 *      Handles the logout process..
 * USAGE
 *      Logout.getDefault().doLogout();
 
 * @class
 * @public
 */
Logout = function() {
    throw(new Error(
            "You cannot instantiate the 'Logout' class. " +
            "Instead, use 'Logout.getDefault()' to retrieve the " +
            "class' unique instance."
    ));
}
Logout.getDefault = function() {
    var context = arguments.callee;
    if (context.instance) { return context.instance };
    function _logout() {

        /**
         * Sets the application's UI in the 'logged out' state.
         * @method
         * @private
         */    	
    	function setUIToLoggedOutState() {
    		var wt = WidgetTools;
    		var get = Main.getDefault().getWidget;
    		wt.deactivate(get('createUserSubPane'));
    		wt.hide(get('createUserSubPane'));
    		wt.deactivate(get('manageAccountSubPane'));
    		wt.hide(get('manageAccountSubPane'));
    		wt.deactivate(get('tasksPane'));
    		wt.disable(get('tasksPane'));
    		wt.deactivate(get('appSettingsPane'));
    		wt.disable(get('appSettingsPane'));
    		wt.deactivate(get('accordionWidget'));
    		wt.disable(get('accordionWidget'));
    		wt.enable(get('users2'));
    		wt.disable(get('users3'));
    		wt.show(get('loginButton'));
    		wt.show(get('cancelLoginButton'));
    		wt.enable(get('loginSubPane'));
    		wt.deactivate(get('loginSubPane'));
    		dojo.byId("loggedInText").style.display = "none";
    		wt.hide(get('logMeOutButton'));
    		wt.hide(get('loginSubPane'));
    		wt.disable(get('anonymous'));
            get('editorWidget').setValue("");
            dojo.byId("userNameModuleRecipient").style.display = "";
            dojo.byId("passwordModuleRecipient").style.display = "";
            dojo.byId("anounymousModuleRecipient").style.display = "";
            dojo.byId("publicAccountsDescription").style.display = "";
            window.setTimeout(function() {
	    		wt.show(get('loginSubPane'));
	    		wt.enable(get('users1'));
	    		get('users1').setChecked(true);
	    		wt.activate(get('loginSubPane'));
	    		var combo = get('userNameCombo');
	    		combo.focus();
	    		StatusBar.getDefault().setMessage('Please login into dAIRnotes');
            }, 1000);
    	}

        /**
         * Disconects all current sessions.
         * @method
         * @private
         */    	
    	function killAllSessions() {
    		Login.getDefault().endSession();
    	}
    	
        /**
         * Retrieves a list of users and populates the associated combobox.
         * @method
         * @private
         */
        this.populateUsersCombo = function() {
        	var combo = Main.getDefault().getWidget('userNameCombo');
			combo.store.root.innerHTML = "";
        	var users = Storage.getDefault().retrieveUsersList();
        	if(users.length) {
        		var makeOption = function(val) {
					var el = document.createElement("option");
					el.value = val;
                    el.innerHTML = val; 					
        		    combo.store.root.appendChild(el);
        		}
                for(var i=0; i<users.length; i++) {
                	makeOption(users[i]);
                }
        	}
        }

        /**
         * Logs current user out, if any.
         * @method
         * @public
         */	
    	this.doLogout = function() {
    		killAllSessions();
    		setUIToLoggedOutState();
    		this.populateUsersCombo();
    	}
    }
    context.instance = new _logout();
    return context.instance;
}
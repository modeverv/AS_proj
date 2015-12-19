/**
 * CLASS
 *      Login
 * DESCRIPTION
 *      Handles the logout process..
 * USAGE
 *      Login.getDefault().doLogin();
 
 * @class
 * @public
 */
Login = function() {
    throw(new Error(
            "You cannot instantiate the 'Login' class. " +
            "Instead, use 'Login.getDefault()' to retrieve the " +
            "class' unique instance."
    ));
}
Login.getDefault = function() {
    var context = arguments.callee;
    if (context.instance) { return context.instance };
    function _login() {
        
        /**
         * Let private methods see the class' instance.
         * @field
         * @private
         */
        var that = this;
        
        /**
         * Holds the name of the user currently logged in, should there be one.
         * @field
         * @private
         */        
        var userLoggedIn = null;
        
        /**
         * Holds current user's access type.
         * @field
         * @private
         */        
        var hasReadOnlyAccess = false;
        
        /**
         * Flag we raise when a user has requested anonymous, read-only access.
         * @field
         * @private
         */
        var hasRequestedReadOnlyAccess = false;

        /**
         * Alters the UI to reflect a successfully login.
         * @method
         * @private
         */        
        function setUIToLoggedInState() {
            var get = Main.getDefault().getWidget;
            var wt = WidgetTools;
            get("users1").setChecked(false);
            wt.disable(get("users1"));
            wt.deactivate(get('loginSubPane'));
            window.setTimeout(function(){
	            dojo.byId("userNameModuleRecipient").style.display = "none";
	            dojo.byId("passwordModuleRecipient").style.display = "none";
	            dojo.byId("anounymousModuleRecipient").style.display = "none";
	            dojo.byId("publicAccountsDescription").style.display = "none";
	            wt.hide(get("loginButton"));
	            wt.hide(get("cancelLoginButton"));
	            dojo.byId("loggedInText").innerHTML = [
		            "Logged in as <strong>"+userLoggedIn+"</strong>",
		            (that.isUserReadOnly && hasRequestedReadOnlyAccess?
		                  '<br /><em>(<u>read only</u>)</em>' : '')
	            ].join('');
	            dojo.byId("loggedInText").style.display = "";
	            wt.show(get("logMeOutButton"));
	            wt.enable(get("logMeOutButton"));
	            wt.activate(get('loginSubPane'));
            }, 250);
        }
        
        /**
         * Checks whether an user is currently logged in.
         * @method
         * @public
         * @return { Boolean }
         *      True, if a user is currently logged in; false otherwise.
         */
        this.isUserLoggedIn = function() {
        	return (userLoggedIn !== null);
        }

        /**
         * Clears the user currently logged in, effectively logging him out.
         * @method
         * @public
         */        
        this.endSession = function() {
        	userLoggedIn = null;
        	hasReadOnlyAccess = false;
        }
        
        /**
         * Will grant readonly access to current user.
         * @method
         * @public 
         */
        this.setReadOnlyAccess = function(){
        	hasReadOnlyAccess = true;
        }

        /**
         * Checks whether currently logged-in user has readonly access.
         * @method
         * @public 
         */        
        this.isUserReadOnly = function() {
        	return hasReadOnlyAccess;
        }
        
        /**
         * Possibly authenticates an user using provided credentials.
         * @method
         * @public
         * @param username { String }
         *      The user's name.
         * @param password { String }
         *      The user's password.
         * @param anonymousRequest { Boolean }
         *      Whether this user requests to login anonymously (i.e., into a 
         *      public account). 
         * @return { Boolean }
         *      True if the authentication succeeded, false otherwise.
         */
        this.authenticateUser = function(username, password, anonymousRequest) {
        	var ret;
        	try {
	        	ret = Storage.getDefault().confirmUser(
	        	   username,
	        	   password,
	        	   anonymousRequest
	        	)
        	} catch(e) {
        		ret = false;
        	}
        	if(ret) {
        		userLoggedIn = username;
        		hasRequestedReadOnlyAccess = anonymousRequest;
        		setUIToLoggedInState();
        		return true;
        	}
        	return false;
        }
    }
    context.instance = new _login();
    return context.instance;
}
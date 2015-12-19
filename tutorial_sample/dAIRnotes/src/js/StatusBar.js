/**
 * CLASS
 *      StatusBar
 * DESCRIPTION
 *      Handles the logout process..
 * USAGE
 *      StatusBar.getDefault().setMessage("Hello World");
 
 * @class
 * @public
 */
StatusBar = function() {
    throw(new Error(
            "You cannot instantiate the 'StatusBar' class. " +
            "Instead, use 'StatusBar.getDefault()' to retrieve the " +
            "class' unique instance."
    ));
}
StatusBar.getDefault = function() {
    var context = arguments.callee;
    if (context.instance) { return context.instance };
    function _statusBar() {
        
        /**
         * Obtains the DOM element representing the status bar.
         * @method
         * @private
         * @return { DOM Element }
         *      The DOM element representing the status bar.
         */
        function getStatusBar() {
            return dojo.byId('statusBarContainer') || null;
        }
        
        /**
         * Displays the given message.
         * @method
         * @public
         * @param message { String }
         *      The message to display.
         */
        this.setMessage = function(message) {
        	var sb = getStatusBar();
        	if(sb) {
        		sb.innerHTML = message;
        	}
        }
        
         /**
         * Clears the status bar.
         * @method
         * @public
         */
        this.clear = function() {
            this.setMessage("");
        }
    }
    context.instance = new _statusBar();
    return context.instance;
}
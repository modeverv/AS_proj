/**
 * CLASS
 *      User
 * DESCRIPTION
 *      Internally represents an user to the application.
 * USAGE
 *      var myUser = new User('John-Doe', '1234', 'true');
 * @class
 * @public
 */
User = function(name, password, isPublic) {
    
    /**
     * User's name.
     * @field
     * @private
     */
	var _name = name;

    /**
     * User's password.
     * @field
     * @private
     */
	var _password = password;

    /**
     * User's account type.
     * @field
     * @private
     */
	var _isPublic = isPublic;

    /**
     * Users's generated unique id.
     * @field
     * @private
     */
	var _uniqueid = User.makeNewUid();

    /**
     * User's saved preferences.
     * @field
     * @private
     */
	var _prefferences = {};

    /**
     * User's saved settings.
     * @field
     * @private
     */
	var _settings = {};
	
	/**
	 * Make the class' instance available to private methods.
	 * @field
	 * @private
	 */
	var that = this;
	
	/**
	 * Custom initialization for class User.
	 * @method
	 * @private
	 */
	function init() {
		var s = Storage.getDefault();
		var haveThisUSer = s.checkIfUserExists(_name);
		if(haveThisUSer) {
			throw (new Error("User <strong>" +_name+ "</strong> is already " +
					"registered. <br /> Please choose a different name."));
		}
		save();
	}
	
	/**
	 * Makes a copy of the given object rather than returning a reference to it.
	 * @method
	 * @private
	 * @return { Object }
	 *     A clone of the given hash.
	 */
	function cloneHash(hash) {
		var ret = {};
		for(var key in hash) {
			ret[key] = (hash[key] === null)? null:
			   (typeof hash[key] == "object")? cloneHash(hash[key]):
			    hash[key];
		}
	}
	
	/**
	 * Phisically saves this user's data to the storage.
	 * @method
	 * @private
	 */
	function save(){
		var s = Storage.getDefault();
		var ud = that.exportUserData();
		s.saveUserData(ud);
	}
	
	/**
	 * Exports a hash containing all user data. The hash table's
     * structure is as follows:
     *      {
     *          name     : String,
     *          password : String,
     *          uniqueid : String,
     *          isPublic : Boolean,
     *          prefferences: 
     *           { <key> : <value>, ... }
     *          settings: 
     *           { <key> : <value>, ... }
     *      }
     * @method
     * @public
     * @return { Object }
     *      The user's data as a hash table.
	 */
	this.exportUserData = function() {
		return {
			'name'         : _name,
			'password'     : _password,
			'uniqueid'     : _uniqueid,
			'isPublic'     : _isPublic,
			'prefferences' : cloneHash(_prefferences),
			'settings'     : cloneHash(_settings)
		}
	}
	
	// @run this class' custom init code.
	init();
}

/**
 * Creates and returns a unique id to be used for uniquely identifying 
 * an user.
 * @method
 * @public
 * @static
 * @return { String }
 *      The unique id, in the form of /^usr_\d{10}_\d{9,}$/
 */
User.makeNewUid = function() {
    var n = Math.floor(Math.random() * (10000000000));
    var t = (new Date()).getTime();
    var a = new Array('usr',n,t);
    return a.join('_');
}
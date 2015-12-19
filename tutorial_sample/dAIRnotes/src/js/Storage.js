/**
 * CLASS
 *      Storage
 * DESCRIPTION
 *      Handles the distributed storage of the application & user data.
 * USAGE
 *      Storage.getDefault().getUser("John Doe");
 
 * @class
 * @public
 */
Storage = function() {
    throw(new Error(
            "You cannot instantiate the 'Storage' class. " +
            "Instead, use 'Storage.getDefault()' to retrieve the " +
            "class' unique instance."
    ));
}
Storage.getDefault = function() {
    var context = arguments.callee;
    if (context.instance) { return context.instance };
    function _storage() {
    	
    	/**
    	 * Let private methods see this class' instance.
    	 * @field
    	 * @private
    	 */
    	var that = this;
    	
    	/**
    	 * The name space prefix to use for storing values. 
    	 * @field
    	 * @private 
    	 */
    	var nameSpace = "_dAIRnotes_";
    	
    	/**
    	 * The name space suffix to use for storing values. To be customized per
    	 * client/request basis.
    	 * @field
    	 * @private
    	 */
    	var suffix = "";
    	
    	/**
    	 * Generic result handler function to be used for all storage 
    	 * transactions.
    	 * @method
    	 * @private
    	 * @param resultType { String }
    	 *     The type of the result, either success or failure.
    	 * @param keyName { String }
    	 *     The key whose transaction succeedded or failed.
    	 * @param resultBody { String }
    	 *     Null for successs, holds error's text on failure.
    	 */
    	var resultHandler = function(resultType, keyName, resultBody) {
    		var t = runtime.trace;
    		t("\n");
    		t("RESULT: " +resultType);
    		t("KEY: " +keyName);
    		t("ERROR: " +resultBody);
    		t("\n");
    	}

    	/**
    	 * Represent's the AIR's Encrypted Local Store.
    	 * @field
    	 * @private
    	 */
    	var ENCRYPTED_STORAGE = dojox.storage.AirEncryptedLocalStorageProvider;

    	/**
    	 * Represents the AIR's Local SQLite Database storage.
    	 * @field
    	 * @private
    	 */
    	var DB_STORAGE = dojox.storage.AirDBStorageProvider;

    	/**
    	 * Represents a file-based storage system.
    	 * @field
    	 * @private
    	 */
    	var FILE_STORAGE = dojox.storage.AirFileStorageProvider;

    	/**
    	 * Holds a reference to the manager that controls the Dojo's storage 
    	 * providers collection.
    	 * @field
    	 * @private
    	 */
    	var manager = dojox.storage.manager;

        /**
         * Holds the timestamp to use for all calls to 'saveDiaryEntry()'
         * durring current session. There will be only one timestamp used per 
         * session.
         * @field
         * @private
         */
        var diaryEntryTimeStamp = null;

        /**
         * Custom initialization for class Storage.
         * @method
         * @private
         */
        function init() {
            // @overwrite AirEncryptedLocalStorageProvider.hasKey():
            manager.setProvider(ENCRYPTED_STORAGE);
            manager.currentProvider.hasKey = function (key, namespace) {
            	return (String(this.get(key, namespace)).length != 0); 
            }
        }

        /**
         * Generic method to save one single, named value.
         * @method
         * @private
         * @param key { String }
         *      The key that represents the value to be stored.
         * @param value { Object }
         *      An object to be stored (it will be strignyfied to JSON)
         * @param storage { Object }
         *      The storage that will accept the value given as parameter. One
         *      of ENCRYPTED_STORAGE, DB_STORAGE or FILE_STORAGE.
         * 
         */
        function save(key, value, storage) {
        	if((typeof key != "undefined" && key !== null) &&
        	   (typeof value != "undefined" && value !== null)) {
	    		manager.setProvider(storage);
	    		manager.currentProvider.put(key, value, resultHandler,
	    		    nameSpace+suffix);
        	}
        }

        /**
         * Generic method to save collections. Subsequent calls will append 
         * rather than overwrite.
         * @method
         * @private
         * @param prefix { String }
         *      The unique prefix that will represent the collection to save.
         * @param array { Object }
         *      A collection or arbitrary value to save.
         * @param storage { Object }
         *      The storage that will accept the value given as parameter. One
         *      of ENCRYPTED_STORAGE, DB_STORAGE or FILE_STORAGE.
         */
        function saveToCollection(prefix, data, storage) {
        	if ((typeof prefix != "undefined" && prefix !== null) &&
        	    (typeof data != "undefined" && data !== null)) {
        		var makeKey = function(prefix, index) {
        			return [prefix, index].join('_');
        		}
    			var counter = 0; 
        		if(data.length && (typeof data != "string")){ 
        			data.reverse();
	        		while (data.length) {
	        			var value = data.pop();
	        			while(lookUp(makeKey(prefix,counter))){ counter++ };
	        			save(makeKey(prefix,counter), value, storage);
	        		}
        		} else {
        			var value = data;
        			while(lookUp(makeKey(prefix,counter))){ counter++ };
        			save(makeKey(prefix,counter), value, storage);
        		}
        	}
        }

        /**
         * Generic method to read one single, named value.
         * @method
         * @private
         * @param key { String }
         *      The key that represents the value to be read.
         * @param storage { Object }
         *      The storage that will possibly provide the expected value. One
         *      of ENCRYPTED_STORAGE, DB_STORAGE or FILE_STORAGE.
         * @return { Object }
         *      The object previously stored under the given key, or null if 
         *      there is no such key.
         */
        function read (key, storage) {
        	if(typeof key != "undefined" && key !== null) {
        		manager.setProvider(storage);
        		return manager.currentProvider.get(key, nameSpace+suffix);
        	}
        	return null;
        }

        /**
         * Generic method to read collections.
         * @method
         * @private
         * @param prefix { String }
         *      The unique prefix that will represent the collection to read.
         * @param storage { Object }
         *      The storage that will possibly provide the expected values. One 
         *      of ENCRYPTED_STORAGE, DB_STORAGE or FILE_STORAGE.
         * @return { Array }
         *      The collection previously stored under the given prefix, or null
         *      if there is no such prefix.
         */
        function readFromCollection (prefix, storage) {
        	if(typeof prefix != "undefined" && prefix !== null) {
                var makeKey = function(prefix, index) {
                    return [prefix, index].join('_');
                }
	        	manager.setProvider(storage);
                var counter = 0;
	        	var ret = [];
                while(lookUp(makeKey(prefix,counter))){
        			ret.push(read(makeKey(prefix,counter), storage));
                	counter++;
                }
        		return ret;
        	}
        	return null;
        }

        /**
         * Generic method to delete one single, named value.
         * @method
         * @private
         * @param key { String }
         *      The key that represents the value to be deleted.
         * @param storage { Object }
         *      The storage that is expected to have stored the key to be 
         *      deleted. One of ENCRYPTED_STORAGE, DB_STORAGE or FILE_STORAGE. 
         */
        function del(key, storage) {
            if(typeof key != "undefined" && key !== null) {
                manager.setProvider(storage);
                manager.currentProvider.remove(key, nameSpace+suffix);
            }
        }

        /**
         * Generic method to delete collections.
         * @method
         * @private
         * @param prefix { String }
         *      The unique prefix that will represent the collection to be
         *      deleted.
         * @param storage { Object }
         *      The storage that is expected to contain the collection to be 
         *      deleted. One of ENCRYPTED_STORAGE, DB_STORAGE or FILE_STORAGE.
         */
        function delCollection(prefix, storage) {
            if(typeof prefix != "undefined" && prefix !== null) {
                manager.setProvider(storage);
                var cp = manager.currentProvider;
                var c = 0;
                while(cp.hasKey(prefix + "_" + c), nameSpace+suffix) {
                    del(prefix + "_" + c, storage);
                    c++;
                }
            }
        }

        /**
         * Looks up the given key in the given storage.
         * @method
         * @private
         * @param key { String }
         *      The key to look up.
         * @storage { Object }
         *      The storage to look into.
         * @return { Boolean }
         *      True, if the key has been found, false otherwise.
         */
        function lookUp(key, storage) {
        	if(typeof key != "undefined" && key !== null) {
                manager.setProvider(storage);
                return manager.currentProvider.hasKey(key, nameSpace+suffix);
        	}
        	return false;
        }
        
        /**
         * Performs actual check on given credentials.
         * @method
         * @private
         * @see this.confirmUser(user, pass, anonymous)
         */
        function confirmUSerCredentials(user, pass, anonymous) {
        	that.registerOwner(user);
        	var res = read(user, ENCRYPTED_STORAGE);
        	if(res) {
        		var data = res.split('|');
        		var password = data[0];
        		var uniqueid = data[1];
        		var isPublic = (data[2] === "true")? true: false;
                
                // @grant read-only anonymous access for public accounts:
        		if(anonymous && isPublic) {
        			that.registerOwner(uniqueid);
        			Login.getDefault().setReadOnlyAccess();
        			return true;
        		}
        		
        		// @check password for other accounts:
        		if(pass === password) {
	        		that.registerOwner(uniqueid);
                    return true;
        		}
        	}
        	
        	// @otherwise fail:
        	that.registerOwner("");
        	return false;
        }

        /**
         * Registers the given user as the owner of all future transactions.
         * @method
         * @public
         * @param name { String }
         *      The user name to be registered as owner.
         * @see saveUserData()
         */
        this.registerOwner = function(name) {
        	suffix = name;
        }

        /**
         * Saves a diary entry to the storage. 
         * Note:
         * Diary entries are saved into the database, so that they are easy to
         * browse/search. 
         * @method
         * @public
         * @param content { String }
         *      The text content of the diary entry.
         * @param timeStamp { Number }
         *      Optional. The date stamp associated with the entry to save. If
         *      omitted, the current datestamp is assumed.
         */
        this.saveDiaryEntry = function(content, timeStamp){
        	if(content && String(content).length) {
	        	var time = diaryEntryTimeStamp ||
	        	    (diaryEntryTimeStamp = (new Date()).getTime());
        		save("DE_"+time, content, DB_STORAGE);
        	}
        }

        /**
         * Save personal user data to the storage.
         * Note:
         * - sensitive information, like user name, password and personal UID 
         *   are kept inside the encrypted local storage;
         * - non sensitive information, like user application settings are kept 
         *   externally, in files to allow emergency changes outside the
         *   application.
         * @method
         * @public
         * @param data { Object }
         *      Hash table holding user data to be saved.
         * @see User.exportUserData()
         */
        this.saveUserData = function(userData) {
        	this.registerOwner(userData.name);
        	
        	// @name, password and uniqueid:
        	var key = userData.name;
        	var value = [
        	   userData.password,
        	   userData.uniqueid,
        	   userData.isPublic
        	].join('|');
        	save(key, value, ENCRYPTED_STORAGE);

        	// @application prefferences & settings:
        	for(var k in userData.prefferences) {
        		save(k, userData.prefferences[k], FILE_STORAGE);
        	}
        	for(var L in userData.settings) {
        		save(L, userData.settings[L], FILE_STORAGE);
        	}

        	// @save name to users list -- do this nonymously:
        	this.registerOwner("");
        	saveToCollection('usersList',
        	   userData.name + (userData.isPublic? " [public]" : ""),
        	   ENCRYPTED_STORAGE);
        	this.registerOwner(userData.name);
        }
        
        /**
         * Determines whether an user with the given hame has already been 
         * registered.
         * @method
         * @public
         * @param userName { String }
         *      The user name to check.
         * @return { Boolean }
         *      True if such a user exists, false otherwise.
         */
        this.checkIfUserExists = function(userName) {
        	var users = this.retrieveUsersList();
        	for(var i=0; i<users.length; i++) {
        		var usr = users[i].split(' [public]').join('');
        		if(usr == userName) { return true }
        	}
        	return false;
        }
        
        /**
         * Obtains the list of users (needed for populating the users combobox).
         * @method
         * @public
         * return { Array }
         *      A possible empty array holding all user names registered to the 
         *      application.
         */
        this.retrieveUsersList = function() {
        	this.registerOwner("");
            return readFromCollection('usersList', ENCRYPTED_STORAGE);
        }
        
        /**
         * Retrieves a list with all the entries this user has ever written.
         * @method
         * @public
         * @return { Array }
         *      A possibly emtly list with all the entries written by this user.
         */
        this.retrieveEntriesList = function() {
        	if(Login.getDefault().isUserLoggedIn()){
        		manager.setProvider(DB_STORAGE);
        		return manager.currentProvider.getKeys(nameSpace+suffix);
        	}
        	return [];
        }
        
        /**
         * Obtains the text associated with the given entry key.
         * @method
         * @public
         * @return { String }
         *      The text of the entry, or null if such an entry cannot be found.
         */
        this.retrieveEntry = function(entryKey) {
        	if(Login.getDefault().isUserLoggedIn()){
	        	return read(entryKey, DB_STORAGE);
        	}
        	return null;
        }
        
       /**
         * Proofs given user credentials.
         * @method
         * @public
         * @param user { String }
         *      The user's name.
         * @param pass { String }
         *      The user's password.
         * @param anonymous { Boolean }
         *      Whether this user requests to login anonymously (i.e., into a
         *      public account).
         * @return { Boolean }
         *      True, if confirmation succeeds, false otherwise.
         */
        this.confirmUser = function(user, pass, anonymous) {
        	var ret = confirmUSerCredentials(user, pass, anonymous);
        	if(ret) {diaryEntryTimeStamp = null};
        	return ret;
        }
        
        // @run this class' initialization code
        init();
    }
    context.instance = new _storage();
    return context.instance;
}
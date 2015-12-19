/**
 * CLASS
 *      UIConector
 * DESCRIPTION
 *      Connects UI elements with associated functionality.
 * USAGE
 *      N/A
 * @class
 * @public
 */
UIConector = function() {
    throw(new Error(
            "You cannot instantiate the 'UIConector' class. " +
            "Instead, use 'UIConector.getDefault()' to retrieve the " +
            "class' unique instance."
    ));
}
UIConector.getDefault = function() {
    var context = arguments.callee;
    if (context.instance) { return context.instance };
    function _uiConector() {
        /**
         * Convenience shortcuts. 
         * @field
         * @private
         */
    	var get = Main.getDefault().getWidget;
        var wt = WidgetTools;

		/**
		 * The entries found for this month.
		 * @field
		 * @private
		 */
    	var entriesThisMonth = null;
        
        /**
         * Default value to pre-fill in the editor.
         * @field
         * @private
         */
        var editorDefaultValue = "";
        
        /**
         * Connects radio buttons inside the 'Users' panel.
         * @method
         * @private
         */        
        function connectUserPanelRadioButtons() {
            get("users1").onClick = onUsersRadioButtonsClick;	
            get("users2").onClick = onUsersRadioButtonsClick;	
            get("users3").onClick = onUsersRadioButtonsClick;	
        }
        
        /**
         * Callback for any of the 'users' panel radio buttons.
         * @method
         * @private
         * @param event { Event }
         *      The mouse event dispatched.
         */
        function onUsersRadioButtonsClick(event) {
        	var allPanels = [
        	   'loginSubPane',
        	   'createUserSubPane',
        	   'manageAccountSubPane'
        	];
        	var inputEl = event.target;
        	var relatedPaneIndex = parseInt(inputEl.id
        	   .charAt(inputEl.id.length-1))-1;
        	for(var i=0; i<allPanels.length; i++) {
        		if(i == relatedPaneIndex) {
        			wt.show(get(allPanels[i]));
        			wt.enable(get(allPanels[i]));
        			wt.activate(get(allPanels[i]));
        			var firstDescendant = get(allPanels[i])
        			     .getDescendants()[0].focus();
        		} else {
        			wt.deactivate(get(allPanels[i]));
        			wt.disable(get(allPanels[i]));
        			wt.hide(get(allPanels[i]));
        		}
        	}
        }
        
        /**
         * Connects UI controls inside the 'create new user' panel.
         * @method
         * @private
         */
        function connectCreateUserUI() {
        	get("newUserName").isValid = isUserCredentialsValid;
        	get("newUserPass").isValid = isPasswordFieldValid;
        	get("confirmNewUserPass").isValid = isPasswordFieldValid;
        	connectCreateUserButton();
        	connectCancelCreateUserButton();
        }
        
        /**
         * Determines whether current given credentials value is valid.
         * @method
         * @private
         * @return { Boolean }
         *      True is the value is valid, false otherwise.
         */
        function isUserCredentialsValid(){
        	this.invalidMessage = "" +
    			"letters, numbers and the underscore [_] symbol only, please"
	    	var testValue = this.textbox.value;
            var ret = /^\w+$/.test(testValue);
            if(!ret) {
            	wt.disable(get("createUserButton"));
            } else {
            	wt.enable(get("createUserButton"));
            }
            return ret;
        }

        /**
         * Determines whether given 'password' and 'confirm password' fields
         * match.
         * @method
         * @private
         * @param passField { Object }
         *      The password dojo widget.
         * @param confirmField { Object }
         *      The confirm password dojo widget.
         * @return { Boolean }
         *      True whether the two fields match, false otherwise.
         */
        function isConfirmedPasswordValid(passField, confirmField) {
        	var ret = passField.textbox.value == confirmField.textbox.value;
        	if(!ret) {
	        	this.invalidMessage = "" +
	        	   "password and confirmation do not match"
        		wt.disable(get("createUserButton"));
        	} else {
	            this.invalidMessage = "" +
	                "letters, numbers and the dash [-] symbol only";
        		wt.enable(get("createUserButton"));
        	}
        	return ret;
        }
        
        /**
         * Determines whether current given password field has valid values.
         * @method
         * @private
         * @return { Boolean }
         *      True if the field value is valid, false otherwise.
         */
        function isPasswordFieldValid() {
           var ret = (
               isUserCredentialsValid.apply(this) &&
               isConfirmedPasswordValid.apply(this, [
                   get("newUserPass"),
                   get("confirmNewUserPass")
               ])
           );
           var checker = 'CHECK_VALID_INTERVAL' + this.id;
           var that = this;
           if(!ret) {
	           if(typeof window[checker] == "undefined") {
		           window[checker] = window.setInterval(function(){
		                that.isValid();
		           }, 100);
	           }
	           return false;
           }
           window.clearInterval(window[checker]);
           window.setTimeout(function(){
               get("newUserPass").state = "";
               get("newUserPass")._setStateClass();
               get("confirmNewUserPass").state = "";
               get("confirmNewUserPass")._setStateClass();
           }, 150);
           return true;
        }

        /**
         * Connects the 'create user' button.
         * @method
         * @private
         */
        function connectCreateUserButton() {
        	var onCreateUserButtonClick = function(){
        		// @grab values and disable controls:
        		var result = {
        			'newUSerName': get("newUserName").textbox.value,
        			'newUserPass': get("newUserPass").textbox.value,
        			'isNewUserPublic': get("makePublic").checked
        		}
        		wt.disable(get("createUserSubPane"));
        		
        		// @setup result dialog:
                var dlg = get('genericDialog');
                var onGenericNoButtonClick, onGenericOKButtonClick;
                onGenericNoButtonClick = onGenericOKButtonClick = function(){
                    dlg.onCancel()
                }
                var _onCancel = dlg.onCancel;
                var onDlgCancel = function() {
                    _onCancel();
                    wt.enable(get('createUserSubPane'));
                    window.setTimeout(function(){
                        get("cancelCreateUserButton").onClick();
                    }, 200);
                }
                dlg.onCancel = onDlgCancel;
                var onGenericYesButton = function() {
                	_onCancel();
	                Logout.getDefault().doLogout();
	                window.setTimeout(function() {
	                    get('users1').setChecked(true);
	                    wt.enable(get('loginSubPane'));
	                    wt.activate(get('loginSubPane'));
	                	get("userPassText").setDisplayedValue("");
	                	get("userPassText").focus();
	                	dojo.byId("dijit__MasterTooltip_0").style.opacity = "0";
	                }, 300);
                	get("userNameCombo").setDisplayedValue([
                	   result.newUSerName,
                	   (result.isNewUserPublic? " [public]" : "")
                	].join(""));
                }

                // @try to create a new user:
        		var usr;
        		try {
	        		usr = new User(
	        		    result.newUSerName,
	        		    result.newUserPass,
	        		    result.isNewUserPublic
	        		);
	        		
	        		// @success:
	        		Logout.getDefault().populateUsersCombo();
        			dlg.titleNode.innerHTML = 'Success';
        			dojo.byId('dialogText').innerHTML = "" +
    					"User <strong>"+result.newUSerName+"</strong> has " +
    					"successfully been created. <br /><br />Do you want " +
    					"to login as <em>"+result.newUSerName+"</em> ?";
        			wt.hide(get('genericOKButton'));
        			wt.hide(get('genericCancelButton'));
        			wt.show(get('genericNoButton'));
        			wt.show(get('genericYesButton'));
        			get('genericNoButton').onClick = onGenericNoButtonClick;
        			get('genericYesButton').onClick = onGenericYesButton;
    			    dlg.show();
    			    get('genericYesButton').focus();
        		} catch(e) {
        			
        			// @failure:
        			dlg.titleNode.innerHTML = 'Error';
        			dojo.byId('dialogText').innerHTML = e;
        			wt.hide(get('genericCancelButton'));
        			wt.hide(get('genericYesButton'));
        			wt.hide(get('genericNoButton'));
        			wt.show(get('genericOKButton'));
        			get('genericOKButton').onClick = onGenericOKButtonClick;
        			dlg.show();
        			get('genericOKButton').focus();
        		}
        	}
        	get("createUserButton").onClick = onCreateUserButtonClick;
        }

        /**
         * Connects the 'cancel' (create user) button.
         * @method
         * @private
         */
        function connectCancelCreateUserButton() {
        	var ourButton = get("cancelCreateUserButton");
        	var clearValidationMarks = function() {
	            get("newUserName").state = "";
	            get("newUserName")._setStateClass();
	            get("newUserPass").state = "";
	            get("newUserPass")._setStateClass();
	            get("confirmNewUserPass").state = "";
	            get("confirmNewUserPass")._setStateClass();
	        }
        	var onCancelCreateUserButton = function(){ 		
        		get("newUserName").setDisplayedValue("");
        		get("newUserPass").setDisplayedValue("");
        		get("confirmNewUserPass").setDisplayedValue("");
        		get("makePublic").setChecked(false);
        		get("newUserName").focus();
        		window.setTimeout(clearValidationMarks, 50);
        	}
        	ourButton.onClick = onCancelCreateUserButton;
        }
        
        /**
         * Connects UI controls inside the 'login' panel.
         * @method
         * @private
         */
        function connectLoginUI() {
        	connectUsersCombo();
        	connectLoginAnonymouslyCheckBox();
        	connectLoginButton();
        	connectLogoutButton();
        	connectCancelLoginButton();
        }
        
        /**
         * Connects the users combobox inside the 'login' panel.
         * @method
         * @private
         */
        function connectUsersCombo() {
        	var onUsersComboChange = function() {
        		var newVal = this.textbox.value;
        		if(newVal.indexOf('[public]') != -1) {
        			wt.enable(get('anonymous'));
        		} else {
        			get('anonymous').setChecked(false);
        			wt.disable(get('anonymous'));
        		}
        		get("userPassText").setValue("");
        	}
        	get("userNameCombo").onChange = onUsersComboChange;
        }
        
        /**
         * Connects the 'login anonymously' checkbox inside the 'login' panel.
         * @method
         * @private
         */        
        function connectLoginAnonymouslyCheckBox() {
        	var onAnonymousCheckBoxClick = function(){
        		if(this.checked) {
	        		get("userPassText").setValue("");
	        		wt.disable(get("userPassText"));
        		} else {
	        		wt.enable(get("userPassText"));
	        		get("userPassText").focus();
        		}
        	}
        	get('anonymous').onClick = onAnonymousCheckBoxClick;
        }

        /**
         * Connects the 'login' button inside the 'login' panel.
         * @method
         * @private
         */        
        function connectLoginButton() {
        	var onLoginButtonClick = function(){
        		// @grab input values and disable controls:
        		var result = {
        			'loginUserName'  : get("userNameCombo").getDisplayedValue(),
        			'loginPassword'  : get("userPassText").textbox.value,
        			'loginAnonymous' : get('anonymous').checked
        		}
        		get("userNameCombo").setDisplayedValue("");
        		get("userPassText").textbox.value = "";
        		get('anonymous').setChecked(false);

                // @setup result dialog:
                var dlg = get('genericDialog');
                var onGenericOKButtonClick = function(){
                    dlg.onCancel()
                }
                var _onCancel = dlg.onCancel;
	                var onDlgCancel = function() {
	                    _onCancel();
	                    wt.enable(get("loginSubPane"));
	                    window.setTimeout(function(){
		                    get("userNameCombo").focus();
	                    }, 260)
	                }
                dlg.onCancel = onDlgCancel;
	                
                // @proof credentials:
                var userName = result.loginUserName.split(' [public]').join('');
                var success = Login.getDefault().authenticateUser(
                    userName,
                    result.loginPassword,
                    result.loginAnonymous
                );
                if(success) {
                	StatusBar.getDefault().setMessage("Successfully logged in");
                	wt.disable(get('users2'));
                	wt.enable(get('tasksPane'));
                	wt.enable(get('appSettingsPane'));
                	wt.activate(get('tasksPane'));
                	if(!Login.getDefault().isUserReadOnly()) {
                		wt.enable(get('task1'));
	                	get('task1').setChecked(true);
	                	setEditorWriteMode();
	                	wt.activate(get("tabsWidget"), 0);
	                	get('editorWidget').setValue(editorDefaultValue);
	                	get('editorWidget').focus();
                	} else {
	                	get('task1').setChecked(false);
                		wt.disable(get('task1'));
	                	get('task3').setChecked(true);
                		get("task3").onClick.apply(get("task3"));
                		wt.activate(get("tabsWidget"), 0);
                	}
                } else {
                	wt.disable(get("loginSubPane"));
                    dlg.titleNode.innerHTML = 'Wrong Credentials';
                    dojo.byId('dialogText').innerHTML = "" +
                    		"Provided user name or password are wrong. <br />" +
                    		"Please re-enter them correctly.";
                    wt.hide(get('genericCancelButton'));
                    wt.hide(get('genericYesButton'));
                    wt.hide(get('genericNoButton'));
                    wt.show(get('genericOKButton'));
                    get('genericOKButton').onClick = onGenericOKButtonClick;
                    dlg.show();
                    get('genericOKButton').focus();
                }
        	}
        	get("loginButton").onClick = onLoginButtonClick;
        }
        
        /**
         * Connects the 'logout' button inside the 'login' panel.
         * @method
         * @private
         */
        function connectLogoutButton() {
        	var onLogoutButtonClick = function(){
        		StatusBar.getDefault().setMessage("Logging out...");
        		wt.enable(get("userPassText"));
        		Logout.getDefault().doLogout();
        	}
        	get("logMeOutButton").onClick = onLogoutButtonClick;
        }
        
        /**
         * Connects the 'cancel' button inside the 'login' panel.
         */
        function connectCancelLoginButton() {
        	var onCancelLoginClick = function() {
        		get("userNameCombo").setDisplayedValue("");
        		get("userPassText").setValue("");
        		get('anonymous').setChecked(false);
        		wt.enable(get("userPassText"));
        		wt.disable(get('anonymous'));
        		get("userNameCombo").focus();
        	}
        	get("cancelLoginButton").onClick = onCancelLoginClick;
        }       
        
        
        /**
         * Connects the widget editor.
         * @method
         * @private
         */
        function connectEditorWidget(){
        	connectEditorSaveFunction();
        }
        
        /**
         * Connects the built-in editor widget "save" feature -- i.e., [Ctrl]+S.
         * @method
         * @private
         */
        function connectEditorSaveFunction(){
        	var onEditorSave = function() {
        		if(!Login.getDefault().isUserReadOnly()) {
	        		var txt = this.getValue();
	        		Storage.getDefault().saveDiaryEntry(txt);
	        		StatusBar.getDefault().setMessage("" +
        				"Successfully saved diary entry on: " +
        				(new Date()).toLocaleString());
        		}
        	}
        	var onSaveButtonClick = function(){
        		var editor = get("editorWidget");
        		onEditorSave.apply(editor);
        		editor.focus();
        	}
        	get("editorWidget").save = onEditorSave;
        	wt.enable(get("saveEditorContentButton"));
        	get("saveEditorContentButton").onClick = onSaveButtonClick;
        }
        
        /**
         * Reverses the effects of 'connectEditorWidget()'. Useful to 
         * effectivelly make the editor read only.
         * @method
         * @private 
         */
        function disconnectEditorWidget() {
        	disconnectEditorSaveFunction();
        }

        /**
         * Disconnects the built in 'save' feature of the editor.
         * @method
         * @private
         */        
        function disconnectEditorSaveFunction() {
        	var noAction = function() {};
            get("editorWidget").save = noAction;
            get("saveEditorContentButton").onClick = noAction;
            wt.disable(get("saveEditorContentButton"));
        }
        
        /**
         * Connects all the radio buttons inside the 'tasks' panel.
         * @method
         * @private
         */
        function connectTaskRadioButtons(){
        	connectWriteEntryForTodayButton();
        	connectBrowseToReadButton();
        }
        
        /**
         * Disables the editor and associated UI.
         * @method
         * @private
         */
        function setEditorWriteMode() {
           if(Login.getDefault().isUserLoggedIn()) {
	           get('editorWidget').iframe.contentDocument.designMode = "on";
	           get('editorWidget').toolbar.domNode.style.visibility = "";
	           get('editorWidget').domNode.style.borderStyle = "solid";
	           get('editorWidget').disabled = false;
	           connectEditorWidget();
	           window.setTimeout(function(){
		           StatusBar.getDefault().setMessage("Editor ready. " +
		                "Type your text and hit [Save]");
	           }, 50)
           }
        }

        /**
         * Enables the editor and associated UI.
         * @method
         * @private 
         */
        function setEditorReadOnlyMode() {
           get('editorWidget').iframe.contentDocument.designMode = "off";
           get('editorWidget').toolbar.domNode.style.visibility = "hidden";
           get('editorWidget').domNode.style.borderStyle = "none";
           get('editorWidget').disabled = true;
           disconnectEditorWidget();
        }
        
        /**
         * Holds the editor value before switching it to 'read only' mode.
         * @field
         * @private
         */
        var editorValueBeforeSwitching = null;
        
        /**
         * Connects the 'write-entry-for-today' radio button.
         * @method
         * @private
         */
        function connectWriteEntryForTodayButton() {
        	var onWriteEntryForTodayButtonClick = function() {
        		wt.deactivate(get("accordionWidget"));
        		wt.disable(get("accordionWidget"));
        		setEditorWriteMode();
        		if(editorValueBeforeSwitching !== null) {
                    get('editorWidget').setValue(editorValueBeforeSwitching);
                    editorValueBeforeSwitching = null;
        		}
                get('editorWidget').focus();
        	}
        	get("task1").onClick = onWriteEntryForTodayButtonClick;
        }

        /**
         * Connects the 'browse-to-read-entries' radio button.
         * @method
         * @private
         */
        function connectBrowseToReadButton() {
        	var onBrowseToReadButtonClick = function(){
        		initializeCalendarWidget();
        		connectCalendarWidget();
        		wt.enable(get("accordionWidget"));
        		wt.activate(get("accordionWidget"), 0);
        		setEditorReadOnlyMode();
        		editorValueBeforeSwitching = get('editorWidget').getValue();
        		get('editorWidget').setValue("");
        		StatusBar.getDefault().setMessage("Canlendar initialized. " +
        			"Select entries to display");
        	}
            get("task3").onClick = onBrowseToReadButtonClick;
        }
        
        /**
         * Initializes the calendar widget.
         * @method
         * @private
         */
        function initializeCalendarWidget() {
        	if(!get("calendarWidget")) {
	        	StatusBar.getDefault().setMessage("Initializing calendar...");
	        	Main.getDefault().addDeclaredWidget (
	        	   "calendarWidget",
	        	   new dijit._Calendar({}, dojo.byId("calendarWidgetRecipient"))
	        	);
        	}
        }
        
        /**
         * Produces a hash with date-indexed entries keys.
         * @method
         * @private
         * @param testDate { Date Object }
         *      A Date object representing the month that is to be searched for
         *      entries. Defaults to current date.
         * @return { Object }
         *      A hash, having a 'YYY/MM/D' keys and associated entry keys as 
         *      values. The entry keys are allways stored in arrays. Returs an
         *      empty object if no entries were found for the given month.
         */
        function getDaysWithEntries (testDate) {
            var ret = {};
            if(!testDate) { testDate = new Date() };
            var allEntries = Storage.getDefault().retrieveEntriesList();
            for(var i=0; i<allEntries.length; i++) {
            	var entry = allEntries[i];
            	var entryDate = new Date(parseInt(entry.substr(3)));
            	if(entryDate.getMonth() == testDate.getMonth()
            		&& entryDate.getFullYear() == testDate.getFullYear() 
            			&& entryDate.getDate() <= testDate.getDate()) {
            		var key = [entryDate.getFullYear(),
	            		entryDate.getMonth(),entryDate.getDate()].join('/');
            		var slot = ret[key] || (ret[key] = []);
            		slot.push(entry);
            	}
            }
            return ret;
        }

        
        /**
         * Connects the calendar widget.
         * @method
         * @private
         */
        function connectCalendarWidget(){
        	StatusBar.getDefault().setMessage("Processing entries list...");
        	entriesThisMonth = getDaysWithEntries();
	        var onDateValueSelect = function(date) {
	        	var key = [date.getFullYear(), date.getMonth(),
	        		date.getDate()].join('/');
	            var entries = entriesThisMonth[key];
	            if(entries) {
	                var content = [];
	                for(var i=0; i<entries.length; i++) {
	                    var dateWritten = new Date(parseInt(entries[i]
	                        .split('DE_').join("")));
	                    var timeStampWritten = dateWritten.toLocaleString();
	                    content.push([
	                        '' +
	                        '<span style="color:steelblue;' +
	                            'font-style:italic;' +
	                            'display:block;' +
	                            'margin-top:25px;' +
	                            'margin-bottom:5px">'+
	                            'Written on ',
	                            timeStampWritten,
	                        '</span>'
	                    ].join(""));
	                    content.push(Storage.getDefault()
	                        .retrieveEntry(entries[i]));
	                }
	                get('editorWidget').setValue(
	                     content.join('')
	                );
	                StatusBar.getDefault().setMessage("" +
	                    "Displaying entries for "+
	                    function(){
	                        var dateStr = [
	                            date.getMonth() + 1,
	                            date.getDate(),
	                            date.getFullYear()
	                        ].join('/');
	                        return dateStr;
	                    }()
	                );
	            }
	        }
        	var _getClassForDate = function(date) {
	        	var key = [date.getFullYear(), date.getMonth(),
	        		date.getDate()].join('/');
                if (entriesThisMonth[key]) {
                	return ' dayWithEntries ';
                }
                return null;
        	}
        	var __adjustDisplay = get("calendarWidget")._adjustDisplay;
        	var onCalendarDisplayChanged = function(prop, changeIndex) {
        		var someDate = new Date(this.displayMonth.getTime());
        		if(prop == 'month') {
        			someDate.setMonth(someDate.getMonth() + changeIndex)
        		};
        		if(prop == 'year') {
        			someDate.setFullYear(someDate.getFullYear() + changeIndex)
        		};
        		var currentDate;
        		if(someDate.getMonth() != new Date().getMonth()) {
        			var currentDate = someDate;
        			var currMonth = currentDate.getMonth();
        			currentDate.setDate(31);
        			while (currentDate.getMonth() > currMonth) {
        				currentDate.setDate(currentDate.getDate() - 1);
        			}
	        		entriesThisMonth = getDaysWithEntries(currentDate);
        		} else {
	        		entriesThisMonth = getDaysWithEntries();
        		}
        		__adjustDisplay.call(this, prop, changeIndex);
        	}
        	get("calendarWidget")._adjustDisplay = onCalendarDisplayChanged;
            get("calendarWidget").getClassForDate = _getClassForDate;
            get("calendarWidget").onValueSelected = onDateValueSelect;
        	get("calendarWidget").setValue(new Date());
        }
        
        /**
         * Connects all the UI elements.
         * @method
         * @public
         */        
        this.connectAllUI = function() {
        	setEditorReadOnlyMode();
            connectUserPanelRadioButtons();
            connectCreateUserUI();
            connectLoginUI();
            connectTaskRadioButtons();
        }
        
        /**
         * Patch the [Date].toString() method as it is proven not to work under 
         * Mac (returns '#c').
         * @method
         * @public
         * @return @see Date.toLocaleString()
         */
		Date.prototype.toLocaleString = function() {
			var dateStr = this.toString();
			var idx;
			if((idx = dateStr.indexOf(' GMT')) != -1) {
				var newStr = dateStr.substring(0, idx);
				return newStr;
			}
			return dateStr;
		}
    }
    context.instance = new _uiConector();
    return context.instance;
}
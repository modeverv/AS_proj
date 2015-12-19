/**
 * LoginDialog.as
 * 指定されたサイトへのログイン処理を行う。
 * 
 * Copyright (c) 2008 MAP - MineApplicationProject. All Rights Reserved.
 * 
 */
 
import flash.data.EncryptedLocalStore;
import flash.events.Event;
import flash.events.HTTPStatusEvent;
import flash.events.IOErrorEvent;
import flash.events.KeyboardEvent;
import flash.events.SecurityErrorEvent;
import flash.net.URLLoader;
import flash.ui.Keyboard;
import flash.utils.ByteArray;

import org.mineap.NNDD.Access2Nico;
import org.mineap.NNDD.view.LoadingPicture;
import org.mineap.NNDD.LogManager;

import mx.controls.Alert;
import mx.controls.Button;
import mx.events.FlexEvent;

// ログイン成功イベントを表す文字列
public static const ON_LOGIN_SUCCESS:String = "onFirestTimeLoginSuccess";

public static const LOGIN_FAIL:String = "LoginFail";

public static const NO_LOGIN:String = "noLogin";

public static var TOP_PAGE_URL:String;
public static var LOGIN_URL:String;

public static var LABEL_CANCEL:String = "キャンセル";
public static var LABEL_LOGIN:String = "ログイン";
public static var LABEL_NO_LOGIN:String = "ログインしない";

private var userName:String;
private var password:String;
private var isStore:Boolean;
private var isAutoLogin:Boolean;
private var isLogout:Boolean;
private var logManager:LogManager;

//ログイン用URLローダー
private var loader:URLLoader;

private var loading:LoadingPicture = new LoadingPicture();

public function initLoginDialog(topURL:String, loginURL:String, isStore:Boolean, isAutoLogin:Boolean, logManager:LogManager, userName:String = "", password:String = "", isLogout:Boolean = false):void
{
	TOP_PAGE_URL = topURL;
	LOGIN_URL = loginURL;
	loginButton.enabled = true;
	noLoginButton.enabled = true;
	
	this.logManager = logManager;
	this.isStore = isStore;
	this.isAutoLogin = isAutoLogin;
	this.isLogout = isLogout;
	this.userName = userName;
	this.password = password;
	
	this.addEventListener(FlexEvent.CREATION_COMPLETE, setNameAndPass);
	
	textInput_userName.setFocus();
}

public function setNameAndPass(event:Event):void{
	textInput_userName.text = this.userName;
	textInput_password.text = this.password;
	checkBox_storeUserNameAndPassword.selected = this.isStore;
	checkbox_autoLogin.selected = this.isAutoLogin;
	
	if(isAutoLogin && !isLogout){
		login();
	}
	
}

public function setBootTimePlay(isBootTime:Boolean):void{
	
}

private function enterHandler(event:FlexEvent):void {
	
	if(textInput_userName.text.length >= 1 && textInput_password.text.length >= 1){
		login();
	}
	
}

// ログインボタン押下字の処理
private function login():void 
{
	if(loginButton.label == LoginDialog.LABEL_LOGIN){
		noLoginButton.enabled = false;
		loginButton.label = LoginDialog.LABEL_CANCEL;
	    
	    //以降のURLRequestが全て認証情報付きで行われるように、デフォルト値としてセット
		URLRequestDefaults.setLoginCredentialsForHost(TOP_PAGE_URL, textInput_userName.text, textInput_password.text);
		
		//ログインURLにアクセス
		var req:URLRequest = new URLRequest(LOGIN_URL);
		//POSTメソッドです
		req.method = "POST";
		
		//メールアドレスとパスワードをURLエンコードしてリクエストに付加
		var variables : URLVariables = new URLVariables ();
		variables.mail = textInput_userName.text;
		variables.password = textInput_password.text;
		req.data = variables;
		
		//ログイン成功時のリスナーを追加してリクエストを実行
		loader = new URLLoader();
		loader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, onHTTPResponse);
		loader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
	    loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
	    loader.load(req);
	    
	    var bytes:ByteArray = new ByteArray();
		
	    if(checkBox_storeUserNameAndPassword.selected){
	    	
	    	EncryptedLocalStore.removeItem("userName");
	    	bytes.writeUTFBytes(textInput_userName.text);
			EncryptedLocalStore.setItem("userName", bytes);
			
			EncryptedLocalStore.removeItem("password");
			bytes = new ByteArray();
			bytes.writeUTFBytes(textInput_password.text);
			EncryptedLocalStore.setItem("password", bytes); 
			
			EncryptedLocalStore.removeItem("storeNameAndPass");
			bytes = new ByteArray();
			bytes.writeBoolean(true);
			EncryptedLocalStore.setItem("storeNameAndPass", bytes);
			
			EncryptedLocalStore.removeItem("isAutoLogin");
			bytes = new ByteArray();
			bytes.writeBoolean(checkbox_autoLogin.selected);
			EncryptedLocalStore.setItem("isAutoLogin", bytes);
			
	    }else{
	    	
	    	EncryptedLocalStore.removeItem("userName");
	    	EncryptedLocalStore.removeItem("password");
	    	
	    	EncryptedLocalStore.removeItem("storeNameAndPass");
	    	bytes = new ByteArray();
	    	bytes.writeBoolean(false);
	    	EncryptedLocalStore.setItem("storeNameAndPass", bytes)
	    	
	    }
	}else if(loginButton.label == LoginDialog.LABEL_CANCEL){
		noLoginButton.enabled = true;
		if(loader != null){
			try{
				(loader as URLLoader).close();
			}catch(error:Error){
				
			}
		}
		loginButton.label = LoginDialog.LABEL_LOGIN;
	}
}

private function notLogin():void
{
	loginButton.enabled = false;
	noLoginButton.enabled = false;
	loginButton.label = LoginDialog.LABEL_LOGIN;
    dispatchEvent(new HTTPStatusEvent(NO_LOGIN));
}

private function errorHandler(event:IOErrorEvent):void
{

	Alert.show("ログインに失敗しました。\nインターネットに接続されている事を確認してください。\nErrorType:" + event.type + "\n" + event.text, "エラー");	
	loginButton.enabled = true;
	noLoginButton.enabled = true;
	loginButton.label = LoginDialog.LABEL_LOGIN;
	logManager.addLog("ログイン失敗:インターネットに接続していない:" + event);
    return;
}

private function onHTTPResponse(event:HTTPStatusEvent):void 
{	

	trace(event);

    if (event.status != 200) {
        Alert.show("ログインできません。\nニコニコ動画がアクセスできる状況であることを確認してください。\nStatus" + event.status, "エラー");
        noLoginButton.enabled = true;
        loginButton.label = LoginDialog.LABEL_LOGIN;
        logManager.addLog("ログイン失敗:ニコニコ動画から応答無し:" + event);
        return;
    }
    
    if (event.responseURL == Access2Nico.LOGIN_FAIL_URL) {
    	Alert.show("ログインできません。\nメールアドレス、もしくはパスワードが間違っています。" + event.status,"エラー");
		noLoginButton.enabled = true;
    	loginButton.label = LoginDialog.LABEL_LOGIN;
    	logManager.addLog("ログイン失敗:メールアドレスもしくはパスワードの設定ミス:" + event);
    	return;
    }
    
    // イベントを送出
    dispatchEvent(new HTTPStatusEvent(ON_LOGIN_SUCCESS));
}

private function buttonKeyUp(event:KeyboardEvent):void{
	if(event.keyCode == Keyboard.ENTER){
		if((event.target as Button).label == LoginDialog.LABEL_CANCEL){
			this.login();
		}else if((event.target as Button).label == LoginDialog.LABEL_LOGIN){
			this.login();
		}else if((event.target as Button).label == LoginDialog.LABEL_NO_LOGIN){
			this.notLogin();
		}
	}	
}
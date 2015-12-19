package jp.fores.foresmessenger.servlet;

import javax.servlet.http.HttpServlet;

import flex.messaging.MessageBroker;
import flex.messaging.messages.AsyncMessage;
import flex.messaging.util.UUIDUtils;

/**
 * サーバー状態通知用のサーブレット。
 */
public class ServerConditionNotifyServlet extends HttpServlet {

	//==========================================================
	//メソッド

	//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
	//オーバーライドするメソッド

	/**
	 * サーブレットがサービスを停止する際に、サーブレットコンテナによって呼び出されます。
	 */
	@Override
	public void destroy() {
		//メッセージブローカーのインスタンスを取得
		MessageBroker msgBroker = MessageBroker.getMessageBroker(null);

		//非同期メッセージのインスタンスを生成
		AsyncMessage msg = new AsyncMessage();

		//宛先を設定
		msg.setDestination("serverConditionNotify");

		//クライアントIDにユニークなIDを設定
		msg.setClientId(UUIDUtils.createUUID());

		//メッセージIDにユニークなIDを設定
		msg.setMessageId(UUIDUtils.createUUID());

		//タイムスタンプを設定
		msg.setTimestamp(System.currentTimeMillis());

		//ヘッダにメッセージタイプを設定
		//(クライアント側での処理判別のため)
		msg.setHeader("messageType", "serverPush");

		//ヘッダにサーバー状態として「stop」を設定
		msg.setHeader("serverCondition", "stop");

		//ボディーは必要ないがとりあえず「stop」という文字列を設定
		msg.setBody("stop");

		//メッセージブローカーを使って作成したメッセージのプッシュ配信を行う
		msgBroker.routeMessageToService(msg, null);
	}
}

package
{
  import flash.events.Event;
  import flash.events.EventDispatcher;
  import flash.net.URLLoader;
  import flash.net.URLLoaderDataFormat;
  import flash.net.URLRequest;
  import flash.net.URLRequestMethod;
  import flash.net.URLVariables;

  /**
  * ConnectPHP
  * @author feb19
  */
  public class ConnectPHP extends EventDispatcher
  {
    public static const COMPLETE:String = "connectPHP_complete";

    private var _result:Object = new Object();

    public function ConnectPHP(url:String = null, variables:Object = null)
    {
      if (url && variables)
      {
        sendAndLoad(url, variables);
      }
    }
    public function sendAndLoad(url:String, variables:Object):void
    {
      var urlRequest:URLRequest = new URLRequest(url);

      var urlVariables:URLVariables = new URLVariables();

      for (var i:String in variables)
      {
        urlVariables[i] = variables[i];
      }

      urlRequest.data = urlVariables;
//      urlRequest.method = URLRequestMethod.POST;
      urlRequest.method = URLRequestMethod.GET;

      var urlLoader:URLLoader = new URLLoader();
      urlLoader.dataFormat = URLLoaderDataFormat.VARIABLES;
      urlLoader.addEventListener(Event.COMPLETE, completeHandler);
      urlLoader.load(urlRequest);
    }
    private function completeHandler(e:Event):void
    {
      var urlVariables:URLVariables = new URLVariables(e.target.data);
      var obj:Object = new Object();
      for (var i:String in urlVariables)
      {
        obj[i] = urlVariables[i];
      }

      _result = obj;

      dispatchEvent(new Event(COMPLETE));
    }
    public function get result():Object
    {
      return _result;
    }
  }
}
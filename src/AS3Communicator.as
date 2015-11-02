package
{
	import com.innogames.as3communicator.controllers.APIController;
	import com.innogames.as3communicator.io.javascript.IConnector;

	import com.innogames.as3communicator.io.javascript.JavaScriptConnector;

	import com.innogames.as3communicator.utils.DebugLogger;
	import com.innogames.as3communicator.utils.InitializationUtils;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.system.Security;

	public class AS3Communicator extends Sprite
	{
		InitializationUtils;

		/**
		 * Adding the connectors to the outside world. For now there's only a JavaScriptConnector, but it could
		 * also be extended to have, lets say, a TCP Socket for communicating between AIR and Selenium or some
		 * other service.
		 */
		private static var vecConnectors:Vector.<IConnector> = new <IConnector>[JavaScriptConnector.instance];

		private var strDOMName:String;

		/**
		 * Creates the instance of AS3Communicator and adds itself to stage.
		 *
		 * @param domName The element name in the HTML DOM tree to look for. If omitted, the first flash object in the
		 * page will be used.
		 */
		public function AS3Communicator(domName:String = "")
		{
			this.strDOMName = domName;

			DebugLogger.instance.logOptions = DebugLogger.LOG_TO_JS_CONSOLE | DebugLogger.LOG_TO_TRACE;

			this.prepareInitialization();
		}

		/**
		 * This method allows to expose additional methods of your program to all enabled IConnectors. Let's say your
		 * application has a userID you want to make accessible. Simply write a getter in your code and after creating
		 * the instance of AS3Communicator, call exposeMethod('getUserID', myUser.id, 'exposes the userID');
		 *
		 * @param methodName
		 * @param callable
		 * @param description
		 */
		public static function exposeMethod(methodName:String, callable:Function, description:String):void
		{
			for (var i:int = 0, intLength:int = AS3Communicator.vecConnectors.length; i < intLength; ++i)
			{
				(AS3Communicator.vecConnectors[i] as IConnector).exposeMethod(methodName, callable, description);
			}

			DebugLogger.instance.log('Exposed method "'+ methodName +'" can be used from now on.');
		}


		private function prepareInitialization():void
		{
			if (!this.stage)
			{
				this.addEventListener(Event.ADDED_TO_STAGE, this.init);
				return;
			}

			this.init(null);
		}


		private function init(evt:Event):void
		{
			APIController.instance.stage = this.stage;

			if(this.hasEventListener(Event.ADDED_TO_STAGE))
			{
				this.removeEventListener(Event.ADDED_TO_STAGE, this.init);
			}

			if(this.parent)
			{
				this.parent.removeChild(this);
			}

			Security.allowDomain("*");
			Security.allowInsecureDomain("*");

			for(var i:int = 0, intLength:int = AS3Communicator.vecConnectors.length; i < intLength; ++i)
			{
				(AS3Communicator.vecConnectors[i] as IConnector).setup(strDOMName);
			}

			DebugLogger.instance.log('AS3Communicator initialized.');
		}
	}
}
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

		private var vecConnectors:Vector.<IConnector>;

		public function AS3Communicator()
		{
			DebugLogger.instance.logOptions = DebugLogger.LOG_TO_JS_CONSOLE | DebugLogger.LOG_TO_TRACE;

			this.prepareInitialization();
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

			/**
			 * Adding the connectors to the outside world. For now there's only a JavaScriptConnector, but it could
			 * also be extended to have, lets say, a TCP Socket for communicating between AIR and Selenium or some
			 * other service.
			 */
			this.vecConnectors = new<IConnector>[JavaScriptConnector.instance];
			for(var i:int = 0, intLength:int = this.vecConnectors.length; i < intLength; ++i)
			{
				(this.vecConnectors[i] as IConnector).setup();
			}

			DebugLogger.instance.log('AS3Communicator initialized.');
		}
	}
}
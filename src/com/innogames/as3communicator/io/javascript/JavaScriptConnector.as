package com.innogames.as3communicator.io.javascript
{

	import com.innogames.as3communicator.controllers.APIController;
	import com.innogames.as3communicator.utils.DebugLogger;
	import com.innogames.as3communicator.utils.IDebugLogger;

	import flash.external.ExternalInterface;
	import flash.system.Security;

	/**
	 * Creates a bridge between Flash and JavaScript. Exposes all accessible API methods to JavaScript.
	 */
	public class JavaScriptConnector implements IDebugLogger, IConnector
	{
		private static const JS_CONNECTION_SCRIPT:XML = <script><![CDATA[
			function(strDOMName)
			{
				var objDomTree = document.getElementsByTagName('object');
				if(!objDomTree || objDomTree.length < 1) throw new Error('Couldn\'t find Flash Object!');

				var objCurrent = null;

				for(var i = 0, intLength = objDomTree.length; i < intLength; ++i)
				{
					objCurrent = objDomTree[i];
					if(objCurrent.type.toLowerCase() !== 'application/x-shockwave-flash') continue;

					if(strDOMName && objCurrent.name !== strDOMName) continue;

					try
					{
						console.log('Found Flash object with name: "'+ objCurrent.name +'", id: "'+ objCurrent.id +'", data: "'+ objCurrent.data +'"');
					}
					catch(e)
					{
						//nothing to do, just the log failed :)
					}

					$flash = objCurrent;
					break;
				}
				if(!$flash)
				{
					console.log('Didn\'t find object with name "'+ strDOMName +'"');
				}
			}
		]]></script>;

		private static var objInstance:JavaScriptConnector;

		public static function get instance():JavaScriptConnector
		{
			var objInstance:JavaScriptConnector = JavaScriptConnector.objInstance;
			if(objInstance === null)
			{
				objInstance = JavaScriptConnector.objInstance = new JavaScriptConnector(new SingletonEnforcer());
			}

			return objInstance;
		}

		public function JavaScriptConnector(objEnforcer:SingletonEnforcer)
		{
			if(!(objEnforcer) is SingletonEnforcer)
			{
				throw new ArgumentError('JavaScriptConnector must be invoked with SingletonEnforcer object. Use'
						+ ' JavaScriptConnector.instance!');
			}

			JavaScriptConnector.objInstance = this;
		}
		private var vecAPI:Vector.<APIMethod>;

		public function log(strMessage:String):void
		{
			if(!(DebugLogger.instance.logOptions & DebugLogger.LOG_TO_JS_CONSOLE)) return;
			//Prevent the Flash Player warning message, see http://stackoverflow.com/questions/26157126
			strMessage = escape(strMessage).replace(/\./g, "%2E").replace(/\:/g, "%3A").replace(/\//g, "%2F");
			try
			{
				ExternalInterface.call('console.log', strMessage);
			}
			catch(logError:Error)
			{
				DebugLogger.instance.logOptions &= ~DebugLogger.LOG_TO_JS_CONSOLE;
				trace('Couldn\'t log to js console. JavaScript logging has now been disabled.');
			}
		}


		public function exposeMethod(methodName:String, callable:Function, description:String):void
		{
			if(!this.vecAPI)
			{
				this.vecAPI = new <APIMethod>[];
			}

			var objAPIMethod:APIMethod = new APIMethod(methodName, callable, description);
			this.vecAPI[this.vecAPI.length] = objAPIMethod;
			ExternalInterface.addCallback(objAPIMethod.name, objAPIMethod.closure)
		}


		public function setup(strDOMName:String):Boolean
		{
			if(!ExternalInterface.available) return false;

			var objController:APIController = APIController.instance;

			this.exposeMethod('clickAtPosition',
					objController.clickAtPosition,
					'(x:int, y:int) - Clicks on the specified position on screen'
			);

			this.exposeMethod(
					'clickObject',
					objController.clickObject,
					'(name:String) - Clicks on the specified object, if it can be'
					+ ' found by the name. Use FullyQualifiedIdentifiers like'
					+ ' "myObject.child.button" or array access, like "[0][1][0]'
			);

			this.exposeMethod(
					'hoverObject',
					objController.hoverObject,
							'(name:String) - Hovers over the specified object, if it can be'
							+ ' found by the name. Use FullyQualifiedIdentifiers like'
							+ ' "myObject.child.button" or array access, like "[0][1][0]'
			);

			this.exposeMethod(
					'stopHoverObject',
					objController.stopHoverObject,
							'(name:String) - Stopd the hovering over the specified object, if it can be'
							+ ' found by the name. Use FullyQualifiedIdentifiers like'
							+ ' "myObject.child.button" or array access, like "[0][1][0]'
			);

			this.exposeMethod('countObjectsOnStage',
					objController.countObjectsOnStage,
					'() - Counts all objects on parentContainer recursively and'
					+ ' returns that number.'
			);

			this.exposeMethod('findObjectByName',
					objController.findObject,
					'(name:String, properties:String|Array) - Tries to find an object by the given name,'
					+ ' or array access (same as for clickObject). The properties argument works the same'
				    + ' like with getObjectTree or other methods.'
			);

			this.exposeMethod('getAllObjectsAndProperties',
					this.proxyFindAllObjectsOnStage,
					'() - Returns all objects that are'
					+ ' currently on parentContainer. Will include all properties. Please note that'
					+ ' this method can be very slow, due to the amount of data created.'
			);

			this.exposeMethod('getAllObjects',
					objController.getAllObjectsOnStage,
					'() - Returns all objects that are currently on parentContainer. This method is not recursive!'
			);

			this.exposeMethod('getObjectAtPosition',
					objController.getObjectAtPosition,
					'(x:int, y:int) - Returns the object at the given location.'
			);

			this.exposeMethod('getObjectProperty',
					objController.getObjectProperty,
					'(objectName:String, propertyName:String) - Returns the specified'
					+ ' property of the given object name (can also be array access).'
					+ ' Please note that this will only work for primitive types like'
					+ ' String, int, etc.'
			);

			this.exposeMethod('getObjectTree',
					objController.getObjectTree,
					'(properties:String|Array) - Returns a representation of the tree structure of the current'
				    + ' display object hierarchy. The properties argument can be set to "all", to retrieve all'
				    + ' available properties, or set to an array that contains the properties that should be retrieved,'
				    + ' like ["x", "y", "width", "height"]'
			);

			this.exposeMethod('help',
					this.printAPI,
					'() - Prints this help documentation.'
			);

			this.exposeMethod('setFormatter',
					objController.setFormatter,
					'(formatter:String) - Sets the formatter type for return values. For now, JSON and '
					+ 'XML are supported. Any subsequent calls to methods will return their values with the '
					+ 'current formatted.'
			);

			this.exposeMethod('setObjectProperty',
					objController.setObjectProperty,
					'(objectName:String, propertyName:String, value:*) - Let\'s you modify any given '
					+ 'property of the given object. You could, for instance, change the .text property of'
					+ ' a TextField, to change it\'s content. The type of the value is dependent on the'
					+ ' property you\'re about to change.'
			);

			this.exposeMethod('toggleHighlight',
					objController.toggleHighlight,
					'(objectName:String) - Will toggle the highlighting of the'
					+ ' given element name (can also be array access). If switched on, the'
					+ ' highlight will be illuminated with a magenta glow.'
			);

			this.exposeMethod('toggleHighlightUnderCursor',
					objController.toggleHighlightUnderCursor,
					'() - Will toggle the highlighting of elements'
					+ ' that are currently under the cursor and are clickable. Will also'
					+ ' print the FQI (FullyQualifiedIdentifier) to console.'
			);

			this.exposeMethod('toggleCursorPosition',
					objController.toggleCursorPosition,
					'() - Will toggle printing the current cursor position to console.'
			);

			DebugLogger.instance.log('SandboxType: ' + Security.sandboxType);
			ExternalInterface.marshallExceptions = true;
			ExternalInterface.call(JavaScriptConnector.JS_CONNECTION_SCRIPT, strDOMName);
			DebugLogger.instance.log('JavaScriptConnector setup.');
			DebugLogger.instance.log(this.printAPI());

			return true;
		}


		private function printAPI():String
		{
			var result:String = '';
			var objAPIMethod:APIMethod;

			for(var i:int = 0, intLength:int = this.vecAPI.length; i < intLength; ++i)
			{
				objAPIMethod = this.vecAPI[i] as APIMethod;
				result += objAPIMethod.name + ' - ' + objAPIMethod.description + '\n\n';
			}

			return result;
		}

		private function proxyFindAllObjectsOnStage():String
		{
			return APIController.instance.getAllObjectsOnStage();
		}
	}
}

internal class SingletonEnforcer
{
}

internal class APIMethod
{
	private var funcToCall:Function,
			strDescription:String,
			strName:String;

	public function APIMethod(strName:String, funcToCall:Function, strDescription:String = null)
	{
		this.strDescription = strDescription;
		this.strName = strName;
		this.funcToCall = funcToCall;
	}


	public function get description():String
	{
		return this.strDescription;
	}

	public function set description(strValue:String):void
	{
		this.strDescription = strValue;
	}


	public function get closure():Function
	{
		return this.funcToCall;
	}


	public function get name():String
	{
		return this.strName;
	}
}
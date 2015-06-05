package com.innogames.as3communicator.io.javascript {
	import com.innogames.as3communicator.controllers.APIController;
	import com.innogames.as3communicator.utils.DebugLogger;
	import com.innogames.as3communicator.utils.IDebugLogger;

	import flash.external.ExternalInterface;
	import flash.system.Security;

	/**
	 * Class comment.
	 */
	public class JavaScriptConnector implements IDebugLogger, IConnector
	{
		private static const JS_CONNECTION_SCRIPT:XML = <script><![CDATA[
			function()
			{
				var objDomTree = document.getElementsByTagName('object');
				if(!objDomTree || objDomTree.length < 1) throw new Error('Couldn\'t find Flash Object!');

				var objCurrent = null;

				for(var i = 0, intLength = objDomTree.length; i < intLength; ++i)
				{
					objCurrent = objDomTree[i];
					if(objCurrent.type.toLowerCase() !== 'application/x-shockwave-flash') continue;

					try
					{
						console.log('Found Flash object with name: "'+ objCurrent.name +'", id: "'+ objCurrent.id +'", data: "'+ objCurrent.data +'"');
					}
					catch(e)
					{
						//nothing to do, just the log failed :)
					}

					$flash = objCurrent;
				}
			}
		]]></script>;

		private static var objInstance:JavaScriptConnector;

		private var vecAPI:Vector.<APIMethod>;

		public function JavaScriptConnector(objEnforcer:SingletonEnforcer)
		{
			if (!(objEnforcer) is SingletonEnforcer)
			{
				throw new ArgumentError('JavaScriptConnector must be invoked with SingletonEnforcer object. Use'
										+ ' JavaScriptConnector.instance!');
			}

			JavaScriptConnector.objInstance = this;
		}


		public static function get instance():JavaScriptConnector
		{
			var objInstance:JavaScriptConnector = JavaScriptConnector.objInstance;
			if (objInstance === null)
			{
				objInstance = JavaScriptConnector.objInstance = new JavaScriptConnector(new SingletonEnforcer());
			}

			return objInstance;
		}


		public function log(strMessage:String):void
		{
			if(!(DebugLogger.instance.logOptions & DebugLogger.LOG_TO_JS_CONSOLE)) return;

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


		public function setup():Boolean
		{
			if (!ExternalInterface.available) return false;

			var objController:APIController = APIController.instance;
			var objAPIMethod:APIMethod;

			this.vecAPI = new<APIMethod>[];

			objAPIMethod					= new APIMethod('clickAtPosition', objController.clickAtPosition);
			objAPIMethod.description		= objAPIMethod.name + '(x, y) - Clicks on the specified position on screen';
			this.vecAPI[this.vecAPI.length] = objAPIMethod;

			objAPIMethod                    = new APIMethod('clickObject', objController.clickObject);
			objAPIMethod.description        = objAPIMethod.name
											  + '(name) - Clicks on the specified object, if it can be'
											  + ' found by the name. Use FullyQualifiedIdentifiers like'
											  + ' "myObject.child.button" or array access, like "[0][1][0]';
			this.vecAPI[this.vecAPI.length] = objAPIMethod;

			objAPIMethod                    = new APIMethod('countObjectsOnStage', objController.countObjectsOnStage);
			objAPIMethod.description        = objAPIMethod.name + '() - Counts all objects on stage recursively and'
											  + ' returns that number.';
			this.vecAPI[this.vecAPI.length] = objAPIMethod;

			objAPIMethod                    = new APIMethod('findObjectByName', objController.findObject);
			objAPIMethod.description        = objAPIMethod.name + '(name) - Tries to find an object by the given name,'
											  + ' or array access (same as for clickObject). Will include all '
											  + 'properties.';
			this.vecAPI[this.vecAPI.length] = objAPIMethod;

			objAPIMethod                    = new APIMethod('getAllObjectsAndProperties', this.proxyFindAllObjectsOnStage);
			objAPIMethod.description        = objAPIMethod.name + '() - Returns all objects that are'
											  + ' currently on stage. Will include all properties. Please note that'
											  + ' this method can be very slow, due to the amount of JSON data'
											  + ' created. Use it only for debugging!';
			this.vecAPI[this.vecAPI.length] = objAPIMethod;

			objAPIMethod                    = new APIMethod('getAllObjects', objController.getAllObjectsOnStage);
			objAPIMethod.description        = objAPIMethod.name
											  + '() - Returns all objects that are currently on stage. This method'
											  + ' is not recursive!';
			this.vecAPI[this.vecAPI.length] = objAPIMethod;

			objAPIMethod                    = new APIMethod('getObjectAtPosition', objController.getObjectAtPosition);
			objAPIMethod.description        = objAPIMethod.name + '(x, y) - Returns the object at the given location.';
			this.vecAPI[this.vecAPI.length] = objAPIMethod;

			objAPIMethod                    = new APIMethod('getObjectProperty', objController.getObjectProperty);
			objAPIMethod.description        = objAPIMethod.name + '(objectName, propertyName) - Returns the specified'
											  + ' property of the given object name (can also be array access).'
											  + ' Please note that this will only work for primitive types like'
											  + ' String, int, etc.';
			this.vecAPI[this.vecAPI.length] = objAPIMethod;

			objAPIMethod                    = new APIMethod('getObjectTree', objController.getObjectTree);
			objAPIMethod.description        = objAPIMethod.name + '() - Returns a very small representation of the tree'
											  + ' structure of the current display object hierarchy';
			this.vecAPI[this.vecAPI.length] = objAPIMethod;

			objAPIMethod                    = new APIMethod('help', this.printAPI);
			objAPIMethod.description        = objAPIMethod.name + '() - Prints this help documentation.';
			this.vecAPI[this.vecAPI.length] = objAPIMethod;

			objAPIMethod                    = new APIMethod('setObjectProperty', objController.setObjectProperty);
			objAPIMethod.description        = objAPIMethod.name
											  + '(objectName, propertyName, value) - Let\'s you modify'
											  + ' any given property of the given object. You could, for instance,'
											  + ' change the .text property of a TextField, to change it\'s content.';
			this.vecAPI[this.vecAPI.length] = objAPIMethod;

			objAPIMethod                    = new APIMethod('toggleHighlight', objController.toggleHighlight);
			objAPIMethod.description        = objAPIMethod.name + '(objectName) - Will toggle the highlighting of the'
											  + ' given element name (can also be array access). If switched on, the'
											  + ' highlight will be illuminated with a magenta glow.';
			this.vecAPI[this.vecAPI.length] = objAPIMethod;

			objAPIMethod                    = new APIMethod('toggleHighlightUnderCursor', objController.toggleHighlightUnderCursor);
			objAPIMethod.description        = objAPIMethod.name + '() - Will toggle the highlighting of elements'
											  + ' that are currently under the cursor and are clickable. Will also'
											  + ' print the FQI (FullyQualifiedIdentifier) to console.';
			this.vecAPI[this.vecAPI.length] = objAPIMethod;

			objAPIMethod                    = new APIMethod('toggleCursorPosition', objController.toggleCursorPosition);
			objAPIMethod.description        = objAPIMethod.name +'() - Will toggle printing the current cursor'
											  + ' position to console.';
			this.vecAPI[this.vecAPI.length] = objAPIMethod;


			/**
			 * Register the API in JavaScript.
			 */
			for(var i:int = 0, intLength:int = this.vecAPI.length; i < intLength; ++i)
			{
				objAPIMethod = this.vecAPI[i] as APIMethod;
				ExternalInterface.addCallback(objAPIMethod.name, objAPIMethod.closure)
			}

			DebugLogger.instance.log('SandboxType: '+ Security.sandboxType);
			ExternalInterface.marshallExceptions = true;
			ExternalInterface.call(JavaScriptConnector.JS_CONNECTION_SCRIPT);
			DebugLogger.instance.log('JavaScriptConnector setup.');

			return true;
		}


		private function printAPI():String
		{
			var result: String = '';
			var objAPIMethod:APIMethod;

			for(var i:int = 0, intLength:int = this.vecAPI.length; i < intLength; ++i)
			{
				objAPIMethod = this.vecAPI[i] as APIMethod;
				result += objAPIMethod.description +'\n\n';
			}

			return result;
		}

		private function proxyFindAllObjectsOnStage():String
		{
			return APIController.instance.getAllObjectsOnStage(true);
		}
	}
}

internal class SingletonEnforcer{}

internal class APIMethod
{
	private var funcToCall		:Function,
				strDescription	:String,
				strName			:String;

	public function APIMethod(strName:String, funcToCall:Function, strDescription:String = null)
	{
		this.strDescription		= strDescription;
		this.strName			= strName;
		this.funcToCall			= funcToCall;
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
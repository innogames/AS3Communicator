package com.innogames.as3communicator.utils
{
	import com.innogames.as3communicator.io.javascript.JavaScriptConnector;

	import flash.external.ExternalInterface;

	/**
	 * Class comment.
	 */
	public class DebugLogger
	{

		public static const LOG_TO_JS_CONSOLE:int = 1,
				LOG_TO_TRACE:int = 1 << 1,
				LOG_TO_INTERFACE:int = 1 << 2;

		private static var objInstance:DebugLogger;

		public static function get instance():DebugLogger
		{
			var objInstance:DebugLogger = DebugLogger.objInstance;
			if(objInstance === null)
			{
				objInstance = DebugLogger.objInstance = new DebugLogger(new SingletonEnforcer());
			}

			return objInstance;
		}

		public function DebugLogger(objEnforcer:SingletonEnforcer)
		{
			if(!(objEnforcer) is SingletonEnforcer)
			{
				throw new ArgumentError('DebugLogger must be invoked with SingletonEnforcer object. Use'
						+ ' DebugLogger.instance!');
			}

			DebugLogger.objInstance = this;

			this.blnUseJSConsole = ExternalInterface.available;
		}
		private var blnUseJSConsole:Boolean,
				intLogOptions:int,
				vecInterfaceLoggers:Vector.<IDebugLogger>;

		public function get logOptions():int
		{
			return this.intLogOptions;
		}

		public function set logOptions(intOptions:int):void
		{
			this.intLogOptions = intOptions;
		}

		public function addLogInterface(objLogger:IDebugLogger):void
		{
			if(this.vecInterfaceLoggers === null)
			{
				this.vecInterfaceLoggers = new <IDebugLogger>[];
			}

			this.vecInterfaceLoggers[this.vecInterfaceLoggers.length] = objLogger;
		}

		public function log(strMessage:String):void
		{
			if(this.intLogOptions & DebugLogger.LOG_TO_INTERFACE && this.vecInterfaceLoggers)
			{
				for(var i:int = 0, intLen:int = vecInterfaceLoggers.length; i < intLen; ++i)
				{
					(this.vecInterfaceLoggers[i] as IDebugLogger).log(strMessage);
				}
			}

			if(this.intLogOptions & DebugLogger.LOG_TO_JS_CONSOLE)
			{
				JavaScriptConnector.instance.log(strMessage);
			}

			if(this.intLogOptions & DebugLogger.LOG_TO_TRACE)
			{
				trace(strMessage);
			}
		}

		public function removeLogInterface(objLogger:IDebugLogger):void
		{
			if(this.vecInterfaceLoggers === null) return;

			var intIndex:int = this.vecInterfaceLoggers.indexOf(objLogger);

			if(intIndex === -1) return;

			if(this.vecInterfaceLoggers.length > 1)
			{
				this.vecInterfaceLoggers[intIndex] = this.vecInterfaceLoggers[this.vecInterfaceLoggers.length - 1];
			}
			else
			{
				this.vecInterfaceLoggers = null;
			}
		}
	}
}

internal class SingletonEnforcer
{
}
package com.innogames.as3communicator.io.javascript
{

	public interface IConnector
	{
		function exposeMethod(methodName:String, callable:Function, description:String):void;

		function setup(strDOMName:String):Boolean;
	}
}

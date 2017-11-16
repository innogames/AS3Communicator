package com.innogames.as3communicator.controllers.commands
{
    import com.innogames.as3communicator.errors.ErrorConstants;

    import flash.display.DisplayObject;

    /**
	 * Calls a method of the given object with ot without paramters. The paramters should be a primitive types. Will
     * return an error message, if method couldn't be found.
	 */
	public class CallObjectMethodCommand implements ICommand
	{
		public function execute(...args:Array):Object
		{
			if(!args
					|| args.length < 3
					|| !(args[0] is DisplayObject)
					|| !(args[1] is String))
			{
				throw new Error(ErrorConstants.INCORRECT_ARGUMENTS);
			}

			var objTargetObject:DisplayObject = args[0] as DisplayObject;
			var strMethodName:String = args[1] as String;
			var paramsAsString:Array = args[2];

			if(!objTargetObject.hasOwnProperty(strMethodName))
			{
				return 'Couldn\'t find method \'' + strMethodName + '\' on object \'' + objTargetObject.name + '\'';
			}

			try
			{
				var params: Array = new Array();
				for (var i: int = 0; i < paramsAsString.length; ++i) {
					var argValue: String = paramsAsString[i];

					if (argValue['containsAny'](['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '.'])) {
						params.push(parseFloat(argValue));
					}
					else if (argValue['containsAny'](['true', 'false'])) {
						params.push(argValue.toLowerCase() === 'true');
					}
					else {
						params.push(argValue);
					}
				}
				
				var returnValue: Object = objTargetObject[strMethodName].apply(objTargetObject, params);
				return strMethodName + '=' + returnValue;
			}
			catch(e:Error)
			{
				return e.toString();
			}
		}
	}
}

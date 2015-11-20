package com.innogames.as3communicator.controllers.commands
{
    import com.innogames.as3communicator.errors.ErrorConstants;

    import flash.display.DisplayObject;

    /**
	 * Sets any property of the given object to the given value. Will return an error message,
	 * if property couldn't be found.
	 */
	public class SetObjectPropertyCommand implements ICommand
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
			var strPropertyName:String = args[1] as String;
			var propertyValue:* = args[2];

			if(!objTargetObject.hasOwnProperty(strPropertyName))
			{
				return 'Couldn\'t find property \'' + strPropertyName + '\' on object \'' + objTargetObject.name + '\'';
			}

			try
			{
				if(propertyValue['containsAny'](['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '.']))
				{
					objTargetObject[strPropertyName] = parseFloat(propertyValue);
				}
				else if(propertyValue['containsAny'](['true', 'false']))
				{
					objTargetObject[strPropertyName] = propertyValue.toLowerCase() === 'true';
				}
				else
				{
					objTargetObject[strPropertyName] = propertyValue;
				}

				return strPropertyName + '=' + objTargetObject[strPropertyName];
			}
			catch(e:Error)
			{
				return e.toString();
			}
		}
	}
}

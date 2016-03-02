package com.innogames.as3communicator.controllers.commands
{
    import com.innogames.as3communicator.errors.ErrorConstants;

    import flash.display.DisplayObject;

    /**
	 * Gets any property of the given object. Will return an error message, if property couldn't be found.
	 */
	public class GetObjectPropertyCommand implements ICommand
	{
		public function execute(...args:Array):Object
		{
			if(!this.hasValidArguments(args))
			{
				throw new Error(ErrorConstants.INCORRECT_ARGUMENTS);
			}

			var objTargetObject:DisplayObject = args[0] as DisplayObject;
			var strPropertyName:String = args[1] as String;

			if(!objTargetObject.hasOwnProperty(strPropertyName))
			{
				return 'Couldn\'t find property \'' + strPropertyName + '\' on object \'' + objTargetObject.name + '\'';
			}

			return objTargetObject[strPropertyName];
		}


		private function hasValidArguments(args:Array):Boolean
		{
			return args
				&& args.length === 2
				&& (args[0] is DisplayObject)
				&& (args[1] is String);
		}
	}
}

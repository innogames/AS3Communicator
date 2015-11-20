package com.innogames.as3communicator.controllers.commands
{
    import com.innogames.as3communicator.errors.ErrorConstants;

    import flash.display.DisplayObject;
    import flash.filters.GlowFilter;

    /**
	 * Toggles highlighting of the given object.
	 */
	public class ToggleHighlightCommand implements ICommand
	{
		public function execute(...args:Array):Object
		{
			if(!args
					|| !args.length
					|| (!args[0] is DisplayObject)
			) throw new Error(ErrorConstants.INCORRECT_ARGUMENTS);

			var objDO:DisplayObject = args[0] as DisplayObject;

			if(objDO.filters.length)
			{
				objDO.filters = [];

				return 'removed highlight from "' + objDO.name + '".';
			}

			objDO.filters = [
				new GlowFilter(0xFF00FF, .65)
			];

			return 'added highlight to "' + objDO.name + '".';
		}
	}
}

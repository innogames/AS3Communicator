package com.innogames.as3communicator.controllers.commands
{
    import com.innogames.as3communicator.errors.ErrorConstants;

    import flash.display.DisplayObject;
    import flash.display.InteractiveObject;
    import flash.events.MouseEvent;

    /**
	 * Will emulate a mouse out on an object
	 */
	public class StopHoverObjectCommand implements ICommand
	{
		public function execute(...args:Array):Object
		{
			if(!args
					|| !args.length
					|| !(args[0] is DisplayObject)) throw new Error(ErrorConstants.INCORRECT_ARGUMENTS);

			var objectToHover:DisplayObject = args[0] as DisplayObject;
			var x:int = (args.length === 3) ? args[1] as int : -1;
			var y:int = (args.length === 3) ? args[2] as int : -1;

			if(!(objectToHover is InteractiveObject))
			{
				if(objectToHover.parent && objectToHover.parent is InteractiveObject)
				{
					objectToHover = objectToHover.parent;
				}
			}

			if((objectToHover is InteractiveObject))
			{
				this.emulateMouseOutObject(objectToHover as InteractiveObject, x, y);
				return 'Stoping hovering over Object \'' + objectToHover.name + '\'';
			}

			return 'Object \'' + objectToHover.name + '\' is not an interactive object and cannot be hovered out!';
		}


		private function emulateMouseOutObject(objectToClick:InteractiveObject, x:int = -1, y:int = -1):void
		{
			if(x !== -1 && y !== -1)
			{
				var evt:MouseEvent = new MouseEvent(MouseEvent.MOUSE_OUT, true, false, x, y);
				objectToClick.dispatchEvent(evt);

				return;
			}

			objectToClick.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_OUT));
		}
	}
}

package com.innogames.as3communicator.controllers.commands
{
    import com.innogames.as3communicator.errors.ErrorConstants;

    import flash.display.DisplayObject;
    import flash.display.InteractiveObject;
    import flash.events.MouseEvent;

    /**
	 * Will emulate a normal click on an object, including MouseDown and MouseUp events.
	 */
	public class ClickObjectCommand implements ICommand
	{
		public function execute(...args:Array):Object
		{
			if(!args
					|| !args.length
					|| !(args[0] is DisplayObject)) throw new Error(ErrorConstants.INCORRECT_ARGUMENTS);

			var objectToClick:DisplayObject = args[0] as DisplayObject;
			var x:int = (args.length === 3) ? args[1] as int : -1;
			var y:int = (args.length === 3) ? args[2] as int : -1;

			if(!(objectToClick is InteractiveObject))
			{
				if(objectToClick.parent && objectToClick.parent is InteractiveObject)
				{
					objectToClick = objectToClick.parent;
				}
			}

			if((objectToClick is InteractiveObject))
			{
				this.emulateClickOnObject(objectToClick as InteractiveObject, x, y);
				return 'Object \'' + objectToClick.name + '\' clicked';
			}

			return 'Object \'' + objectToClick.name + '\' is not an interactive object and cannot be clicked!';
		}


		private function emulateClickOnObject(objectToClick:InteractiveObject, x:int = -1, y:int = -1):void
		{
			if(x !== -1 && y !== -1)
			{
				var evt:MouseEvent = new MouseEvent(MouseEvent.MOUSE_DOWN, true, false, x, y);
				objectToClick.dispatchEvent(evt);
				evt = new MouseEvent(MouseEvent.CLICK, true, false, x, y);
				objectToClick.dispatchEvent(evt);
				evt = new MouseEvent(MouseEvent.MOUSE_UP, true, false, x, y);
				objectToClick.dispatchEvent(evt);

				return;
			}

			objectToClick.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN));
			objectToClick.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
			objectToClick.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_UP));
		}
	}
}

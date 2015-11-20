package com.innogames.as3communicator.controllers.commands
{
    import com.innogames.as3communicator.errors.ErrorConstants;

    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    import flash.display.InteractiveObject;
    import flash.geom.Point;

    /**
	 * Clicks at a specific position on the stage, stops after the first InteractiveObject.
	 */
	public class ClickAtPositionCommand implements ICommand
	{
		public function execute(...args:Array):Object
		{
			if(!args
					|| args.length !== 3
					|| !(args[0] is DisplayObjectContainer)
					|| !(args[1] is int)
					|| !(args[2] is int)) throw new Error(ErrorConstants.INCORRECT_ARGUMENTS);

			var ptDest:Point = new Point(args[0] as int, args[1] as int);
			var objParentContainer:DisplayObjectContainer = args[2] as DisplayObjectContainer;
			var ptLocal:Point = objParentContainer.globalToLocal(ptDest);
			var arrObjects:Array = objParentContainer.getObjectsUnderPoint(ptDest);
			var objCurrentObject:DisplayObject;

			new ClickObjectCommand().execute(objParentContainer);

			if(arrObjects.length)
			{
				for(var len:int = arrObjects.length, i:int = len; --i < len;)
				{
					objCurrentObject = arrObjects[i];
					if(!(objCurrentObject is InteractiveObject))
					{
						if(objCurrentObject.parent && objCurrentObject.parent is InteractiveObject)
						{
							objCurrentObject = objCurrentObject.parent;
						}
					}
					if(objCurrentObject is InteractiveObject)
					{
						ptLocal = (objCurrentObject as InteractiveObject).globalToLocal(ptDest);

						return new ClickObjectCommand().execute(objCurrentObject, ptLocal.x, ptLocal.y) as String;
					}
				}
			}

			return "No clickable object found.";
		}
	}
}

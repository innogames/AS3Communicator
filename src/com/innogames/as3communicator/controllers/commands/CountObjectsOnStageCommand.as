package com.innogames.as3communicator.controllers.commands
{
    import com.innogames.as3communicator.errors.ErrorConstants;
    import com.innogames.as3communicator.model.DisplayObjectVO;

    /**
	 * Implements the function to count all DisplayObjects recursively that are currently on the stage.
	 */
	public class CountObjectsOnStageCommand implements ICommand
	{
		public function execute(...args:Array):Object
		{
			if(!args
					|| !args.length
					|| !(args[0] is Vector.<DisplayObjectVO>)) throw new Error(ErrorConstants.INCORRECT_ARGUMENTS);

			var vecObjects:Vector.<DisplayObjectVO> = args[0] as Vector.<DisplayObjectVO>;
			var intTotalNumberOfObjects:int = 0;

			for(var i:int = 0, len:int = vecObjects.length; i < len; ++i)
			{
				intTotalNumberOfObjects += this.countObjectsRecursive(vecObjects[i]);
			}

			intTotalNumberOfObjects += len;

			return intTotalNumberOfObjects;
		}


		private function countObjectsRecursive(objParent:DisplayObjectVO):int
		{
			var intChildCount:int = 0;
			if(objParent.hasChildren)
			{
				for(var i:int = 0, len:int = objParent.children.length; i < len; ++i)
				{
					intChildCount += this.countObjectsRecursive(objParent.children[i]);
				}

				intChildCount += len;
			}

			return intChildCount;
		}
	}
}

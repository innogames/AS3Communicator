package com.innogames.as3communicator.utils
{
    import com.innogames.as3communicator.model.DisplayObjectVO;

    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;

    /**
	 * Combines utility method for iterating over DisplayObjectVOs.
	 */
	public class DisplayObjectVOIteratorUtil
	{
		public static function getChildren(objParent:DisplayObject):Vector.<DisplayObjectVO>
		{
			var i:int,
					len:int,
					objCurrentDisplayChild:DisplayObject,
					objCurrentChildVO:DisplayObjectVO,
					objParentContainer:DisplayObjectContainer,
					objPool:DisplayObjectVOPool,
					vecChildren:Vector.<DisplayObjectVO>,
					vecGrandChildren:Vector.<DisplayObjectVO>;

			if(!(objParent is DisplayObjectContainer)) return null;

			objParentContainer = objParent as DisplayObjectContainer;

			if(objParentContainer.numChildren === 0) return null;

			objPool = DisplayObjectVOPool.instance;
			len = objParentContainer.numChildren;
			vecChildren = new Vector.<DisplayObjectVO>(len, true);
			do
			{
				objCurrentDisplayChild = objParentContainer.getChildAt(i);
				vecGrandChildren = DisplayObjectVOIteratorUtil.getChildren(objCurrentDisplayChild);
				objCurrentChildVO = objPool.getElement(objCurrentDisplayChild, vecGrandChildren);
				vecChildren[i] = objCurrentChildVO;
			}
			while(++i !== len);

			return vecChildren;
		}
	}
}

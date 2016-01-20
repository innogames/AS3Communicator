package com.innogames.as3communicator.utils
{
    import com.innogames.as3communicator.model.DisplayObjectVO;

    import flash.display.DisplayObject;

    /**
	 * Provides pooling for DisplayObjectVO instances.
	 */
	public class DisplayObjectVOPool
	{
		private static var objInstance:DisplayObjectVOPool;

		private var objFirstElement:PoolElement;


		public static function get instance():DisplayObjectVOPool
		{
			var objInstance:DisplayObjectVOPool = DisplayObjectVOPool.objInstance;
			if(objInstance === null)
			{
				objInstance = DisplayObjectVOPool.objInstance = new DisplayObjectVOPool(new SingletonEnforcer());
			}

			return objInstance;
		}

		public function DisplayObjectVOPool(objEnforcer:SingletonEnforcer)
		{
			if(!(objEnforcer is SingletonEnforcer))
			{
				throw new ArgumentError('Class must be invoked with SingletonEnforcer object. Use'
						+ ' get instance!');
			}

			this.objFirstElement = new PoolElement();
			this.objFirstElement.objVO = new DisplayObjectVO();
		}

		public function getElement(objDO:DisplayObject = null, vecChildren:Vector.<DisplayObjectVO> = null):DisplayObjectVO
		{
			var objCurrent:PoolElement = this.objFirstElement;

			while(true)
			{
				if(!objCurrent.blnUsed)
				{
					objCurrent.blnUsed = true;
					break;
				}

				if(!objCurrent.objNext)
				{
					objCurrent.objNext = new PoolElement();
					objCurrent.objNext.objVO = new DisplayObjectVO();
				}

				objCurrent = objCurrent.objNext;
			}

			var objVO:DisplayObjectVO = objCurrent.objVO;

			if(objDO)
			{
				objVO.displayObject = objDO;
			}

			if(vecChildren)
			{
				objVO.children = vecChildren;
			}

			return objVO;
		}


		public function freeAllElements():void
		{
			var objCurrent:PoolElement = this.objFirstElement;
			var objVO:DisplayObjectVO;

			while(true)
			{
				objCurrent.blnUsed = false;
				objVO = objCurrent.objVO;
				objVO.children = null;
				objVO.displayObject = null;

				objCurrent = objCurrent.objNext;

				if(!objCurrent) break;
			}
		}


		public function freeElement(objVO:DisplayObjectVO):void
		{
			var objCurrent:PoolElement = this.objFirstElement;

			while(true)
			{
				if(objCurrent.blnUsed === false)
				{
					objCurrent = objCurrent.objNext;
					if(!objCurrent) break;
				}

				if(objCurrent.objVO === objVO)
				{
					objCurrent.blnUsed = false;
					return;
				}

				objCurrent = objCurrent.objNext;
				if(!objCurrent) break;
			}
		}
	}
}

import com.innogames.as3communicator.model.DisplayObjectVO;

internal class SingletonEnforcer
{
}

internal class PoolElement
{
	public var objVO:DisplayObjectVO;
	public var blnUsed:Boolean;
	public var objNext:PoolElement;
	public var objPrev:PoolElement;
}
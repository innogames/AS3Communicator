package com.innogames.as3communicator.controllers.commands
{
	import com.innogames.as3communicator.errors.ErrorConstants;
	import com.innogames.as3communicator.model.DisplayObjectVO;

	/**
	 * Attempts to find an object by its given name.
	 */
	public class FindObjectVOByNameCommand implements ICommand
	{
		private static const BRACKET_CLOSE:String = ']';
		private static const BRACKET_OPEN:String = '[';
		private static const DOT:String = '.';

		public function execute(...args:Array):Object
		{
			if(!args || args.length !== 2) throw new Error(ErrorConstants.INCORRECT_ARGUMENTS);

			var strName:String = args[0] as String;
			var vecObjectList:Vector.<DisplayObjectVO> = args[1] as Vector.<DisplayObjectVO>;

			var blnFound:Boolean,
				blnLookingForFQI:Boolean,
				childObject:DisplayObjectVO,
				currentDO:DisplayObjectVO,
				currentNamePart:String,
				restNamePart:String;

			/**
			 * First look at dot-notation "parent.child.subchild"
			 */
			if(strName['containsBefore'](DOT, BRACKET_OPEN))
			{
				currentNamePart = strName['substringBefore'](DOT);
				restNamePart = strName['substringAfter'](DOT);
				blnLookingForFQI = true;
			}

			/**
			 * Then look at array-access "parent[0].subchild"
			 */
			else if(strName['contains']([BRACKET_OPEN, BRACKET_CLOSE]))
			{
				if(!strName['startsWith'](BRACKET_OPEN))
				{
					currentNamePart = strName['substringBefore'](BRACKET_OPEN);
					restNamePart = strName['substringAfter'](currentNamePart);
					blnLookingForFQI = true;
				}
				else
				{
					var childIndex:int = parseInt(strName['substringBetween'](BRACKET_OPEN, BRACKET_CLOSE));
					restNamePart = strName['substringAfter'](BRACKET_CLOSE);

					/**
					 * Starting from parent[0].subchild
					 * we'd now have the remaining .subchild, so we need to cut off the dot, to have accurate naming
					 */
					if(restNamePart['startsWith'](DOT))
					{
						restNamePart = restNamePart['substringAfter'](DOT)
					}

					if(vecObjectList && vecObjectList.length > childIndex)
					{
						childObject = vecObjectList[childIndex];
						vecObjectList = childObject.children;
					}
					else
					{
						return null;
					}
				}

				if(!childObject)
				{
					childObject = this.execute(currentNamePart, vecObjectList) as DisplayObjectVO;
					if(childObject)
					{
						vecObjectList = childObject.children;
					}
				}

				if(restNamePart)
				{
					return this.execute(restNamePart, vecObjectList) as DisplayObjectVO;
				}

				return childObject;
			}

			/**
			 * Then fall back to regular name "uniqueChild"
			 */
			else
			{
				currentNamePart = strName;
			}

			var i:int = -1,
				len:int = vecObjectList.length;
			while(++i !== len)
			{
				currentDO = vecObjectList[i] as DisplayObjectVO;
				if(currentDO.displayObject.name === currentNamePart)
				{
					blnFound = true;

					// not looking for children, return the final object
					if(!restNamePart) return currentDO;

					/**
					 * we're looking for children, but the currentDO doesn't have any, so return null, since we can't
					 * find something where nothing is.
					 */
					if(!currentDO.hasChildren) return null;
				}

				var blnTraverse:Boolean = (
								!blnLookingForFQI && !blnFound
						) || (
								blnFound && blnLookingForFQI
						);
				if(blnTraverse && currentDO.hasChildren)
				{
					if(!restNamePart)
					{
						restNamePart = currentNamePart;
					}

					childObject = this.execute(restNamePart, currentDO.children) as DisplayObjectVO;

					restNamePart = null;

					if(blnLookingForFQI && !childObject) return null;

					if(childObject !== null) return childObject;
				}
			}

			return null;
		}
	}
}

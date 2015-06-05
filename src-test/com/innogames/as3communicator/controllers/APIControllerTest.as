package com.innogames.as3communicator.controllers
{
	import com.innogames.as3communicator.utils.InitializationUtils;

	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;

	import org.hamcrest.assertThat;

	/**
	 * Class comment.
	 */
	public class APIControllerTest
	{
		use namespace testable;

		private var objAPIController:APIController;
		private var objDisplayObjectContainingNullNames:Sprite;

		[BeforeClass]
		{
			InitializationUtils;
		}

		public function APIControllerTest()
		{
		}


		[Before]
		public function setUp():void
		{
			this.objAPIController = APIController.instance;

			this.objDisplayObjectContainingNullNames = new Sprite();
			this.objDisplayObjectContainingNullNames.name = 'first';

			var objChildContainer:Sprite = new Sprite();
			objChildContainer.name = '';

			var objChild:Shape = new Shape();
			objChild.name = 'shape';

			objChildContainer.addChild(objChild);
			this.objDisplayObjectContainingNullNames.addChild(objChildContainer);
		}


		[After]
		public function tearDown():void
		{
			this.objDisplayObjectContainingNullNames = null;
		}

		[Test]
		public function test_getFQI_with_emptyNames():void
		{
			var strFQI:String = this.objAPIController.getFQI((this.objDisplayObjectContainingNullNames.getChildAt(0) as Sprite).getChildAt(0));

			assertThat(strFQI, 'first..shape');
		}
	}
}

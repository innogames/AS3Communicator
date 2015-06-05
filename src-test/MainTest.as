package {

	import com.innogames.as3communicator.controllers.APIController;
	import com.innogames.as3communicator.model.DisplayObjectVO;

	import flash.display.DisplayObject;
	import flash.display.Sprite;

	import org.fluint.uiImpersonation.UIImpersonator;
	import org.hamcrest.assertThat;

	public class MainTest {

		use namespace testable;

		private var objAS3Selenium		:AS3Communicator;
		private var vecDisplayObjects	:Vector.<DisplayObjectVO>;

		public function MainTest()
		{
		}

		[Before(async,ui)]
		public function setUp():void
		{
			var objMasterDO			:Sprite,
				objZeroChild		:Sprite,
				objFirstChild		:Sprite,
				objFirstChildSprite	:Sprite,
				voMaster			:DisplayObjectVO,
				voZeroChild			:DisplayObjectVO,
				voFirstChild		:DisplayObjectVO,
				voFirstChildSprite	:DisplayObjectVO;

			objMasterDO			= new Sprite();
			objZeroChild		= new Sprite();
			objFirstChild		= new Sprite();
			objFirstChildSprite	= new Sprite();
			objMasterDO			.name	= 'master';
			objZeroChild		.name	= 'zero';
			objFirstChild		.name	= 'first';
			objFirstChildSprite	.name	= 'sprite';

			objMasterDO.addChild(objFirstChild);
			objMasterDO.addChild(objZeroChild);
			objFirstChild.addChild(objFirstChildSprite);

			voFirstChildSprite	= new DisplayObjectVO(objFirstChildSprite, null);
			voZeroChild			= new DisplayObjectVO(objZeroChild, null);
			voFirstChild		= new DisplayObjectVO(objFirstChild, new<DisplayObjectVO>[voFirstChildSprite]);
			voMaster			= new DisplayObjectVO(objMasterDO, new<DisplayObjectVO>[voZeroChild, voFirstChild]);

			this.vecDisplayObjects = new <DisplayObjectVO>[];
			this.vecDisplayObjects.push(voMaster);

			this.objAS3Selenium = new AS3Communicator();
			UIImpersonator.addChild(this.objAS3Selenium);
		}

		[After(async,ui)]
		public function tearDown():void
		{
			UIImpersonator.removeChild(this.objAS3Selenium);
			this.objAS3Selenium = null;
		}

		[Test]
		public function testFindObjectByName_DotNotation():void
		{
			var strToFind	:String = 'master.first.sprite';
			var objResult	:DisplayObject;

			objResult = APIController.instance.findObjectByName(strToFind, this.vecDisplayObjects);

			assertThat(objResult.name, 'sprite');
		}

		[Test]
		public function testFindObjectByName_ArrayNotation_last(): void {
			var strToFind: String = 'master.first[0]';
			var objResult: DisplayObject;

			objResult = APIController.instance.findObjectByName(strToFind, this.vecDisplayObjects);

			assertThat(objResult.name, 'sprite');
		}


		[Test]
		public function testFindObjectByName_ArrayNotation_inbetween(): void {
			var strToFind: String = 'master[1].sprite';
			var objResult: DisplayObject;

			objResult = APIController.instance.findObjectByName(strToFind, this.vecDisplayObjects);

			assertThat(objResult.name, 'sprite');
		}


		[Test]
		public function testFindObjectByName_ArrayNotation_first(): void {
			var strToFind: String = '[0].first.sprite';
			var objResult: DisplayObject;

			objResult = APIController.instance.findObjectByName(strToFind, this.vecDisplayObjects);

			assertThat(objResult.name, 'sprite');
		}


		[Test]
		public function testFindObjectByName_ArrayNotation_only(): void {
			var strToFind: String = '[0][1][0]';
			var objResult: DisplayObject;

			objResult = APIController.instance.findObjectByName(strToFind, this.vecDisplayObjects);

			assertThat(objResult.name, 'sprite');
		}

		[Test]
		public function testFindObjectByName_on_real_example():void
		{
			this.vecDisplayObjects = new <DisplayObjectVO>[];

//			"instance6.instance8.instance163.HudContainer/CONTAINER_BUTTOM_LEFT.PlayerCityMainMenu.instance431.instance585.instance593"
			var objDOVO:DisplayObjectVO;
			var objChild:DisplayObjectVO;
			var vecInstance6Children:Vector.<DisplayObjectVO> = new <DisplayObjectVO>[];

			objDOVO = new DisplayObjectVO(new Sprite(), null);
			objDOVO.displayObject.name = 'root1';
			this.vecDisplayObjects.push(objDOVO);

			objChild = new DisplayObjectVO(new Sprite(), new <DisplayObjectVO>[new DisplayObjectVO(new Sprite(), null)]);
			objChild.displayObject.name = 'instance7';
			vecInstance6Children.push(objChild);

			var subChild: DisplayObjectVO = new DisplayObjectVO(new Sprite(), null);
			subChild.displayObject.name   = 'instance163';
			objChild                    = new DisplayObjectVO(new Sprite(), new <DisplayObjectVO>[subChild]);
			objChild.displayObject.name = 'instance8';
			vecInstance6Children.push(objChild);

			objChild                    = new DisplayObjectVO(new Sprite(), new <DisplayObjectVO>[new DisplayObjectVO(new Sprite(), null)]);
			objChild.displayObject.name = 'instance9';
			vecInstance6Children.push(objChild);

			objChild                    = new DisplayObjectVO(new Sprite(), new <DisplayObjectVO>[new DisplayObjectVO(new Sprite(), null)]);
			objChild.displayObject.name = 'instance10';
			vecInstance6Children.push(objChild);

			objChild                    = new DisplayObjectVO(new Sprite(), new <DisplayObjectVO>[new DisplayObjectVO(new Sprite(), null)]);
			objChild.displayObject.name = 'instance11';
			vecInstance6Children.push(objChild);

			objChild                    = new DisplayObjectVO(new Sprite(), new <DisplayObjectVO>[new DisplayObjectVO(new Sprite(), null)]);
			objChild.displayObject.name = 'instance13';
			vecInstance6Children.push(objChild);

			objChild                    = new DisplayObjectVO(new Sprite(), new <DisplayObjectVO>[new DisplayObjectVO(new Sprite(), null)]);
			objChild.displayObject.name = 'instance59';
			vecInstance6Children.push(objChild);

			objDOVO                    = new DisplayObjectVO(new Sprite(), vecInstance6Children);
			objDOVO.displayObject.name = 'instance6';

			this.vecDisplayObjects.push(objDOVO);

			objDOVO = new DisplayObjectVO(new Sprite(), null);
			objDOVO.displayObject.name = 'instance66';
			this.vecDisplayObjects.push(objDOVO);

			var strToFind:String = 'instance6.instance8.instance163';
			var objResult: DisplayObject;

			objResult = APIController.instance.findObjectByName(strToFind, this.vecDisplayObjects);

			assertThat(objResult.name, 'instance163');
		}
	}
}

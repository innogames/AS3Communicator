package com.innogames.as3communicator.utils {
	import com.innogames.as3communicator.utils.StringPrototypeFunctionsInitializer;

	import org.hamcrest.assertThat;

	public class InitializationUtilsTest {

		StringPrototypeFunctionsInitializer;

		public function InitializationUtilsTest() {
		}

		[Test]
		public function test_containsBefore_false_if_first_not_present():void
		{
			var strName:String = 'first[0]';

			assertThat(strName['containsBefore']('.','['), false);
		}


		[Test]
		public function test_containsBefore_false_if_last_not_present(): void {
			var strName: String = 'master.first';

			assertThat(strName['containsBefore']('.', '['), true);
		}


		[Test]
		public function test_containsBefore_true_if_matches(): void {
			var strName: String = 'master.first[0]';

			assertThat(strName['containsBefore']('.', '['), true);
		}


		[Test]
		public function test_containsBefore_false_if_no_match(): void {
			var strName: String = 'master';

			assertThat(strName['containsBefore']('.', '['), false);
		}


		[Test]
		public function test_substringAfter_returns_correct_substring():void
		{
			var strName:String = 'master[0].first';
			assertThat(strName['substringAfter']('master'), '[0].first');
		}


		[Test]
		public function test_substringBetween_returns_correct_substring():void
		{
			var strName:String = '<tag>content</tag>';
			assertThat(strName['substringBetween']('<tag>', '</tag>'), 'content');
		}
	}
}

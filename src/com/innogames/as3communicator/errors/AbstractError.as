package com.innogames.as3communicator.errors {

	/**
	 * AbstractError for common problems with abstract classes
	 */
	public class AbstractError extends Error {

		public static const METHOD_MUST_BE_OVERRIDDEN:String = 'Method is abstract and must be overridden';

		public function AbstractError(message:String = '')
		{
			super(message);
		}
	}
}

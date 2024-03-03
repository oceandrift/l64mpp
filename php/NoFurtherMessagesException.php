<?php

declare(strict_types=1);

namespace Oceandrift\L64mpp;

use \Exception;

class NoFurtherMessagesException extends Exception
{
	function __construct()
	{
		parent::__construct('End of stream; no more messages.');
	}
}
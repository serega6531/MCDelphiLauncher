<?php

function cryptStr($str)
{
	$result = '';
	$key = 7;
	for ($i=0; $i < strlen($str); $i++) { 
		$result .= chr(ord($str[$i]) + $key);
	}
	return $result;
}

function decryptStr($str)
{
	$result = '';
	$key = 7;
	for ($i=0; $i < strlen($str); $i++) { 
		$result .= chr(ord($str[$i]) - $key);
	}
	return $result;
}

?>
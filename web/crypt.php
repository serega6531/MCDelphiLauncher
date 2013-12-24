<?php

$key = 7;

function cryptStr($str)
{
	global $key;
	$result = '';
	for ($i=0; $i < strlen($str); $i++) { 
		$result .= chr(ord($str[$i]) + $key);
	}
	return $result;
}

function decryptStr($str)
{
	global $key;
	$result = '';
	for ($i=0; $i < strlen($str); $i++) { 
		$result .= chr(ord($str[$i]) - $key);
	}
	return $result;
}

?>
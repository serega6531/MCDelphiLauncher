<?php

$key = 7;

function cryptStr($str, $key2 = 0)
{
	global $key;
	$result = '';
	for ($i=0; $i < strlen($str); $i++) { 
		$result .= chr(ord($str[$i]) + $key - $key2);
	}
	return $result;
}

function decryptStr($str, $key2 = 0)
{
	global $key;
	$result = '';
	for ($i=0; $i < strlen($str); $i++) { 
		$result .= chr(ord($str[$i]) - $key + $key2);
	}
	return $result;
}

?>
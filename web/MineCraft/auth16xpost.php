<?php
require('../system.php');
require('crypt.php');

function generateSessionId() {
    srand(time());
    $randNum = rand(1000000000, 2147483647).rand(1000000000, 2147483647).rand(0,9);
    return $randNum;
}

function logExit($text, $output = "Bad login") {
  vtxtlog($text); exit($output);
}

if (empty($_POST)) 

	logExit("[auth16xpost.php] login process [Empty input] [LOGIN PASSWORD clientToken HID]");

	loadTool('user.class.php'); 
	BDConnect('auth');

$login = decryptStr($_POST["username"]); $password = decryptStr($_POST["password"]); $clientToken = decryptStr($_POST["clientToken"]); $hid = decryptStr($_POST["hid"]);

if (!preg_match("/^[a-zA-Z0-9_-]+$/", $password)  or
	!preg_match("/^[a-f0-9-]+$/", $clientToken)) 
		
	logExit("[auth16xpost.php] login process [Bad symbols] User [$login] Password [$password] clientToken [$clientToken]");		

	$BD_Field = (strpos($login, '@') === false)? $bd_users['login'] : $bd_users['email'] ; 	
	$auth_user = new User($login, $BD_Field); 
	
	if ( !$auth_user->id() ) logExit("[auth16xpost.php] login process [Unknown user] User [$login] Password [$password]");
	if ( $auth_user->lvl() <= 1 ) exit("Bad login");
	if ( !$auth_user->authenticate($password) ) logExit("[auth16xpost.php] login process [Wrong password] User [$login] Password [$password]");

    $sessid = generateSessionId();
    BD("UPDATE `{$bd_names['users']}` SET `{$bd_users['session']}`='".TextBase::SQLSafe($sessid)."' WHERE `{$BD_Field}`='".TextBase::SQLSafe($login)."'");
    BD("UPDATE `{$bd_names['users']}` SET `{$bd_users['clientToken']}`='".TextBase::SQLSafe($clientToken)."' WHERE `{$BD_Field}`='".TextBase::SQLSafe($login)."'");

	$ohid = BD("SELECT `id` FROM `hids` WHERE `hid`='".TextBase::SQLSafe($hid)."'");
    if (mysql_num_rows($ohid) == 0)
    {
    	vtxtlog("Updating hid for [$login : $hid]");
    	BD("INSERT INTO `hids` (`hid`, `banned`) VALUES ('".TextBase::SQLSafe($hid)."', '0')");	
    }

    $hidsql = BD("SELECT `banned` FROM `hids` WHERE `hid`='".TextBase::SQLSafe($hid)."'");
    while ($row1 = mysql_fetch_array($hidsql))
    {
    	if ($row1['banned'] == 1)
    	{
    		logExit("[auth16xpost.php] login process [HID banned: $hid]");
    	}
	}

	vtxtlog("[auth16xpost.php] login process [Success] User [$login] Session [$sessid] clientToken[$clientToken] hid [$hid]");			
        
        $responce = array(
            'clientToken' => cryptStr($clientToken), 
            'accessToken' => cryptStr($sessid));
        
        exit(json_encode($responce));
?>
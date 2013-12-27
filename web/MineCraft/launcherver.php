<?php

//WORKING ON WEBMCR
//IF YOU DONT HAVE WEBMCR JUST DO
//die('1'); //WHERE 1 IS LAUNCHER VERSION

require('../system.php');
BDConnect('launcherver');
echo sqlConfigGet('launcher-version');
?>
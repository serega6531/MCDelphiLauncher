<?php
require('../system.php');
BDConnect('version.php');
if ($_GET['what'] == 'version') {
	exit(sqlConfigGet('launcher-version'));
} else {
	exit('00000000000000000000000000000000');
}
?>
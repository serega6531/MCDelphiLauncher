<?php
require('../system.php');
BDConnect('launcherver');
if ($_GET['what'] == 'version') {
	echo sqlConfigGet('launcher-version');
} else {
	echo '00000000000000000000000000000000';
}
?>
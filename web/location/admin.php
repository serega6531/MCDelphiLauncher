<?php
if (!defined('MCR')) exit;
 
//...
  
    case 'ban':	
	
//...

	case 'hids': 
	BDConnect('HIDs');
	if ((isset($_POST['do'])) and (isset($_POST['id']))) {
		if ($_POST['do'] == 'ban') {
			BD("UPDATE `hids` SET `banned` = '1' WHERE `id` = {$_POST['id']}");
		} else {
			BD("UPDATE `hids` SET `banned` = '0' WHERE `id` = {$_POST['id']}");
		}
	}
	$func1 = function ($int) {if ($int == 1) {return 'Да';}         else {return 'Нет';}      };
	$func2 = function ($int) {if ($int == 1) {return 'Разбанить';}  else {return 'Забанить';} };
	$func3 = function ($int) {if ($int == 1) {return 'unban';}      else {return 'ban';}      };
	$table = "";
	if (isset($_POST['player'])) {
		$hids = BD("SELECT * FROM `hids` WHERE `username` LIKE '%".TextBase::SQLSafe($_POST['player'])."%' ORDER BY `id` DESC LIMIT 0, 20");
	} else {
		$hids = BD("SELECT * FROM `hids` ORDER BY `id` LIMIT 0, 20");
	}
	$count = mysql_num_rows($hids);
	if ($count > 0){
  		while ($result = mysql_fetch_array($hids)) {
			$table .= "
			<form method=\"post\">
   	     	  <tr>
   	     	      <td>".$result['username']."</td>
   	     	      <td>".$result['hid']."</td>
   	     	      <td>".$func1($result['banned'])."</td>
   	   		      <td width='130px'><input type=\"submit\" value=\"". $func2($result['banned']) ."\"></td>
         	 </tr>
         	 <input type=\"hidden\" name=\"id\" value=\"".$result['id']."\">
         	 <input type=\"hidden\" name=\"do\" value=\"".$func3($result['banned'])."\">
         	 </form>";
  		}

  		include View::Get('hids.html', $st_subdir);
	} else {echo '<div class="block-header">Ничего нет</div><div class="block-line"></div><div class="tab-pane" id="launcher"><p>Нет игроков</p></div><br /><br /><center><input type="button" value="Показать всех" onclick="window.location.href=location.href;"></center>';}	
	break;

    case 'rcon': 
	
//...
    
?>
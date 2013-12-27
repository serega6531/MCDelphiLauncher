<?php

if (empty($_POST)) 
{
	$page = 'Системная страница'; 
	$content_main .= 'Системная страница';
}

loadTool('monitoring.class.php');

$countNames = array('a', 'b', 'c', 'd', 'e', 'f', 'g', 'h');

if (isset($_POST['count'])) {
			$result = BD("SELECT `id` FROM `{$bd_names['servers']}` ORDER BY priority DESC");
			$count = mysql_num_rows($result);
			if ($count > 0) {
				$serversIds['count'] = $count;
				$i = 0;
				while ($servers = mysql_fetch_array($result)) {
					$serversIds[$countNames[$i]] = (int)$servers['id'];
					$i = $i + 1;		
				}
				echo json_encode($serversIds);
			} else {
				echo json_encode(array('count' => 0));
			}
		die();
		} 
	
if (isset($_POST['server'])) {
		$server = new Server($_POST['server']);
		$server->UpdateState(true);
		$st = $server->getInfo();
		$info = array('id' => $st['id'], 'name' => $st['name'], 'adress' => $st['address'], 'status' => $st['online'], 'players' => (int)$server->GetPlayers()[1], 'slots' => $st['slots']);
		echo json_encode($info);
		die();
	}

?>
<?php if (!defined('MCR')) exit;

$menu_items = array (

  0 => array (
  
  	//...
	
    'control' => array (
	
      //...
    	
    ),

    'hids' => array (
  
      'name' => 'Управление Hardware Id',
      'url' => Rewrite::GetURL(array('control', 'hids')),
      'parent_id' => 'admin',
      'lvl' => 15,
      'permission' => -1,
      'active' => false,
      'inner_html' => '',
    ),
	
    'category_news' => array (
	
    //...
	
  ),
);

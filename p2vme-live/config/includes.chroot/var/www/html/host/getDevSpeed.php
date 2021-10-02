<?php
$device = htmlspecialchars($_GET["dev"]);
// $link_speed = trim(shell_exec("cat /sys/class/net/$link_name/speed"));
$link_speed = trim(shell_exec("cat /tmp/$device/speed"));
print_r($link_speed);
print_r("teste");
?>

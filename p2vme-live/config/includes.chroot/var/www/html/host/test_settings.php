                        <h5 class="card-title">Test Results:</h5>
                        <table class="table table-striped table-hover table-bordered" style="width:50%">
                            <thead>
                                <th scope="col">Item</th>
                                <th scope="col">Value</th>
                                <th scope="col" style="width:70px">Status</th>
                            </thead>
                            <tbody>
                                <?php
                                    function pingAddress($ip) {
                                        $pingresult = exec("/bin/ping -c 3 -i 0.3 $ip", $outcome, $status);
                                        if (0 == $status) {
                                            $out = '<td class="bg-success text-white" align="center">OK</td>';
                                            $status = "alive";
                                        } else {
                                            $out = '<td class="bg-danger text-white" align="center">FAIL</td>';
                                            $status = "dead";
                                        }
                                        return $out;
                                    }

                                    $link_name = trim($_POST['nic_device']);
                                    $conn_ip = shell_exec("nmcli -g ip4.address device show $link_name");
                                    $conn_ip = explode("/",$conn_ip);
                                    $conn_ip = $conn_ip[0];
                                    $conn_gw = shell_exec("nmcli -g ip4.gateway device show $link_name");
                                    $conn_gw = trim($conn_gw);
                                    $conn_dns = shell_exec("nmcli -g ip4.dns device show $link_name");
                                    $conn_dns = explode("|",$conn_dns);
                                ?>
                                <tr>
                                    <th>IP Address</th>
                                    <td><?=$conn_ip?></td>
                                    <?php echo pingAddress($conn_ip);?>
                                </tr>
                                <tr>
                                    <th>Gateway</th>
                                    <td><?=$conn_gw?></td>
                                    <?php echo pingAddress($conn_gw);?>
                                </tr>
                                <?php
                                    $dns_id = 1;
                                    foreach($conn_dns as $conn_dns_srv){
                                        ?>
                                <tr>
                                    <th>DNS <?=$dns_id?></th>
                                    <td><?=$conn_dns_srv?></td>
                                    <?php echo pingAddress($conn_dns_srv);?>
                                </tr>
                                <?php
                                        $dns_id = $dns_id + 1;
                                    }
                                ?>
                            </tbody>
                        </table>
                        <?php
                            $run_id = shell_exec("cat /sys/class/net/$link_name/address");
                            $run_id = str_replace(":", "", $run_id);
                            $run_id = trim($run_id);
                            $run_id = substr($run_id, 4); 
                            $run_id_file = fopen("id.conf", "w") or die("Unable to open file!");
                            fwrite($run_id_file, $run_id);
                            fclose($run_id_file);
                        ?>
                        If all the tests are "OK" you must be able to proceed remotely using the following URL:<br>
                        <h5><span class="text-primary">http://<?=$conn_ip?></span></h5>
                        <p>
                            <h5>Take note of your conversion ID: <span class="text-danger"><b><?=strtoupper($run_id)?></b></span></h5>
                        </p>



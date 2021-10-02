<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>BS4IT P2VME</title>
    <link href="./css/bootstrap.min.css" rel="stylesheet" integrity="sha384-8qyea/eRYO2XZM/yJWJOs7fEo2bkOidOmKgf7ySbCT+FX3n9XGUKDegmdslTxeoM" crossorigin="anonymous">
</head>
<body>
    <div class="mt-4"></div>
    <?php
        // Build list of disks we're may be interested about;
        $get_blockdevices = shell_exec('lsblk -d -I 8,65,66,67,68,69,70,71,128,129,130,131,132,133,134,135,259  -n -J -o NAME,SIZE,VENDOR,MODEL');
        $blockdevices = json_decode($get_blockdevices);
        // print_r($blockdevices); 
        //Get number of sockets
        $get_cpu_sockets = shell_exec('lscpu --parse=SOCKET | egrep -v "^#"| uniq | wc -l');
        //Get number of cores
        $get_cpu_cores = shell_exec('lscpu --parse=CORE | egrep -v "^#"| uniq | wc -l');
        //Get number of theads
        $get_cpu_theads = shell_exec('lscpu --parse=CPU | egrep -v "^#"| uniq | wc -l');
        //Get CPU Model
        $get_cpu_model = shell_exec('cat /proc/cpuinfo | grep "model name" | uniq | cut -f2 -d":" | xargs');
        //Get CPU Max MHZ
        // $get_cpu_maxmhz = shell_exec('lscpu --parse=MAXMHZ | egrep -v "^#" | uniq | cut -d "." -f 1');
        //Get installed memory
        $get_memory = shell_exec('free -m | grep "Mem:" | xargs | cut -d " " -f 2');
        $get_fw_mode = shell_exec('[ -d /sys/firmware/efi ] && echo -n UEFI || echo -n BIOS');
        $installed_memory = round($get_memory / 1024);
        $nic_devices = shell_exec('lshw -class network -json');
        $nic_devices = json_decode($nic_devices);

        $run_id = trim(shell_exec("cat host/id.conf"));
    ?>
    <div class="container">
        <div class="jumbotron">
            <div class="card">
                <div class="card-header">
                    <img src="data:image/png;base64,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"> P2VME
                </div>
                <div class="card-body">
                <?php
                //Detect if the "Set Config" Button was pressed
                if(isset($_POST['set_config']))
                
                //If it was pressed, set variables, write configuration and metadata files, restart services and notify user about next steps.
                { 
                    $selected_devs = $_POST['selected_devs']; //Array cointaining selected disks
                    $installed_os = $_POST['installed_os'];
                    $server_name = $_POST['server_name'];
                    $cpu_sockets = $_POST['cpu_sockets'];
                    $cpu_cores = $_POST['cpu_cores'];
                    $fw_mode = $_POST['fw_mode'];
                    $memory = $_POST['memory'];
                    $nics = $_POST['nics'];
                    if(empty($selected_devs) || empty($installed_os) || empty($server_name)) 
                    //if(empty($installed_os) || empty($server_name)) 
                    //if(empty($installed_os)) 
                    //if(empty($selected_devs)) 
                    {?>
                        <span class="text-danger bg-light"><b>You must select at least one block device, choose Operating system and fill Server name </b></span>
                        <hr>
                        <button onclick="goBack()" name="go_back" class="btn btn-primary float-begin">Get back to fix it</button>
                        <script>
                            function goBack() {
                            window.history.back();
                            }
                        </script> 
                    <?php
                    } else {
                        //create json output file cointaining all settings
                        $p2vme_data ->conversion_id = $run_id;
                        $p2vme_data ->server_name = $server_name;
                        $p2vme_data ->installed_os = $installed_os;
                        $p2vme_data ->cpu_sockets = $cpu_sockets;
                        $p2vme_data ->cpu_cores = $cpu_cores;
                        $p2vme_data ->memory = $memory;
                        $p2vme_data ->fw_mode = $fw_mode;
                        $p2vme_data ->nics = $nics;
                        // $p2vme_data ->
                        // $p2vme_data ->
                        //create iscsi configuration file:
                        $target_id = $run_id;
                        #$target_id = str_replace(array("\n", "\r"), '', $target_id );
                        $tgt_conf = "default-driver iscsi\n";
                        $tgt_conf = $tgt_conf . "<target iqn.2014-04.br.com.bs4it:" . $target_id . ">\n";
                        $tgt_conf = $tgt_conf . "   controller_tid " . hexdec($target_id) . "\n";
                        $tgt_conf = $tgt_conf . "   vendor_id BS4IT\n";
                        $i = 1;
                        $d = 0;
                        $disks = array();
                        foreach ($selected_devs as $selected_dev) {
                            $disk_id = strtolower($run_id);
                            $disk_id .= sprintf('%04d', $i);
                            $tgt_conf = $tgt_conf . "   <direct-store /dev/" . $selected_dev . ">\n";
                            $tgt_conf = $tgt_conf . "   </direct-store>\n";
                            // $p2vme_data ->disks = array($selected_dev, $disk_id);
                            $disk[$i-1] ->device = $selected_dev;
                            $disk[$i-1] ->disk_id = $disk_id;
                            array_push($disks,$disk[$i-1]);
                            $i = $i+1;
                        }
                        //print_r($disks);
                        $p2vme_data ->disks = $disks;
                        $tgt_conf = $tgt_conf . "</target>\n";
                        $p2vme_dataJSON = json_encode($p2vme_data);
                        // Open JSON file for writting
                        $p2vme_dataJSON_file = fopen("p2vme.json", "w") or die("Unable to open JSON file!");
                        $json_success = fwrite($p2vme_dataJSON_file, $p2vme_dataJSON);
                        fclose($p2vme_dataJSON_file);
                        // Done creating Json File

                        // Open TGT config file for writting
                        $tgt_conf_file = fopen("p2vme.conf", "w") or die("Unable to open config file!");
                        $tgt_conf_success = fwrite($tgt_conf_file, $tgt_conf);
                        fclose($tgt_conf_file);
                        // Done creating TGT configuration file
                        
                        // Restart TGT service
                        $tgt_result = exec("/usr/bin/sudo /usr/bin/systemctl restart tgt.service", $outcome, $tgt_svc_success);


                        ?>
                    <h5>Applying settings for conversion ID <span class="text-danger"> <?=$run_id?></span></h5>
                    <hr>
                    <p class="card-text">The following happened:</p>
                    <table class="table table-striped table-hover table-bordered" style="width:50%">
                            <tbody>
                                <tr>
                                    <th>Parameters validation</th>
                                    <td class="bg-success text-white" align="center">OK</td>
                                </tr>
                                <tr>
                                    <th>Writting disk export daemon config file</th>
                                    <?php
                                        if ($tgt_conf_success != false){
                                            echo '<td class="bg-success text-white" align="center">OK</td>';
                                        } else {
                                            echo '<td class="bg-danger text-white" align="center">FAIL</td>';
                                        } 
                                    ?>
                                </tr>
                                <tr>
                                    <th>Writting JSON conversion file</th>
                                    <?php
                                        if ($json_success != false){
                                            echo '<td class="bg-success text-white" align="center">OK</td>';
                                        } else {
                                            echo '<td class="bg-danger text-white" align="center">FAIL</td>';
                                        } 
                                    ?>
                                </tr>
                                <tr>
                                    <th>Restarting export daemon service</th>
                                    <?php
                                        if ($tgt_svc_success == 0){
                                            echo '<td class="bg-success text-white" align="center">OK</td>';
                                        } else {
                                            echo '<td class="bg-danger text-white" align="center">FAIL - err ' . $tgt_svc_success . '</td>';
                                        } 
                                        //echo $tgt_svc_success;
                                    ?>
                                </tr>
                            </tbody>
                        </table>





                    <p>If all the boxes are green you're good to go to the next step, just close this window. <b>  </b>
                    <br>If something went wrong, please check and try again.
                    
                <?php }} else {
                            if (file_exists ("p2vme.json") && !isset($_POST['clear_config']))   { ?>
                                <h2>The conversion <span class="text-danger"> <?=$run_id?> </span>is currently running!</h2>
                                <hr>
                                <h5 class="card-text">If you don't understand what it means or just don't wanna mess around, please just close this window now!</h5>
                                <hr>
                                <h4 class="card-text">Once you click the button bellow this conversion will be broken and you'll need to set it up again.</h4>
                                <h4 class="card-text text-danger">!!! If this conversion is still published data may be lost !!!</h4>
                                <hr>
                                <form name="clear_config_form" method="post" action="<?php echo $_SERVER['PHP_SELF']; ?>">
                                    <input type="checkbox" id="terms_and_conditions" value="1" onclick="terms_changed(this)" /> <b>YES, I REALLY WANT TO CLEAR THE RUNNING CONVERSION</b><br>
                                    <button name="clear_config" type="submit" class="btn btn-danger" id="clear_config_button" disabled>I have read and I want to CLEAR Config</button>
                                </form>
                                <script>
                                    //JavaScript function that enables or disables a submit button depending
                                    //on whether a checkbox has been ticked or not.
                                    function terms_changed(termsCheckBox){
                                        //If the checkbox has been checked
                                        if(termsCheckBox.checked){
                                            //Set the disabled property to FALSE and enable the button.
                                            document.getElementById("clear_config_button").disabled = false;
                                        } else{
                                            //Otherwise, disable the submit button.
                                            document.getElementById("clear_config_button").disabled = true;
                                        }
                                    }
                                </script>


                            <?php } else {
                    
                    ?>
                
                    <h5>These are the settings for conversion ID <span class="text-danger"> <?=$run_id?></span></h5>
                    <hr>
                    <h5 class="card-title">Block devices</h5>
                    <p class="card-text">Please select the block devices you want to be published for conversion. At least one device must be selected.</p>
                    <form name="device_selection" method="post" action="<?php echo $_SERVER['PHP_SELF']; ?>">
                        <table class="table table-striped table-hover table-bordered">
                            <thead>
                                <tr>
                                    <th scope="col">#</th>
                                    <th scope="col">Device</th>
                                    <th scope="col">Size</th>
                                    <th scope="col">Vendor</th>
                                    <th scope="col">Model</th>
                                </tr>
                            </thead>
                            <tbody>
                                <?php
                                    unlink("p2vme.json");
                                    foreach ($blockdevices->blockdevices as $blockdevice) {
                                        ?>
                                <tr>
                                    <th scope="row">
                                        <input type="checkbox" class="form-check-input" name="selected_devs[]" value="<?=trim($blockdevice->name)?>">
                                    </th>
                                    <td><?=trim($blockdevice->name)?></td>
                                    <td><?=trim($blockdevice->size)?></td>
                                    <td><?=trim($blockdevice->vendor)?></td>
                                    <td><?=trim($blockdevice->model)?></td>
                                </tr>
                                <?php } ?>
                            </tbody>
                        </table>
                        <hr>
                        <h5 class="card-title">Detected CPU(s)</h5>
                        <p class="card-text">See below the detected CPU(s), memory and their characteristics.</p>
                        <table class="table table-striped table-hover table-bordered">
                            <thead>
                                <tr>
                                    <th scope="col"># of Sockets</th>
                                    <th scope="col"># of Cores</th>
                                    <th scope="col"># of Theads</th>
                                    <th scope="col">Model</th>
                                    <th scope="col">Memory</th>
                                    <th scope="col">NICs</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr>
                                    <td>
                                        <select class="form-control form-control-sm" name="cpu_sockets" style="width:40px">
                                            <?php
                                                for ($i = 1; $i <= 10; $i++) { 
                                                    if (trim($get_cpu_sockets) == $i) {
                                                        $selected = "selected";
                                                    }else{
                                                        $selected = "";
                                                        }
                                                    echo "<option value=$i $selected>$i</option>";
                                                }
                                            ?>
                                        </select>
                                    </td>
                                    <td>
                                        <select class="form-control form-control-sm" name="cpu_cores" style="width:40px">
                                            <?php
                                                for ($i = 1; $i <= 20; $i++) { 
                                                    if (trim($get_cpu_cores) == $i) {
                                                        $selected = "selected";
                                                    }else{
                                                        $selected = "";
                                                        }
                                                    echo "<option value=$i $selected>$i</option>";
                                                }
                                            ?>
                                        </select>      
                                    </td>
                                    <td><?=trim($get_cpu_theads)?></td>
                                    <td><?=trim($get_cpu_model)?></td>
                                    <td><input type="text" id="memory" name="memory" required minlength="1" maxlength="4" size="4" value=<?=$installed_memory?> style="width:50px"> </input>GB</td>
                                    <td>
                                        <select class="form-control form-control-sm" name="nics" style="width:40px">
                                            <?php
                                                for ($i = 1; $i <= 10; $i++) { 
                                                    if (count($nic_devices) == $i) {
                                                        $selected = "selected";
                                                    }else{
                                                        $selected = "";
                                                        }
                                                    echo "<option value=$i $selected>$i</option>";
                                                }
                                            ?>
                                        </select>      
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                        <hr>
                        <h5 class="card-title">Operating System</h5>
                        <p class="card-text">Please select the O.S type this server originaly runs, firmware mode and the Server name.</p>
                        <table class="table table-striped table-hover table-bordered table-responsive-sm" style="width: 50%">
                            <tbody>
                                <tr>
                                    <th scope="col" style="width: 30%">Installed O.S.:</th>
                                    <td>
                                    <div class="form-group col-9">
                                        <select class="form-control form-control-sm" name="installed_os">
                                            <option></option>
                                            <option value="rhel9_64Guest">Red Hat Enterprise Linux 9 (64-bit)</option>
                                            <option value="rhel8_64Guest">Red Hat Enterprise Linux 8 (64-bit)</option>
                                            <option value="rhel7_64Guest">Red Hat Enterprise Linux 7 (64-bit)</option>
                                            <option value="rhel7Guest">Red Hat Enterprise Linux 7 (32-bit)</option>
                                            <option value="rhel6_64Guest">Red Hat Enterprise Linux 6 (64-bit)</option>
                                            <option value="rhel6Guest">Red Hat Enterprise Linux 6 (32-bit)</option>
                                            <option value="rhel5_64Guest">Red Hat Enterprise Linux 5 (64-bit)</option>
                                            <option value="rhel5Guest">Red Hat Enterprise Linux 5 (32-bit)</option>
                                            <option value="oracleLinux9_64Guest">Oracle Linux 9 (64-bit)</option>
                                            <option value="oracleLinux8_64Guest">Oracle Linux 8 (64-bit)</option>
                                            <option value="oracleLinux7_64Guest">Oracle Linux 7 (64-bit)</option>
                                            <option value="oracleLinux7Guest">Oracle Linux 7 (32-bit)</option>
                                            <option value="oracleLinux6_64Guest">Oracle Linux 6 (64-bit)</option>
                                            <option value="oracleLinux6Guest">Oracle Linux 6 (32-bit)</option>
                                            <option value="oracleLinux64Guest">Oracle Linux 4/5 (64-bit)</option>
                                            <option value="oracleLinuxGuest">Oracle Linux 4/5 (32-bit)</option>
                                            <option value="centos9_64Guest">CentOS 9 (64-bit)</option>
                                            <option value="centos8_64Guest">CentOS 8 (64-bit)</option>
                                            <option value="centos7_64Guest">CentOS 7 (64-bit)</option>
                                            <option value="centos7Guest">CentOS 7 (32-bit)</option>
                                            <option value="centos6_64Guest">CentOS 6 (64-bit)</option>
                                            <option value="centos6Guest">CentOS 6 (32-bit)</option>
                                            <option value="centos64Guest">CentOS 4/5 (64-bit)</option>
                                            <option value="centosGuest">CentOS 4/5 (32-bit)</option>
                                            <option value="debian11_64Guest">Debian GNU/Linux 11 (64-bit)</option>
                                            <option value="debian11Guest">Debian GNU/Linux 11 (32-bit)</option>
                                            <option value="debian10_64Guest">Debian GNU/Linux 10 (64-bit)</option>
                                            <option value="debian10Guest">Debian GNU/Linux 10 (32-bit)</option>
                                            <option value="debian9_64Guest">Debian GNU/Linux 9 (64-bit)</option>
                                            <option value="debian9Guest">Debian GNU/Linux 9 (32-bit)</option>
                                            <option value="debian8_64Guest">Debian GNU/Linux 8 (64-bit)</option>
                                            <option value="debian8Guest">Debian GNU/Linux 8 (32-bit)</option>
                                            <option value="debian7_64Guest">Debian GNU/Linux 7 (64-bit)</option>
                                            <option value="debian7Guest">Debian GNU/Linux 7 (32-bit)</option>
                                            <option value="debian6_64Guest">Debian GNU/Linux 6 (64-bit)</option>
                                            <option value="debian6Guest">Debian GNU/Linux 6 (32-bit)</option>
                                            <option value="ubuntu64Guest">Ubuntu Linux (64-bit)</option>
                                            <option value="ubuntuGuest">Ubuntu Linux (32-bit)</option>
                                            <option value="winNetStandard64Guest">Windows Server 2003 (64-bit)</option>
                                            <option value="winNetStandardGuest">Windows Server 2003 (64-bit)</option>
                                            <option value="windows7Server64Guest">Windows Server 2008 R2 (64-bit)</option>
                                            <option value="windows8Server64Guest">Windows Server 2012 (64-bit)</option>
                                            <option value="windows9Server64Guest">Windows Server 2016 or later (64-bit)</option>
                                        </select>
                                    </div>
                                    </td>
                                </tr>
                                <tr>
                                    <th scope="col" style="width: 30%">Server Name:</th>
                                    <td>
                                    <div class="form-group col-4">
                                        <input class="form-control form-control-sm" name="server_name"></input>
                                    </div>
                                    </td>
                                </tr>
                                <tr>
                                    <th scope="col" style="width: 30%">Firmware Mode:</th>
                                    <td>
                                    <div class="form-group col-4">
                                        <select class="form-control form-control-sm" name="fw_mode">
                                            <option value="uefi" <?php if ($get_fw_mode == "UEFI") echo "selected"; ?>>UEFI</option>
                                            <option value="bios" <?php if ($get_fw_mode == "BIOS") echo "selected"; ?>>BIOS</option>
                                        </select>
                                    </div>
                                    <span class="small">Recommended setting based on currently booted mode: <b><?=$get_fw_mode?>.</b></span>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                        <hr>
                        <button name="set_config" type="submit" class="btn btn-primary float-end" onclick="myFunction()" id="myDIV">Set Config</button>
                        <script>
                            function myFunction() {
                            var x = document.getElementById("myDIV");
                            x.innerHTML = "<b>Please wait, processing!</b>";
                            x.style.backgroundColor='red';
                            }
                        </script>
                    </form>
                    <?php }
                        }?>
                </div>
            </div>
        </div>
    </div>
    <script src="./js/bootstrap.bundle.min.js" integrity="sha384-JEW9xMcG8R+pH31jmWH6WWP0WintQrMb4s7ZOdauHnUtxwoG2vI5DkLtS3qm9Ekf" crossorigin="anonymous"></script>
</body>
</html>
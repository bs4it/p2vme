<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>P2VME Host Selection</title>
    <link href="../css/bootstrap.min.css" rel="stylesheet" integrity="sha384-8qyea/eRYO2XZM/yJWJOs7fEo2bkOidOmKgf7ySbCT+FX3n9XGUKDegmdslTxeoM" crossorigin="anonymous">
    <script src="../js/jquery-3.5.1.min.js"></script>
    <script>
    $(document).ready(function(){ //hides/shows disable/enable IP relatec fields based on dhcp/static choice
        $("select").change(function(){
            $(this).find("option:selected").each(function(){
                var optionValue = $(this).attr("value");
                if(optionValue == "static"){
                    $(".static").not("." + optionValue).hide();
                    $("." + optionValue).show();
                    $(".static").prop('disabled', false);
                    
                } else{
                    $(".static").hide();
                    $(".static").prop('disabled', true);
                }
            });
        }).change();
    });
    </script>
</head>
<body>
    <div class="mt-4"></div>
    <div class="container">
        <div class="jumbotron">
            <div class="card">
                <div class="card-header">
                    <img src="data:image/png;base64,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"> P2VME
                </div>
                <?php
                //Detect if the "Set Config" Button was pressed
                if(isset($_POST['nic_selection_button']))
                //If it was pressed, go ahead.
                { 
                $link_name = $_POST['nic_device'];
                $vendormodel = $_POST['vendormodel'];
                ?>
                <div class="card-body"> 
                    <h5 class="card-title">IP Settings</h5>
                    <p class="card-text">You are setting up IP for the following interface</p>
                    <table class="table table-striped table-hover table-bordered">
                        <thead>
                            <tr>
                                <th scope="col">NIC</th>
                                <th scope="col">MAC Address</th>
                                <th scope="col">Vendor/Model</th>
                                <th scope="col">State</th>
                                <th scope="col">Speed</th>
                            </tr>
                        </thead>
                            <tbody>
                                <?php
                                //Remove all network connetions from NetworkManager
                                shell_exec('for i in `nmcli c | grep -o -- "[0-9a-fA-F]\{8\}-[0-9a-fA-F]\{4\}-[0-9a-fA-F]\{4\}-[0-9a-fA-F]\{4\}-[0-9a-fA-F]\{12\}"` ; do sudo nmcli connection delete uuid $i ; done');
                                //Build ethernet devices list
                                if (trim(shell_exec("cat /sys/class/net/$link_name/carrier")) == 0) {
                                        $link_state = "Disconnected";
                                        $link_speed = "-----";
                                    }
                                    if (trim(shell_exec("cat /sys/class/net/$link_name/carrier")) == 1) {
                                        $link_state = "Link Up";
                                        $link_speed = trim(shell_exec("cat /sys/class/net/$link_name/speed"));
                                        if ($link_speed < 1000){
                                            $link_speed = $link_speed . " Mb/s";
                                        } else {
                                            $link_speed = ($link_speed /1000);
                                            $link_speed = $link_speed . " Gb/s";
                                        }
                                    }
                                    ?>
                                <tr>
                                    <td><?=trim($link_name)?></td>
                                    <td><?=strtoupper(trim(shell_exec("cat /sys/class/net/$link_name/address")))?></td>
                                    <td><?=$vendormodel?></td>
                                    <td><?=$link_state?></td>
                                    <td><?=$link_speed?></td>
                                </tr>
                            </tbody>
                    </table>
                    <hr>
                    <form name="ip_settings" method="post" action="apply_ip.php">
                        <div style="width:300px">
                            <div class="input-group mb-3">
                                <span class="input-group-text" id="basic-addon3" style="width:60%">Configuration mode:</span>
                                    <select id="ip_mode" name="ip_mode" class="form-select form-select-md" aria-label=".form-select-md">
                                        <option value="dhcp" selected>DHCP</option>
                                        <option value="static">Static</option>
                                    </select>
                            </div>
                            <div class="static input-group mb-3 ">
                                <span class="input-group-text" id="basic-addon3" style="width:50%">IP Address</span>
                                <input type="text" class="form-control static" id="ipv4" name="ipv4" aria-describedby="basic-addon3" required pattern="^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$">
                            </div>
                            <div class="static input-group mb-3">
                                <span class="input-group-text" id="basic-addon3" style="width:50%">Net Mask</span>
                                <input type="text" class="form-control static" id="netmask" name="netmask" aria-describedby="basic-addon3" required pattern="^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$">
                            </div>
                            <div class="static input-group mb-3">
                                <span class="input-group-text" id="basic-addon3" style="width:50%">Gateway</span>
                                <input type="text" class="form-control static" id="gw" name="gw" aria-describedby="basic-addon3" required pattern="^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$">
                            </div>
                            <div class="static input-group mb-3">
                                <span class="input-group-text" id="basic-addon3" style="width:50%">DNS Server</span>
                                <input type="text" class="form-control static" id="dns" name="dns" aria-describedby="basic-addon3" required pattern="^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$">
                            </div>
                        </div>
                        <input type="hidden" id="nic_device" name="nic_device" value="<?=$link_name?>">
                        <input type="hidden" id="vendormodel" name="vendormodel" value="<?=$vendormodel?>">
                        <div class="btn-group float-end" role="group" aria-label="Bottons">
                            <button name="refresh" type="button" onClick="window.history.back()" class="btn btn-primary">Back</button>
                            <button name="ip_settings_button" type="submit" class="btn btn-primary">Next</button>
                        </div>
                    </form>
                    <script src='../js/jquery.inputmask.bundle.js'></script>
                    <script id="rendered-js" >
                        //input mask bundle ip address
                        var ipv4_address = $('#ipv4');
                        ipv4_address.inputmask({
                        alias: "ip",
                        greedy: false //The initial mask shown will be "" instead of "-____".
                        });

                        var netmask_address = $('#netmask');
                        netmask_address.inputmask({
                        alias: "ip",
                        greedy: false //The initial mask shown will be "" instead of "-____".
                        });

                        var gw_address = $('#gw');
                        gw_address.inputmask({
                        alias: "ip",
                        greedy: false //The initial mask shown will be "" instead of "-____".
                        });

                        var dns_address = $('#dns');
                        dns_address.inputmask({
                        alias: "ip",
                        greedy: false //The initial mask shown will be "" instead of "-____".
                        });

                    //# sourceURL=pen.js
                    </script>
                </div>
                <?php } else { ?>
                <div class="card-body">
                    <h5 class="card-title">Something went wrong!</h5>
                    <p class="card-text">You need to select a NIC at the previous step.</p>
                    <a href=nic_selection.php class="btn btn-primary" role="button">NIC selection</a>
                <?php } ?>

            </div>
        </div>
    </div>
    <script src="../js/bootstrap.bundle.min.js" integrity="sha384-JEW9xMcG8R+pH31jmWH6WWP0WintQrMb4s7ZOdauHnUtxwoG2vI5DkLtS3qm9Ekf" crossorigin="anonymous"></script>
</body>
</html>

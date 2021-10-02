<?php

?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>P2VME Host Selection</title>
    <style>
        #loader {
            border: 12px solid #f3f3f3;
            border-radius: 50%;
            border-top: 12px solid #444444;
            width: 70px;
            height: 70px;
            animation: spin 1s linear infinite;
        }
          
        @keyframes spin {
            100% {
                transform: rotate(360deg);
            }
        }
          
        .center {
            position: absolute;
            top: 0;
            bottom: 0;
            left: 0;
            right: 0;
            margin: auto;
        }


        .overlay{
            display: none;
            position: fixed;
            width: 100%;
            height: 100%;
            top: 0;
            left: 0;
            z-index: 999;
            background: rgba(240,240,240,0.8) url("loader.gif") center no-repeat;
        }
        /* Turn off scrollbar when body element has the loading class */
        body.loading{
            overflow: hidden;   
        }
        /* Make spinner image visible when body element has the loading class */
        body.loading .overlay{
            display: block;
        }
    </style>
    <link href="../css/bootstrap.min.css" rel="stylesheet" integrity="sha384-8qyea/eRYO2XZM/yJWJOs7fEo2bkOidOmKgf7ySbCT+FX3n9XGUKDegmdslTxeoM" crossorigin="anonymous">
    <script src="../js/jquery-3.5.1.min.js"></script>

</head>
<body>
    <div class="mt-4"></div>
    <div class="overlay"></div>
    <div class="container">
        <div class="jumbotron">
            <div class="card">
                <div class="card-header">
                    <img src="data:image/png;base64,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"> P2VME
                </div>
                <?php
                function mask2cidr($mask)
                {
                  $long = ip2long($mask);
                  $base = ip2long('255.255.255.255');
                  return 32-log(($long ^ $base)+1,2);
                
                  /* xor-ing will give you the inverse mask,
                      log base 2 of that +1 will return the number
                      of bits that are off in the mask and subtracting
                      from 32 gets you the cidr notation */
                }

                

                //Detect if the "Set Config" Button was pressed
                if(isset($_POST['ip_settings_button']))
                //If it was pressed, go ahead.
                { 
                //Remove all network connetions from NetworkManager
                shell_exec('for i in `nmcli c | grep -o -- "[0-9a-fA-F]\{8\}-[0-9a-fA-F]\{4\}-[0-9a-fA-F]\{4\}-[0-9a-fA-F]\{4\}-[0-9a-fA-F]\{12\}"` ; do sudo nmcli connection delete uuid $i ; done');
                $link_name = trim($_POST['nic_device']);
                $vendormodel = $_POST['vendormodel'];
                $ip_mode = $_POST['ip_mode'];
                $ipv4 = $_POST['ipv4'];
                $netmask = $_POST['netmask'];
                $prefix = mask2cidr($netmask);
                $gw = $_POST['gw'];
                $dns = $_POST['dns'];
                //Check IP mode and create connection
                if ($ip_mode == "dhcp") {
                    $ip_mode_text = "DHCP";
                    shell_exec("sudo nmcli con add type ethernet con-name $link_name ifname $link_name");
                }
                if ($ip_mode == "static") {
                    $ip_mode_text = "Static";
                    shell_exec("sudo nmcli con add type ethernet con-name $link_name ifname $link_name ip4 $ipv4/$prefix gw4 $gw ipv4.dns $dns,1.1.1.1");
                }
                
                ?>
                <div class="card-body"> 
                    <h5 class="card-title">IP Settings Applied</h5>
                    <p class="card-text">The following settings were applied:</p>
                    <table class="table table-striped table-hover table-bordered" style="width:25%">
                        <thead>
                            <tr>
                                <th scope="col">NIC</th>
                                <td><?=$link_name?></td>
                            </tr>
                        </thead>
                            <tbody>
                                <tr>
                                    <th>Mode</th>
                                    <td><?=$ip_mode_text?></td>
                                </tr>
                            </tbody>
                    </table>
                    <hr>
                    <script>
                        window.onload = function(){
                            $("#contents").load("test_settings.php", {
                                nic_device: "<?=$link_name?>"
                            });
                        }

                        // Initiate an Ajax request on button click
                        $(document).ready(function(){
                        $("#test_settings").click(function(){
                        // $(document).on("click", "button", function(){
                            $("#contents").load("test_settings.php", {
                                nic_device: "<?=$link_name?>"
                            });      
                        });
                        })

                        // Add remove loading class on body element based on Ajax request status
                        $(document).on({
                            ajaxStart: function(){
                                $("body").addClass("loading"); 
                            },
                            ajaxStop: function(){ 
                                $("body").removeClass("loading"); 
                            }    
                        });


                    </script>
                    <div id="contents">
                    </div>
                    <hr>
                    <div class="btn-group float" role="group" aria-label="Bottons">
                        <button name="test_settings" id="test_settings" type="button" class="btn btn-primary">Repeat Test</button>
                    </div>
                    <div class="btn-group float-end" role="group" aria-label="Bottons">
                        <button name="refresh" type="button" onClick="window.history.back()" class="btn btn-primary">Back</button>
                        <a href="startup.php" class="btn btn-primary">Start Over</a>
                    </div>
                    
                </div>
                <?php } else { ?>
                <div class="card-body">
                    <h5 class="card-title">Something went wrong!</h5>
                    <p class="card-text">You need to properly set the IP.</p>
                    <a href=ip_settings.php class="btn btn-primary" role="button">Return to IP Settings</a>
                <?php } ?>

            </div>
        </div>
    </div>
    <script src="../js/bootstrap.bundle.min.js" integrity="sha384-JEW9xMcG8R+pH31jmWH6WWP0WintQrMb4s7ZOdauHnUtxwoG2vI5DkLtS3qm9Ekf" crossorigin="anonymous"></script>
</body>
</html>

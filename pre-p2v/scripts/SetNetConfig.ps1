param([switch]$Elevated)

function Test-Admin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
    $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

if ((Test-Admin) -eq $false)  {
    if ($elevated) {
        # tried to elevate, did not work, aborting
    } else {
        Start-Process powershell.exe -Verb RunAs -ArgumentList ('-noprofile -noexit -file "{0}" -elevated' -f ($myinvocation.MyCommand.Definition))
    }
    exit
}

#'running with full privileges'

# get current folder
$folder = split-path -parent $MyInvocation.MyCommand.Definition

Function SetNet {
    param(
	    [Parameter(Mandatory)]
		[string] $NetConfig,

	    [Parameter(Mandatory)]
		[string] $NIC
	)
    # Determina the Configuration to apply
    $NetConfigSel = $NetConfigOBJ | Where-Object {$_.Name -eq $NetConfig}
    $NICSel = Get-NetAdapter | Where-Object {$_.Name -eq $NIC}

    # Remove existing configuration
    Write-Host "Removing adresses from $NIC"
    # Remove IP Addresses
    $NICSel | Remove-NetIPAddress -Confirm:$false
    # Remove Gateway

    If (($NICSel | Get-NetIPConfiguration).Ipv4DefaultGateway) {
        Write-Host "Removing gateway from $NIC"
        $NICSel | Remove-NetRoute -Confirm:$false
    }

    # Remove DNS Servers
    Write-Host "Removing DNS Servers from $NIC"
    $NICSel | Set-DnsClientServerAddress -ResetServerAddresses -Confirm:$false
    # Remove DNS Suffixes
    Write-Host "Removing DNS Suffix from $NIC"
    $NICSel | Set-DnsClient -ResetConnectionSpecificSuffix -Confirm:$false
   
    # disable IPV6 ON THIS INTERFACE
    Write-Host "Disabling IPv6 from $NIC"
    $NICSel | Disable-NetAdapterBinding -ComponentID ms_tcpip6 -Confirm:$false


    # Apply configuration

    # Add IP Addresses
    $NetConfigSel.Addresses | ForEach-Object {
        Write-host
        # Adding IP
        Write-Host "Adding $_.IPAddress/$_.PrefixLength to $NIC"
        $NICSel | New-NetIPAddress -IPAddress $_.IPAddress -PrefixLength $_.PrefixLength -Confirm:$false
    }
    
    # Add gateway
    If ($NetConfigSel.DefaultGateway) {
        Write-Host "Adding $NetConfigSel.DefaultGateway as gateway on $NIC"
        $NICSel | New-NetRoute -DestinationPrefix "0.0.0.0/0" -NextHop $NetConfigSel.DefaultGateway
    }
    
    # Add DNS Servers
    $NICSel | Set-DnsClientServerAddress -ServerAddresses $NetConfigSel.DNSServers

    # Add DNS Suffix
    $NICSel | Set-DnsClient -ConnectionSpecificSuffix $NetConfigSel.DNSClientCFG.ConnectionSpecificSuffix -RegisterThisConnectionsAddress $NetConfigSel.DNSClientCFG.RegisterThisConnectionsAddress -UseSuffixWhenRegistering $NetConfigSel.DNSClientCFG.UseSuffixWhenRegistering -Confirm:$false

    # Change NIC Name
    $NICSel | Rename-NetAdapter -NewName $NetConfigSel.Name

}





# get current folder
$folder = split-path -parent $MyInvocation.MyCommand.Definition

# test if file is created
If((test-path "$folder\netconfig.json"))
{
    $NetConfigOBJ = Get-Content $folder\netconfig.json | Out-String | ConvertFrom-Json
}
else
{
    Write-Host -ForegroundColor Red "Something is wrong. Check 'netconfig.json' file"
    break
}

$nic_list = Get-NetAdapter | Where-Object { $_.AdminStatus -eq "Up" } | Select-Object Name | Sort-Object -Property Name


Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = 'NICCfg - Set Config'
$form.Size = New-Object System.Drawing.Size(310,338)
$form.StartPosition = 'CenterScreen'

$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Location = New-Object System.Drawing.Point(75,250)
$OKButton.Size = New-Object System.Drawing.Size(75,23)
$OKButton.Text = 'OK'
$OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.AcceptButton = $OKButton
$form.Controls.Add($OKButton)

$CancelButton = New-Object System.Windows.Forms.Button
$CancelButton.Location = New-Object System.Drawing.Point(150,250)
$CancelButton.Size = New-Object System.Drawing.Size(75,23)
$CancelButton.Text = 'Cancel'
$CancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$form.CancelButton = $CancelButton
$form.Controls.Add($CancelButton)

$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(10,5)
$label.Size = New-Object System.Drawing.Size(300,20)
$label.Font = New-Object System.Drawing.Font("Arial",9,[System.Drawing.FontStyle]::Bold)
$label.Text = 'Check the Config to be used and select its NIC'
$form.Controls.Add($label)

$label2 = New-Object System.Windows.Forms.Label
$label2.Location = New-Object System.Drawing.Point(10,30)
$label2.Size = New-Object System.Drawing.Size(90,20)
$label2.Text = 'This Config'
$form.Controls.Add($label2)

$label3 = New-Object System.Windows.Forms.Label
$label3.Location = New-Object System.Drawing.Point(140,30)
$label3.Size = New-Object System.Drawing.Size(280,20)
$label3.Text = 'Will be applied to this NIC'
$form.Controls.Add($label3)

$labelCred = New-Object System.Windows.Forms.Label
$labelCred.AutoSize = $True
$labelCred.Location = New-Object System.Drawing.Point(155,280) 
$labelCred.Size = New-Object System.Drawing.Size(100,10)
$labelCred.Font = New-Object System.Drawing.Font("Arial",7,[System.Drawing.FontStyle]::Bold)
$labelCred.Text = "2021, Fernando Della Torre"
$form.Controls.Add($labelCred) 

$checkBoxes = @{}
$comboBox = @{}
$initialPosition = 50
$NetConfigOBJ| ForEach-Object {
    $Index = $_.Index
    $checkBoxes[$Index] = New-Object System.Windows.Forms.Checkbox
    $checkBoxes[$Index].Location = New-Object System.Drawing.Point(20,$initialPosition)
    $checkBoxes[$Index].Size = New-Object System.Drawing.Size(70,20)
    $checkBoxes[$Index].Visible = $true
    $checkBoxes[$Index].Text = $_.Name
    $checkBoxes[$Index].Checked = $false
    $form.Controls.Add($checkBoxes[$Index]) 

    $comboBox[$Index] = New-Object System.Windows.Forms.ComboBox
    $comboBox[$Index].Location  = New-Object System.Drawing.Point(140,$initialPosition)
    $comboBox[$Index].Size = New-Object System.Drawing.Size(131,280)
    $comboBox[$Index].Height = 10
    $comboBox[$Index].DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList;
    #$comboBox[$Index].Items.Add("")
    $nic_list | ForEach-Object {
        $comboBox[$Index].Items.Add( "$($_.Name)")
    }
    
    $form.Controls.Add($comboBox[$Index])
    $initialPosition = $initialPosition + 20
}
$form.Topmost = $true
$result = $form.ShowDialog()

if ($result -eq [System.Windows.Forms.DialogResult]::OK)
{
    # For each checked configuration call the function to apply config to corresponding NIC
    ForEach ($checkBox in $checkBoxes.GetEnumerator()) {
        if ( ($checkBox.Value.Checked -eq $true) -and ($comboBox[$checkBox.Name].SelectedItem -ne $null ) )
        {
            SetNet -NIC ($comboBox[$checkBox.Name].SelectedItem).ToString() -NetConfig ($checkBox.Value.Text).ToString()
        }

    }
    # Set Global DNS Configurations
    #Set-DnsClientGlobalSetting -SuffixSearchList $NetConfigOBJ.DnsClientGlobalSetting.SuffixSearchList -UseDevolution $NetConfigOBJ.DnsClientGlobalSetting.UseDevolution -DevolutionLevel $NetConfigOBJ.DnsClientGlobalSetting.DevolutionLevel
}else{
exit
}





# END OF GUI

#Read XML
#$XMLfile = '.\netconfig.xml'
#[XML]$NICInfos = Get-Content $XMLfile


#$NIC_NAME = $selected_nic
#$NIC_NEWNAME = $NICInfos.host.nic.name
#$NIC_IPS = $NICInfos.host.nic.ips.ip.addr
#$NIC_MASKS = $NICInfos.host.nic.ips.ip.mask
#$NIC_GW = $NICInfos.host.nic.gw
#$NIC_DNS = $NICInfos.host.nic.dns_servers.dns_server
#$NIC_DNS_SUFFIX = $NICInfos.host.nic.dns_suffix


#Get NIC Object and config
#$NIC_OBJ = get-wmiobject win32_networkadapter | where {$_.netconnectionid -eq $selected_nic}
#$NIC_CFG = gwmi win32_networkadapterconfiguration | where {$_.Index -eq $NIC_OBJ.DeviceID}

#Set new NIC name
#$NIC_OBJ.NetConnectionID=$NIC_NEWNAME
#$NIC_OBJ.Put()

#Set NIC IP Configs
#$resultIP = $NIC_CFG.EnableStatic(($NIC_IPS),($NIC_MASKS))
#        if ($resultIP.ReturnValue -ne 0) {
#            # handle non-successful response code here.
#            [System.Windows.Forms.MessageBox]::Show("ERROR Setting IP! ReturnValue = " + $resultIP.ReturnValue,"ERROR",0,16)
#            exit
#        }

#$resultGW = $NIC_CFG.SetGateways($NIC_GW)
#        if ($resultGW.ReturnValue -ne 0) {
#            # handle non-successful response code here.
#            [System.Windows.Forms.MessageBox]::Show("ERROR Setting GW! ReturnValue = " + $resultGW.ReturnValue,"ERROR",0,16)
#            exit
#        }

#$resultDNS = $NIC_CFG.SetDNSServerSearchOrder($NIC_DNS)
#        if ($resultDNS.ReturnValue -ne 0) {
#            # handle non-successful response code here.
#            [System.Windows.Forms.MessageBox]::Show("ERROR Setting DNS! ReturnValue = " + $resultDNS.ReturnValue,"ERROR",0,16)
#            exit
#        }

#$resultDNS_SUFFIX = $NIC_CFG.SetDNSDomain($NIC_DNS_SUFFIX)
#        if ($resultDNS_SUFFIX.ReturnValue -ne 0) {
3            # handle non-successful response code here.
#            [System.Windows.Forms.MessageBox]::Show("ERROR Setting DNS Suffix! ReturnValue = " + $resultDNS_SUFFIX.ReturnValue,"ERROR",0,16)
#            exit
#        }


#[System.Windows.Forms.MessageBox]::Show("NIC renamed to $NIC_NEWNAME and IP settings applied","ERROR",0,64)

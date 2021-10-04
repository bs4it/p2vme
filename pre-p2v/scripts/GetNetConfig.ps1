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

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# get current folder
$folder = split-path -parent $MyInvocation.MyCommand.Definition
# Read config file
$cfgFile = $folder+"\GetNetConfig.conf"
# test if config file is there
If((test-path "$cfgFile"))
{
    # Load config file to variable
    $cfgFile = Get-Content $cfgFile
}
else
{
    [System.Windows.Forms.MessageBox]::Show("The config file $cfgFile was not found. Quitting.","GetNetCfonfig",0,"Error")
    break
}

# Decode lines
$IniHash = @{}
ForEach($line in $cfgFile)
{
$SplitArray = $line.Split("=")
$IniHash += @{$SplitArray[0].Trim() = $SplitArray[1].Trim()}
}

$destinationfolder = ($IniHash.DestinationFolder).Replace("`"","")


# Create a folder on c: to store the data

If(!(test-path $destinationfolder))
{
      $newFolder = New-Item -ItemType Directory -Force -Path $destinationfolder
      Write-Host -ForegroundColor Yellow "Creating folder $destinationfolder."
}


$form = New-Object System.Windows.Forms.Form
$form.Text = 'NICCfg - Get Config'
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
$label.Size = New-Object System.Drawing.Size(280,15)
$label.Font = New-Object System.Drawing.Font("Arial",9,[System.Drawing.FontStyle]::Bold)
$label.Text = 'Please select the NICs to get config from:'
$form.Controls.Add($label)

$label2 = New-Object System.Windows.Forms.Label
$label2.Location = New-Object System.Drawing.Point(10,20)
$label2.Size = New-Object System.Drawing.Size(280,20)
$label2.Text = 'Use SHIFT or CTRL for multiple selection.'
$form.Controls.Add($label2)

$labelCred = New-Object System.Windows.Forms.Label
$labelCred.AutoSize = $True
$labelCred.Location = New-Object System.Drawing.Point(155,280) 
$labelCred.Size = New-Object System.Drawing.Size(100,10)
$labelCred.Font = New-Object System.Drawing.Font("Arial",7,[System.Drawing.FontStyle]::Bold)
$labelCred.Text = "2021, Fernando Della Torre"
$form.Controls.Add($labelCred) 

#$listBox = New-Object System.Windows.Forms.CheckedListBox
$listBox = New-Object System.Windows.Forms.ListBox
$listBox.Location = New-Object System.Drawing.Point(10,40)
$listBox.Size = New-Object System.Drawing.Size(273,280)
$listBox.Height = 200
$listBox.SelectionMode = 'MultiExtended'


$nic_list = Get-NetAdapter | Where-Object { $_.AdminStatus -eq "Up" } | Select-Object Name | Sort-Object -Property Name
$nic_list | ForEach-Object {
    $listBox.Items.Add( "$($_.Name)")
}



$form.Controls.Add($listBox)
$form.Topmost = $true

$result = $form.ShowDialog()

if ($result -eq [System.Windows.Forms.DialogResult]::OK)
{
    $selected_nic = $listBox.SelectedItems

}else{
exit
}

# END OF GUI

## Function the check if a IP belongs to a network
function Test-IPInSubnet {
    [CmdletBinding()]
    param(
        [Parameter(
            Position = 0, 
            Mandatory, 
            ValueFromPipelineByPropertyName
        )]
        [ValidateNotNull()]
        [IPAddress]
        $Subnet = "172.20.76.0",

        [Parameter(
            Position = 1, 
            Mandatory, 
            ValueFromPipelineByPropertyName
        )]
        [Alias('Mask')]
        [ValidateNotNull()]
        [IPAddress]
        $SubnetMask = "255.255.254.0",

        [Parameter(
            Position = 0, 
            Mandatory, 
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [Alias('Address')]
        [ValidateNotNull()]
        [IPAddress]
        $IPAddress = "172.20.76.5"
    )
    process {
        $Subnet.Address -eq ($IPAddress.Address -band $SubnetMask.Address)
    }
}


$NetConfigOBJ = @()
$counter = 0
#$selected_nic
$nics = $listBox.SelectedItems
$nics | ForEach-Object {
    $nic = $_
    $nic = Get-NetAdapter | Where-Object { $_.Name -eq $nic }
    $nic_name = $nic.Name
    $nic_mac = $nic.MacAddress
    $nic_ip_cfg = $nic | Get-NetIPConfiguration
    $nic_gw = $nic_ip_cfg.IPv4DefaultGateway.NextHop
    $nic_dns = ($nic_ip_cfg.DNSServer | ? { $_.AddressFamily -eq 2 }).ServerAddresses
    $nic_dns_client_cfg = $nic | Get-DnsClient
    $nic_ip = $nic | Get-NetIPAddress | Where { $_.AddressFamily -eq "IPv4" } | Select-Object IPAddress, PrefixLength | Sort-Object -Property IPAddress
    $nic_ip_sorted = @()
    # if gateway is not empty
    if ( $nic_gw ) {
       # Write-host "Há gateway"
        # check if the network belongs to the gateway and add the ones that belong into the object, so they will be the first on the list
        $nic_ip | ForEach-Object {
            $SubnetMask = [ipaddress]([math]::pow(2, 32) -1 -bxor [math]::pow(2, (32 - $_.PrefixLength))-1)
            $IPAddress = [ipaddress]$_.IPAddress
            $GWAddress = [ipaddress]$nic_gw
            $Subnet = [ipaddress]( $IPAddress.Address -band $SubnetMask.address)
            if ( Test-IPInSubnet -IPAddress $GWAddress.IPAddressToString -Subnet $Subnet.IPAddressToString -SubnetMask $SubnetMask.IPAddressToString ) {
                $nic_ip_sorted += [pscustomobject]@{IPAddress=$_.IPAddress;PrefixLength=$_.PrefixLength}
                
            } 
        }
        # check if the network belongs to the gateway and add the ones that doesnt belong into the object, so they will be the last on the list
        $nic_ip | ForEach-Object {
            $SubnetMask = [ipaddress]([math]::pow(2, 32) -1 -bxor [math]::pow(2, (32 - $_.PrefixLength))-1)
            $IPAddress = [ipaddress]$_.IPAddress
            $GWAddress = [ipaddress]$nic_gw
            $Subnet = [ipaddress]( $IPAddress.Address -band $SubnetMask.address)
            if ( -not (Test-IPInSubnet -IPAddress $GWAddress.IPAddressToString -Subnet $Subnet.IPAddressToString -SubnetMask $SubnetMask.IPAddressToString) ) {
                $nic_ip_sorted += [pscustomobject]@{IPAddress=$_.IPAddress;PrefixLength=$_.PrefixLength}
                
            }
        }
        $nic_ip = $nic_ip_sorted

    } else {
    #    Write-Host "Nao há gateway"
        $nic_ip = $nic_ip | Sort-Object -Property IPAddress
    }


    $NetConfigOBJ += [pscustomobject]@{Index=$counter;Hostname=$env:computername;Name=$nic_name;MacAddress=$nic_mac;Addresses=$nic_ip;DefaultGateway=$nic_gw;DNSServers=$nic_dns;DNSClientCFG=$nic_dns_client_cfg}
    $counter +=1
}

$NetConfigOBJ | ConvertTo-Json -Depth 4 | Out-File "$destinationfolder\netconfig.json"

# test if file is created
If((test-path "$destinationfolder\netconfig.json"))
{
    Copy-Item "$folder\SetNetConfig.ps1" -Destination $destinationfolder
    [System.Windows.Forms.MessageBox]::Show("The selected NIC's configurations were saved to $destinationfolder\netconfig.json.","GetNetCfonfig",0,64)
}
else
{
    Write-Host -ForegroundColor Red "File $destinationfolder\volumes.json was not found. Please check for permission issues."
}

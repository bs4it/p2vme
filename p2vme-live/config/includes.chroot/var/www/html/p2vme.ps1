$ErrorActionPreference = "Stop"
Set-PowerCLIConfiguration -Scope User -Confirm:$false -ParticipateInCEIP $false
#01 - conectar ao server e puxar json
#02 - carregar itens em variaveis (discos em array)
#03 - exibir configuração encontrada e pedir confirmação
#04 - Checar se existe conexão ativa, caso haja pergunta se quer aproveiar ou fechar a conexão e iniciar uma nova
#05 - Solicitar IP e credenciais do vCenter
#06 - Conectar no vCenter ou host e validar as credenciais, se houver erro, abortar
#07 - Conectar e listar Hosts, solicitar seleção pelo numero
#08 - Conectar e listar DataStores, solicitar seleção pelo numero
#09 - Solicitar confirmação exibindo host e datastore
#10 - Executar

$errmsg = ""
do {
    # Clear Screen
    Clear-Host
    # Write welcome and first instructions
    Write-Host -ForegroundColor Green "Welcome to P2VME VM Creation Tool"
    Write-Output ""
    Write-Host -ForegroundColor Red "$errmsg"
    # Ask source IP
    $IP = Read-Host -Prompt "Source Server IP"
    $IP -as [ipaddress] -as [Bool]
    if (-Not ($IP -as [ipaddress] -as [Bool] -eq $true)){$errmsg = "Please enter a valid IPV4 address!"}

} while (($SelectedHost.Length -eq 0) -or -Not ($IP -as [ipaddress] -as [Bool] -eq $true))

Write-Output "Connecting to $IP"
# Read json file
$jsonData = Invoke-RestMethod -TimeoutSec 2 -Uri "http://$IP/p2vme.json"
# Fill variables
$convertion_id = $jsonData.convertion_id
$server_name = $jsonData.server_name
$installed_os = $jsonData.installed_os
$installed_os_text = switch ($installed_os) {
    "debian8_64Guest"  {"Debian GNU/Linux 8 (64-bit)"; break}
    "debian8Guest"   {"Debian GNU/Linux 8 (32-bit)"; break}
    "debian9_64Guest" {"Debian GNU/Linux 9 (64-bit"; break}
    "debian9Guest"  {"Debian GNU/Linux 9 (32-bit)"; break}
    "debian10_64Guest" {"Debian GNU/Linux 10 (64-bit)"; break}
    "debian10Guest"  {"Debian GNU/Linux 10 (32-bit)"; break}
    "rhel5_64Guest"  {"Red Hat Enterprise Linux 5 (64-bit)"; break}
    "rhel5Guest"  {"Red Hat Enterprise Linux 5 (32-bit)"; break}
    "rhel6_64Guest"  {"Red Hat Enterprise Linux 6 (64-bit)"; break}
    "rhel6Guest"  {"Red Hat Enterprise Linux 6 (32-bit)"; break}
    "rhel7_64Guest"  {"Red Hat Enterprise Linux 7 (64-bit)"; break}
    "rhel7Guest"  {"Red Hat Enterprise Linux 7 (32-bit)"; break}
    "ubuntu64Guest"  {"Ubuntu Linux (64-bit)"; break}
    "ubuntuGuest"  {"Ubuntu Linux (32-bit)"; break}
    "winNetStandard64Guest"  {"Windows Server 2003 (64-bit)"; break}
    "winNetStandardGuest"  {"Windows Server 2003 (64-bit)"; break}
    "windows7Server64Guest"  {"Windows Server 2008 R2 (64-bit)"; break}
    "windows8Server64Guest"  {"Windows Server 2012 (64-bit)"; break}
    "windows9Server64Guest"  {"Windows Server 2016 or later (64-bit)"; break}
    default {"Something is Wrong here"; break}
 }
$cpu_sockets = $jsonData.cpu_sockets
$cpu_cores = $jsonData.cpu_cores
$memory = $jsonData.memory
$nics = $jsonData.nics
$disks = $jsonData.disks
Start-Sleep -Milliseconds 500
# Clear screen again
Clear-Host
# Show source server details
Write-Host -ForegroundColor Green "Source Server Detais"
Write-Output ""
Write-Host -NoNewline "Convertion ID: "
Write-Host -ForegroundColor Yellow $convertion_id
Write-Host -NoNewline "Server Name: "
Write-Host -ForegroundColor Yellow $server_name
Write-Host -NoNewline "Guest Operating System: "
Write-Host -ForegroundColor Yellow $installed_os_text
Write-Host -NoNewline "CPU Sockets: "
Write-Host -ForegroundColor Yellow $cpu_sockets
Write-Host -NoNewline "CPU Cores: "
Write-Host -ForegroundColor Yellow $cpu_cores
Write-Host -NoNewline "Memory: "
Write-Host -ForegroundColor Yellow $memory
Write-Host -NoNewline "# of NICs: "
Write-Host -ForegroundColor Yellow $nics
Write-Host -ForegroundColor Green "Disks to be presented"
Write-Host "Device `t ID"
# Loop through the disks
    ForEach ($disk in $disks)
    {
        Write-Host -NoNewline -ForegroundColor Yellow $disk.device
        #Write-Host -NoNewline -ForegroundColor White
        Write-Host -ForegroundColor Yellow `t $disk.disk_id
    }
Write-Host ""
$OK = Read-Host -Prompt "Is it OK? (Y/N)"
# If answer is not Y the script will quit
if ($OK -ne "Y") {
    Write-Host "Quitting script. Bye."
    break
}

if ($vcenter_conn.IsConnected -eq $true) {
    Clear-Host
    Write-Host -ForegroundColor Green "Connection is already active!"
    Write-Host ""
    Write-Host -NoNewline -ForegroundColor Gray "You are alreary connected to server "
    Write-Host -NoNewline -ForegroundColor Yellow $vcenter_conn.ServiceUri.Host
    Write-Host -NoNewline -ForegroundColor Gray " under the user "
    Write-Host -ForegroundColor Yellow $vcenter_conn.User
    Write-Host ""
    Write-Host -NoNewline -ForegroundColor Gray "Do you want to "
    Write-Host -NoNewline -ForegroundColor Cyan "Keep"
    Write-Host -NoNewline -ForegroundColor Gray " the same connection or "
    Write-Host -NoNewline -ForegroundColor Cyan "Start"
    Write-Host -ForegroundColor Gray " a new one?"
    $vcenter_delconn = Read-Host -Prompt "Select S to start a new connection or any other key to keep the current connecton"
    if ($vcenter_delconn -eq "S") {
        $ErrorActionPreference = "SilentlyContinue"
        $vcenter_conn = Disconnect-VIServer -Server * -Force –Confirm:$false -ErrorAction SilentlyContinue
        $ErrorActionPreference = "Stop"
    }
}

if ($vcenter_conn.IsConnected -ne $true) {
    $errmsg = ""
    $vcenter_server = ""
    do {
        Clear-Host
        Write-Host -ForegroundColor Green "Destination Server Info"
        Write-Host -ForegroundColor Red "$errmsg"
        $vcenter_server = Read-Host -Prompt "Enter the vCenter Server address (IP or FQDN)"
        if ($vcenter_server.Length -eq 0){$errmsg = "This value cannot be null!"}

    } while ($vcenter_server.Length -eq 0)
    $vcenter_server_cred = Get-Credential
    Clear-Host
    Write-Host -NoNewline -ForegroundColor Green "Logging in to the vCenter server "
    Write-Host -NoNewline -ForegroundColor Yellow $vcenter_server
    Write-Host " ..."
    # Create a new connection do vCenter Server
    $vcenter_conn = Connect-VIServer -Server $vcenter_server -Credential $vcenter_server_cred
    if ($vcenter_conn.IsConnected -ne $True){
        Write-Host ""
        Write-Host -NoNewline -ForegroundColor Gray "Connection"
        Write-Host -ForegroundColor Red " Fail."
        break
    }Else{
        Write-Host ""
        Write-Host -NoNewline -ForegroundColor Gray "Connection"
        Write-Host -ForegroundColor Green " OK"
    }
}
# GET SELECTED HOST
$vSphereHosts = Get-VMHost
$errmsg = ""
do {
    Clear-Host
    Write-Host -ForegroundColor Green "Select an available Host"
    Write-Host -ForegroundColor Red "$errmsg"
    $ObjIndex = 0
    $vSphereHosts | Format-Table -Property @{name="ID";expression={$global:ObjIndex;$global:ObjIndex+=1}},Name,Model,PowerState
    $SelectedHost = Read-Host -Prompt "Type the ID of desired server"
    if (-Not ($SelectedHost -in 1..$vSphereHosts.Count)){$errmsg = "This value must be within the IDs!"}

} while (($SelectedHost.Length -eq 0) -or -Not ($SelectedHost -in 1..$vSphereHosts.Count))

$SelectedHost = $vSphereHosts.Item($SelectedHost-1)
Write-Host ""
Write-Host -NoNewline -ForegroundColor Gray "Selected host: "
Write-Host -ForegroundColor Yellow $SelectedHost.Name
Start-Sleep -Milliseconds 500


# GET SELECTED DATASTORE
$HostDatastores = $SelectedHost | Get-Datastore
$errmsg = ""
do {
    Clear-Host
    Write-Host -NoNewline -ForegroundColor Green "Available Datastores on host "
    Write-Host -ForegroundColor Yellow $SelectedHost.Name
    Write-Host -ForegroundColor Red "$errmsg"
    $ObjIndex = 0
    $HostDatastores | Format-Table -Property @{name="ID";expression={$global:ObjIndex;$global:ObjIndex+=1}},Name,FreeSpaceGB,CapacityGB
    $SelectedDataStore = Read-Host -Prompt "Type the ID of desired DataStore"
    if (-Not ($SelectedDataStore -in 1..$HostDatastores.Count)){$errmsg = "This value must be within the IDs!"}

} while (($SelectedDataStore.Length -eq 0) -or -Not ($SelectedDataStore -in 1..$HostDatastores.Count))

$SelectedDataStore = $HostDatastores.Item($SelectedDataStore-1)
Write-Host ""
Write-Host -NoNewline -ForegroundColor Gray "Selected DataStore: "
Write-Host -ForegroundColor Yellow $SelectedDataStore.Name
Start-Sleep -Milliseconds 500

# Create iSCSI Connection
$iSCSItargetIP = $IP
$hba = $SelectedHost | Get-VMHostHba -Type IScsi | Where {$_.Model -eq "iSCSI Software Adapter"}
# Check to see if the SendTarget exist, if not add it
if (Get-IScsiHbaTarget -IScsiHba $hba -Type Send | Where {$_.Address -cmatch $iSCSItargetIP}) {
    Write-Host "The target $iSCSItargetIP does exist on $SelectedHost" 
 }
 else {
    Write-Host "The target $iSCSItargetIP doesn't exist on $SelectedHost" 
    Write-Host "Creating $iSCSItargetIP on $host ..." 
    #New-IScsiHbaTarget -IScsiHba $hba -Address $iSCSItargetIP -ChapType Required -ChapName "user" -ChapPassword $chappassword -MutualChapEnabled $true -MutualChapName "user" -MutualChapPassword $mutualchap
    New-IScsiHbaTarget -IScsiHba $hba -Address $iSCSItargetIP
 }
 


# ForEach ($vSphereHost in $vSphereHosts){
#     $ObjIndex = [Array]::IndexOf($vSphereHosts.Name,$vSphereHost.Name)
#     Write-Host -NoNewline "$ObjIndex `t"
#     Write-Host -NoNewline $vSphereHost.Name "`t"
#     Write-Host  $vSphereHost.PowerState

# }




#Get-Datastore | select Id, Name, CapacityGB, FreeSpaceGB, Type | FT


# Write-Host $vcenter_server
# Write-Host $vcenter_server_cred




#Set-PowerCLIConfiguration -InvalidCertificateAction Ignore

#Disconnect-VIServer -Force –Confirm:$false –Server $vcenter_server
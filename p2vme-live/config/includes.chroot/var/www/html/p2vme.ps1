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

} while (($IP.Length -eq 0) -or -Not ($IP -as [ipaddress] -as [Bool] -eq $true))

Write-Output "Connecting to $IP"
# Read json file
$jsonData = Invoke-RestMethod -TimeoutSec 2 -Uri "http://$IP/p2vme.json"
# Fill variables
$conversion_id = $jsonData.conversion_id
$server_name = $jsonData.server_name
$installed_os = $jsonData.installed_os
$installed_os_text = switch ($installed_os) {
    "rhel9_64Guest"  {"Red Hat Enterprise Linux 9 (64-bit)"; break}
    "rhel8_64Guest"  {"Red Hat Enterprise Linux 8 (64-bit)"; break}
    "rhel7_64Guest"  {"Red Hat Enterprise Linux 7 (64-bit)"; break}
    "rhel7Guest"  {"Red Hat Enterprise Linux 7 (32-bit)"; break}
    "rhel6_64Guest"  {"Red Hat Enterprise Linux 6 (64-bit)"; break}
    "rhel6Guest"  {"Red Hat Enterprise Linux 6 (32-bit)"; break}
    "rhel5_64Guest"  {"Red Hat Enterprise Linux 5 (64-bit)"; break}
    "rhel5Guest"  {"Red Hat Enterprise Linux 5 (32-bit)"; break}
    "oracleLinux9_64Guest"  {"Oracle Linux 9 (64-bit)"; break}
    "oracleLinux8_64Guest"  {"Oracle Linux 8 (64-bit)"; break}
    "oracleLinux7_64Guest"  {"Oracle Linux 7 (64-bit)"; break}
    "oracleLinux7Guest"  {"Oracle Linux 7 (32-bit)"; break}
    "oracleLinux6_64Guest"  {"Oracle Linux 6 (64-bit)"; break}
    "oracleLinux6Guest"  {"Oracle Linux 6 (32-bit)"; break}
    "oracleLinux64Guest"  {"Oracle Linux 4/5 (64-bit)"; break}
    "oracleLinuxGuest"  {"Oracle Linux 4/5 (32-bit)"; break}
    "centos9_64Guest"  {"CentOS 9 (64-bit)"; break}
    "centos8_64Guest"  {"CentOS 8 (64-bit)"; break}
    "centos7_64Guest"  {"CentOS 7 (64-bit)"; break}
    "centos7Guest"  {"CentOS 7 (32-bit)"; break}
    "centos6_64Guest"  {"CentOS 6 (64-bit)"; break}
    "centos6Guest"  {"CentOS 6 (32-bit)"; break}
    "centos64Guest"  {"CentOS 4/5 (64-bit)"; break}
    "centosGuest"  {"CentOS 4/5 (32-bit)"; break}
    "debian11_64Guest"  {"Debian GNU/Linux 11 (64-bit)"; break}
    "debian11Guest"  {"Debian GNU/Linux 11 (32-bit)"; break}
    "debian10_64Guest"  {"Debian GNU/Linux 10 (64-bit)"; break}
    "debian10Guest"  {"Debian GNU/Linux 10 (32-bit)"; break}
    "debian9_64Guest"  {"Debian GNU/Linux 9 (64-bit)"; break}
    "debian9Guest"  {"Debian GNU/Linux 9 (32-bit)"; break}
    "debian8_64Guest"  {"Debian GNU/Linux 8 (64-bit)"; break}
    "debian8Guest"  {"Debian GNU/Linux 8 (32-bit)"; break}
    "debian7_64Guest"  {"Debian GNU/Linux 7 (64-bit)"; break}
    "debian7Guest"  {"Debian GNU/Linux 7 (32-bit)"; break}
    "debian6_64Guest"  {"Debian GNU/Linux 6 (64-bit)"; break}
    "debian6Guest"  {"Debian GNU/Linux 6 (32-bit)"; break}
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
$cores_per_socket = $cpu_cores / $cpu_sockets
$memory = $jsonData.memory
$nics = $jsonData.nics
$fw_mode = $jsonData.fw_mode
$disks = $jsonData.disks
Start-Sleep -Milliseconds 500
# Clear screen again
Clear-Host
# Show source server details
Write-Host -ForegroundColor Green "Source Server Detais"
Write-Output ""
Write-Host -NoNewline "Conversion ID: "
Write-Host -ForegroundColor Yellow $conversion_id
Write-Host -NoNewline "Source IP: "
Write-Host -ForegroundColor Yellow $IP
Write-Host -NoNewline "Server Name: "
Write-Host -ForegroundColor Yellow $server_name
Write-Host -NoNewline "Guest Operating System: "
Write-Host -ForegroundColor Yellow $installed_os_text
Write-Host -NoNewline "Firmware Mode: "
Write-Host -ForegroundColor Yellow $fw_mode.ToUpper()
Write-Host -NoNewline "CPU Sockets: "
Write-Host -ForegroundColor Yellow $cpu_sockets
Write-Host -NoNewline "CPU Cores per Socket: "
Write-Host -ForegroundColor Yellow $cores_per_socket
Write-Host -NoNewline "Total CPU Cores: "
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
    Write-Host -NoNewline -ForegroundColor Gray "You are already connected to server "
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
        $vcenter_conn = Disconnect-VIServer -Server * -Force -Confirm:$false -ErrorAction SilentlyContinue
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
    $global:vcenter_conn = Connect-VIServer -Server $vcenter_server -Credential $vcenter_server_cred
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
    $script:ObjIndex = 0
    $vSphereHosts | Format-Table -Property @{name="ID";expression={$script:ObjIndex;$script:ObjIndex+=1}},Name,Model,PowerState
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
    $script:ObjIndex = 0
    $HostDatastores | Format-Table -Property @{name="ID";expression={$script:ObjIndex;$script:ObjIndex+=1}},Name,FreeSpaceGB,CapacityGB
    $SelectedDataStore = Read-Host -Prompt "Type the ID of desired DataStore"
    if (-Not ($SelectedDataStore -in 1..$HostDatastores.Count)){$errmsg = "This value must be within the IDs!"}

} while (($SelectedDataStore.Length -eq 0) -or -Not ($SelectedDataStore -in 1..$HostDatastores.Count))

$SelectedDataStore = $HostDatastores.Item($SelectedDataStore-1)
Write-Host ""
Write-Host -NoNewline -ForegroundColor Gray "Selected DataStore: "
Write-Host -ForegroundColor Yellow $SelectedDataStore.Name
Start-Sleep -Milliseconds 500


# Get Selected Network
$HostNetworks = $SelectedHost | Get-VirtualPortGroup | Sort
$errmsg = ""
do {
    Clear-Host
    Write-Host -NoNewline -ForegroundColor Green "Available Networks on host "
    Write-Host -ForegroundColor Yellow $SelectedHost.Name
    Write-Host -ForegroundColor Red "$errmsg"
    $script:ObjIndex = 0
    $HostNetworks | Format-Table -Property @{name="ID";expression={$script:ObjIndex;$script:ObjIndex+=1}},Name,VLanId
    $SelectedNetwork = Read-Host -Prompt "Type the ID of desired Network"
    if (-Not ($SelectedNetwork -in 1..$HostNetworks.Count)){$errmsg = "This value must be within the IDs!"}

} while (($SelectedNetwork.Length -eq 0) -or -Not ($SelectedNetwork -in 1..$HostNetworks.Count))

$SelectedNetwork = $HostNetworks.Item($SelectedNetwork-1)
Write-Host ""
Write-Host -NoNewline -ForegroundColor Gray "Selected Network: "
Write-Host -ForegroundColor Yellow $SelectedNetwork.Name
Start-Sleep -Seconds 1

# Use Memory Hot Plug ?
Clear-Host
Write-Host -ForegroundColor Green "Memory Hot Plug Selection"
Write-Host ""
$MemHotPlug = ""
$MemHotPlug = Read-Host -Prompt "Do you want to enable Memory Hot Plug for this VM? (Y/N)"
if ($MemHotPlug -eq "Y"){$MemHotPlugBol = $true}else{$MemHotPlugBol = $false}
# iSCSI Section
Clear-Host
Write-Host -ForegroundColor Green "Checking for iSCSI connection "
Write-Host ""
# Create iSCSI Connection
$iSCSItargetIP = $IP
$hba = $SelectedHost | Get-VMHostHba -Type IScsi | Where {$_.Model -eq "iSCSI Software Adapter"}
# Check to see if the SendTarget exist, if not add it
if (Get-IScsiHbaTarget -IScsiHba $hba -Type Send | Select-Object Address | Where {$_.Address -eq $iSCSItargetIP}) {
    Write-Host -NoNewline -ForegroundColor Gray "The target "
    Write-Host -NoNewline -ForegroundColor Yellow $iSCSItargetIP
    Write-Host -NoNewline -ForegroundColor Gray " does exist on "
    Write-Host -ForegroundColor Yellow $SelectedHost
 }
 else {
    Write-Host -NoNewline -ForegroundColor Gray "The target "
    Write-Host -NoNewline -ForegroundColor Yellow $iSCSItargetIP
    Write-Host -NoNewline -ForegroundColor Gray " does not exist on "
    Write-Host -ForegroundColor Yellow $SelectedHost
    Write-Host -NoNewline -ForegroundColor Gray "Creating "
    Write-Host -NoNewline -ForegroundColor Yellow $iSCSItargetIP
    Write-Host -NoNewline -ForegroundColor Gray " on " 
    Write-Host -NoNewline -ForegroundColor Yellow $SelectedHost
    Write-Host -ForegroundColor Gray " ..." 
    #New-IScsiHbaTarget -IScsiHba $hba -Address $iSCSItargetIP -ChapType Required -ChapName "user" -ChapPassword $chappassword -MutualChapEnabled $true -MutualChapName "user" -MutualChapPassword $mutualchap
    $newTarget = New-IScsiHbaTarget -IScsiHba $hba -Address $iSCSItargetIP
 }
Start-Sleep -Milliseconds 500
# Check if disks were mapped by the iSCSI initiator
Write-Host ""
Write-Host -ForegroundColor Yellow "Rescanning iSCSI bus..."
Write-Host ""
$rescan = Get-VMHostStorage -VMHost $SelectedHost -RescanAllHba
$to_be_mapped_disks = $disks.Count
$mapped_disks = ($rescan.ScsiLun | Where-Object CanonicalName -Match $conversion_id | Where-Object LunType -EQ disk).Count
if ($to_be_mapped_disks -ne $mapped_disks) {
    Write-Host -ForegroundColor Red "Unable to find all disks that should me mapped. Desired: $to_be_mapped_disks, Found: $mapped_disks"
    Write-Host -ForegroundColor Red "Quitting."
    break
} else {
    Write-Host -ForegroundColor Yellow "Disks mapped accordingly."
}
Start-Sleep -Seconds 1

Clear-Host
Write-Host -ForegroundColor Green "Virtual Machine Creation"
Write-Host ""
Write-Host -NoNewline -ForegroundColor Gray "Creating VM "
Write-Host -ForegroundColor Yellow $server_name
# Create VM
$CreateVM = New-VM -CD -DiskMB 1 -Name $server_name -VMHost $SelectedHost -Datastore $SelectedDataStore -NumCpu $cpu_cores -CoresPerSocket $cores_per_socket -MemoryGB $memory -GuestId $installed_os
# Get default controller type for later use
$ControllerType = $CreateVM | Get-ScsiController
# Remove VMDK Disk from VM
$SetVM = $CreateVM | Get-HardDisk | Remove-HardDisk -Confirm:$false -DeletePermanently:$true
Write-Host -NoNewline -ForegroundColor Gray "Setting network interface to "
Write-Host -ForegroundColor Yellow $SelectedNetwork
# Set VMXNET3
$SetVM = $CreateVM | Get-NetworkAdapter | Remove-NetworkAdapter -Confirm:$false
$SetVM = $CreateVM | New-NetworkAdapter -Type Vmxnet3 -StartConnected -NetworkName $SelectedNetwork
Write-Host -NoNewline -ForegroundColor Gray "Setting firmware mode to "
Write-Host -ForegroundColor Yellow $fw_mode.ToUpper()
Write-Host -NoNewline -ForegroundColor Gray "Setting Memory Hot Plug to "
if ($MemHotPlugBol -eq $false){
    Write-Host -ForegroundColor Yellow "Disabled"
}else{
    Write-Host -ForegroundColor Yellow "Enabled"
}
# Set Firmware mode
if ($fw_mode -eq "uefi") {
    $spec = New-Object VMware.Vim.VirtualMachineConfigSpec
    $spec.Firmware = [VMware.Vim.GuestOsDescriptorFirmwareType]::efi
    $boot = New-Object VMware.Vim.VirtualMachineBootOptions
    $boot.EfiSecureBootEnabled = $true
    $spec.BootOptions = $boot
    $spec.MemoryHotAddEnabled = $MemHotPlugBol
    $CreateVM.ExtensionData.ReconfigVM($spec)    
} else {
    $spec = New-Object VMware.Vim.VirtualMachineConfigSpec
    $spec.Firmware = [VMware.Vim.GuestOsDescriptorFirmwareType]::bios
    $boot = New-Object VMware.Vim.VirtualMachineBootOptions
    $boot.EfiSecureBootEnabled = $false
    $spec.BootOptions = $boot
    $spec.MemoryHotAddEnabled = $MemHotPlugBol
    $CreateVM.ExtensionData.ReconfigVM($spec)
}
Write-Host -ForegroundColor Gray "Adding vRDM disks to the VM:"
# Add vRDM disks
#$rdm = Get-SCSILun -VmHost $SelectedHost -LunType disk | Where-Object CanonicalName -Match $conversion_id | Select-Object ConsoleDeviceName | Sort-Object
# Get list od devices with our conversion ID
#$rdm = Get-SCSILun -VmHost $SelectedHost -LunType disk | Where-Object {$_.CanonicalName -Match $conversion_id} | Select-Object ConsoleDeviceName | Sort-Object
$rdm = Get-SCSILun -VmHost $SelectedHost -LunType disk | Where-Object {$_.CanonicalName -Match $conversion_id}
$rdm | ForEach-Object {
    Write-Host -NoNewline -ForegroundColor Gray " - Adding "
    Write-Host -NoNewline -ForegroundColor Yellow $_.CapacityGB
    Write-Host -NoNewline -ForegroundColor Gray " GB disk: "
    $device_short_name = $_.ConsoleDeviceName
    $device_short_name = $device_short_name.Split("/") | Select-Object -Last 1
    Write-Host -ForegroundColor Yellow $device_short_name
    $SetVM = $CreateVM | New-HardDisk -DiskType RawVirtual -DeviceName $_.ConsoleDeviceName
}
Write-Host -NoNewline -ForegroundColor Gray "Setting SCSI controller type to "
Write-Host -ForegroundColor Yellow "ParaVirtual"
$SetVM = $CreateVM | Get-ScsiController | Set-ScsiController -Type ParaVirtual
#Write-Host -ForegroundColor Yellow $ControllerType.Type
#$SetVM = $CreateVM | Get-ScsiController | Set-ScsiController -Type $ControllerType.Type
Write-Host ""
Write-Host -ForegroundColor Gray "Creating Protective Snapshot"
$VMSnapShot = $CreateVM | New-Snapshot -Name "BS4IT P2VME Protective Snapshot" -Description "Please do not remove this snapshot during the conversion proccess." -Memory:$false -Confirm:$false
if ( $installed_os -like 'win*' ) {
    Write-Host -ForegroundColor Gray "Windows VM - Inserting Driver Injection Tool ISO"
    $CreateVM | Get-CDDrive | Set-CDDrive -StartConnected $true -IsoPath "[$SelectedDataStore] p2vme-driver-injection.iso" -Confirm:$false
}
Write-Host ""
Write-Host -ForegroundColor Gray "Done."
Write-Host -ForegroundColor Yellow "Bye!"
break


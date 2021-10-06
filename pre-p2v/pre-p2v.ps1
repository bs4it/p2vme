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

# Read config file
$cfgFile = $folder+"\pre-p2v.conf"
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

Write-Host -ForegroundColor Yellow "Getting Network Interfaces Settings..."
Invoke-Expression "$folder\scripts\GetNetConfig.ps1"
Write-Host -ForegroundColor Yellow "Getting Volumes Settings..."
Invoke-Expression "$folder\scripts\GetVolumes.ps1"
Copy-Item "$folder\scripts\post-p2v.ps1" -Destination $destinationfolder
Copy-Item "$folder\scripts\DeviceCleanupCmd.exe" -Destination "$destinationfolder\scripts"
Copy-Item "$folder\scripts\DeviceCleanup.exe" -Destination "$destinationfolder\scripts"
Write-Host -ForegroundColor Green "Tasks complete, closing window in 3 seconds"
Start-Sleep -Seconds 1
Write-Host -ForegroundColor Green "Tasks complete, closing window in 2 seconds"
Start-Sleep -Seconds 1
Write-Host -ForegroundColor Green "Tasks complete, closing window in 1 second"
Start-Sleep -Seconds 1
Write-Host -ForegroundColor Green "Tasks complete, closing window in 0 second"
Start-Sleep -Milliseconds 500
stop-process -Id $PID

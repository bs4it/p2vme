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
$cfgFile = $folder+"\GetVolumes.conf"
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


# Get volumes ID, path etc and save to json
Get-Volume | Where-Object { $_.DriveType -eq "Fixed" } | ConvertTo-Json -Compress | Out-File "$destinationfolder\volumes.json"

# test if file is created
If((test-path "$destinationfolder\volumes.json"))
{
    Copy-Item "$folder\SetVolumes.ps1" -Destination $destinationfolder
    Write-Host -ForegroundColor Yellow "File $destinationfolder\volumes.json created."
}
else
{
    Write-Host -ForegroundColor Red "File $destinationfolder\volumes.json was not found. Please check for permission issues."
}
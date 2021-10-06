This set of folders and files must be copied over a Windows PE that can run powershell.


You must install Windows ADK (Assessment and Deployment Kit) and its dependencies then use the following steps:


This example considers you have cloned git to c:\projects\p2vme and is building Windows PE to C:\P2VME-DRV-INJECT


copype amd64 C:\P2VME-DRV-INJECT

Dism /Mount-Image /ImageFile:C:\P2VME-DRV-INJECT\media\sources\boot.wim /index:1 /MountDir:C:\P2VME-DRV-INJECT\mount

Dism /Image:C:\P2VME-DRV-INJECT\mount /Add-Driver /Driver:C:\projects\p2vme\p2vme-driver-injection\p2vme\drivers /Recurse

Dism /Add-Package /Image:"C:\P2VME-DRV-INJECT\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\WinPE-WMI.cab"
Dism /Add-Package /Image:"C:\P2VME-DRV-INJECT\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\en-us\WinPE-WMI_en-us.cab"
Dism /Add-Package /Image:"C:\P2VME-DRV-INJECT\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\WinPE-NetFX.cab"
Dism /Add-Package /Image:"C:\P2VME-DRV-INJECT\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\en-us\WinPE-NetFX_en-us.cab"
Dism /Add-Package /Image:"C:\P2VME-DRV-INJECT\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\WinPE-Scripting.cab"
Dism /Add-Package /Image:"C:\P2VME-DRV-INJECT\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\en-us\WinPE-Scripting_en-us.cab"
Dism /Add-Package /Image:"C:\P2VME-DRV-INJECT\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\WinPE-PowerShell.cab"
Dism /Add-Package /Image:"C:\P2VME-DRV-INJECT\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\en-us\WinPE-PowerShell_en-us.cab"
Dism /Add-Package /Image:"C:\P2VME-DRV-INJECT\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\WinPE-StorageWMI.cab"
Dism /Add-Package /Image:"C:\P2VME-DRV-INJECT\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\en-us\WinPE-StorageWMI_en-us.cab"
Dism /Add-Package /Image:"C:\P2VME-DRV-INJECT\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\WinPE-DismCmdlets.cab"
Dism /Add-Package /Image:"C:\P2VME-DRV-INJECT\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\en-us\WinPE-DismCmdlets_en-us.cab"

Copy the content of the folder "c:\projects\p2vme" inside "C:\P2VME-DRV-INJECT\mount", overwritting when asked for.

Dism /Unmount-Image /MountDir:C:\P2VME-DRV-INJECT\mount /Commit

MakeWinPEMedia /ISO C:\P2VME-DRV-INJECT C:\P2VME-DRV-INJECT\p2vme_drv_inject.iso

There you got the "p2vme_drv_inject.iso" ready to go!




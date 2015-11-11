######################################################################################
## Add-hd Powershell Script                                                         ##
## Written By: Damon Chance                                                         ##
##                                                                                  ##
## Takes input from a deployment spreadsheet and adds additional hard drives.       ##
##  CSV File is shared with VM Creation Script and has the following headers:       ## 
##  Items with an "(*)" are needed for this script                                  ##                             
##  HostName - netbios name of server                                               ##   
##  (*) ServerName - Fully Qualified name of server                                 ## 
##  vHost - Name of the ESX Server that the host lives on                           ## 
##  Customization - Customization Spec to use for th VM                             ## 
##  Template - Template to use for VM                                               ## 
##  Description - Information for Notes field                                       ## 
##  CPU - vcpu's required for VM                                                    ## 
##  RAM - Ram in GB required                                                        ##   
##  (*) ldbds - datastore designation for Live DB drives ("1" or "2" for even/odd)  ##
##  C - Cdrive Size (typically set by the template)                                 ## 
##  (*) D -  Application drive size                                                 ## 
##  (*) E - Size of drive for SQL Data                                              ## 
##  (*) F - Size for SQL Logs or Live DB drive                                      ## 
##  (*) G - Size for SLQ TempDb or Archive drive                                    ## 
##  (*) LunID - Assigned LUN Number after Luns are created for RDMs                 ## 
##  IpAddress - IP Address for primary NIC                                          ##  
##  (*) SQL - Is SQL Installed or not                                               ## 
##  (*) DS - Datastore for C/D vmdk                                                 ##  
##                                                                                  ##
######################################################################################
## Set Variables

## CSV Location
$Script = "confighd.csv"
## Set Datastore Names for specific Data types if not specified in CSV 
$nvr_evenDS = "cata_nvr_livedb_evens"
$nvr_oddDS = "cata_nvr_livedb_odds"
$fnvr_evenDS = "cata_fonvr_livedb_evens"
$fnvr_oddDS = "cata_fonvr_livedb_odds"
$SQLDataDS = "cata_vm_1"
$SQLLogsDS = "cata_vm_1"
$SQLTempDBDS = "cata_vm_1"
$vicenter = "srv-cat-vc1.cnits.com"

#Import VCenter Snapins and connect to the VCenter Server

If (-not (Get-PSSnapin VMware.VimAutomation.Core -ErrorAction SilentlyContinue)) 
	{
	add-PSSnapin VMware.VimAutomation.Core | Out-Null 
	}
Connect-VIServer -Server $vicenter | Out-Null

## Imports CSV file and create drives.
$vms = Import-Csv $script

foreach ($vm in $vms){
#Start building Application drive if it exists
    If($vm.D -ne ""){
        Write-Host "Application Drive" 
        new-harddisk -Persistence persistent -CapacityGB $vm.D -VM $vm.ServerName -StorageFormat EagerZeroedThick
    }
#Start building Database drives if SQL Server
    If($vm.SQL -eq 1){
        Write-Host "Building SQL Drives"
        new-harddisk -Persistence IndependentPersistent -CapacityGB $vm.E -VM $vm.ServerName -DataStore $SQLDataDS -StorageFormat EagerZeroedThick  | New-ScsiController -Type Paravirtual
        new-harddisk -Persistence IndependentPersistent -CapacityGB $vm.F -VM $vm.ServerName -DataStore $SQLLogsDS -StorageFormat EagerZeroedThick  | New-ScsiController -Type Paravirtual
        new-harddisk -Persistence IndependentPersistent -CapacityGB $vm.G -VM $vm.ServerName -DataStore $SQLTempDBDS -StorageFormat EagerZeroedThick  | New-ScsiController -Type Paravirtual

    }
#Start building live Database Drives if value is present in CSV
    IF($vm.ldbds -ne ""){
        Write-Host "Building LiveDB drives."
        If($vm.ldbds -eq 1){
            write-host "=1"
            new-harddisk -Persistence IndependentPersistent -CapacityGB $vm.F -VM $vm.ServerName `
            -DataStore $nvr_oddDS -StorageFormat EagerZeroedThick  | New-ScsiController -Type Paravirtual
        }elseif($vm.ldbds -eq 2){
            write-host "=2"
            new-harddisk -Persistence IndependentPersistent -CapacityGB $vm.F -VM $vm.ServerName `
            -DataStore $nvr_evenDS -StorageFormat EagerZeroedThick | New-ScsiController -Type Paravirtual
        }elseif($vm.ldbds -eq 3){
            write-host "=3"
            new-harddisk -Persistence IndependentPersistent -CapacityGB $vm.F -VM $vm.ServerName `
            -DataStore $fnvr_oddDS -StorageFormat EagerZeroedThick | New-ScsiController -Type Paravirtual
        }elseif($vm.ldbds -eq 4){
            write-host "=4"
            new-harddisk -Persistence IndependentPersistent -CapacityGB $vm.F -VM $vm.ServerName `
            -DataStore $fnvr_evenDS -StorageFormat EagerZeroedThick | New-ScsiController -Type Paravirtual
        }
    }
# RDM Drive Setup. Uses LUN Number to determine the disk ID and then adds it to the VM.     
    If($vm.LunID -ne ""){ 
        Write-Host "Creating Archive Drives" #Start building Archive drives as RDM if a LUN Number is present in the CSV 
        $runtimeID = "*" + $vm.LunID
        $devID = Get-SCSILun -VMhost $vm.vHost -LunType Disk | Where-Object {$_.runtimename -like $runtimeID} | Select ConsoleDeviceName

            new-harddisk -DiskType RawPhysical -DeviceName $devID.ConsoleDeviceName  -VM $vm.ServerName | New-ScsiController -Type ParaVirtual
    }
}

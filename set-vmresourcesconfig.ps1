$csv = "c:\scripts\surv-cata-deploymentsNew.csv"

$vms = Import-CSV $csv

foreach ($vm in $vms){
$spec = New-Object VMware.Vim.VirtualMachineConfigSpec
$spec.memoryReservationLockedToMax = $true
(Get-VM $VM.ServerName).ExtensionData.ReconfigVM_Task($spec)
}
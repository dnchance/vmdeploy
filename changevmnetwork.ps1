$vms = import-csv "C:\cne\sbx-deployments.csv"
foreach ($vm in $vms)
{
    Get-NetworkAdapter -vm $vm.servername -name "Network adapter 1" | Set-NetworkAdapter -NetworkName igt_data-10.22.102.0/24 -confirm:$false 
    $servername
}
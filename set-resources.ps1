##Connect to the Vcenter Server
#connect-viserver srv-cat-vc1.cnits.com -Force
##Import Script and apply changes.
Import-Csv "C:\CNE\sbx-deployments.csv" -UseCulture | %{

get-vm $_.ServerName | set-vm -MemoryGB $_.RAM -NumCpu $_.CPU -Confirm:$false


}
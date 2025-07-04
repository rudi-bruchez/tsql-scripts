Get-ComputerInfo | Select-Object CsProcessors, OsName, OsArchitecture | Format-List

Get-WmiObject Win32_Processor | Select-Object Name, DeviceID, NumberOfCores, NumberOfLogicalProcessors, StatusInfo, CurrentClockSpeed | Format-Table

Get-ItemProperty -Path "HKLM:\HARDWARE\DESCRIPTION\System\CentralProcessor\0"

################# VM ? #################

# Get-WmiObject -Class Win32_ComputerSystem | Select-Object Manufacturer, Model
Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object Manufacturer, Model


# | Hypervisor  | Manufacturer          | Model                             |
# | ----------- | --------------------- | --------------------------------- |
# | Hyper-V     | Microsoft Corporation | Virtual Machine                   |
# | VMware      | VMware, Inc.          | VMware Virtual Platform           |
# | VirtualBox  | Oracle Corporation    | VirtualBox                        |
# | KVM         | QEMU                  | Standard PC (i440FX + PIIX, 1996) |

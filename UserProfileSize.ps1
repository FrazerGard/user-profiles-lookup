<#function ProfileSizer{
    Clear-Host
    $loop = "Y"
    while ($loop -eq "Y") {
        function ProfileSizeLookup {
            $PCName = Read-Host 'Please enter PC name'
            $DACreds = Read-Host 'Please enter your initials'

            Invoke-Command -ComputerName $PCName -Credential internal\"$DACreds"admin -ScriptBlock {
                Get-ChildItem -force -Path C:\Users -ErrorAction SilentlyContinue |  Where-Object { -not($_.Attributes -band [System.IO.FileAttributes]::ReparsePoint) } | Where-Object Name -NotLike 'All users' | Where-Object { $_ -is [io.directoryinfo] } | ForEach-Object {
                $len = 0
                Get-ChildItem -recurse -force $_.fullname -ErrorAction SilentlyContinue | Where-Object { -not($_.Attributes -band [System.IO.FileAttributes]::ReparsePoint) } | ForEach-Object { $len += $_.length }
                $_.fullname, '{0:N2} GB' -f ($len / 1Gb)
                }
            }
        }
    ProfileSizeLookup
    $loop = Read-Host "Type 'Y' to search again. Press enter to exit."
    }
}#>


function ProfileSizeLookup {
    Get-ChildItem -force -ErrorAction SilentlyContinue | Where-Object Name -NotLike 'All users' | Where-Object { $_ -is [io.directoryinfo] } | ForEach-Object {
    $len = 0
    Get-ChildItem -recurse -force $_.fullname -ErrorAction SilentlyContinue | ForEach-Object { $len += $_.length }
    $_.fullname, '{0:N2} GB' -f ($len / 1Gb)
    }
}
$PCName = Read-Host 'Please enter PC name'
$DACreds = Read-Host 'Please enter your initials'

New-PSDrive -name UserSize -psprovider FileSystem -credential internal\"$DACreds"admin  -root "\\$PCName\c$"
set-location UserSize:\Users
ProfileSizeLookup
set-location C:
Remove-PSDrive UserSize
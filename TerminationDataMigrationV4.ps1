<# 
1. Requests tech to select username from C:/Users folder. Selects relevant data, reports number of files found.
2. Requests termination date and the length of Hold Term.
3. Creates a "LaptopSN-Username-Date" folder and corresponding subfolders on H drive.
4. Copies data to the corresponding folder on the H drive. (Does not move empty folders.)
5. Sends an email to notify you when the script has completed.
#>

Write-host  -ForegroundColor red "This script moves a user's data when they have been terminated.  It intentionally excludes any .exe and .msi files per IT Policy, so double check that you don't need them. `n"

$UserProfiles = Get-ChildItem -Path C:\users\ |
Where-Object {
                ($_.name -notlike "Administrator*") -and
                ($_.Name -notlike "COMPANYNAME*") -and
                ($_.name -notlike "public*") -and
                ($_.name -notlike "*-a*")
             }

$users = @($UserProfiles) 
$n = 0
$menutext = ""
foreach ($user in $Users)   {
$menutext = $menutext + "$($n+1): Type '$($n+1)' for $($users[$n]) and press Enter. `n"
$n =+ 1
                            }

           
[string]$Title = 'Select a User'
Write-Host "================ $Title ================"
Write-Host $menutext  
        


$input = Read-Host "Please make a selection"
$input2 = switch ($input)
    {
        '1' {$($users[0])}
        '2' {$($users[1])}
        '3' {$($users[2])}
        '4' {$($users[3])}
        '5' {$($users[4])}
        '6' {$($users[5])}
        '7' {$($users[6])}
        '8' {$($users[7])}
        '9' {$($users[8])}
        '10' {$($users[9])}
        default {"Please select a valid number representing a username."}
    }

if ($input2 = 'default') {Write-Host $input2 ; break} else {

       

#date-pickers exist for $termdate, but are complicated
$TermDate = Read-Host -Prompt "Refer to the MACD and type the termination date in MM-DD-YY format"
Write-Host "Press 1 for 30-day hold, or 2 for 1-year hold."
$HoldLength = Read-Host -Prompt "Please make a selection."
$HoldLength2 = switch ($HoldLength)
                        {
                            '1' {"30-Days"}
                            '2' {"1-Year"}
                        }


$Bios = Get-WmiObject win32_bios
$SN = $bios.serialnumber
$sw = [Diagnostics.Stopwatch]::StartNew()

$Desktop = Get-ChildItem -Path C:\Users\$input2\Desktop -Exclude "*.exe", "*.msi" 
$Downloads = Get-ChildItem -Path C:\Users\$input2\Downloads -Exclude "*.exe", "*.msi"
$Docs = Get-ChildItem -Path C:\Users\$input2\Documents -Exclude "*.exe", "*.msi"
#$Music = Get-ChildItem -Path C:\Users\$input2\Music -Exclude "*.exe", "*.msi"
$Pictures = Get-ChildItem -Path C:\Users\$input2\Pictures -Exclude "*.exe", "*.msi"
$Videos = Get-ChildItem -Path C:\Users\$input2\Videos -Exclude "*.exe", "*.msi"

Write-Host -ForegroundColor Cyan "There are $($desktop.count) Desktop items, $($Downloads.count) Downloads, $($docs.count) Documents, $($music.count) in Music, $($Pictures.count) Pictures and $($Videos.count) Videos to be moved."

$target2 = "$sn-$input2-$TermDate"
New-Item -Path \\txalfs02\users\$input2 -ItemType Directory -Name "~Hold for $HoldLength2 from $TermDate"
New-Item -Path \\txalfs02\users\$input2 -ItemType Directory -Name $target2

if ($data1 -gt 0) {New-Item -Path \\txalfs02\users\$input2\$target2 -ItemType Directory -Name Desktop}
if ($data2 -gt 0) {New-Item -Path \\txalfs02\users\$input2\$target2 -ItemType Directory -Name Downloads}
if ($data3 -gt 0) {New-Item -Path \\txalfs02\users\$input2\$target2 -ItemType Directory -Name Docs}
if ($data4 -gt 0) {New-Item -Path \\txalfs02\users\$input2\$target2 -ItemType Directory -Name Music}
if ($data5 -gt 0) {New-Item -Path \\txalfs02\users\$input2\$target2 -ItemType Directory -name Pictures}
if ($data6 -gt 0) {New-Item -Path \\txalfs02\users\$input2\$target2 -ItemType Directory -Name Videos}

<# Should make this a function, or simplify the  data into one variable. #>
$Desktop | ForEach-Object {Copy-Item -Recurse $_.FullName -Destination \\txalfs02.wrca.com\users\$input2\$target2\Desktop}
$Downloads | ForEach-Object {Copy-Item -Recurse $_.FullName -Destination \\txalfs02.wrca.com\users\$input2\$target2\Downloads}
$Docs | ForEach-Object {Copy-Item -Recurse $_.FullName -Destination \\txalfs02.wrca.com\users\$input2\$target2\Docs}
#$Music | ForEach-Object {Copy-Item -Recurse $_.FullName -Destination \\txalfs02.wrca.com\users\$input2\$target2\Music}
$Pictures | ForEach-Object {Copy-Item -Recurse $_.FullName -Destination \\txalfs02.wrca.com\users\$input2\$target2\Pictures}
$Videos | ForEach-Object {Copy-Item -Recurse $_.FullName -Destination \\txalfs02.wrca.com\users\$input2\$target2\Videos}

$sw.Stop()
Write-Host "All specified data has been moved to $($input2)'s H Drive, and it took $($sw.elapsed) to complete."
Read-Host -Prompt "Press Enter to continue."}
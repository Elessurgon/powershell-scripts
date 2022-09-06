# Figure out how to run multiple instances without overwriting DB data which is created by gowitness
# Add nmap (or naabu), dalfox, assetfinder, subfinder in the toolchain

param ($domain, $dir = './', $name, $type = 'Passive', $chrome='C:\Program Files\Google\Chrome\Application\chrome.exe', $start="N", $file="N", $blacklist="N")
if ($null -eq $name) {
    $name = $domain
}
if ($null -eq $domain) {
    Write-host -Prompt "Enter domain" 
}

if (-not(Test-Path -Path $dir)) {
    New-Item -Path "$dir" -ItemType Directory
}

$command = "./amass.exe enum -v -src -ip -brute -min-for-recursive 2 -p 80,443,8080 -dir $dir -o $dir/subdomains_all_$name.txt "
if ($file -eq 'Y') {
    $command = $command + "  -df " + $domain
} else {
    $command = $command + "  -d " + $domain
}

if ($blacklist -ne 'N') {
    $command = $command + " -blf " + $blacklist
} 

if ($type -eq 'Active') {
    $command = $command + " -active  "
} else {
    Write-Host "Passive Scan"
}

Write-Host $command
Invoke-Expression $command

if ($type -ne "Skip") {
    $names_extract = "./amass.exe db -names -dir $dir "
    $viz =  "./amass.exe viz -d3 -dir $dir "
    if ($file -eq 'Y') {
        $names_extract = $names_extract + " -df $domain "
        $viz =  $viz + " -df $domain "
    } else {
        $names_extract = $names_extract + " -d $domain "
        $viz =  $viz + " -d $domain "
    }
    $io = " > $dir/subdomains_$name.txt "
    $cmd = $names_extract + $io
    Invoke-Expression $cmd
    Invoke-Expression $viz
    Rename-Item -Path ".\amass.html" -NewName "$name.html"
    Move-Item -force -Path "./$name.html" -Destination $dir
}
.\gowitness.exe file -f $dir\subdomains_$name.txt --chrome-path $chrome -F --delay 5 -P $dir/screenshots
Move-Item -force -Path "./gowitness.sqlite3" -Destination $dir
if ($start -eq "Y") {
    Set-Location $dir
    ..\gowitness.exe server
}
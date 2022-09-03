# Add nmap (or naabu), dalfox, assetfinder, subfinder in the toolchain
param ($domain, $dir = './', $name, $type = 'Passive', $chrome='C:\Program Files\Google\Chrome\Application\chrome.exe')
if ($null -eq $name) {
    $name = $domain
}
if ($null -eq $domain) {
    Write-host -Prompt "Enter domain" 
}

if (-not(Test-Path -Path $dir)) {
    New-Item -Path "$dir" -ItemType Directory
}

if ($type -eq 'Active') {
    ./amass.exe enum -active -v -src -ip -brute -min-for-recursive 2 -d $domain -o $dir/subdomains_all_$name.txt -dir $dir -p 80,443,8080
} elseif ($type -eq 'Passive') {
    ./amass.exe enum -v -src -ip -brute -min-for-recursive 2 -d $domain -o $dir/subdomains_all_$name.txt -dir $dir
} elseif($type -eq "Skip") {
    Write-Host "Skipped scan"
} else {
    Write-Host -Prompt "Write a valid option"
}
if ($type -ne "Skip") {
    ./amass.exe db -names -d $domain -dir $dir > $dir/subdomains_$name.txt
    ./amass.exe viz -d3 -d $domain -dir $dir
    Rename-Item -Path ".\amass.html" -NewName "$name.html"
    Move-Item -force -Path "./$name.html" -Destination $dir
}
.\gowitness.exe file -f $dir\subdomains_$name.txt --chrome-path $chrome -F --delay 5 -P $dir/screenshots
Move-Item -force -Path "./gowitness.sqlite3" -Destination $dir
Set-Location $dir
..\gowitness.exe server
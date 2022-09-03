param ($domain, $dir = './', $name, $type = 'Passive')
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
    ./amass.exe enum -active -v -src -ip -brute -min-for-recursive 2 -d $domain -o $dir/subdomains_all_$name.txt -p 80,443,8080
} elseif ($type -eq 'Passive') {
    ./amass.exe enum -v -src -ip -brute -min-for-recursive 2 -d $domain -o $dir/subdomains_all_$name.txt
} else {
    Write-Host -Prompt "Write a valid option"
}
./amass.exe db -names -d $domain > $dir/subdomains_$name.txt
./amass.exe viz -d3 -d $domain  
Rename-Item -Path ".\amass.html" -NewName "$name.html"
Move-Item -force -Path "./$name.html" -Destination $dir

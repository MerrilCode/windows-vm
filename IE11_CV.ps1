$key  = "HKCU:\Software\Microsoft\Internet Explorer\BrowserEmulation\ClearableListData"
$item = "UserFilter"

. .\Get-IPrange.ps1
$cidr = "^((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)\.){3}(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)/(3[0-2]|[1-2]?[0-9])$"

[byte[]] $regbinary = @()

#This seems constant
[byte[]] $header   = 0x41,0x1F,0x00,0x00,0x53,0x08,0xAD,0xBA

#This appears to be some internal value delimeter
[byte[]] $delim_a  = 0x01,0x00,0x00,0x00

#This appears to separate entries
[byte[]] $delim_b  = 0x0C,0x00,0x00,0x00

#This is some sort of checksum, but this value seems to work
[byte[]] $checksum = 0xFF,0xFF,0xFF,0xFF

#This could be some sort of timestamp for each entry ending with 0x01, but setting to this value seems to work
[byte[]] $filler   = 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x01

#Examples: mydomain.com, 192.168.1.0/24
$domains = @("google.com","192.168.1.0/24")

function Get-DomainEntry($domain) {
    [byte[]] $tmpbinary = @()

    [byte[]] $length = [BitConverter]::GetBytes([int16]$domain.Length)
    [byte[]] $data = [System.Text.Encoding]::Unicode.GetBytes($domain)

    $tmpbinary += $delim_b
    $tmpbinary += $filler
    $tmpbinary += $delim_a
    $tmpbinary += $length
    $tmpbinary += $data

    return $tmpbinary
}

if($domains.Length -gt 0) {
    [int32] $count = $domains.Length

    [byte[]] $entries = @()
    
    foreach($domain in $domains) {
        if($domain -match $cidr) {
            $network = $domain.Split("/")[0]
            $subnet  = $domain.Split("/")[1]
            $ips = Get-IPrange -ip $network -cidr $subnet
            $ips | %{$entries += Get-DomainEntry $_}
            $count = $count - 1 + $ips.Length
        }
        else {
            $entries += Get-DomainEntry $domain
        }
    }

    $regbinary = $header
    $regbinary += [byte[]] [BitConverter]::GetBytes($count)
    $regbinary += $checksum
    $regbinary += $delim_a
    $regbinary += [byte[]] [BitConverter]::GetBytes($count)
    $regbinary += $entries
}

Set-ItemProperty -Path $key -Name $item -Value $regbinary
#import-module au

. $PSScriptRoot\..\..\scripts\all.ps1

$releases    = 'https://help.elgato.com/hc/en-us/articles/360028242631-Elgato-Stream-Deck-Software-Release-Notes'

function global:au_SearchReplace {
    @{
        ".\tools\chocolateyInstall.ps1" = @{
            '(^\s*url64\s*=\s*)(''.*'')'            = "`$1'$($Latest.URL64)'"
            "(?i)(^\s*checksum64\s*=\s*)('.*')"       = "`$1'$($Latest.Checksum64)'"
            "(?i)(^\s*checksumType64\s*=\s*)('.*')"   = "`$1'$($Latest.ChecksumType64)'"
        }
    }
}

function global:au_BeforeUpdate() {
    $Latest.Checksum64 = Get-RemoteChecksum $Latest.Url64
    $Latest.ChecksumType64 = 'SHA256'
}

function global:au_AfterUpdate {
    Set-DescriptionFromReadme -SkipFirst 2
}

function global:au_GetLatest {

    $page = Invoke-WebRequest -Uri $releases -UseBasicParsing
    $regex = 'Stream_Deck_(?<version>[\d\.]+).msi'
    $url = $page.links | Where-Object href -match $regex | Select-Object -First 1 -expand href

    return @{
        URL64   = $url
        Version = $matches.version
    }
}

Update-Package -ChecksumFor none
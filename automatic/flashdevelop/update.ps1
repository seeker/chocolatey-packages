Add-Type -AssemblyName System.Web

$base_url = 'http://www.flashdevelop.org/community/'
$releases = $base_url + 'viewforum.php?f=11'
$installer_ext = '.*exe$'

function global:au_GetLatest {
    $url     = get_installer_link
    $version = [regex]::Match($url, 'FlashDevelop-([\d\.]*)\.exe$').Groups[1].ToString()
	 
    $Latest = @{ URL = $url; Version = $version }
    return $Latest
}

function global:au_SearchReplace {
    @{
        'tools\chocolateyInstall.ps1' = @{
            "(^[$]url\s*=\s*)('.*')"       = "`$1'$($Latest.URL)'"
            "(^[$]checksum\s*=\s*)('.*')"  = "`$1'$($Latest.Checksum32)'"
        }
     }
}

<#
.DESCRIPTION
Get the URL to the forum thread with the lastest version.
#>
function current_release {
     $release_page = Invoke-WebRequest -UseBasicParsing -Uri $releases
	 $download_page = $release_page.links | ? title -match 'Posted' | select -First 1 -expand href

	return [Uri]::new([Uri]$base_url, [System.Web.HttpUtility]::HtmlDecode($download_page)).AbsoluteUri
}

<#
.DESCRIPTION
Find the installer download URL in the thread post. 

.PARAMETER page_link
URl to the thread containing the release.
#>
function download_link($page_link) {
	$download_page = Invoke-WebRequest -UseBasicParsing -Uri $page_link
	
	return $download_page.links | ? href -match $installer_ext | select -expand href
}

<#
.DESCRIPTION
Get the installer URL for the lastest version.
#>
function get_installer_link {
	$download_page_url = current_release
	$installer_link = download_link $download_page_url
	
	return $installer_link
}

<#
.DESCRIPTION
Get the package version from the URL.
#>
function get_version($url) {
	return [regex]::Match($url, 'FlashDevelop-([\d\.]*)\.exe$').Groups[1].ToString()
}

update -ChecksumFor 32
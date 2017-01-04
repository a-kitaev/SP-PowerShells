#  This script checks a site for duplicates and writes findings into csv file
#  Loops through all document libraries
#  This version of the script compares MD5 hash of the files so it will find duplicates even if they are renamed

#Add-PSSnapin Microsoft.SharePoint.PowerShell #-ErrorAction SilentlyContinue [system.reflection.assembly]::LoadWithPartialName(“Microsoft.SharePoint”)

$RootSiteUrl = "https://your.site.com/sites/test"  #Site to check
$Items = @() 
$duplicateItems = @() 
$web = get-spweb $RootSiteUrl

function Get-SPFileHash ($fileurl)			#This function returns hash of a file
{
	$file = $web.GetFile($fileurl)
	$bytes = $file.OpenBinary()
	$md5 = New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
	$hash = [system.BitConverter]::ToString($md5.ComputeHash($bytes))
	return $hash	
}

foreach ($list in $Web.Lists)				#Loopping through document libraries
{ 
if($list.BaseType -eq "DocumentLibrary" -and $list.RootFolder.Url -notlike "_*" -and $list.RootFolder.Url -notlike "SitePages*")
{
if($list.Items.count -gt 5000){ 
Write-Host $list.title "contains " -nonewline 
Write-Host $list.Items.count -foregroundcolor red -NoNewLine 
Write-Host " items. Be patient"}
Else {Write-Host $list.title "contains " $list.Items.count " items. Checking for duplicates"}
foreach($item in $list.Items) 				#Looping through each item in a document library
{
$record = New-Object -TypeName System.Object
if($item.File.length -gt 0)
{
$record | Add-Member NoteProperty FileName ($item.file.Name)
$record | Add-Member NoteProperty FullPath ($Web.Url + "/" + $item.Url)
$record | Add-Member NoteProperty Hash (Get-SPFileHash ($Web.Url + "/" + $item.Url))
$Items += $record
}
}
}
}

$web.Dispose()

$duplicateItems = $Items | Group-Object Hash | Where-Object {$_.Count -gt 1} | Foreach-Object { $_.Group} | Select Filename, Fullpath, Hash
Write-Host "Found " $duplicateItems.count "duplicates" -foregroundcolor green
$duplicateItems | Export-CSV "c:\scripts\duplicates.csv" -Encoding UTF8


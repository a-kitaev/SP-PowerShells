# This script checks teo libraries for duplicates
# Exports info about duplicates to .csv
#

#Add-PSSnapin Microsoft.SharePoint.PowerShell #-ErrorAction SilentlyContinue [system.reflection.assembly]::LoadWithPartialName(“Microsoft.SharePoint”)

$SiteUrl = "https://portal.avestragroup.com/ITDep"
$SiteUrl2 =	"https://portal.avestragroup.com/ITDep"	#site to check
$ListName = "/shared%20documents/"					# first library
$ListName2 = "/Internal%20Documents/"					# second library

$Items = @() 
$Duplicates = @() 
$duplicateItems = @() 

$web = get-spweb $SiteUrl
$web2 = get-spweb $SiteUrl2


$list = $web.getlist($web.Url+$listname)					#checking first library
if($list.Items.count -gt 5000){ 
Write-Host $list.title "contains " -nonewline 
Write-Host $list.Items.count -foregroundcolor red -NoNewLine 
Write-Host " items. Be patient"}
Else {Write-Host $list.title "contains " $list.Items.count " items. Checking for duplicates"}
foreach($item in $list.Items) 
{ 
#	write-host $item.file.name
$record = New-Object -TypeName System.Object
if($item.File.length -gt 0)
{
$record | Add-Member NoteProperty FileName ($item.file.Name)
$record | Add-Member NoteProperty FullPath ($Web.Url + "/" + $item.Url)
$Items += $record
If ($Items.count % 1000 -eq 0) {Write-Host "Checked " $Items.count " items"}
}

}
$list2 = $web2.getlist($web2.Url+$listname2)					#checking second library
if($list2.Items.count -gt 5000){ 
Write-Host $list2.title "contains " -nonewline 
Write-Host $list2.Items.count -foregroundcolor red -NoNewLine 
Write-Host " items. Be patient"}
Else {Write-Host $list2.title "contains " $list2.Items.count " items. Checking for duplicates"}
foreach($item in $list2.Items) 
{ 
#	write-host $item.file.name
$record = New-Object -TypeName System.Object
if($item.File.length -gt 0)
{
$record | Add-Member NoteProperty FileName ($item.file.Name)
$record | Add-Member NoteProperty FullPath ($Web2.Url + "/" + $item.Url)
$Items += $record
If ($Items.count % 1000 -eq 0) {Write-Host "Checked " $Items.count " items"}
}

}

$web.Dispose()
$web2.Dispose()


$duplicateItems = $Items | Group-Object Filename| Where-Object {$_.Count -gt 1} | Foreach-Object { $_.Group} | Select Filename, Fullpath
Write-Host "Found " $duplicateItems.count "duplicate candidates" -foregroundcolor green

$duplicateItems | Export-CSV "c:\scripts\duplicates.csv" -Encoding UTF8




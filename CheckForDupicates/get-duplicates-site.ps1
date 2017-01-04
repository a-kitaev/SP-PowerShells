# Check a site for duplicate documents
# Export info about found duplicates to csv

#Add-PSSnapin Microsoft.SharePoint.PowerShell #-ErrorAction SilentlyContinue [system.reflection.assembly]::LoadWithPartialName(“Microsoft.SharePoint”)

$RootSiteUrl = "https://portal.avestragroup.com/ITDep"
$Items = @() 
$Duplicates = @() 
$duplicateItems = @() 
$duplicateshelper = @()

$web = get-spweb $RootSiteUrl

foreach ($list in $Web.Lists)
{ 
if($list.BaseType -eq "DocumentLibrary" -and $list.RootFolder.Url -notlike "_*" -and $list.RootFolder.Url -notlike "SitePages*")
{
if($list.Items.count -gt 5000){ 
Write-Host $list.title "contains " -nonewline 
Write-Host $list.Items.count -foregroundcolor red -NoNewLine 
Write-Host " items. Be patient"}
Else {Write-Host $list.title "contains " $list.Items.count " items. Checking for duplicates"}
foreach($item in $list.Items) 
{
$record = New-Object -TypeName System.Object
if($item.File.length -gt 0)
{
$record | Add-Member NoteProperty FileName ($item.file.Name)
$record | Add-Member NoteProperty FullPath ($Web.Url + "/" + $item.Url)
$Items += $record
}
}
}
}

$web.Dispose()

$duplicateItems = $Items | Group-Object Filename| Where-Object {$_.Count -gt 1} | Foreach-Object { $_.Group} | Select Filename, Fullpath
Write-Host "Found " $duplicateItems.count "duplicate candidates" -foregroundcolor green
$duplicateItems | Export-CSV "c:\scripts\duplicates.csv" -Encoding UTF8


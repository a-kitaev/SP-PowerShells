$sitecol = Get-SPSite -Identity "https://your.site.com/"
$Items = @() 
foreach($site in $sitecol){
  foreach($web in $site.AllWebs){
  Write-Host "Checking " $Web.Title " site" -foregroundcolor Green
    foreach($list in $web.lists){
      if($list.BaseType -eq "DocumentLibrary") {
	Write-Host $list.title "contains " $list.Items.count " items"
        $itemSize = 0
        foreach($item in $list.items) {
		$record = New-Object -TypeName System.Object
         	$itemSize = ($item.file).length
		$record | Add-Member NoteProperty FileSize ([string][Math]::Round(($itemSize/1KB),2))
		$record | Add-Member NoteProperty FileName (($item.file).name)
		$record | Add-Member NoteProperty FilePath (($item.file).parentfolder)
		$record | Add-Member NoteProperty Editor ($item["Editor"])
		$record | Add-Member NoteProperty Author ($item["Author"])
		$record | Add-Member NoteProperty DateModified ($item["Modified"])
		$record | Add-Member NoteProperty DateCreated ($item["Created"])
		$Items += $record
        }
      } 
    }
    $web.Dispose()
  }
}
$Items | Export-CSV "c:\scripts\stats.csv" -Encoding UTF8

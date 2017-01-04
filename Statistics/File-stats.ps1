$sitecol = Get-SPSite -Identity "https://your.site.com"

foreach($site in $sitecol)
{
  foreach($s in $site.AllWebs)
  {
    foreach($l in $s.lists)
    {
      if($l.BaseType -eq "DocumentLibrary") {
        $itemSize = 0
        foreach($item in $l.items) {
          $itemSize = ($item.file).length
		  $filesize = [string][Math]::Round(($itemSize/1KB),2)
		  $filename = ($item.file).name
		  $filename2 = ($item.file).parentfolder
		  $filename3 = $item["Editor"]
		  $filename4 = $item["Author"]
		  $filename5 = $item["Modified"]
		  $filename6 = $item["Created"]
		  $title = $filesize + "," + $s.Title + "," + $l.Title + "," + $filename + "," + $filename2 + "," + $filename3 + "," + $filename4 + "," + $filename5 + "," + $filename6
		  $title >> "output.csv"
        }
      } 
    }
    $s.Dispose()
  }
}

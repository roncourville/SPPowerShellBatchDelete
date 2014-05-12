Add-Type @'
public class BatchCommand
{
	 public string command;        
	 public string list;
	 public int count;
}
'@

function PurgeLists($webUrl, [System.Array]$lists) {
$webUrl;
	$web = get-spweb $webUrl.toString();
	
	Write-Host "Building batch queries...";
	$batchArr = BuildBatchArray $web $lists ;
	
	ForEach ($batch in $batchArr)
	{
		 Write-Host "Now deleting " $batch.count.ToString() " items in " $batch.list;
		 $web.ProcessBatchData($batch.command);
	}
}

function BuildBatchArray($web, [System.Array]$lists) {
	$batchArr = @();
	
	ForEach ($list in $lists)
	{
		 $batch = New-Object BatchCommand;
		 $batch.command = BuildBatchDeleteCommand($web.Lists[$list]);
		 $batch.list = $list;
		 $batch.count = $web.Lists[$list].ItemCount;
		 $batchArr += $batch;
	}

	return $batchArr;
}

function BuildBatchDeleteCommand([Microsoft.SharePoint.SPList] $spList)
{
	$sbDelete = "";
	$sbDelete += '<?xml version="1.0" encoding="UTF-8"?><Batch>';
	$command = '<Method><SetList Scope="Request">' + $spList.ID +
	'</SetList><SetVar Name="ID">{0}</SetVar><SetVar Name="Cmd">Delete</SetVar></Method>';

     foreach ($item in $spList.Items)
     {
          $sbDelete += $command -f $item.ID.ToString();
     }
     $sbDelete += "</Batch>";
     return $sbDelete;
}



$webUrl = Read-Host "Please enter SharePoint Web URL";
[string[]] $lists = (Read-Host "Enter SharePoint lists to be purged (separate with comma)").split(',') | % {$_.trim()}

PurgeLists $webUrl $lists;

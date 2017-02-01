<#
	Parses a .css/.js/.jpg file, grabs the content and encodes it.  
	Then inserts it into the associated .item (into the blob field) in the destination directory
	
	$assetRoot/sitecore/assets/css_asset.css -> $destinationDirectory/css_asset.item
	
    Example usage: 
    .\parse-content-and-itemize.ps1 "project.web" "project.web/content/script.js" "tdsproject/"
#>

Param(
    [Parameter(Position=0, Mandatory=$true)]
    [string]$assetPath,
	[Parameter(Position=1, Mandatory=$true)]
    [string]$assetRoot,
    [Parameter(Position=2, Mandatory=$true)]
    [string]$destinationDirectory,
	[Parameter(Position=3, Mandatory=$false)]
    [string]$sitecoreLibPath = ("{0}\..\lib\Sitecore\" -f (Resolve-Path .) ) 
)

$assetRoot = resolve-path $assetRoot
$destinationDirectory = resolve-path $destinationDirectory
$sitecoreLibPath = resolve-path $sitecoreLibPath

$sitecoreKernelPath = ("{0}Sitecore.Kernel.dll" -f $sitecoreLibPath);
$writableExtensions = @("gif", "png", "jpg", "css", "js", "svg");
[System.Reflection.Assembly]::LoadFile($sitecoreKernelPath) | Out-Null;

$contentItem = Get-Item $assetPath
if($writableExtensions.Contains($contentItem.Extension.Replace(".","")))
{
	$contentItemContent = Get-Content $contentItem -Raw
	$contentItemBytes = [System.Text.Encoding]::UTF8.GetBytes($contentItemContent)
	$contentItemEncoded = [System.Convert]::ToBase64String($contentItemBytes)
	
	
	$relavantAssetPath = ($contentItem).FullName.Replace($assetRoot, "");
	$absoluteItemPath = Get-Item ("{0}/{1}" -f $destinationDirectory, $relavantAssetPath).Replace($contentItem.Extension, ".item")
	
	#$sr = New-Object System.IO.StreamReader($absoluteItemPath)
	$mode = [System.IO.FileMode]::Open
	$access = [System.IO.FileAccess]::ReadWrite
	$sharing = [IO.FileShare]::ReadWrite
	$fs = New-Object IO.FileStream($absoluteItemPath, $mode, $access, $sharing)
	$sr = New-Object System.IO.StreamReader($fs)
	$tokenizer = New-Object Sitecore.Data.Serialization.ObjectModel.Tokenizer($sr);
	$syncItem = [Sitecore.Data.Serialization.ObjectModel.SyncItem]::ReadItem($tokenizer, $false);	
		
	$topVersion = $syncItem.GetLatestVersions()
	$itemsAreDifferent = $false;
	foreach($sharedField in $syncItem.SharedFields)
	{
		if($sharedField.FieldName.ToLower().Equals("blob"))
		{
			$syncItemBlob = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($sharedField.FieldValue));
			if($syncItemBlob -ne $contentItemContent)
			{
				$itemsAreDifferent = $true;
			}
		}
	}
	
	if($itemsAreDifferent)
	{
		$sv = [Sitecore.Data.Serialization.ObjectModel.SyncVersion]::BuildVersion($topVersion.Language, (($topVersion.Version -as [int]) + 1), [guid]::NewGuid())
		$sw = New-Object System.IO.StreamWriter($fs)
		$fs.SetLength(0);#clear out .item file
		foreach($sharedField in $syncItem.SharedFields)
		{
			if($sharedField.FieldName.ToLower().Equals("blob")){
				$sharedField.FieldValue = $contentItemEncoded
			}
			$sv.Fields.Add($sharedField);
		}
		$syncItem.Versions.Add($sv)
		write-host "Item Updated:" $absoluteItemPath
		$syncItem.Serialize($sw);
		$sw.Dispose()
	}

	$sr.Dispose()
}


<#
	Parses a .item file, grabs the fields defined below (right now just the blob field) and 
	creates/updates the corresponding decoded asset in the specified destination directory
	
	$itemPath/sitecore/assets/css_asset.item -> $destinationDirectory/css_asset.css (based on the Extension defined in the item)
	
    Example usage: 
    .\parse-item-and-write.ps1 "tdsproject/css_asset.item" "project.web/"
	
#>

Param(
    [Parameter(Position=0, Mandatory=$true)]
    [string]$itemPath,
    [Parameter(Position=1, Mandatory=$true)]
    [string]$destinationDirectory = $PSScriptRoot,
	[Parameter(Position=2, Mandatory=$false)]
    [string]$sitecoreLibPath = ("{0}\..\lib\Sitecore\" -f (Resolve-Path .) )
)

$itemPath = resolve-path $itemPath
$destinationDirectory = resolve-path $destinationDirectory
$sitecoreLibPath = resolve-path $sitecoreLibPath

$sitecoreKernelPath = ("{0}Sitecore.Kernel.dll" -f $sitecoreLibPath);
$writableExtensions = @("gif", "png", "jpg", "css", "js", "svg");
[System.Reflection.Assembly]::LoadFile($sitecoreKernelPath) | Out-Null;

$sr = New-Object System.IO.StreamReader(Get-Item $itemPath)
$tokenizer = New-Object Sitecore.Data.Serialization.ObjectModel.Tokenizer($sr);
$syncItem = [Sitecore.Data.Serialization.ObjectModel.SyncItem]::ReadItem($tokenizer, $false);

$contentObject = @{
	Path = $syncItem.ItemPath
	Name = $syncItem.Name
	Extension = ""
	Blob = ""
}
foreach($sharedField in $syncItem.SharedFields)
{
	if($sharedField.FieldName.ToLower().Equals("blob"))
	{
		$contentObject.Blob = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($sharedField.FieldValue));
	}
	elseif($sharedField.FieldName.ToLower().Equals("extension"))
	{
		$contentObject.Extension = $sharedField.FieldValue;
	}
}

if($writableExtensions.Contains($contentObject.Extension.ToLower()))
{
	$wantFile = ("{2}/{0}.{1}" -f $contentObject.Path, $contentObject.Extension, $destinationDirectory) 
	$fileExists = Test-Path $wantFile
	If ($fileExists -eq $True) {
		$existingFileContent = get-content $wantFile -Raw
		if($existingFileContent -ne $contentObject.Blob)
		{
			$contentObject.Blob | new-item -Force -path $wantFile | Out-Null
			write-host "Updated: " $existingFileContent
		}
		else{
			write-host "Updated triggered, file matched: " $wantFile
		}
	}
	else{
		$contentObject.Blob | new-item -Force -path $wantFile | Out-Null;
		write-host "Created: " $wantFile
	}


}


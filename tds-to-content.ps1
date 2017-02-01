<#
	Script to run across all items in a project and create the associated assets
#>

$tdsSourceProject = "TDSProject";
$tdsSourceProjectDirectory = ("$PSScriptRoot\..\{0}\" -f $tdsSourceProject);
Get-ChildItem -Path $tdsSourceProjectDirectory -Recurse -Include *.item | % {
	& .\parse-item-and-write.ps1 $_.FullName $PSScriptRoot
}


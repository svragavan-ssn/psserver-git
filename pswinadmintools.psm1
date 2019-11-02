
$script:PSModuleRoot = $PSScriptRoot
foreach ($function in (Get-ChildItem "$script:PSModuleRoot\functions\*.ps1")) {
	 . $function.FullName 
}
param([switch] $Watch, [switch] $Debug)

function Format-Pester($results) {
    $results.TestResult `
        | ?{ -not $_.Passed } `
        | Sort Describe, Context `
        | group { $_.Describe } `
        | %{
            write-host "$($_.Name)" -ForegroundColor Red
            $_.Group | %{
                write-host "   $($_.Context)" -ForegroundColor Green
                $_.FailureMessage -split "`n" | %{
                write-host "      $($_)" -ForegroundColor Red
                }
            }
        }
}

function New-FileSystemWatcher(
    [Parameter(Mandatory)][ValidateNotNullOrEmpty()] [string] $TargetFile,
    [Parameter(Mandatory)][ValidateNotNull()] [ScriptBlock] $Action
) {
    
    $fullPath = Resolve-Path $TargetFile

    $fsw= New-Object System.IO.FileSystemWatcher
    $fsw.Path = (Split-Path $fullPath -Parent)
    $fsw.Filter = (SPlit-Path $FullPath -Leaf)
    $fsw.NotifyFilter = [IO.NotifyFilters]::LastWrite

    Register-ObjectEvent -InputObject $fsw `
        -EventName Changed `
        -Action $Action | Out-Null

    return $fsw
}

function Find-AssociatedTestFile (
    [Alias("FullName")]
    [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [ValidateNotNullOrEmpty()]
    [string] $FullPath) {

    $fileInfo = New-Object IO.FileInfo $FullPath
    $TestFileName = "$($FileInfo.BaseName).Tests.ps1"
    gci -path "./tests" -filter $TestFileName -recurse
}

function New-WatchList() {
    gci -path "./Functions" -filter *.ps1 -recurse `
    | %{ 
        return [PsCustomObject] @{
            "SourceFile" = $_.FullName;
            "TestFile" = ($_ | Find-AssociatedTestFile).FullName
        }
    } `
    | ?{ $_.SourceFile -and $_.TestFile };
}

function Save-WatchList([Parameter(Mandatory)][ValidateNotNull()][array] $Array) {
    [System.AppDomain]::Currentdomain.SetData("Posh-Watch:WatchList", $Array)                    
}

function Get-WatchList() {
    [System.AppDomain]::Currentdomain.GetData("Posh-Watch:WatchList")        
}

$OnSourceFileChanged = {
    param($sender, $e)
    #
    # It is necessary to reproduce this function here as the parent closure will
    # not be available during the event.
    #
    function Find-AssociatedTestFile (
        [string] $FullPath) {
    
        $fileInfo = New-Object IO.FileInfo $FullPath
        $TestFileName = "$($FileInfo.BaseName).Tests.ps1"
        write-host "Test file: $TestFileName"
        gci -path "./tests" -filter $TestFileName -recurse
    }
    
    $TestFile = Find-AssociatedTestFile -FullPath $e.FullPath

    Invoke-Pester -Script $TestFile.FullName
}

$OnTestFileChanged = {
    param($sender, $e)
    Invoke-Pester -Script $e.FullPath
}

function Start-Watch() {   
    $watchers = @()
    Save-WatchList (New-WatchList) | Out-Null
    Get-WatchList | %{
        $Watchers += New-FileSystemWatcher -TargetFile $_.SourceFile -Action $OnSourceFileChanged
        $Watchers += New-FileSystemWatcher -TargetFile $_.TestFile -Action $OnTestFileChanged
    }
    
    write-host "Monitoring $($Watchers.Count) files..."
    try {
            while ($true) { 
                # infinite loop to wait 
            }    
    } finally {
        write-host "Ending monitoring."
        Get-EventSubscriber | Unregister-Event    
    }    
}

if ($Watch) {
    Start-Watch
} elseif (-not $Debug) {
    $results = Invoke-Pester -Passthru

    Format-Pester $results
}
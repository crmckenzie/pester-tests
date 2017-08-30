function Invoke-DoStuff(
    [Parameter(Mandatory, ValueFromPipeline)] $InputObject
){
    Process {
        return $InputObject
    }
}
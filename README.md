The purpose of this repo is to demonstrate a problem I'm having with Pester in versions 4.0.5 and 4.0.6.

When setting up an auto-watch, calls to `Assert-MockCalled` fail with this error:

>RuntimeException: Module '__DynamicModule_4432ff5d-ed1a-4cea-aa96-ff13c6e0cd2d' is not a Script module.  Detected modules of the following types: ''
at Get-ScriptModule, C:\Program Files\WindowsPowerShell\Modules\Pester\4.0.6\Functions\InModuleScope.ps1: line 128
at Validate-Command, C:\Program Files\WindowsPowerShell\Modules\Pester\4.0.6\Functions\Mock.ps1: line 839
at <ScriptBlock>, C:\Users\{UserName}\src\Modules\pester-tests\tests\Invoke-DoStuff.Tests.ps1: line 24

To see the failure, do the following steps:

1. Clone the repo
2. Navigate to the repo root
3. Execute `./Test.ps1 -Watch`
4. Open and Save /Tests/Invoke-DoStuff.Tests.ps1


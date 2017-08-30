Describe "Invoke-DoStuff" {
    BeforeAll {
        . ("./Functions/Invoke-DoStuff.ps1")
    }

    Context "Mock" {
        It "returns mocked object" {
            Mock Invoke-DoStuff { 7 } -ParameterFilter {
                $InputObject -eq 5
            } 

            $result = Invoke-DoStuff -InputObject 5

            $result | Should Be 7
        }
    }

    Context "Assert-MockCalled" {
        It "Properly asserts mock called" {
            Mock Invoke-DoStuff -Verifiable
            
            Invoke-DoStuff 5

            Assert-MockCalled Invoke-DoStuff 
        }
    }
}
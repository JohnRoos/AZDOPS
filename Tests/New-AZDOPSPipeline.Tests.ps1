Remove-Module AZDOPS -ErrorAction SilentlyContinue
Import-Module $PSScriptRoot\..\Source\AZDOPS

InModuleScope -ModuleName AZDOPS {
    Describe 'New-AZDOPSPipeline tests' {
        Context 'Creating Pipeline' {
            BeforeAll {

                $OrganizationName = 'DummyOrg'
                $Project = 'DummyProject'
                $PipeName = 'DummyPipe1'
                $YamlPath = 'DummyYamlPath/file.yaml'
                $Repository = 'DummyRepo'

                Mock -CommandName GetAZDOPSHeader -ModuleName AZDOPS -MockWith {
                    @{
                        Header       = @{
                            'Authorization' = 'Basic Base64=='
                        }
                        Organization = $OrganizationName
                    }
                } -ParameterFilter { $OrganizationName -eq $OrganizationName }
                Mock -CommandName GetAZDOPSHeader -ModuleName AZDOPS -MockWith {
                    @{
                        Header       = @{
                            'Authorization' = 'Basic Base64=='
                        }
                        Organization = $OrganizationName
                    }
                }
                
                Mock -CommandName InvokeAZDOPSRestMethod -ModuleName AZDOPS -MockWith {
                    return $InvokeSplat
                } -ParameterFilter { $method -eq 'Post' }
                Mock -CommandName Get-AZDOPSRepository -ModuleName AZDOPS -MockWith {
                    throw
                } -ParameterFilter { $Repository -eq 'MissingRepo' }
                Mock -CommandName Get-AZDOPSRepository -ModuleName AZDOPS -MockWith {
                    return @'
                    {
                        "id": "39956c9b-d818-4338-8d99-f5e6004bdb72",
                        "name": "DummyRepo",
                        "url": "https://dev.azure.com/OrganizationName/Project/_apis/git/repositories/39956c9b-d818-4338-8d99-f5e6004bdb72",
                        "project": {
                            "id": "39956c9b-d818-4338-8d99-f5e6004bdb73",
                            "name": "DummyProject",
                            "url": "https://dev.azure.com/OrganizationName/_apis/projects/Project",
                            "state": "wellFormed",
                            "visibility": "private"
                        },
                        "defaultBranch": "refs/heads/main",
                        "remoteUrl": "https://OrganizationName@dev.azure.com/OrganizationName/DummyRepo/_git/DummyRepo",
                        "sshUrl": "git@ssh.dev.azure.com:v3/OrganizationName/DummyRepo/DummyRepo",
                        "webUrl": "https://dev.azure.com/OrganizationName/DummyRepo/_git/DummyRepo",
                        "_links": {
                            "self": {
                                "href": "https://dev.azure.com/OrganizationName/Project/_apis/git/repositories/39956c9b-d818-4338-8d99-f5e6004bdb72"
                            }
                        },
                        "isDisabled": false
                    }
'@ | ConvertFrom-Json
                }
            }
            It 'uses InvokeAZDOPSRestMethod one time' {
                New-AZDOPSPipeline -Organization $OrganizationName -Project $Project -Name $PipeName -YamlPath $YamlPath -Repository $Repository
                Should -Invoke 'InvokeAZDOPSRestMethod' -ModuleName 'AZDOPS' -Exactly -Times 1
            }
            It 'uses Get-AZDOPSRepository one time' {
                New-AZDOPSPipeline -Organization $OrganizationName -Project $Project -Name $PipeName -YamlPath $YamlPath -Repository $Repository
                Should -Invoke 'Get-AZDOPSRepository' -ModuleName 'AZDOPS' -Exactly -Times 1
            }
            It 'returns output after getting pipeline' {
                New-AZDOPSPipeline -Organization $OrganizationName -Project $Project -Name $PipeName -YamlPath $YamlPath -Repository $Repository | Should -BeOfType [pscustomobject] -Because 'InvokeAZDOPSRestMethod should convert the json to pscustomobject'
            }
            It 'should not throw with mandatory parameters' {
                { New-AZDOPSPipeline -Organization $OrganizationName -Project $Project -Name $PipeName -YamlPath $YamlPath -Repository $Repository} | Should -Not -Throw
            }
            It 'should throw if Repository Name is invalid' {
                { New-AZDOPSPipeline -Organization $OrganizationName -Project $Project -Name $PipeName -YamlPath $YamlPath -Repository 'MissingRepo'} | Should -Throw
            }
            It 'should throw if YamlPath dont contain *.yaml' {
                { New-AZDOPSPipeline -Organization $OrganizationName -Project $Project -Name $PipeName -YamlPath 'MissingYamlPath' -Repository $Repository} | Should -Throw
            }
            It 'should not throw without optional parameters' {
                { New-AZDOPSPipeline -Project $Project -Name $PipeName -YamlPath $YamlPath -Repository $Repository} | Should -Not -Throw
            }
        }

        Context 'Parameters' {
            It 'Should have parameter Organization' {
                (Get-Command New-AZDOPSPipeline).Parameters.Keys | Should -Contain 'Organization'
            }
            It 'Organization should not be required' {
                (Get-Command New-AZDOPSPipeline).Parameters['Organization'].Attributes.Mandatory | Should -Be $false
            }
            It 'Should have parameter Project' {
                (Get-Command New-AZDOPSPipeline).Parameters.Keys | Should -Contain 'Project'
            }
            It 'Project should be required' {
                (Get-Command New-AZDOPSPipeline).Parameters['Project'].Attributes.Mandatory | Should -Be $true
            }
            It 'Should have parameter Name' {
                (Get-Command New-AZDOPSPipeline).Parameters.Keys | Should -Contain 'Name'
            }
            It 'Name should be required' {
                (Get-Command New-AZDOPSPipeline).Parameters['Name'].Attributes.Mandatory | Should -Be $true
            }
            It 'Should have parameter YamlPath' {
                (Get-Command New-AZDOPSPipeline).Parameters.Keys | Should -Contain 'YamlPath'
            }
            It 'YamlPath should be required' {
                (Get-Command New-AZDOPSPipeline).Parameters['YamlPath'].Attributes.Mandatory | Should -Be $true
            }
            It 'Should have parameter Repository' {
                (Get-Command New-AZDOPSPipeline).Parameters.Keys | Should -Contain 'Repository'
            }
            It 'Repository should be required' {
                (Get-Command New-AZDOPSPipeline).Parameters['Repository'].Attributes.Mandatory | Should -Be $true
            }
            It 'Should have parameter PipelineGroupFolder' {
                (Get-Command New-AZDOPSPipeline).Parameters.Keys | Should -Contain 'PipelineGroupFolder'
            }
            It 'PipelineGroupFolder should not be required' {
                (Get-Command New-AZDOPSPipeline).Parameters['PipelineGroupFolder'].Attributes.Mandatory | Should -Be $false
            }
        }
    }
} 
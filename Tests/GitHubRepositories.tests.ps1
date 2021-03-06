# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

<#
.Synopsis
   Tests for GitHubRepositories.ps1 module
#>

[CmdletBinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '',
    Justification='Suppress false positives in Pester code blocks')]
param()

# This is common test code setup logic for all Pester test files
$moduleRootPath = Split-Path -Path $PSScriptRoot -Parent
. (Join-Path -Path $moduleRootPath -ChildPath 'Tests\Common.ps1')

try
{
    # Define Script-scoped, readonly, hidden variables.
    @{
        defaultRepoDesc = "This is a description."
        defaultRepoHomePage = "https://www.microsoft.com/"
        defaultRepoTopic = "microsoft"
    }.GetEnumerator() | ForEach-Object {
        Set-Variable -Force -Scope Script -Option ReadOnly -Visibility Private -Name $_.Key -Value $_.Value
    }

    Describe 'GitHubRepositories\New-GitHubRepository' {

        Context -Name 'When creating a repository for the authenticated user' -Fixture {

            Context -Name 'When creating a public repository with default settings' -Fixture {
                BeforeAll -ScriptBlock {
                    $repoName = ([Guid]::NewGuid().Guid)
                    $newGitHubRepositoryParms = @{
                        RepositoryName = $repoName
                    }
                    $repo = New-GitHubRepository @newGitHubRepositoryParms
                }

                It 'Should return an object of the correct type' {
                    $repo | Should -BeOfType PSCustomObject
                }

                It 'Should return the correct properties' {
                    $repo.name | Should -Be $repoName
                    $repo.private | Should -BeFalse
                    $repo.description | Should -BeNullOrEmpty
                    $repo.homepage | Should -BeNullOrEmpty
                    $repo.has_issues | Should -BeTrue
                    $repo.has_projects | Should -BeTrue
                    $repo.has_Wiki | Should -BeTrue
                    $repo.allow_squash_merge | Should -BeTrue
                    $repo.allow_merge_commit | Should -BeTrue
                    $repo.allow_rebase_merge | Should -BeTrue
                    $repo.delete_branch_on_merge | Should -BeFalse
                    $repo.is_template | Should -BeFalse
                }

                AfterAll -ScriptBlock {
                    if ($repo)
                    {
                        Remove-GitHubRepository -Uri $repo.svn_url -Confirm:$false
                    }
                }
            }

            Context -Name 'When creating a private repository with default settings' -Fixture {
                BeforeAll -ScriptBlock {
                    $repoName = ([Guid]::NewGuid().Guid)
                    $newGitHubRepositoryParms = @{
                        RepositoryName = $repoName
                        Private = $true
                    }
                    $repo = New-GitHubRepository @newGitHubRepositoryParms
                }

                It 'Should return an object of the correct type' {
                    $repo | Should -BeOfType PSCustomObject
                }

                It 'Should return the correct properties' {
                    $repo.name | Should -Be $repoName
                    $repo.private | Should -BeTrue
                    $repo.description | Should -BeNullOrEmpty
                    $repo.homepage | Should -BeNullOrEmpty
                    $repo.has_issues | Should -BeTrue
                    $repo.has_projects | Should -BeTrue
                    $repo.has_Wiki | Should -BeTrue
                    $repo.allow_squash_merge | Should -BeTrue
                    $repo.allow_merge_commit | Should -BeTrue
                    $repo.allow_rebase_merge | Should -BeTrue
                    $repo.delete_branch_on_merge | Should -BeFalse
                    $repo.is_template | Should -BeFalse
                }

                AfterAll -ScriptBlock {
                    if ($repo)
                    {
                        Remove-GitHubRepository -Uri $repo.svn_url -Confirm:$false
                    }
                }
            }

            Context -Name 'When creating a repository with all possible settings' -Fixture {
                BeforeAll -ScriptBlock {
                    $repoName = ([Guid]::NewGuid().Guid)
                    $testGitIgnoreTemplate=(Get-GitHubGitIgnore)[0]
                    $testLicenseTemplate=(Get-GitHubLicense)[0].key

                    $newGitHubRepositoryParms = @{
                        RepositoryName = $repoName
                        Description = $defaultRepoDesc
                        HomePage = $defaultRepoHomePage
                        NoIssues = $true
                        NoProjects = $true
                        NoWiki = $true
                        DisallowSquashMerge = $true
                        DisallowMergeCommit = $true
                        DisallowRebaseMerge = $false
                        DeleteBranchOnMerge = $true
                        GitIgnoreTemplate = $testGitIgnoreTemplate
                        LicenseTemplate = $testLicenseTemplate
                        IsTemplate = $true
                    }
                    $repo = New-GitHubRepository @newGitHubRepositoryParms
                }

                It 'Should return an object of the correct type' {
                    $repo | Should -BeOfType PSCustomObject
                }

                It 'Should return the correct properties' {
                    $repo.name | Should -Be $repoName
                    $repo.description | Should -Be $defaultRepoDesc
                    $repo.homepage | Should -Be $defaultRepoHomePage
                    $repo.has_issues | Should -BeFalse
                    $repo.has_projects | Should -BeFalse
                    $repo.has_Wiki | Should -BeFalse
                    $repo.allow_squash_merge | Should -BeFalse
                    $repo.allow_merge_commit | Should -BeFalse
                    $repo.allow_rebase_merge | Should -BeTrue
                    $repo.delete_branch_on_merge | Should -BeTrue
                    $repo.is_template | Should -BeTrue
                }

                It 'Should have created a .gitignore file' {
                    { Get-GitHubContent -Uri $repo.svn_url -Path '.gitignore' } | Should -Not -Throw
                }

                It 'Should have created a LICENSE file' {
                    { Get-GitHubContent -Uri $repo.svn_url -Path 'LICENSE' } | Should -Not -Throw
                }

                AfterAll -ScriptBlock {
                    if ($repo)
                    {
                        Remove-GitHubRepository -Uri $repo.svn_url -Confirm:$false
                    }
                }
            }

            Context -Name 'When creating a repository with alternative Merge settings' -Fixture {
                BeforeAll -ScriptBlock {
                    $repoName = ([Guid]::NewGuid().Guid)
                    $newGitHubRepositoryParms = @{
                        RepositoryName = $repoName
                        DisallowSquashMerge = $true
                        DisallowMergeCommit = $false
                        DisallowRebaseMerge = $true
                    }
                    $repo = New-GitHubRepository @newGitHubRepositoryParms
                }

                It 'Should return an object of the correct type' {
                    $repo | Should -BeOfType PSCustomObject
                }

                It 'Should return the correct properties' {
                    $repo.name | Should -Be $repoName
                    $repo.allow_squash_merge | Should -BeFalse
                    $repo.allow_merge_commit | Should -BeTrue
                    $repo.allow_rebase_merge | Should -BeFalse
                }

                AfterAll -ScriptBlock {
                    if ($repo)
                    {
                        Remove-GitHubRepository -Uri $repo.svn_url -Confirm:$false
                    }
                }
            }

            Context -Name 'When a TeamID is specified' -Fixture {
                BeforeAll -ScriptBlock {
                    $repoName = ([Guid]::NewGuid().Guid)
                    $mockTeamID=1
                    $newGitHubRepositoryParms = @{
                        RepositoryName = $repoName
                        TeamID = $mockTeamID
                    }
                }

                It 'Should throw the correct exception' {
                    $errorMessage = 'TeamId may only be specified when creating a repository under an organization.'
                    { New-GitHubRepository @newGitHubRepositoryParms } | Should -Throw $errorMessage
                }
            }
        }

        Context -Name 'When creating an organization repository' -Fixture {

            Context -Name 'When creating a public repository with default settings' -Fixture {
                BeforeAll -ScriptBlock {
                    $repoName = ([Guid]::NewGuid().Guid)
                    $newGitHubRepositoryParms = @{
                        RepositoryName = $repoName
                        OrganizationName = $script:organizationName
                    }
                    $repo = New-GitHubRepository @newGitHubRepositoryParms
                }

                It 'Should return an object of the correct type' {
                    $repo | Should -BeOfType PSCustomObject
                }

                It 'Should return the correct properties' {
                    $repo.name | Should -Be $repoName
                    $repo.private | Should -BeFalse
                    $repo.organization.login | Should -Be $script:organizationName
                    $repo.description | Should -BeNullOrEmpty
                    $repo.homepage | Should -BeNullOrEmpty
                    $repo.has_issues | Should -BeTrue
                    $repo.has_projects | Should -BeTrue
                    $repo.has_Wiki | Should -BeTrue
                    $repo.allow_squash_merge | Should -BeTrue
                    $repo.allow_merge_commit | Should -BeTrue
                    $repo.allow_rebase_merge | Should -BeTrue
                    $repo.delete_branch_on_merge | Should -BeFalse
                    $repo.is_template | Should -BeFalse
                }

                AfterAll -ScriptBlock {
                    if ($repo)
                    {
                        Remove-GitHubRepository -Uri $repo.svn_url -Confirm:$false
                    }
                }
            }

            Context -Name 'When creating a private repository with default settings' -Fixture {
                BeforeAll -ScriptBlock {
                    $repoName = ([Guid]::NewGuid().Guid)
                    $newGitHubRepositoryParms = @{
                        RepositoryName = $repoName
                        Private = $true
                        OrganizationName = $script:organizationName
                    }
                    $repo = New-GitHubRepository @newGitHubRepositoryParms
                }

                It 'Should return an object of the correct type' {
                    $repo | Should -BeOfType PSCustomObject
                }

                It 'Should return the correct properties' {
                    $repo.name | Should -Be $repoName
                    $repo.private | Should -BeTrue
                    $repo.organization.login | Should -Be $script:organizationName
                    $repo.description | Should -BeNullOrEmpty
                    $repo.homepage | Should -BeNullOrEmpty
                    $repo.has_issues | Should -BeTrue
                    $repo.has_projects | Should -BeTrue
                    $repo.has_Wiki | Should -BeTrue
                    $repo.allow_squash_merge | Should -BeTrue
                    $repo.allow_merge_commit | Should -BeTrue
                    $repo.allow_rebase_merge | Should -BeTrue
                    $repo.delete_branch_on_merge | Should -BeFalse
                    $repo.is_template | Should -BeFalse
                }

                AfterAll -ScriptBlock {
                    if ($repo)
                    {
                        Remove-GitHubRepository -Uri $repo.svn_url -Confirm:$false
                    }
                }
            }
        }
    }

    Describe 'Getting repositories' {
        Context 'For authenticated user' {
            BeforeAll -Scriptblock {
                $publicRepo = New-GitHubRepository -RepositoryName ([Guid]::NewGuid().Guid) -AutoInit
                $privateRepo = New-GitHubRepository -RepositoryName ([Guid]::NewGuid().Guid) -AutoInit -Private
            }

            It "Should have the public repo" {
                $publicRepos = @(Get-GitHubRepository -Visibility Public)
                $privateRepos = @(Get-GitHubRepository -Visibility Private)
                $publicRepo.name | Should -BeIn $publicRepos.name
                $publicRepo.name | Should -Not -BeIn $privateRepos.name
            }

            It "Should have the private repo" {
                $publicRepos = @(Get-GitHubRepository -Visibility Public)
                $privateRepos = @(Get-GitHubRepository -Visibility Private)
                $privateRepo.name | Should -BeIn $privateRepos.name
                $privateRepo.name | Should -Not -BeIn $publicRepos.name
            }

            It 'Should not permit bad combination of parameters' {
                { Get-GitHubRepository -Type All -Visibility All } | Should -Throw
                { Get-GitHubRepository -Type All -Affiliation Owner } | Should -Throw
            }

            AfterAll -ScriptBlock {
                Remove-GitHubRepository -Uri $publicRepo.svn_url -Confirm:$false
                Remove-GitHubRepository -Uri $privateRepo.svn_url -Confirm:$false
            }
        }

        Context 'For any user' {
            It "Should have results for The Octocat" {
                $repos = @(Get-GitHubRepository -OwnerName 'octocat' -Type Public)
                $repos.Count | Should -BeGreaterThan 0
                $repos[0].owner.login | Should -Be 'octocat'
            }
        }

        Context 'For organizations' {
            BeforeAll -Scriptblock {
                $repo = New-GitHubRepository -OrganizationName $script:organizationName -RepositoryName ([Guid]::NewGuid().Guid) -AutoInit
            }

            It "Should have results for the organization" {
                $repos = @(Get-GitHubRepository -OrganizationName $script:organizationName -Type All)
                $repo.name | Should -BeIn $repos.name
            }

            AfterAll -ScriptBlock {
                Remove-GitHubRepository -Uri $repo.svn_url -Confirm:$false
            }
        }

        Context 'For public repos' {
            # Skipping these tests for now, as it would run for a _very_ long time.
            # No obviously good way to verify this.
        }

        Context 'For a specific repo' {
            BeforeAll -ScriptBlock {
                $repo = New-GitHubRepository -RepositoryName ([Guid]::NewGuid().Guid) -AutoInit
            }

            It "Should be a single result using Uri ParameterSet" {
                $result = Get-GitHubRepository -Uri $repo.svn_url
                $result | Should -BeOfType PSCustomObject
            }

            It "Should be a single result using Elements ParameterSet" {
                $result = Get-GitHubRepository -OwnerName $repo.owner.login -RepositoryName $repo.name
                $result | Should -BeOfType PSCustomObject
            }

            It 'Should not permit additional parameters' {
                { Get-GitHubRepository -OwnerName $repo.owner.login -RepositoryName $repo.name -Type All } | Should -Throw
            }

            It 'Should require both OwnerName and RepositoryName' {
                { Get-GitHubRepository -RepositoryName $repo.name } | Should -Throw
                { Get-GitHubRepository -Uri "https://github.com/$script:ownerName" } | Should -Throw
            }

            AfterAll -ScriptBlock {
                Remove-GitHubRepository -Uri $repo.svn_url -Confirm:$false
            }
        }
    }

    Describe 'Deleting repositories' {

        Context -Name 'For deleting a repository' -Fixture {
            BeforeEach -ScriptBlock {
                $repo = New-GitHubRepository -RepositoryName ([Guid]::NewGuid().Guid) -Description $defaultRepoDesc -AutoInit
            }

            It 'Should get no content using -Confirm:$false' {
                Remove-GitHubRepository -OwnerName $repo.owner.login -RepositoryName $repo.name -Confirm:$false
                { Get-GitHubRepository -OwnerName $repo.owner.login -RepositoryName $repo.name } | Should -Throw
            }

            It 'Should get no content using -Force' {
                Remove-GitHubRepository -OwnerName $repo.owner.login -RepositoryName $repo.name -Force
                { Get-GitHubRepository -OwnerName $repo.owner.login -RepositoryName $repo.name } | Should -Throw
            }
        }
    }

    Describe 'Renaming repositories' {

        Context -Name 'For renaming a repository' -Fixture {
            BeforeEach -Scriptblock {
                $repo = New-GitHubRepository -RepositoryName ([Guid]::NewGuid().Guid) -AutoInit
                $suffixToAddToRepo = "_renamed"
                $newRepoName = "$($repo.name)$suffixToAddToRepo"
            }

            It "Should have the expected new repository name - by URI" {
                $renamedRepo = $repo | Rename-GitHubRepository -NewName $newRepoName -Force
                $renamedRepo.name | Should -Be $newRepoName
            }

            It "Should have the expected new repository name - by Elements" {
                $renamedRepo = Rename-GitHubRepository -OwnerName $repo.owner.login -RepositoryName $repo.name -NewName $newRepoName -Confirm:$false
                $renamedRepo.name | Should -Be $newRepoName
            }

            AfterEach -Scriptblock {
                Remove-GitHubRepository -Uri "$($repo.svn_url)$suffixToAddToRepo" -Confirm:$false
            }
        }
    }

    Describe 'GitHubRepositories\Update-GitHubRepository' {

        Context -Name 'When updating a public repository' -Fixture {
            BeforeAll -ScriptBlock {
                $repoName = ([Guid]::NewGuid().Guid)
                $repo = New-GitHubRepository -RepositoryName $repoName
            }

            Context -Name 'When updating a repository with all possible settings' {
                BeforeAll -ScriptBlock {
                    $updateGithubRepositoryParms = @{
                        OwnerName = $repo.owner.login
                        RepositoryName = $repoName
                        Private = $true
                        Description = $defaultRepoDesc
                        HomePage = $defaultRepoHomePage
                        NoIssues = $true
                        NoProjects = $true
                        NoWiki = $true
                        DisallowSquashMerge = $true
                        DisallowMergeCommit = $true
                        DisallowRebaseMerge = $false
                        DeleteBranchOnMerge = $true
                        IsTemplate = $true
                    }
                    $updatedRepo = Update-GitHubRepository @updateGithubRepositoryParms
                }

                It 'Should return an object of the correct type' {
                    $updatedRepo | Should -BeOfType PSCustomObject
                }

                It 'Should return the correct properties' {
                    $updatedRepo.name | Should -Be $repoName
                    $updatedRepo.private | Should -BeTrue
                    $updatedRepo.description | Should -Be $defaultRepoDesc
                    $updatedRepo.homepage | Should -Be $defaultRepoHomePage
                    $updatedRepo.has_issues | Should -BeFalse
                    $updatedRepo.has_projects | Should -BeFalse
                    $updatedRepo.has_Wiki | Should -BeFalse
                    $updatedRepo.allow_squash_merge | Should -BeFalse
                    $updatedRepo.allow_merge_commit | Should -BeFalse
                    $updatedRepo.allow_rebase_merge | Should -BeTrue
                    $updatedRepo.delete_branch_on_merge | Should -BeTrue
                    $updatedRepo.is_template | Should -BeTrue
                }
            }

            Context -Name 'When updating a repository with alternative Merge settings' {
                BeforeAll -ScriptBlock {
                    $updateGithubRepositoryParms = @{
                        OwnerName = $repo.owner.login
                        RepositoryName = $repoName
                        DisallowSquashMerge = $true
                        DisallowMergeCommit = $false
                        DisallowRebaseMerge = $true
                    }
                    $updatedRepo = Update-GitHubRepository @updateGithubRepositoryParms
                }

                It 'Should return an object of the correct type' {
                    $updatedRepo | Should -BeOfType PSCustomObject
                }

                It 'Should return the correct properties' {
                    $updatedRepo.name | Should -Be $repoName
                    $updatedRepo.allow_squash_merge | Should -BeFalse
                    $updatedRepo.allow_merge_commit | Should -BeTrue
                    $updatedRepo.allow_rebase_merge | Should -BeFalse
                }
            }

            Context -Name 'When updating a repository with the Archive setting' {
                BeforeAll -ScriptBlock {
                    $updateGithubRepositoryParms = @{
                        OwnerName = $repo.owner.login
                        RepositoryName = $repoName
                        Archived = $true
                    }
                    $updatedRepo = Update-GitHubRepository @updateGithubRepositoryParms
                }

                It 'Should return an object of the correct type' {
                    $updatedRepo | Should -BeOfType PSCustomObject
                }

                It 'Should return the correct properties' {
                    $updatedRepo.name | Should -Be $repoName
                    $updatedRepo.archived | Should -BeTrue
                }
            }

            AfterAll -ScriptBlock {
                if ($repo)
                {
                    Remove-GitHubRepository -Uri $repo.svn_url -Confirm:$false
                }
            }
        }

        Context -Name 'When updating a private repository' -Fixture {
            BeforeAll -ScriptBlock {
                $repoName = ([Guid]::NewGuid().Guid)
                $repo = New-GitHubRepository -RepositoryName $repoName -Private

                $updateGithubRepositoryParms = @{
                    OwnerName = $repo.owner.login
                    RepositoryName = $repoName
                    Private = $false
                }
                $updatedRepo = Update-GitHubRepository @updateGithubRepositoryParms
            }

            It 'Should return an object of the correct type' {
                $updatedRepo | Should -BeOfType PSCustomObject
            }

            It 'Should return the correct properties' {
                $updatedRepo.name | Should -Be $repoName
                $updatedRepo.private | Should -BeFalse
            }

            AfterAll -ScriptBlock {
                if ($repo)
                {
                    Remove-GitHubRepository -Uri $repo.svn_url -Confirm:$false
                }
            }
        }
    }

    Describe 'Get/set repository topic' {

        Context -Name 'For creating and getting a repository topic' -Fixture {
            BeforeAll -ScriptBlock {
                $repo = New-GitHubRepository -RepositoryName ([Guid]::NewGuid().Guid) -AutoInit
            }

            It 'Should have the expected topic' {
                Set-GitHubRepositoryTopic -OwnerName $repo.owner.login -RepositoryName $repo.name -Name $defaultRepoTopic
                $topic = Get-GitHubRepositoryTopic -OwnerName $repo.owner.login -RepositoryName $repo.name
                $topic.names | Should -Be $defaultRepoTopic
            }

            It 'Should have no topics' {
                Set-GitHubRepositoryTopic -OwnerName $repo.owner.login -RepositoryName $repo.name -Clear
                $topic = Get-GitHubRepositoryTopic -OwnerName $repo.owner.login -RepositoryName $repo.name
                $topic.names | Should -BeNullOrEmpty
            }

            AfterAll -ScriptBlock {
                Remove-GitHubRepository -Uri $repo.svn_url -Confirm:$false
            }
        }
    }

    Describe 'Get repository languages' {

        Context -Name 'For getting repository languages' -Fixture {
            BeforeAll -ScriptBlock {
                $repo = New-GitHubRepository -RepositoryName ([Guid]::NewGuid().Guid) -AutoInit
            }

            It 'Should be empty' {
                $languages = Get-GitHubRepositoryLanguage -OwnerName $repo.owner.login -RepositoryName $repo.name
                $languages | Should -BeNullOrEmpty
            }

            It 'Should contain PowerShell' {
                $languages = Get-GitHubRepositoryLanguage -OwnerName "microsoft" -RepositoryName "PowerShellForGitHub"
                $languages.PowerShell | Should -Not -BeNullOrEmpty
            }

            AfterAll -ScriptBlock {
                Remove-GitHubRepository -Uri $repo.svn_url -Force
            }
        }
    }

    Describe 'Get repository tags' {

        Context -Name 'For getting repository tags' -Fixture {
            BeforeAll -ScriptBlock {
                $repo = New-GitHubRepository -RepositoryName ([Guid]::NewGuid().Guid) -AutoInit
            }

            It 'Should be empty' {
                $tags = Get-GitHubRepositoryTag -OwnerName $repo.owner.login -RepositoryName $repo.name
                $tags | Should -BeNullOrEmpty
            }

            AfterAll -ScriptBlock {
                Remove-GitHubRepository -Uri $repo.svn_url -Confirm:$false
            }
        }
    }
}
finally
{
    if (Test-Path -Path $script:originalConfigFile -PathType Leaf)
    {
        # Restore the user's configuration to its pre-test state
        Restore-GitHubConfiguration -Path $script:originalConfigFile
        $script:originalConfigFile = $null
    }
}
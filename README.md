# PowerShellForGitHub PowerShell Module

[![[GitHub version]](https://badge.fury.io/gh/microsoft%2FPowerShellForGitHub.svg)](https://github.com/microsoft/PowerShellForGitHub/releases)
[![powershellgallery](https://img.shields.io/powershellgallery/v/PowerShellForGitHub)](https://www.powershellgallery.com/packages/PowerShellForGitHub)
[![downloads](https://img.shields.io/powershellgallery/dt/PowerShellForGitHub.svg?label=downloads)](https://www.powershellgallery.com/packages/PowerShellForGitHub)
[![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/microsoft/PowerShellForGitHub)](https://github.com/microsoft/PowerShellForGitHub)
[![downloads](https://img.shields.io/badge/license-MIT-green)](https://github.com/HowardWolosky/PowerShellForGitHub/blob/master/LICENSE)
[![CII Best Practices](https://bestpractices.coreinfrastructure.org/projects/3990/badge)](https://bestpractices.coreinfrastructure.org/projects/3990)
[![tweet](https://img.shields.io/twitter/url?url=https%3A%2F%2Ftwitter.com%2FQuackFu)](https://twitter.com/intent/tweet?text=%23PowerShellForGitHub%20%40QuackFu%20&original_referer=https://github.com/microsoft/PowerShellForGitHub)
<br />
[![Build status](https://dev.azure.com/ms/PowerShellForGitHub/_apis/build/status/PowerShellForGitHub-CI?branchName=master)](https://dev.azure.com/ms/PowerShellForGitHub/_build?definitionId=109&_a=summary&repositoryFilter=63&branchFilter=2197)
[![Azure DevOps tests](https://img.shields.io/azure-devops/tests/ms/PowerShellForGitHub/109/master)](https://dev.azure.com/ms/PowerShellForGitHub/_build?definitionId=109&_a=summary&repositoryFilter=63&branchFilter=2197)
[![Azure DevOps coverage](https://img.shields.io/azure-devops/coverage/ms/PowerShellForGitHub/109/master)](https://dev.azure.com/ms/PowerShellForGitHub/_build?definitionId=109&_a=summary&repositoryFilter=63&branchFilter=2197)
<br />
[![Help Wanted Issues](https://img.shields.io/github/issues/microsoft/PowerShellForGitHub/help%20wanted)](https://github.com/microsoft/PowerShellForGitHub/issues?q=is%3Aissue+is%3Aopen+label%3A%22help+wanted%22)
[![GitHub last commit](https://img.shields.io/github/last-commit/microsoft/PowerShellForGitHub)](https://github.com/HowardWolosky/PowerShellForGitHub/commits/master)

#### Table of Contents

*   [Overview](#overview)
*   [Current API Support](#current-api-support)
*   [Installation](#installation)
*   [Configuration](#configuration)
*   [Usage](#usage)
*   [Logging](#logging)
*   [Developing and Contributing](#developing-and-contributing)
*   [Legal and Licensing](#legal-and-licensing)
*   [Governance](#governance)
*   [Code of Conduct](#code-of-conduct)
*   [Reporting Security Issues](#reporting-security-issues)
*   [Privacy Policy](#privacy-policy)

----------

## Overview

This is a [PowerShell](https://microsoft.com/powershell) [module](https://technet.microsoft.com/en-us/library/dd901839.aspx)
that provides command-line interaction and automation for the [GitHub v3 API](https://developer.github.com/v3/).

----------

## Current API Support

At present, this module can:
 * Query issues
 * Query [pull requests](https://developer.github.com/v3/pulls/)
 * Query [collaborators](https://developer.github.com/v3/repos/collaborators/)
 * Query [contributors](https://developer.github.com/v3/repos/statistics/)
 * Query [organizations](https://developer.github.com/v3/orgs/)
 * Query, create, update and remove [Issues](https://developer.github.com/v3/issues/) and
   all of their related properties (assignees, comments, events, labels, milestones, timeline)
 * Query, create, update and remove [Labels](https://developer.github.com/v3/issues/labels/)
 * Query, check, add and remove [Assignees](https://developer.github.com/v3/issues/assignees/)
 * Query, create, update and remove [Repositories](https://developer.github.com/v3/repos/)
 * Query and update [Users](https://developer.github.com/v3/users/)

Development is ongoing, with the goal to add broad support for the entire API set.

For a comprehensive look at what work is remaining to be API Complete, refer to [Issue #70](https://github.com/PowerShell/PowerShellForGitHub/issues/70).

Review [examples](USAGE.md#examples) to see how the module can be used to accomplish some of these tasks.

----------

## Installation

You can get latest release of the PowerShellForGitHub on the [PowerShell Gallery](https://www.powershellgallery.com/packages/PowerShellForGitHub)

```PowerShell
Install-Module -Name PowerShellForGitHub
```

----------

## Configuration

To avoid severe API rate limiting by GitHub, you should configure the module with your own personal
access token.

1) Create a new API token by going to https://github.com/settings/tokens/new (provide a description
   and check any appropriate scopes)
2) Call `Set-GitHubAuthentication`, enter anything as the username (the username is ignored but
   required by the dialog that pops up), and paste in the API token as the password.  That will be
   securely cached to disk and will persist across all future PowerShell sessions.
If you ever wish to clear it in the future, just call `Clear-GitHubAuthentication`).

> For automated scenarios (like GithHub Actions) where you are dynamically getting the access token
> needed for authentication, refer to `Example 2` in `Get-Help Set-GitHubAuthentication -Examples`
> for how to configure in a promptless fashion.
>
> Alternatively, you _could_ configure PowerShell itself to always pass in a plain-text access token
> to any command (by setting `$PSDefaultParameterValues["*-GitHub*:AccessToken"] = "<access token>"`),
> although keep in mind that this is insecure (any other process could access this plain-text value).

A number of additional configuration options exist with this module, and they can be configured
for just the current session or to persist across all future sessions with `Set-GitHubConfiguration`.
For a full explanation of all possible configurations, run the following:

 ```powershell
Get-Help Set-GitHubConfiguration -ShowWindow
```

For example, if you tend to work on the same repository, you can save yourself a lot of typing
by configuring the default OwnerName and/or RepositoryName that you work with.  You can always
override these values by explicitly providing a value for the parameter in an individual command,
but for the common scenario, you'd have less typing to do.

 ```powershell
Set-GitHubConfiguration -DefaultOwnerName PowerShell
Set-GitHubConfiguration -DefaultRepositoryName PowerShellForGitHub
```

> Be warned that there are some commands where you may want to only ever supply the OwnerName
> (like if you're calling `Get-GitHubRepository` and want to see all the repositories owned
> by a particular user, as opposed to getting a single, specific repository).  In cases like that,
> you'll need to explicitly pass in `$null` as the relevant parameter value as a temporary override
> for your default if you've set a default for one (or both) of these values.

There are more great configuration options available.  Just review the help for that command for
the most up-to-date list!

### GitHub Enterprise

To set the configuration to use a GitHub Enterprise server instead of GitHub.com, simply supply
the `ApiHostName` parameter with the hostname of your GitHub Enterprise server.

 ```powershell
Set-GitHubConfiguration -ApiHostName "github.contoso.com"
```

----------

## Usage

Example command:

```powershell
$issues = Get-GitHubIssue -Uri 'https://github.com/PowerShell/PowerShellForGitHub'
```

For more example commands, please refer to [USAGE](USAGE.md#examples).

----------

## Developing and Contributing

Please see the [Contribution Guide](CONTRIBUTING.md) for information on how to develop and
contribute.

If you have any problems, please consult [GitHub Issues](https://github.com/PowerShell/PowerShellForGitHub/issues)
to see if has already been discussed.

If you do not see your problem captured, please file [feedback](CONTRIBUTING.md#feedback).

----------

## Legal and Licensing

PowerShellForGitHub is licensed under the [MIT license](LICENSE).

----------

## Governance

Governance policy for this project is described [here](GOVERNANCE.md).

----------

## Code of Conduct

For more info, see [CODE_OF_CONDUCT](CODE_OF_CONDUCT.md)

----------

## Reporting Security Issues

Please refer to [SECURITY.md](./SECURITY.md).

----------

## Privacy Policy

For more information, refer to Microsoft's [Privacy Policy](https://go.microsoft.com/fwlink/?LinkID=521839).

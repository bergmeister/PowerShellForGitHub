# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

function Get-GitHubOrganizationMember
{
<#
    .SYNOPSIS
        Retrieve list of members within an organization.

    .DESCRIPTION
        Retrieve list of members within an organization.

        The Git repo for this module can be found here: http://aka.ms/PowerShellForGitHub

    .PARAMETER OrganizationName
        The name of the organization

    .PARAMETER AccessToken
        If provided, this will be used as the AccessToken for authentication with the
        REST Api.  Otherwise, will attempt to use the configured value or will run unauthenticated.

    .PARAMETER NoStatus
        If this switch is specified, long-running commands will run on the main thread
        with no commandline status update.  When not specified, those commands run in
        the background, enabling the command prompt to provide status information.
        If not supplied here, the DefaultNoStatus configuration property value will be used.

    .OUTPUTS
        [PSCustomObject[]] List of members within the organization.

    .EXAMPLE
        Get-GitHubOrganizationMember -OrganizationName PowerShell
#>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSShouldProcess", "", Justification="Methods called within here make use of PSShouldProcess, and the switch is passed on to them inherently.")]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSReviewUnusedParameter", "", Justification="One or more parameters (like NoStatus) are only referenced by helper methods which get access to it from the stack via Get-Variable -Scope 1.")]
    [CmdletBinding(SupportsShouldProcess)]
    param
    (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String] $OrganizationName,

        [string] $AccessToken,

        [switch] $NoStatus
    )

    Write-InvocationLog

    $telemetryProperties = @{
        'OrganizationName' = (Get-PiiSafeString -PlainText $OrganizationName)
    }

    $params = @{
        'UriFragment' = "orgs/$OrganizationName/members"
        'Description' =  "Getting members for $OrganizationName"
        'AccessToken' = $AccessToken
        'TelemetryEventName' = $MyInvocation.MyCommand.Name
        'TelemetryProperties' = $telemetryProperties
        'NoStatus' = (Resolve-ParameterWithDefaultConfigurationValue -Name NoStatus -ConfigValueName DefaultNoStatus)
    }

    return Invoke-GHRestMethodMultipleResult @params
}

function Test-GitHubOrganizationMember
{
<#
    .SYNOPSIS
        Check to see if a user is a member of an organization.

    .DESCRIPTION
        Check to see if a user is a member of an organization.

        The Git repo for this module can be found here: http://aka.ms/PowerShellForGitHub

    .PARAMETER OrganizationName
        The name of the organization.

    .PARAMETER UserName
        The name of the user being inquired about.

    .PARAMETER AccessToken
        If provided, this will be used as the AccessToken for authentication with the
        REST Api.  Otherwise, will attempt to use the configured value or will run unauthenticated.

    .PARAMETER NoStatus
        If this switch is specified, long-running commands will run on the main thread
        with no commandline status update.  When not specified, those commands run in
        the background, enabling the command prompt to provide status information.
        If not supplied here, the DefaultNoStatus configuration property value will be used.

    .OUTPUTS
        [Bool]

    .EXAMPLE
        Test-GitHubOrganizationMember -OrganizationName PowerShell -UserName Octocat
#>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSShouldProcess", "", Justification="Methods called within here make use of PSShouldProcess, and the switch is passed on to them inherently.")]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSReviewUnusedParameter", "", Justification="One or more parameters (like NoStatus) are only referenced by helper methods which get access to it from the stack via Get-Variable -Scope 1.")]
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([bool])]
    param
    (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String] $OrganizationName,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String] $UserName,

        [string] $AccessToken,

        [switch] $NoStatus
    )

    Write-InvocationLog

    $telemetryProperties = @{
        'OrganizationName' = (Get-PiiSafeString -PlainText $OrganizationName)
    }

    $params = @{
        'UriFragment' = "orgs/$OrganizationName/members/$UserName"
        'Description' =  "Checking if $UserName is a member of $OrganizationName"
        'Method' = 'Get'
        'ExtendedResult' = $true
        'AccessToken' = $AccessToken
        'TelemetryEventName' = $MyInvocation.MyCommand.Name
        'TelemetryProperties' = $telemetryProperties
        'NoStatus' = (Resolve-ParameterWithDefaultConfigurationValue -Name NoStatus -ConfigValueName DefaultNoStatus)
    }

    try
    {
        $result = Invoke-GHRestMethod @params
        return ($result.statusCode -eq 204)
    }
    catch
    {
        return $false
    }
}

<#

    .SYNOPSIS
        This command migrates a project to version 0.3 of the Q# language
        and the Quantum Development Kit.

    .NOTES
        This command replaces the existing Q# source code with new
        source code formatted using 0.3 syntax. The original source code
        is stored in a backup folder under the obj/qsharp folder.

    .PARAMETER Version
        Version of the Quantum Development Kit package to migrate the
        project to.

    .PARAMETER Project
        Path to a C# project file that contains Q# code to be migrated.
        If not set, defaults to migrating C# projects in the current
        directory.

    .PARAMETER Force
        If set, the project will be migrated even if it does not build
        in its current state. This is useful, for instance, when migrating
        a 0.2 project that depends on a project that has already been
        migrated.

    .EXAMPLE
        PS> ./qdk-migrate.ps1

        Migrates a C# project in the current directory to use
        a 0.3-compatible version of the Quantum Development Kit.

    .EXAMPLE
        PS> ./qdk-migrate.ps1 -Force ./src/project-name/ProjectName.csproj

        Migrates the C# project located at `./src/project-name/ProjectName.csproj`
        to a 0.3-compatible version of the Quantum Development Kit,
        even if it does not currently build.

    .INPUTS
        None

    .OUTPUTS
        None

    .LINK
        https://review.docs.microsoft.com/en-us/quantum/relnotes/0.3-migration

#>

[CmdletBinding()]
param(
    [switch] $Force,

    [Parameter(Position=1)]
    $Project = (Get-ChildItem *.csproj),

    [Parameter(Position=2)]
    [string]
    $Version = "0.3.1810.2508-preview"
)

Write-Host ""
Write-Host "This script will migrate project '$Project' to QDK v0.3."
Write-Host ""
Write-Host "All the q# files will be migrated to the new syntax,"
Write-Host "and will be reformated in the process (no information"
Write-Host "will be lost and the original version can be found at "
Write-Host "obj\qsharp\.backup)."
Write-Host ""
Read-Host "Press ENTER to continue..."


# Make sure we start with a working project:
dotnet build $Project
if ($LastExitCode -ne 0) {
    if ($Force) {
        Write-Warning "Project $Project is failing to build. Continuing migration due to '-Force'."
    } else {
        Write-Host ""
        Write-Error "Project $Project migration failed."
        Write-Host "The project is not building correctly as it-is."
        Write-Host "Please fix your project, then try again to migrate" -foreground Yellow
        Write-Host "or specify '-force' to skip this check." -foreground Yellow
        Write-Host ""
        exit 1
    }
}
dotnet clean $Project 

# Install the latest templates:
dotnet new --install "Microsoft.Quantum.ProjectTemplates.$Version.nupkg"

# Update the project to the latest nugets:
function update-package {
    Param($pkg)

    if (Select-String -pattern $pkg -path $Project -quiet) 
    {
        dotnet add $Project package $pkg -v $Version
    }
}

update-package "Microsoft.Quantum.Development.Kit"
update-package "Microsoft.Quantum.Canon"
update-package "Microsoft.Quantum.Xunit"

# Migrate to new syntax:
dotnet restore $Project 
dotnet msbuild $Project /t:qsharpFormat

# Try to build once upgraded:
dotnet build $Project 
if ($LastExitCode -ne 0) {
    Write-Host ""
    Write-Warning "Your project is now migrated to use 0.3 syntax,"
    Write-Warning "however, it is failing to compile."
    Write-Host ""
    Write-Host "A typical reason for this is that the new q# compiler"
    Write-Host "requires user-defined types to be explicitly unwrapped when"
    Write-Host "trying to use them as their base type. For more information: "
    Write-Host "TODO:URL"
    Write-Host ""
    Write-Host "Please correct these build errors to complete your migration."
    exit 1
} else {
    Write-Host ""
    Write-Host "All set. Your project has now been migrated to 0.3 syntax."
    exit 0
}

# SIG # Begin signature block
# MIIkTAYJKoZIhvcNAQcCoIIkPTCCJDkCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCBdHPn8v3m2tLbf
# 8C1tzvc4MBsdsgzKOG+Mu9WNsqcuXqCCDYEwggX/MIID56ADAgECAhMzAAABA14l
# HJkfox64AAAAAAEDMA0GCSqGSIb3DQEBCwUAMH4xCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNpZ25p
# bmcgUENBIDIwMTEwHhcNMTgwNzEyMjAwODQ4WhcNMTkwNzI2MjAwODQ4WjB0MQsw
# CQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
# ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMR4wHAYDVQQDExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIB
# AQDRlHY25oarNv5p+UZ8i4hQy5Bwf7BVqSQdfjnnBZ8PrHuXss5zCvvUmyRcFrU5
# 3Rt+M2wR/Dsm85iqXVNrqsPsE7jS789Xf8xly69NLjKxVitONAeJ/mkhvT5E+94S
# nYW/fHaGfXKxdpth5opkTEbOttU6jHeTd2chnLZaBl5HhvU80QnKDT3NsumhUHjR
# hIjiATwi/K+WCMxdmcDt66VamJL1yEBOanOv3uN0etNfRpe84mcod5mswQ4xFo8A
# DwH+S15UD8rEZT8K46NG2/YsAzoZvmgFFpzmfzS/p4eNZTkmyWPU78XdvSX+/Sj0
# NIZ5rCrVXzCRO+QUauuxygQjAgMBAAGjggF+MIIBejAfBgNVHSUEGDAWBgorBgEE
# AYI3TAgBBggrBgEFBQcDAzAdBgNVHQ4EFgQUR77Ay+GmP/1l1jjyA123r3f3QP8w
# UAYDVR0RBEkwR6RFMEMxKTAnBgNVBAsTIE1pY3Jvc29mdCBPcGVyYXRpb25zIFB1
# ZXJ0byBSaWNvMRYwFAYDVQQFEw0yMzAwMTIrNDM3OTY1MB8GA1UdIwQYMBaAFEhu
# ZOVQBdOCqhc3NyK1bajKdQKVMFQGA1UdHwRNMEswSaBHoEWGQ2h0dHA6Ly93d3cu
# bWljcm9zb2Z0LmNvbS9wa2lvcHMvY3JsL01pY0NvZFNpZ1BDQTIwMTFfMjAxMS0w
# Ny0wOC5jcmwwYQYIKwYBBQUHAQEEVTBTMFEGCCsGAQUFBzAChkVodHRwOi8vd3d3
# Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2NlcnRzL01pY0NvZFNpZ1BDQTIwMTFfMjAx
# MS0wNy0wOC5jcnQwDAYDVR0TAQH/BAIwADANBgkqhkiG9w0BAQsFAAOCAgEAn/XJ
# Uw0/DSbsokTYDdGfY5YGSz8eXMUzo6TDbK8fwAG662XsnjMQD6esW9S9kGEX5zHn
# wya0rPUn00iThoj+EjWRZCLRay07qCwVlCnSN5bmNf8MzsgGFhaeJLHiOfluDnjY
# DBu2KWAndjQkm925l3XLATutghIWIoCJFYS7mFAgsBcmhkmvzn1FFUM0ls+BXBgs
# 1JPyZ6vic8g9o838Mh5gHOmwGzD7LLsHLpaEk0UoVFzNlv2g24HYtjDKQ7HzSMCy
# RhxdXnYqWJ/U7vL0+khMtWGLsIxB6aq4nZD0/2pCD7k+6Q7slPyNgLt44yOneFuy
# bR/5WcF9ttE5yXnggxxgCto9sNHtNr9FB+kbNm7lPTsFA6fUpyUSj+Z2oxOzRVpD
# MYLa2ISuubAfdfX2HX1RETcn6LU1hHH3V6qu+olxyZjSnlpkdr6Mw30VapHxFPTy
# 2TUxuNty+rR1yIibar+YRcdmstf/zpKQdeTr5obSyBvbJ8BblW9Jb1hdaSreU0v4
# 6Mp79mwV+QMZDxGFqk+av6pX3WDG9XEg9FGomsrp0es0Rz11+iLsVT9qGTlrEOla
# P470I3gwsvKmOMs1jaqYWSRAuDpnpAdfoP7YO0kT+wzh7Qttg1DO8H8+4NkI6Iwh
# SkHC3uuOW+4Dwx1ubuZUNWZncnwa6lL2IsRyP64wggd6MIIFYqADAgECAgphDpDS
# AAAAAAADMA0GCSqGSIb3DQEBCwUAMIGIMQswCQYDVQQGEwJVUzETMBEGA1UECBMK
# V2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0
# IENvcnBvcmF0aW9uMTIwMAYDVQQDEylNaWNyb3NvZnQgUm9vdCBDZXJ0aWZpY2F0
# ZSBBdXRob3JpdHkgMjAxMTAeFw0xMTA3MDgyMDU5MDlaFw0yNjA3MDgyMTA5MDla
# MH4xCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdS
# ZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMT
# H01pY3Jvc29mdCBDb2RlIFNpZ25pbmcgUENBIDIwMTEwggIiMA0GCSqGSIb3DQEB
# AQUAA4ICDwAwggIKAoICAQCr8PpyEBwurdhuqoIQTTS68rZYIZ9CGypr6VpQqrgG
# OBoESbp/wwwe3TdrxhLYC/A4wpkGsMg51QEUMULTiQ15ZId+lGAkbK+eSZzpaF7S
# 35tTsgosw6/ZqSuuegmv15ZZymAaBelmdugyUiYSL+erCFDPs0S3XdjELgN1q2jz
# y23zOlyhFvRGuuA4ZKxuZDV4pqBjDy3TQJP4494HDdVceaVJKecNvqATd76UPe/7
# 4ytaEB9NViiienLgEjq3SV7Y7e1DkYPZe7J7hhvZPrGMXeiJT4Qa8qEvWeSQOy2u
# M1jFtz7+MtOzAz2xsq+SOH7SnYAs9U5WkSE1JcM5bmR/U7qcD60ZI4TL9LoDho33
# X/DQUr+MlIe8wCF0JV8YKLbMJyg4JZg5SjbPfLGSrhwjp6lm7GEfauEoSZ1fiOIl
# XdMhSz5SxLVXPyQD8NF6Wy/VI+NwXQ9RRnez+ADhvKwCgl/bwBWzvRvUVUvnOaEP
# 6SNJvBi4RHxF5MHDcnrgcuck379GmcXvwhxX24ON7E1JMKerjt/sW5+v/N2wZuLB
# l4F77dbtS+dJKacTKKanfWeA5opieF+yL4TXV5xcv3coKPHtbcMojyyPQDdPweGF
# RInECUzF1KVDL3SV9274eCBYLBNdYJWaPk8zhNqwiBfenk70lrC8RqBsmNLg1oiM
# CwIDAQABo4IB7TCCAekwEAYJKwYBBAGCNxUBBAMCAQAwHQYDVR0OBBYEFEhuZOVQ
# BdOCqhc3NyK1bajKdQKVMBkGCSsGAQQBgjcUAgQMHgoAUwB1AGIAQwBBMAsGA1Ud
# DwQEAwIBhjAPBgNVHRMBAf8EBTADAQH/MB8GA1UdIwQYMBaAFHItOgIxkEO5FAVO
# 4eqnxzHRI4k0MFoGA1UdHwRTMFEwT6BNoEuGSWh0dHA6Ly9jcmwubWljcm9zb2Z0
# LmNvbS9wa2kvY3JsL3Byb2R1Y3RzL01pY1Jvb0NlckF1dDIwMTFfMjAxMV8wM18y
# Mi5jcmwwXgYIKwYBBQUHAQEEUjBQME4GCCsGAQUFBzAChkJodHRwOi8vd3d3Lm1p
# Y3Jvc29mdC5jb20vcGtpL2NlcnRzL01pY1Jvb0NlckF1dDIwMTFfMjAxMV8wM18y
# Mi5jcnQwgZ8GA1UdIASBlzCBlDCBkQYJKwYBBAGCNy4DMIGDMD8GCCsGAQUFBwIB
# FjNodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2RvY3MvcHJpbWFyeWNw
# cy5odG0wQAYIKwYBBQUHAgIwNB4yIB0ATABlAGcAYQBsAF8AcABvAGwAaQBjAHkA
# XwBzAHQAYQB0AGUAbQBlAG4AdAAuIB0wDQYJKoZIhvcNAQELBQADggIBAGfyhqWY
# 4FR5Gi7T2HRnIpsLlhHhY5KZQpZ90nkMkMFlXy4sPvjDctFtg/6+P+gKyju/R6mj
# 82nbY78iNaWXXWWEkH2LRlBV2AySfNIaSxzzPEKLUtCw/WvjPgcuKZvmPRul1LUd
# d5Q54ulkyUQ9eHoj8xN9ppB0g430yyYCRirCihC7pKkFDJvtaPpoLpWgKj8qa1hJ
# Yx8JaW5amJbkg/TAj/NGK978O9C9Ne9uJa7lryft0N3zDq+ZKJeYTQ49C/IIidYf
# wzIY4vDFLc5bnrRJOQrGCsLGra7lstnbFYhRRVg4MnEnGn+x9Cf43iw6IGmYslmJ
# aG5vp7d0w0AFBqYBKig+gj8TTWYLwLNN9eGPfxxvFX1Fp3blQCplo8NdUmKGwx1j
# NpeG39rz+PIWoZon4c2ll9DuXWNB41sHnIc+BncG0QaxdR8UvmFhtfDcxhsEvt9B
# xw4o7t5lL+yX9qFcltgA1qFGvVnzl6UJS0gQmYAf0AApxbGbpT9Fdx41xtKiop96
# eiL6SJUfq/tHI4D1nvi/a7dLl+LrdXga7Oo3mXkYS//WsyNodeav+vyL6wuA6mk7
# r/ww7QRMjt/fdW1jkT3RnVZOT7+AVyKheBEyIXrvQQqxP/uozKRdwaGIm1dxVk5I
# RcBCyZt2WwqASGv9eZ/BvW1taslScxMNelDNMYIWITCCFh0CAQEwgZUwfjELMAkG
# A1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQx
# HjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEoMCYGA1UEAxMfTWljcm9z
# b2Z0IENvZGUgU2lnbmluZyBQQ0EgMjAxMQITMwAAAQNeJRyZH6MeuAAAAAABAzAN
# BglghkgBZQMEAgEFAKCBsDAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgor
# BgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAvBgkqhkiG9w0BCQQxIgQg8jdl12m2
# /kXGsFJ6ifFLyvxBnHO0BP/JezQvtyEsotUwRAYKKwYBBAGCNwIBDDE2MDSgFIAS
# AE0AaQBjAHIAbwBzAG8AZgB0oRyAGmh0dHBzOi8vd3d3Lm1pY3Jvc29mdC5jb20g
# MA0GCSqGSIb3DQEBAQUABIIBABFcKMJQhTz4S+c3oCsDliOkYhzHyt+ELPW0F+HV
# GL4jzzlxF8OjjCHfczXXgyQV9AyHbFxd18oj5o3AWzNVHdbEJr+hEtmM+L/8CM9F
# 5bgqO7ZUgU7J5niYVYuxNvrFMGA17WmGEtBnCqMhR00mtEpkBuhSrP8jDMzt3Nos
# 0cyG3L2d3N8cJGmDvkm5PSugul56OJQH56YQdtODIJTpATaPZ/tcPXiyqlZru+TN
# l2+p2QX0Z0E4xFxLzh+4i4mDASHlDfKZYflTb8V+NeTs/rHPi3LBreftT36e2sPV
# V/GH8HWm0WKQXxJdHyrIBQAkUlTdpbAxKlONBR7VoGpGg6OhghOpMIITpQYKKwYB
# BAGCNwMDATGCE5UwghORBgkqhkiG9w0BBwKgghOCMIITfgIBAzEPMA0GCWCGSAFl
# AwQCAQUAMIIBVAYLKoZIhvcNAQkQAQSgggFDBIIBPzCCATsCAQEGCisGAQQBhFkK
# AwEwMTANBglghkgBZQMEAgEFAAQgmewCcCRtKW6SPpo5whosEdC1eXqGjshVcFW9
# b+fN0swCBlvN9CD3oBgTMjAxODEwMjkyMDMzMzIuMDkzWjAHAgEBgAIB9KCB0KSB
# zTCByjELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcT
# B1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjElMCMGA1UE
# CxMcTWljcm9zb2Z0IEFtZXJpY2EgT3BlcmF0aW9uczEmMCQGA1UECxMdVGhhbGVz
# IFRTUyBFU046RDIzNi0zN0RBLTk3NjExJTAjBgNVBAMTHE1pY3Jvc29mdCBUaW1l
# LVN0YW1wIFNlcnZpY2Wggg8VMIIGcTCCBFmgAwIBAgIKYQmBKgAAAAAAAjANBgkq
# hkiG9w0BAQsFADCBiDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24x
# EDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlv
# bjEyMDAGA1UEAxMpTWljcm9zb2Z0IFJvb3QgQ2VydGlmaWNhdGUgQXV0aG9yaXR5
# IDIwMTAwHhcNMTAwNzAxMjEzNjU1WhcNMjUwNzAxMjE0NjU1WjB8MQswCQYDVQQG
# EwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwG
# A1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQg
# VGltZS1TdGFtcCBQQ0EgMjAxMDCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoC
# ggEBAKkdDbx3EYo6IOz8E5f1+n9plGt0VBDVpQoAgoX77XxoSyxfxcPlYcJ2tz5m
# K1vwFVMnBDEfQRsalR3OCROOfGEwWbEwRA/xYIiEVEMM1024OAizQt2TrNZzMFcm
# gqNFDdDq9UeBzb8kYDJYYEbyWEeGMoQedGFnkV+BVLHPk0ySwcSmXdFhE24oxhr5
# hoC732H8RsEnHSRnEnIaIYqvS2SJUGKxXf13Hz3wV3WsvYpCTUBR0Q+cBj5nf/Vm
# wAOWRH7v0Ev9buWayrGo8noqCjHw2k4GkbaICDXoeByw6ZnNPOcvRLqn9NxkvaQB
# wSAJk3jN/LzAyURdXhacAQVPIk0CAwEAAaOCAeYwggHiMBAGCSsGAQQBgjcVAQQD
# AgEAMB0GA1UdDgQWBBTVYzpcijGQ80N7fEYbxTNoWoVtVTAZBgkrBgEEAYI3FAIE
# DB4KAFMAdQBiAEMAQTALBgNVHQ8EBAMCAYYwDwYDVR0TAQH/BAUwAwEB/zAfBgNV
# HSMEGDAWgBTV9lbLj+iiXGJo0T2UkFvXzpoYxDBWBgNVHR8ETzBNMEugSaBHhkVo
# dHRwOi8vY3JsLm1pY3Jvc29mdC5jb20vcGtpL2NybC9wcm9kdWN0cy9NaWNSb29D
# ZXJBdXRfMjAxMC0wNi0yMy5jcmwwWgYIKwYBBQUHAQEETjBMMEoGCCsGAQUFBzAC
# hj5odHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpL2NlcnRzL01pY1Jvb0NlckF1
# dF8yMDEwLTA2LTIzLmNydDCBoAYDVR0gAQH/BIGVMIGSMIGPBgkrBgEEAYI3LgMw
# gYEwPQYIKwYBBQUHAgEWMWh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9QS0kvZG9j
# cy9DUFMvZGVmYXVsdC5odG0wQAYIKwYBBQUHAgIwNB4yIB0ATABlAGcAYQBsAF8A
# UABvAGwAaQBjAHkAXwBTAHQAYQB0AGUAbQBlAG4AdAAuIB0wDQYJKoZIhvcNAQEL
# BQADggIBAAfmiFEN4sbgmD+BcQM9naOhIW+z66bM9TG+zwXiqf76V20ZMLPCxWbJ
# at/15/B4vceoniXj+bzta1RXCCtRgkQS+7lTjMz0YBKKdsxAQEGb3FwX/1z5Xhc1
# mCRWS3TvQhDIr79/xn/yN31aPxzymXlKkVIArzgPF/UveYFl2am1a+THzvbKegBv
# SzBEJCI8z+0DpZaPWSm8tv0E4XCfMkon/VWvL/625Y4zu2JfmttXQOnxzplmkIz/
# amJ/3cVKC5Em4jnsGUpxY517IW3DnKOiPPp/fZZqkHimbdLhnPkd/DjYlPTGpQqW
# hqS9nhquBEKDuLWAmyI4ILUl5WTs9/S/fmNZJQ96LjlXdqJxqgaKD4kWumGnEcua
# 2A5HmoDF0M2n0O99g/DhO3EJ3110mCIIYdqwUB5vvfHhAN/nMQekkzr3ZUd46Pio
# SKv33nJ+YWtvd6mBy6cJrDm77MbL2IK0cs0d9LiFAR6A+xuJKlQ5slvayA1VmXqH
# czsI5pgt6o3gMy4SKfXAL1QnIffIrE7aKLixqduWsqdCosnPGUFN4Ib5KpqjEWYw
# 07t0MkvfY3v1mYovG8chr1m1rtxEPJdQcdeh0sVV42neV8HR3jDA/czmTfsNv11P
# 6Z0eGTgvvM9YBS7vDaBQNdrvCScc1bN+NR4Iuto229Nfj950iEkSMIIE8TCCA9mg
# AwIBAgITMwAAAMlK1n6YThTUewAAAAAAyTANBgkqhkiG9w0BAQsFADB8MQswCQYD
# VQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEe
# MBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNyb3Nv
# ZnQgVGltZS1TdGFtcCBQQ0EgMjAxMDAeFw0xODA4MjMyMDI2MTNaFw0xOTExMjMy
# MDI2MTNaMIHKMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4G
# A1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSUw
# IwYDVQQLExxNaWNyb3NvZnQgQW1lcmljYSBPcGVyYXRpb25zMSYwJAYDVQQLEx1U
# aGFsZXMgVFNTIEVTTjpEMjM2LTM3REEtOTc2MTElMCMGA1UEAxMcTWljcm9zb2Z0
# IFRpbWUtU3RhbXAgU2VydmljZTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoC
# ggEBANYjaoQ2UEPBUNTS4UPpL11PaEO/UFNLuogXBRIhEBMP0ZudXHR08PQyWlZw
# ZSrdggcB4/gEppzEUCZxyAOUpZLSqj75rxCViSABt0leuhOAHeX8MHDv6GobJL59
# GNHnZj2SbyXZEyYK++w1oEKJKVv2F2bmpuLSyX0SiYP36urUtPwQdm3rrtZ2aGa9
# alTK/Tl+pEiKDVcV2dKbVT3CJlSvlBhzjp214IHBzwJX7YACFIdXlQvuI9pCUaGL
# re96b8k1KFVveMWAx16HkfYt+XvCQpWGX6tkRHwmupbW56f4XOaelvCgJ5LnUpGX
# T8OsnvXU8EC5o9zp1sLjgdjnmBkCAwEAAaOCARswggEXMB0GA1UdDgQWBBQrhuMJ
# APMlE8c1b2VwuH4gDpp7JzAfBgNVHSMEGDAWgBTVYzpcijGQ80N7fEYbxTNoWoVt
# VTBWBgNVHR8ETzBNMEugSaBHhkVodHRwOi8vY3JsLm1pY3Jvc29mdC5jb20vcGtp
# L2NybC9wcm9kdWN0cy9NaWNUaW1TdGFQQ0FfMjAxMC0wNy0wMS5jcmwwWgYIKwYB
# BQUHAQEETjBMMEoGCCsGAQUFBzAChj5odHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20v
# cGtpL2NlcnRzL01pY1RpbVN0YVBDQV8yMDEwLTA3LTAxLmNydDAMBgNVHRMBAf8E
# AjAAMBMGA1UdJQQMMAoGCCsGAQUFBwMIMA0GCSqGSIb3DQEBCwUAA4IBAQAD1vAT
# n1fy5B2lHrKdpjK5mmCz4itQCTdCJC/bpW8vEm4jdnW818H08sQwt2GMnYIxq3T/
# usrLrDW7uaYrx16l9DyXeEis41mfEsEpVpCjqqaT0shx4hmdD5JRgGCmG3La/Hql
# KtgoV+d6twPgBV52NgupSK5vKH6ni6M5rVphyYbaSR1a/DxAn5SyE2TpSg1XglyB
# BVPuQegAy7dI/1aLPZ4m92hS2j8HbEMzjlIDpaPVgxl4Xlxfc5csR4Ckr6ui3B35
# fDNrlyAy8uShmwkFveu+g8/uc6hG2UZy97jAdcFPqofbWyFDhjjiSSMUGg1/EkUB
# pM/Y18ivuDB2UW9soYIDpzCCAo8CAQEwgfqhgdCkgc0wgcoxCzAJBgNVBAYTAlVT
# MRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQK
# ExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xJTAjBgNVBAsTHE1pY3Jvc29mdCBBbWVy
# aWNhIE9wZXJhdGlvbnMxJjAkBgNVBAsTHVRoYWxlcyBUU1MgRVNOOkQyMzYtMzdE
# QS05NzYxMSUwIwYDVQQDExxNaWNyb3NvZnQgVGltZS1TdGFtcCBTZXJ2aWNloiUK
# AQEwCQYFKw4DAhoFAAMVAGSC4KoXbHiKw909SsGSry/oPEgXoIHaMIHXpIHUMIHR
# MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVk
# bW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSUwIwYDVQQLExxN
# aWNyb3NvZnQgQW1lcmljYSBPcGVyYXRpb25zMScwJQYDVQQLEx5uQ2lwaGVyIE5U
# UyBFU046MjY2NS00QzNGLUM1REUxKzApBgNVBAMTIk1pY3Jvc29mdCBUaW1lIFNv
# dXJjZSBNYXN0ZXIgQ2xvY2swDQYJKoZIhvcNAQEFBQACBQDfgVOdMCIYDzIwMTgx
# MDI5MDkzODM3WhgPMjAxODEwMzAwOTM4MzdaMHYwPAYKKwYBBAGEWQoEATEuMCww
# CgIFAN+BU50CAQAwCQIBAAIBZgIB/zAHAgEAAgIZQTAKAgUA34KlHQIBADA2Bgor
# BgEEAYRZCgQCMSgwJjAMBgorBgEEAYRZCgMBoAowCAIBAAIDFuNgoQowCAIBAAID
# HoSAMA0GCSqGSIb3DQEBBQUAA4IBAQDBDfTGdnxz8gPDUcSQqeh5ADMIISyPxcr7
# 88vPtkdIkBw4MGTI5E4ljwObaPCMdurCalsoebWc2Le+LwkHWBwkcIfhDGxg4Ua+
# Y4e5n2s0zEgjxBiCFG1brQ84y65IWyX48tGc01vMqsQE0qN+5P3TlqVpLSL8nAcU
# q0ugZrXEmyQ0OlKIwghq9VRrHsUMhCRpR+VVE1bZtUnGf+8CqsoX3h3Epzej68De
# Js44m39hQLCOlvPSG51qvvEQK0IhLL8/DoZhZtq8lUNiiVe37mhZIt/5Zh0QCMbe
# NIZXa7IcggSARs/m0TJ88LUhO+zVe46fuyTDBCY/tx3+c0OVGuKoMYIC9TCCAvEC
# AQEwgZMwfDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNV
# BAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQG
# A1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENBIDIwMTACEzMAAADJStZ+mE4U
# 1HsAAAAAAMkwDQYJYIZIAWUDBAIBBQCgggEyMBoGCSqGSIb3DQEJAzENBgsqhkiG
# 9w0BCRABBDAvBgkqhkiG9w0BCQQxIgQg/8e3na/0sfZxfFlPb93FjdQnxp3E2eXa
# k/YLZVvUvlcwgeIGCyqGSIb3DQEJEAIMMYHSMIHPMIHMMIGxBBRkguCqF2x4isPd
# PUrBkq8v6DxIFzCBmDCBgKR+MHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNo
# aW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29y
# cG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAyMDEw
# AhMzAAAAyUrWfphOFNR7AAAAAADJMBYEFHqkK281aeIZOgf6Z9ZofWldP5EzMA0G
# CSqGSIb3DQEBCwUABIIBAMkKJqp+7Zh/vCHo2p1hOoxJ/gt00mvOp3oBjYttqZsu
# Q6aEIrm9LX2y6gvwwya5144yu8zzfXKLrfOGax8O6rCSUaboeUEyo6WqzsNFOAeB
# 7Hg7j1od8G6D8b/qEb3CtIcQniqbGVHH1yhU8jPQvw+0cNZO4OrdEx3shFNtNZo8
# cSGusT1LnRPXmprfaGXf+4cF8zLWNbVUILizNz0IYpjEJH5VHuAZBIHBMYK4q0bd
# zwEKdmv+WhZGGhfbBIQHauqk7eiMExfzjCA/2xeC6YKRsza4l8wYdjdaFqZ8/Aun
# MtrPAqoHemCv6v600/xzrn1w6DEwLmrxAdMhvLY68ns=
# SIG # End signature block

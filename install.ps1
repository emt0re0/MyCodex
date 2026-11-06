[CmdletBinding(SupportsShouldProcess)]
param(
    [string]$CodexHome = $(if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $env:USERPROFILE '.codex' }),
    [ValidateSet('windows','macos','linux')][string]$Platform = 'windows'
)
$ErrorActionPreference = 'Stop'
$common = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'AGENTS.md'))
$profile = [IO.File]::ReadAllText((Join-Path $PSScriptRoot "platforms/$Platform.md"))
$content = $common.TrimEnd() + "`n`n" + $profile.TrimEnd() + "`n"
$target = Join-Path $CodexHome 'AGENTS.md'
if ($PSCmdlet.ShouldProcess($target, "Install common + $Platform instructions; back up existing file")) {
    [IO.Directory]::CreateDirectory($CodexHome) | Out-Null
    if (Test-Path -LiteralPath $target) {
        Copy-Item -LiteralPath $target -Destination ($target + '.backup-' + [guid]::NewGuid().ToString('N'))
    }
    [IO.File]::WriteAllText($target, $content, [Text.UTF8Encoding]::new($false))
    if ([IO.File]::ReadAllText($target) -cne $content) { throw 'Verification failed' }
    Write-Output "Installed common + $Platform : $target"
}

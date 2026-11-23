[CmdletBinding()]
param(
    [switch]$SkipVerify
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if ((Test-Path Variable:IsWindows) -and (-not $IsWindows)) {
    $shArgs = if ($SkipVerify) { @('--skip-verify') } else { @() }
    & bash (Join-Path $PSScriptRoot 'install-deps.sh') @shArgs
    exit $LASTEXITCODE
}

$Packages = @(
    'latexmk', 'jsonparse', 'nunito', 'comfortaa', 'fontawesome5',
    'geometry', 'xcolor', 'colortbl', 'tcolorbox', 'tikzfill',
    'pdfcol', 'environ', 'listings', 'listingsutf8', 'pgf',
    'pgfplots', 'hyperref', 'rerunfilecheck', 'uniquecounter',
    'ec', 'cm-super', 'fontaxes', 'mweights', 'figureversions'
)

function Update-SessionPath {
    $parts = @(
        [Environment]::GetEnvironmentVariable('Path', 'Machine'),
        [Environment]::GetEnvironmentVariable('Path', 'User'),
        "$env:LOCALAPPDATA\Programs\MiKTeX\miktex\bin\x64",
        'C:\Program Files\MiKTeX\miktex\bin\x64',
        'C:\Strawberry\perl\bin'
    ) | Where-Object { $_ -and (Test-Path $_ -ErrorAction SilentlyContinue) -or ($_ -like '*;*') }
    $env:PATH = ($parts -join ';')
}

function Install-WingetPackage([string]$Id, [switch]$UserScope) {
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        throw "winget is required to install $Id automatically. Install App Installer from Microsoft Store and re-run."
    }
    Write-Host "Installing $Id via winget..."
    $baseArgs = @('install', '--id', $Id, '--exact', '--silent', '--accept-package-agreements', '--accept-source-agreements')
    if ($UserScope) {
        & winget @baseArgs --scope user
        if ($LASTEXITCODE -eq 0) { Update-SessionPath; return }
    }
    & winget @baseArgs
    if ($LASTEXITCODE -ne 0) { throw "winget install failed for $Id (exit code $LASTEXITCODE)." }
    Update-SessionPath
}

function Find-Python {
    foreach ($candidate in @('python', 'python3')) {
        $cmd = Get-Command $candidate -ErrorAction SilentlyContinue
        # WindowsApps shim exits non-zero when Python is not actually installed.
        if ($cmd) {
            & $cmd.Source -c "import json" 2>$null
            if ($LASTEXITCODE -eq 0) { return $cmd.Source }
        }
    }
    return $null
}

Update-SessionPath

if (-not (Get-Command pdflatex -ErrorAction SilentlyContinue)) {
    Install-WingetPackage -Id 'MiKTeX.MiKTeX' -UserScope
}

$hasTlmgr = [bool](Get-Command tlmgr -ErrorAction SilentlyContinue)
if ((-not $hasTlmgr) -and (-not (Get-Command perl -ErrorAction SilentlyContinue))) {
    Install-WingetPackage -Id 'StrawberryPerl.StrawberryPerl'
}

$pythonExe = Find-Python
if (-not $pythonExe) {
    Install-WingetPackage -Id 'Python.Python.3.12' -UserScope
    $pythonExe = Find-Python
    if (-not $pythonExe) { throw 'Python installation completed, but python was not found on PATH.' }
}

if (Get-Command miktex -ErrorAction SilentlyContinue) {
    & initexmf --set-config-value '[MPM]AutoInstall=1'
    $installed = @{}
    foreach ($line in (& miktex packages list --template "{isInstalled} {id}`n")) {
        if ($line -match '^true\s+(\S+)$') { $installed[$Matches[1]] = $true }
    }
    $missing = @($Packages | Where-Object { -not $installed.ContainsKey($_) })
    if ($missing.Count -gt 0) {
        Write-Host "Updating MiKTeX package database and installing $($missing.Count) package(s)..."
        & miktex packages update-package-database
        foreach ($pkg in $missing) {
            Write-Host "  -> $pkg"
            & miktex packages install $pkg
            if ($LASTEXITCODE -ne 0) { throw "Failed to install MiKTeX package '$pkg'." }
        }
        & initexmf --update-fndb
        & initexmf --mkmaps
        & miktex packages check-update | Out-Null
    }
} elseif ($hasTlmgr) {
    Write-Host 'Installing LaTeX packages via tlmgr...'
    & tlmgr install @Packages
    if ($LASTEXITCODE -ne 0) { throw 'tlmgr package installation failed.' }
} else {
    throw 'pdflatex is installed, but neither miktex nor tlmgr package manager was found.'
}

if (-not $SkipVerify) {
    $repoRoot = Split-Path -Parent $PSScriptRoot
    $latexDir = Join-Path $repoRoot 'latex'
    $sampleJson = Join-Path $latexDir 'data\baby.sample.json'
    & $pythonExe -m json.tool $sampleJson > $null
    if ($LASTEXITCODE -ne 0) { throw "JSON validation failed for $sampleJson." }

    $tmpDir = Join-Path ([IO.Path]::GetTempPath()) ("babybook-verify-" + [guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $tmpDir | Out-Null
    try {
        $smokeJson = Join-Path $tmpDir 'smoke.json'
        $smokeJsonTex = $smokeJson -replace '\\', '/'
        Set-Content -Path $smokeJson -Encoding Ascii -Value '{"baby":{"name":"Anaya"}}'
        $smokeTex = Join-Path $tmpDir 'smoke.tex'
        Set-Content -Path $smokeTex -Encoding Ascii -Value @"
\documentclass{babybook}
\loadbookdata{$smokeJsonTex}
\begin{document}
\pagetitle{Dependency Check}
\field{Name}{baby.name}
\end{document}
"@
        Push-Location $latexDir
        try {
            Write-Host 'Verifying latexmk + pdflatex build...'
            & latexmk -pdf -interaction=nonstopmode "-outdir=$tmpDir" $smokeTex > $null
            if ($LASTEXITCODE -ne 0 -or -not (Test-Path (Join-Path $tmpDir 'smoke.pdf'))) {
                throw 'Verification compile with latexmk failed.'
            }
        } finally {
            Pop-Location
        }
    } finally {
        Remove-Item -Recurse -Force $tmpDir -ErrorAction SilentlyContinue
    }
}

Write-Host 'All dependencies are installed and verified.'

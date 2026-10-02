#Requires -Version 7.0
<#
.SYNOPSIS
    Baut die Dübi-Style-Website und veröffentlicht sie automatisch auf GitHub Pages.

.DESCRIPTION
    Ersetzt die manuellen Schritte aus README.md:
      1. Änderungen auf dem Quell-Branch committen und hochladen
      2. "bundle exec jekyll build" ausführen
      3. Den Inhalt von _site/ auf den gh-pages-Branch veröffentlichen

    Es wird ein temporärer Git-Worktree verwendet. Der Hauptordner wird also
    NICHT umgeschaltet, und CNAME (duebi-style.ch) sowie .nojekyll bleiben erhalten.

.EXAMPLE
    .\publish.ps1
    .\publish.ps1 -Message "Neue Produkte"
    .\publish.ps1 -NoPush            # nur lokal bauen und committen, nichts hochladen

.PARAMETER Message
    Commit-Nachricht. Standard: "Website aktualisiert (Datum Uhrzeit)".

.PARAMETER SourceBranch
    Quell-Branch mit dem Inhalt. Standard: main.

.PARAMETER PublishBranch
    Branch, der auf GitHub Pages veröffentlicht wird. Standard: gh-pages.

.PARAMETER NoPush
    Baut und committet lokal, führt aber KEINEN Push zum Server aus.
#>
[CmdletBinding()]
param(
    [string]$Message = "",
    [string]$SourceBranch = "main",
    [string]$PublishBranch = "gh-pages",
    [switch]$NoPush
)

$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $false

function Write-Step([string]$Text) {
    Write-Host ""
    Write-Host "==> $Text" -ForegroundColor Cyan
}

function Run([string[]]$Command) {
    $exe = $Command[0]
    $arguments = @($Command | Select-Object -Skip 1)
    & $exe @arguments
    if ($LASTEXITCODE -ne 0) {
        throw "Befehl fehlgeschlagen: $($Command -join ' ') (Exitcode $LASTEXITCODE)"
    }
}

try {
    # ----- Repository prüfen -----
    $repoRoot = (& git rev-parse --show-toplevel 2>$null)
    if ($LASTEXITCODE -ne 0 -or -not $repoRoot) {
        throw "Dieser Ordner ist kein Git-Repository."
    }
    $repoRoot = $repoRoot.Trim()
    Set-Location -LiteralPath $repoRoot

    $currentBranch = (& git rev-parse --abbrev-ref HEAD).Trim()
    if ($currentBranch -ne $SourceBranch) {
        throw "Du bist auf dem Branch '$currentBranch'. Der Inhalt muss auf '$SourceBranch' liegen. Bitte zuerst ausführen: git checkout $SourceBranch"
    }

    if (-not $Message) {
        $Message = "Website aktualisiert ($(Get-Date -Format 'yyyy-MM-dd HH:mm'))"
    }

    # ----- Sicherheitshinweis: Zugangsdaten in der Remote-URL -----
    $remoteUrl = (& git remote get-url origin 2>$null)
    if ($remoteUrl -and $remoteUrl -match '://[^/@]+@') {
        Write-Host "Hinweis: In der Git-Remote-URL scheint ein Zugangstoken eingebettet zu sein." -ForegroundColor Yellow
        Write-Host "         Dieses Token sollte aus Sicherheitsgruenden regelmaessig erneuert werden." -ForegroundColor Yellow
    }

    # ----- 1. Quellaenderungen committen -----
    Write-Step "Aenderungen auf '$SourceBranch' committen"
    Run @('git', 'add', '-A')
    $sourceChanges = (& git status --porcelain)
    if ($sourceChanges) {
        Run @('git', 'commit', '-m', $Message)
        Write-Host "Commit erstellt: $Message"
    } else {
        Write-Host "Keine Aenderungen zum Committen."
    }

    if (-not $NoPush) {
        Write-Step "Quell-Branch '$SourceBranch' hochladen"
        Run @('git', 'push', 'origin', $SourceBranch)
    } else {
        Write-Host "(-NoPush) Quell-Branch wird nicht hochgeladen."
    }

    # ----- 2. Website bauen -----
    Write-Step "Website bauen (bundle exec jekyll build)"
    Run @('bundle', 'exec', 'jekyll', 'build')
    $siteDir = Join-Path $repoRoot '_site'
    if (-not (Test-Path -LiteralPath (Join-Path $siteDir 'index.html'))) {
        throw "Der Build hat keine gueltige Ausgabe in _site/ erzeugt."
    }

    # ----- 3. Auf den Publish-Branch veroeffentlichen -----
    Write-Step "Auf '$PublishBranch' veroeffentlichen"
    $tempWorktree = Join-Path ([System.IO.Path]::GetTempPath()) ("duebi-publish-" + [System.Guid]::NewGuid().ToString('N'))

    Run @('git', 'worktree', 'prune')
    Run @('git', 'fetch', 'origin', $PublishBranch)
    Run @('git', 'worktree', 'add', '--force', '--detach', $tempWorktree, "origin/$PublishBranch")

    try {
        # .nojekyll sicherstellen, sonst wuerde GitHub Pages die Dateien erneut verarbeiten.
        $nojekyll = Join-Path $tempWorktree '.nojekyll'
        if (-not (Test-Path -LiteralPath $nojekyll)) {
            New-Item -ItemType File -Path $nojekyll | Out-Null
        }

        # CNAME (eigene Domain duebi-style.ch) bleibt erhalten, weil nur ueber
        # bestehende Dateien kopiert und nichts geloescht wird.
        Get-ChildItem -LiteralPath $siteDir -Force | Copy-Item -Destination $tempWorktree -Recurse -Force

        Run @('git', '-C', $tempWorktree, 'add', '-A')
        $publishChanges = (& git -C $tempWorktree status --porcelain)
        if ($publishChanges) {
            Run @('git', '-C', $tempWorktree, 'commit', '-m', "Deploy: $Message")
            if (-not $NoPush) {
                Run @('git', '-C', $tempWorktree, 'push', 'origin', "HEAD:$PublishBranch")
                Write-Host "Erfolgreich veroeffentlicht."
            } else {
                Write-Host "(-NoPush) Veroeffentlichung nur lokal erstellt, nicht hochgeladen."
            }
        } else {
            Write-Host "Keine Aenderungen zu veroeffentlichen - die Website ist bereits aktuell."
        }
    }
    finally {
        if (Test-Path -LiteralPath $tempWorktree) {
            & git worktree remove --force $tempWorktree 2>$null | Out-Null
        }
        & git worktree prune | Out-Null
    }

    Write-Host ""
    Write-Host "Fertig." -ForegroundColor Green
    if (-not $NoPush) {
        Write-Host "Die Website ist in wenigen Minuten live: https://duebi-style.ch" -ForegroundColor Green
    }
}
catch {
    Write-Host ""
    Write-Host "FEHLER: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

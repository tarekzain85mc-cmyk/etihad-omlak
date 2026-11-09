$ErrorActionPreference = 'Stop'

$repositoryRoot = Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')
$coordinatorPromptPath = Join-Path $repositoryRoot 'docs\automation\CLAUDE_COORDINATOR.md'

Set-Location -LiteralPath $repositoryRoot
$coordinatorPrompt = Get-Content -Raw -LiteralPath $coordinatorPromptPath

claude --name 'اتحاد الملاك — منسق الخطة' --permission-mode plan $coordinatorPrompt

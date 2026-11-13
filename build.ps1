# Builds Demiurge (see build.bat): .\build.ps1, or .\build.ps1 templates for the export templates too.
& "$PSScriptRoot\build.bat" @args
exit $LASTEXITCODE

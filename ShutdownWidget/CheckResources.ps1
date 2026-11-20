Add-Type -AssemblyName System.Reflection
$asm = [System.Reflection.Assembly]::LoadFile('D:\OPENAI\shutdown timer widget\ShutdownWidget\bin\Release\net10.0-windows\win-x64\ShutdownWidget.dll')
$resources = $asm.GetManifestResourceNames()
Write-Host 'Embedded resources:'
$resources | ForEach-Object { Write-Host "  $_" }
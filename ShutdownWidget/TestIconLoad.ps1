Add-Type -AssemblyName System.Reflection
Add-Type -AssemblyName System.Drawing

$asm = [System.Reflection.Assembly]::LoadFile('D:\OPENAI\shutdown timer widget\ShutdownWidget\bin\Release\net10.0-windows\win-x64\ShutdownWidget.dll')

$stream = $asm.GetManifestResourceStream('ShutdownWidget.icon.ico')
if ($stream -eq $null) {
    Write-Host "ERROR: Resource stream is null"
    exit 1
}
Write-Host "Stream length: $($stream.Length) bytes"

try {
    $icon = New-Object System.Drawing.Icon $stream
    Write-Host "SUCCESS: Icon loaded, size: $($icon.Size)"
    $icon.Save('D:\OPENAI\shutdown timer widget\ShutdownWidget\test_output.ico')
    Write-Host "Saved test_output.ico"
} catch {
    Write-Host "ERROR loading icon: $($_.Exception.Message)"
}
Param (
  [String] $neobuildData
)
[String] $neobuildTemp = "$env:TEMP\neocore"
[String] $toolsHost = "http://azertyvortex.free.fr/download"

function cdTemplate {
  Write-Host "setup cd_template"
  Download $toolsHost/neobuild-cd_template.zip $neobuildTemp\neobuild-cd_template.zip
  expandZip $neobuildTemp\neobuild-cd_template.zip $neobuildData
  Start-Sleep 5
}

function raine {
  Write-Host "setup raine emulator"
  Download $toolsHost/neobuild-raine.zip $neobuildTemp\neobuild-raine.zip
  expandZip $neobuildTemp\neobuild-raine.zip $neobuildData
  Start-Sleep 5
}

function raineConfig {
  Write-Host "configure raine"
  $content = [System.IO.File]::ReadAllText("$neobuildData\raine\config\raine32_sdl.cfg").Replace("/*neocd_bios*/","neocd_bios = $env:appdata\neocore\raine\roms\NEOCD.BIN")
  [System.IO.File]::WriteAllText("$neobuildData\raine\config\raine32_sdl.cfg", $content)
}

function bin {
  Write-Host "setup bin"
  Download $toolsHost/neocore-bin.zip $neobuildTemp\neocore-bin.zip
  expandZip $neobuildTemp\neocore-bin.zip $neobuildData
  Start-Sleep 5
}

function sdk {
  Write-Host "setup sdk"
  Download $toolsHost/neodev-sdk.zip $neobuildTemp\neodev-sdk.zip
  expandZip $neobuildTemp\neodev-sdk.zip $neobuildData
  Start-Sleep 5
}

function Download([String] $url, [String] $targetFile){
  Write-Host "download : $url $targetFile"
  Import-Module BitsTransfer

  $start_time = Get-Date
  Start-BitsTransfer -Source $url -Destination $targetFile
  Write-Output "Time taken: $((Get-Date).Subtract($start_time).Seconds) second(s)"
}

function expandZip([String] $file, [String] $destination) {
  Write-Host "expand $file $destination"
  $shell = new-object -com shell.application
  $zip = $shell.NameSpace($file)
  foreach($item in $zip.items()) {
    $shell.Namespace($destination).copyhere($item)
  }
}

function Main {
  if ((Test-Path -Path $neobuildData) -eq $true) { Remove-Item -Force -Recurse -Path $neobuildData }
  if ((Test-Path -Path $neobuildTemp) -eq $true) { Remove-Item -Force -Recurse -Path $neobuildTemp }
  New-Item -ItemType Directory -Force -Path $neobuildData
  New-Item -ItemType Directory -Force -Path $neobuildTemp
  sdk
  cdTemplate
  raine
  raineConfig
  bin
}

Main

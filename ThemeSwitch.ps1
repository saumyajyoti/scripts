#!/usr/bin/env -S pwsh -nop

$GSettings = "~/.config/git/config"
. $PSScriptRoot/Nice/WallConfig.ps1

# Script for toggling theme settings for system, apps, and tools.
# Handles:
#   - Wallpaper
#   - System Theme
#   - Apps Theme
#   - Titlebar and window borders
#   - conhost
#   - windowsterminal
#   - git

Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public class DeskWall
{
  [DllImport("User32.dll", CharSet=CharSet.Unicode)]
  public static extern int SystemParametersInfo (Int32 uAction, Int32 uParam, String lpvParam, Int32 fuWinIni);
}
"@

$ThemeRegistry = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize"
$WTSettings = "$Env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json"
$CheckWall = Get-ItemProperty `
  -Path 'HKCU:\Control Panel\Desktop\' `
  -Name WallPaper
$CheckTheme = Get-ItemProperty `
  -Path $ThemeRegistry `
  -Name AppsUseLightTheme

if (!$CheckTheme.AppsUseLightTheme) {
  # Wallpaper
  if ($CheckWall.WallPaper -ne $WallPaper_Light) {
    [DeskWall]::SystemParametersInfo(0x0014, 0, $WallPaper_Light, 0x03) | Out-Null
  }

  # System
  Set-ItemProperty `
    -Path $ThemeRegistry `
    -Name SystemUsesLightTheme `
    -Value 1

  # Apps
  Set-ItemProperty `
    -Path $ThemeRegistry `
    -Name AppsUseLightTheme `
    -Value 1

  # Titlebar and window borders
  Set-ItemProperty `
    -Path HKCU:\SOFTWARE\Microsoft\Windows\DWM `
    -Name ColorPrevalence `
    -Value 0

  # Windows Console
  colortool -b some-light.ini

  # Windows Terminal
  Set-Content `
    -Path $WTSettings `
    -Value ((Get-Content $WTSettings).
        Replace('"theme": "dark"', '"theme": "light"').
        Replace('"colorScheme": "Tango Dark"', '"colorScheme": "Tango Light"').
        Replace('"colorScheme": "Campbell"', '"colorScheme": "some-light"').
        Replace('"colorScheme": "Bluloco Dark"', '"colorScheme": "Bluloco Light"').
        Replace('"tabColor": "#0D1117"', '"tabColor": "#f9f9f9"'))

  # Git
  Set-Content `
    -Path $GSettings `
    -Value (Get-Content $GSettings).Replace("decorations calochortus-lyallii", "decorations hoopoe")
} else {
  # Wallpaper
  if ($CheckWall.WallPaper -ne $WallPaper_Dark) {
    [DeskWall]::SystemParametersInfo(0x0014, 0, $WallPaper_Dark, 0x03) | Out-Null
  }

  # System
  Set-ItemProperty `
    -Path $ThemeRegistry `
    -Name SystemUsesLightTheme `
    -Value 0

  # Apps
  Set-ItemProperty `
    -Path $ThemeRegistry `
    -Name AppsUseLightTheme `
    -Value 0

  # Titlebar and window borders
  Set-ItemProperty `
    -Path HKCU:\SOFTWARE\Microsoft\Windows\DWM `
    -Name ColorPrevalence `
    -Value 1

  # Windows Console
  colortool -b campbell.ini

  # Windows Terminal
  Set-Content `
    -Path $WTSettings `
    -Value ((Get-Content $WTSettings).
        Replace('"theme": "light"', '"theme": "dark"').
        Replace('"colorScheme": "Tango Light"', '"colorScheme": "Tango Dark"').
        Replace('"colorScheme": "some-light"', '"colorScheme": "Campbell"').
        Replace('"colorScheme": "Bluloco Light"', '"colorScheme": "Bluloco Dark"').
        Replace('"tabColor": "#f9f9f9"', '"tabColor": "#0D1117"'))

  # Git
  Set-Content `
    -Path $GSettings `
    -Value (Get-Content $GSettings).Replace("decorations hoopoe", "decorations calochortus-lyallii")
}

@echo off
cd /d "%~dp0"
rem Builds KinetikCalendar.exe with the .NET Framework compiler that ships with Windows. No SDK needed.
rem "build.bat package" also makes KinetikCalendar.zip (the exe, README and licence) for a release.
if not exist icon.ico powershell -NoProfile -ExecutionPolicy Bypass -File make-icon.ps1 || exit /b 1
C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe /nologo /utf8output /codepage:65001 /platform:x64 /target:winexe /out:KinetikCalendar.new.exe /win32icon:icon.ico /resource:icon.ico,icon.ico ^
  /r:System.Windows.Forms.dll /r:System.Drawing.dll /r:System.Core.dll ^
  KinetikCalendar.cs || exit /b 1
rem Built under a new name first, so this works while the app is running. The exe it replaces goes to ..\Old Versions
rem (when that folder is there), stamped with the date and time, to go back to if a build misbehaves.
if exist KinetikCalendar.exe if exist "..\Old Versions\" (
  for /f %%t in ('powershell -NoProfile -Command "Get-Date -Format yyyy-MM-dd-HHmmss"') do move /y KinetikCalendar.exe "..\Old Versions\KinetikCalendar-%%t.exe" >nul
)
if exist KinetikCalendar.exe move /y KinetikCalendar.exe KinetikCalendar.old.exe >nul
move /y KinetikCalendar.new.exe KinetikCalendar.exe >nul || exit /b 1
if exist KinetikCalendar.old.exe del KinetikCalendar.old.exe 2>nul
echo Built KinetikCalendar.exe
if /i not "%~1"=="package" exit /b 0
if exist dist rmdir /s /q dist
mkdir dist\KinetikCalendar
copy /y KinetikCalendar.exe dist\KinetikCalendar\ >nul
copy /y README.md dist\KinetikCalendar\ >nul
copy /y LICENSE dist\KinetikCalendar\ >nul
if exist KinetikCalendar.zip del KinetikCalendar.zip
powershell -NoProfile -Command "Compress-Archive -Path dist\KinetikCalendar\* -DestinationPath KinetikCalendar.zip"
rmdir /s /q dist
echo Made KinetikCalendar.zip

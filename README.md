# winmakesh
Minimal version of make and sh for windows. Once installed you can double click on .sh files to execute them with busybox. You will have access from the console to make and sh (as alias of busybox).
It will hardcode sh.exe and make.exe, so be careful as it might conflict with other installations.

# TO INSTALL
From Powershell:
```
Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-WebRequest -Uri "https://raw.githubusercontent.com/AlessandroChecco/winmakesh/main/install-make-sh.ps1" -UseBasicParsing | Invoke-Expression
```


# TO UNINSTALL
From Powershell:
```
Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-WebRequest -Uri "https://raw.githubusercontent.com/AlessandroChecco/winmakesh/main/uninstall-make-sh.ps1" -UseBasicParsing | Invoke-Expression

```

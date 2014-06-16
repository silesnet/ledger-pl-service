@echo off
cscript.exe /Nologo %~dp0..\lib\load-to-insert-gt.vbs "%1" "%2" customers "%1.jrn"

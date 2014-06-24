@echo off
cscript.exe /Nologo %~dp0..\lib\load-to-insert-gt.vbs "%1" "%2" invoices "%1.jrn" --dry

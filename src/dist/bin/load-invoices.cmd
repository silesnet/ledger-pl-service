@echo off
cscript.exe /Nologo src\main\vbs\load-to-insert-gt.vbs "%1" "%2" invoices "%1.jrn" --dry

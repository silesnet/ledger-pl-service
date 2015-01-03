@echo off
cscript.exe /Nologo loader-test.vbs
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%
cscript.exe /Nologo insert-gt-test.vbs
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%
cscript.exe /Nologo journal-test.vbs
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%
cscript.exe /Nologo yaml-parser-test.vbs
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%
cscript.exe /Nologo ..\..\main\vbs\load-to-insert-gt.vbs fixtures\yaml-fixture.yml subiekt.xml invoices tmp\invoices.jrn --dry
if ERRORLEVEL 0 exit /b %ERRORLEVEL%
cscript.exe /Nologo ..\..\main\vbs\load-to-insert-gt.vbs fixtures\yaml-fixture.yml subiekt.xml customers tmp\customers.jrn --dry
if ERRORLEVEL 0 exit /b %ERRORLEVEL%

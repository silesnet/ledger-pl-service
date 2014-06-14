@echo off
rem cscript.exe /Nologo loader-test.vbs
rem if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%
cscript.exe /Nologo insert-gt-test.vbs
rem if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%
rem cscript.exe /Nologo journal-test.vbs
rem if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%
rem cscript.exe /Nologo yaml-parser-test.vbs
rem if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%
rem cscript.exe /Nologo ..\..\main\vbs\load-to-insert-gt.vbs fixtures\yaml-fixture.yml subiekt.xml invoices tmp\invoices.jrn --dry
rem if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%
rem cscript.exe /Nologo ..\..\main\vbs\load-to-insert-gt.vbs fixtures\yaml-fixture.yml subiekt.xml customers tmp\customers.jrn --dry
rem if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

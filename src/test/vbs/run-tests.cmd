@echo off
cscript.exe /Nologo loader-test.vbs
cscript.exe /Nologo insert-gt-test.vbs
cscript.exe /Nologo journal-test.vbs
cscript.exe /Nologo yaml-parser-test.vbs
cscript.exe /Nologo ..\..\main\vbs\load-to-insert-gt.vbs fixtures\yaml-fixture.yml subiekt.xml invoices tmp\invoices.jrn --dry
cscript.exe /Nologo ..\..\main\vbs\load-to-insert-gt.vbs fixtures\yaml-fixture.yml subiekt.xml customers tmp\customers.jrn --dry

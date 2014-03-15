@echo off
cscript.exe /Nologo load-invoices.vbs test\yaml-empty.yml test\yaml-fixture.yml
cscript.exe /Nologo test/journal-test.vbs
cscript.exe /Nologo test/yaml-parser-test.vbs

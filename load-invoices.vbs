Option Explicit

include "yaml-parser"

Dim inputFile, configFile
If WScript.Arguments.Count = 2 Then
  configFile = WScript.Arguments.Item(0)
  inputFile = WScript.Arguments.Item(1)
Else
  WScript.Echo "Usage: import-invoices.vbs <Subiekt.xml> <input.yml>"
  WScript.Quit -1
End If

Dim yaml
Set yaml = yamlOf(inputFile)
WScript.Echo yaml.hasNext()

WScript.Quit 0

Sub include(file)
  ExecuteGlobal CreateObject("Scripting.FileSystemObject").openTextFile(file & ".vbs").readAll()
End Sub

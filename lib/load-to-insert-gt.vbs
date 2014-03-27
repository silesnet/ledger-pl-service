Option Explicit

include "lib/yaml-parser"
include "lib/insert-gt"
include "lib/journal"
include "lib/loader"

Dim inputFile, configFile
If WScript.Arguments.Count = 2 Then
  configFile = WScript.Arguments.Item(0)
  inputFile = WScript.Arguments.Item(1)
Else
  WScript.Echo "Usage: import-invoices.vbs <Subiekt.xml> <input.yml>"
  WScript.Quit -1
End If

debug "# Insert GT invoice loader STARTED"

Dim source, sink, journal
Set source = yamlOf(inputFile)
debug "yaml parser configured with '" & inputFile & "'"
If Not source.hasNext Then
  debug "nothing to load, input file si empty!"
  WScript.Quit 0
End If

Set journal = journalOf(inputFile & ".jrn")
debug "journal configured with '" & inputFile & ".jrn'"

debug "loading invoicees..."

debug "FINISHED, loaded " & loaded & " of " & invoices & " invoices"

WScript.Quit 0

Sub debug(msg)
  WScript.Echo msg
End Sub

Sub include(file)
  ExecuteGlobal CreateObject("Scripting.FileSystemObject").openTextFile(file & ".vbs").readAll()
End Sub

Option Explicit

include "lib/yaml-parser"
include "lib/insert-gt"
include "lib/journal"
include "lib/loader"

Dim sinkName, insertGtConfig, inputFile, journalFile
If WScript.Arguments.Count = 4 Then
  inputFile = WScript.Arguments.Item(0)
  insertGtConfig = WScript.Arguments.Item(1)
  sinkName = LCase(WScript.Arguments.Item(2))
  journalFile = WScript.Arguments.Item(3)
Else
  WScript.Echo "Usage: load-to-insert-gt.vbs <input.yml> <Subiekt.xml> (customers|invoices) <journal.jrn>"
  WScript.Quit -1
End If

debug "# Insert GT invoice loader"
Dim source, insertGt, sink, journal, loader

debug "configuring YAML parser with '" & inputFile & "'..."
Set source = yamlOf(inputFile)
If Not source.hasNext Then
  debug "nothing to load, input file is empty!"
  WScript.Quit 0
End If

debug "configuring InsERT GT with '" & insertGtConfig & "'..."
Set insertGt = insertOf(insertGtConfig)
' Set insertGt = New FakeInsertGtClass

debug "configuring load type with '" & sinkName & "'..."
Select Case sinkName
  Case "invoices"
    Set sink = New InvoiceSinkClass
    sink.setInsertGt insertGt
  Case "customers"
    Set sink = New CustomerSinkClass
    sink.setInsertGt insertGt
  Case Else
    WScript.Echo "ERROR: unsupported load type"
    WScript.Quit -1
End Select

debug "configuring journal '" & journalFile & "'..."
Set journal = journalOf(journalFile)

debug "loading invoices STARTED..."
Set loader = loaderOf(source, sink, journal)
loader.loadAll

debug "FINISHED, loaded " & loader.loadedDocuments() & " of " & loader.allDocuments() & " " & sinkName

WScript.Quit 0

Sub debug(msg)
  WScript.Echo msg
End Sub

Sub include(file)
  ExecuteGlobal CreateObject("Scripting.FileSystemObject").openTextFile(file & ".vbs").readAll()
End Sub

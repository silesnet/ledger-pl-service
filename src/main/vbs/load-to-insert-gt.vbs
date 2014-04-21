Option Explicit

include "yaml-parser"
include "insert-gt"
include "journal"
include "loader"

Dim sinkName, insertGtConfig, inputFile, journalFile
If WScript.Arguments.Count >= 4 Then
  inputFile = WScript.Arguments.Item(0)
  insertGtConfig = WScript.Arguments.Item(1)
  sinkName = LCase(WScript.Arguments.Item(2))
  journalFile = WScript.Arguments.Item(3)
Else
  echoUsage
  WScript.Quit 0
End If

debug "# Insert GT loader"
Dim source, insertGt, sink, journal, loader

debug "configuring YAML parser with '" & inputFile & "'..."
Set source = yamlOf(inputFile)
If Not source.hasNext Then
  debug "nothing to load, input file is empty!"
  WScript.Quit -1
End If

debug "configuring InsERT GT with '" & insertGtConfig & "'..."
If WScript.Arguments.Count = 5 Then
  If WScript.Arguments.Item(4) = "--dry" Then
    Set insertGt = New FakeInsertGtClass
  Else
    WScript.Echo "unknown argument '" & WScript.Arguments.Item(4) & "'"
    echoUsage
    WScript.Quit 0
  End If
Else
  Set insertGt = insertOf(insertGtConfig)
End If

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
    WScript.Quit 0
End Select

debug "configuring journal '" & journalFile & "'..."
Set journal = journalOf(journalFile)

debug "loading invoices STARTED..."
Set loader = loaderOf(source, sink, journal)
loader.loadAll

debug "FINISHED, loaded " & loader.loadedDocuments() & " of " & loader.allDocuments() & " " & sinkName

WScript.Quit -1

Sub debug(msg)
  WScript.Echo msg
End Sub

Sub echoUsage()
  WScript.Echo "Usage: load-to-insert-gt.vbs <input.yml> <Subiekt.xml> (customers|invoices) <journal.jrn> [--dry]"
End Sub

Sub include(file)
  Dim fs, path
  Set fs = CreateObject("Scripting.FileSystemObject")
  path = fs.GetParentFolderName(WScript.ScriptFullName) & "\" & file & ".vbs"
  ExecuteGlobal fs.openTextFile(path).readAll()
End Sub

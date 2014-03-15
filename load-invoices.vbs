Option Explicit

include "yaml-parser"
include "journal"

Dim inputFile, configFile
If WScript.Arguments.Count = 2 Then
  configFile = WScript.Arguments.Item(0)
  inputFile = WScript.Arguments.Item(1)
Else
  WScript.Echo "Usage: import-invoices.vbs <Subiekt.xml> <input.yml>"
  WScript.Quit -1
End If

debug "# Insert GT invoice loader STARTED"

Dim yaml, jrn
Set yaml = yamlOf(inputFile)
debug "yaml parser configured with '" & inputFile & "'"
If Not yaml.hasNext Then
  debug "nothing to load, input file si empty!"
  WScript.Quit 0
End If

Set jrn = journalOf(inputFile & ".jrn")
debug "journal configured with '" & inputFile & ".jrn'"

debug "loading invoicees..."
Dim invoice, invoices, invoiceNumber, loaded
invoices = 0
loaded = 0
On Error Resume Next
While yaml.hasNext()
  noFatalError "checking next invoice"
  Set invoice = yaml.nextDocument()
  noFatalError "reading invoice"
  invoiceNumber = ""
  invoices = invoices + 1
  validate(invoice)
  If noError("validating invoice") Then
    invoiceNumber = invoice.Item("number")
    load(invoice)
    If noError("loading invoice") Then
      storeRecord("OK")
      noFatalError "storing journal record"
      loaded = loaded + 1
      ' debug "  " & invoiceNumber & " OK"
    End If
  End If
  Set invoice = Nothing
Wend
On Error Goto 0

debug "FINISHED, loaded " & loaded & " of " & invoices & " invoices"

WScript.Quit 0

Sub validate(invoice)
  ' If invoices = 2 Then Err.Raise 1001, "validate invoice", "invoice is not valid"
End Sub

Sub load(invoice)
  ' If invoices = 3 Then Err.Raise 1002, "load invoice", "failed to load into Insert GT"
End Sub

Sub noFatalError(operation)
  If Err.Number <> 0 Then
    WScript.Echo "FATAL error when " & operation & " {" & errorMessage() & "}"
    WScript.Quit Err.Number
  End If
End Sub

Function noError(operation)
  If Err.Number <> 0 Then
    Dim message
    message = "FAILED " & failureMessage(operation)
    On Error Resume Next
    debug message
    storeRecord(message)
    noFatalError "storing journal record"
    noError = False
  Else
    noError = True
  End If
  Err.Clear
End Function

Function failureMessage(operation)
  Dim numberPart
  numberPart =  ""
  If invoiceNumber <> "" Then numberPart = ", number: '" & invoiceNumber & "'"
  failureMessage = operation & " {seq: " & invoices & numberPart & ", " & errorMessage() & "}"
End Function

Function errorMessage
  errorMessage = "error: '" & Err.Source & ": " & Err.Description & "'"
End Function

Sub storeRecord(message)
  jrn.store invoices & "|" & invoiceNumber & "|" & message & vbLf 
  ' If invoices = 1 Then Err.Raise 1000, "checking", "no next"
End Sub

Sub debug(msg)
  WScript.Echo msg
End Sub

Sub include(file)
  ExecuteGlobal CreateObject("Scripting.FileSystemObject").openTextFile(file & ".vbs").readAll()
End Sub

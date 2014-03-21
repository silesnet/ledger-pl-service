Option Explicit

Function loaderOf(source, sink)
  Dim journal
  Set journal = new LoaderClass
  journal.configure source, sink
  Set journalOf = journal
End Function

Class LoaderClass
  Private isConfigured
  Private source
  Private sink

  Private Sub Class_Initialize
    debug "creating loader"
    isConfigured = False
  End Sub

  Private Sub Class_Terminate
    debug "destroying loader"
    If isConfigured Then
      ' clean up here
    End If
  End Sub

  Public Sub configure(aSource, aSink)
    debug "initializing loader with source and sink"
    assertNotConfigured
    source = aSource
    sink = aSink
    isConfigured = True
  End Sub

  Private Sub assertNotConfigured
    If isConfigured Then Err.Raise 1, "Loader", "already configured"
  End Sub

  Private Sub assertConfigured
    If Not isConfigured Then Err.Raise 2, "Loader", "not configured"
  End Sub

  Private Sub debug(msg)
    WScript.Echo msg
  End Sub
End Class

WScript.Quit 0

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

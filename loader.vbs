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
  Private journal
  Private documents
  Private loaded

  Private Sub Class_Initialize()
    debug "creating loader"
    isConfigured = False
    documents = 0
    loaded = 0
  End Sub

  Private Sub Class_Terminate()
    debug "destroying loader"
    If isConfigured Then
      ' clean up here
    End If
  End Sub

  Public Sub configure(aSource, aSink, aJournal)
    debug "initializing loader with source and sink"
    assertNotConfigured
    source = aSource
    sink = aSink
    journal = aJournal
    isConfigured = True
  End Sub

  Public Sub loadAll()
    assertConfigured
    debug "loading all documents, expect valid document"
    Dim doc, docId
    On Error Resume Next
    While source.hasNext()
      noFatalError "checking next document"
      Set doc = source.nextDocument()
      noFatalError "reading document"
      docId = ""
      documents = documents + 1
      validate(doc)
      If noError("validating document") Then
        docId = doc.Item("number")
        sink.add(doc)
        If noError("loading document") Then
          storeRecord("OK")
          noFatalError "storing journal record"
          loaded = loaded + 1
          ' debug "  " & invoiceNumber & " OK"
        End If
      End If
      Set doc = Nothing
    Wend
    On Error Goto 0
  End Sub

  Public Property Get allDocuments()
    allDocuments = documents
  End Property

  Public Property Get loadedDocuments()
    loadedDocuments = loaded
  End Property

  Private Sub assertNotConfigured()
    If isConfigured Then Err.Raise 1, "Loader", "already configured"
  End Sub

  Private Sub assertConfigured()
    If Not isConfigured Then Err.Raise 2, "Loader", "not configured"
  End Sub

  Private Sub debug(msg)
    WScript.Echo msg
  End Sub
End Class

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

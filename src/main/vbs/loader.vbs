Option Explicit

Function loaderOf(aSource, aSink, aJournal)
  Dim loader
  Set loader = new LoaderClass
  loader.configure aSource, aSink, aJournal
  Set loaderOf = loader
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
    debug "initializing loader with source, sink and journal"
    assertNotConfigured
    Set source = aSource
    Set sink = aSink
    Set journal = aJournal
    isConfigured = True
  End Sub

  Public Sub loadAll()
    assertConfigured
    debug "loading all documents"
    Dim doc, docId
    On Error Resume Next
    While source.hasNext()
      noFatalError "checking next document"
      Set doc = source.nextDocument()
      noFatalError "reading document"
      documents = documents + 1
      docId = sink.validate(doc)
      If noError("validating document", docId) Then
        sink.update(doc)
        If noError("loading document", docId) Then
          storeRecord docId, "OK"
          noFatalError "storing journal record"
          loaded = loaded + 1
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

  Sub noFatalError(operation)
    If Err.Number <> 0 Then
      WScript.Echo "FATAL error when " & operation & " {" & errorMessage() & "}"
      WScript.Quit Err.Number
    End If
  End Sub

  Function noError(operation, docId)
    If Err.Number <> 0 Then
      Dim message
      message = "FAILED " & failureMessage(operation, docId)
      On Error Resume Next
      debug message
      storeRecord docId, message
      noFatalError "storing journal record"
      noError = False
    Else
      noError = True
    End If
    Err.Clear
  End Function

  Function failureMessage(operation, docId)
    Dim idPart
    idPart =  ""
    If docId <> "" Then idPart = ", id: '" & docId & "'"
    failureMessage = operation & " {seq: " & documents & idPart & ", " & errorMessage() & "}"
  End Function

  Function errorMessage
    errorMessage = "error: '" & Err.Number & ": " & Err.Source & ": " & Replace(Err.Description, vbCrLf, "") & "'"
  End Function

  Sub storeRecord(docId, message)
    journal.store documents & "|" & docId & "|" & message & vbLf
  End Sub

  Private Sub debug(msg)
    ' WScript.Echo msg
  End Sub
End Class

Option Explicit

Function journalOf(output)
  Dim journal
  Set journal = new JournalClass
  journal.setOutput output
  Set journalOf = journal
End Function

Class JournalClass
  Private isInitialized
  Private output

  Private Sub Class_Initialize
    debug "creating journal"
    isInitialized = False
  End Sub

  Private Sub Class_Terminate
    debug "destroying journal"
    If isInitialized Then
      output.Close
      debug "journal output file closed"
    End If
  End Sub

  Public Sub setOutput(file)
    debug "initializing journal with '" & file & "'"
    assertNotInitialized
    Set output = CreateObject("Scripting.FileSystemObject").CreateTextFile(file)
    isInitialized = True
  End Sub

  Public Sub store(record)
    output.Write record
  End Sub

  Private Sub assertNotInitialized
    If isInitialized Then Err.Raise 1, "Journal", "already initialized"
  End Sub

  Private Sub assertInitialized
    If Not isInitialized Then Err.Raise 2, "Journal", "not initialized"
  End Sub

  Private Sub debug(msg)
    'WScript.Echo msg
  End Sub
End Class

Option Explicit

include "../../main/vbs/loader"
include "../../main/vbs/map-utils"

testAll

Sub testAll
  WScript.Echo "TEST loader...  "
  testValidationFailure
  testLoad
  WScript.Echo "PASSED"
End Sub

Sub testValidationFailure
  WScript.Echo "# it should produce journal entry with id when validation fails"
  Dim source, sink, journal, loader
  Set source = New SourceClass
  source.configure 1
  Set sink = New NonValidatingSinkClass
  Set journal = New IdCheckingJournalClass
  Set loader = loaderOf(source, sink, journal)
  loader.loadAll()
End Sub

Sub testLoad
  WScript.Echo "# it should load all documents"
  Dim source, sink, journal, loader
  Set source = New SourceClass
  source.configure 1
  Set sink = New SinkClass
  Set journal = New JournalClass
  Set loader = loaderOf(source, sink, journal)
  loader.loadAll()
End Sub

Sub assert(cond, msg)
  If Not cond Then
    WScript.Echo "FAILED: " & msg
    WScript.Quit -1
  End If
End Sub

Sub include(file)
  ExecuteGlobal CreateObject("Scripting.FileSystemObject").openTextFile(file & ".vbs").readAll()
End Sub

Class SourceClass
  Private size
  Private current

  Private Sub Class_Initialize
    size = 0
    current = 0
  End Sub

  Public Sub configure(aSize)
    size = aSize
  End Sub

  Public Function hasNext()
    hasNext = (current < size)
  End Function

  Public Function nextDocument()
    Set nextDocument = CreateObject("Scripting.Dictionary")
    nextDocument.Add "seq", current
    current = current + 1
  End Function

End Class

Class SinkClass
  Private count

  Private Sub Class_Initialize
    count = 0
  End Sub

  Public Function docId(doc)
    docId = count
  End Function

  Public Function validate(doc)
    validate = count
  End Function

  Public Sub update(doc)
    count = count + 1
  End Sub
End Class

Class NonValidatingSinkClass
  Private count

  Private Sub Class_Initialize
    count = 0
  End Sub

  Public Function docId(doc)
    docId = count
  End Function

  Public Function validate(doc)
    Err.Raise 1001, "validate", "something is missing"
  End Function

  Public Sub update(doc)
    count = count + 1
  End Sub
End Class


Class JournalClass
  Private count

  Private Sub Class_Initialize
    count = 0
  End Sub

  Public Sub store(record)
    count = count + 1
  End Sub

End Class

Class IdCheckingJournalClass
  Private count

  Private Sub Class_Initialize
    count = 0
  End Sub

  Public Sub store(record)
    count = count + 1
    Dim fields, id
    fields = Split(record, "|")
    id = fields(1)
    assert id <> "", "id is missing from jornal record '" + record + "'"
  End Sub

End Class


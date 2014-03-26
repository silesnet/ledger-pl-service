Option Explicit

include "lib/loader"
include "lib/map-utils"

testAll

Sub testAll
  WScript.Echo "TEST loader...  "
  testLoad
  WScript.Echo "PASSED"
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

  Public Function validate(doc)
    validate = count
  End Function

  Public Sub add(doc)
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

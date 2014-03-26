Option Explicit

include "lib/journal"

Dim fs
Set fs = CreateObject("Scripting.FileSystemObject")

testAll

Sub testAll
  WScript.Echo "TEST journal... "
  testOutputFileCreation
  testWriteRecord
  WScript.Echo "PASSED"
End Sub

Sub testWriteRecord
  WScript.Echo "# it should store record"
  deleteFile("test/record.jrn")
  Dim journal
  Set journal = journalOf("test/record.jrn")
  journal.store("OK")
  assert fs.OpenTextFile("test/record.jrn").readAll() = "OK", "store record"
End Sub

Sub testOutputFileCreation
  WScript.Echo "# it should create output file"
  deleteFile("test/test.jrn")
  Dim journal
  Set journal = journalOf("test/test.jrn")
  assert fs.FileExists("test/test.jrn"), "read journal"
End Sub

Sub deleteFile(file)
  If fs.FileExists(file) Then fs.DeleteFile(file)
End Sub

Sub assert(cond, msg)
  If Not cond Then
    WScript.Echo "FAILED: " & msg
    WScript.Quit -1
  End If
End Sub

Sub include(file)
  ExecuteGlobal CreateObject("Scripting.FileSystemObject").OpenTextFile(file & ".vbs").readAll()
End Sub

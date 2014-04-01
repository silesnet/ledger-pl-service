Option Explicit

include "lib/journal"

Dim fs, tmp
Set fs = CreateObject("Scripting.FileSystemObject")
tmp = "test/tmp"
If Not fs.FolderExists(tmp) Then fs.CreateFolder tmp

testAll

Sub testAll
  WScript.Echo "TEST journal... "
  testOutputFileCreation
  testWriteRecord
  WScript.Echo "PASSED"
End Sub

Sub testWriteRecord
  WScript.Echo "# it should store record"
  deleteFile("test/tmp/record.jrn")
  Dim journal
  Set journal = journalOf("test/tmp/record.jrn")
  journal.store("OK")
  assert fs.OpenTextFile("test/tmp/record.jrn").readAll() = "OK", "store record"
End Sub

Sub testOutputFileCreation
  WScript.Echo "# it should create output file"
  deleteFile("test/tmp/test.jrn")
  Dim journal
  Set journal = journalOf("test/tmp/test.jrn")
  assert fs.FileExists("test/tmp/test.jrn"), "read journal"
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

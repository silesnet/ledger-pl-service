Option Explicit

include "insert-gt"

testAll

Sub testAll
  WScript.Echo "TEST InsERT GT..."
  testInsertStart
  WScript.Echo "PASSED"
End Sub

Sub testInsertStart
  WScript.Echo "# it should start InsERT GT application"
  Dim ins
  Set ins = insertOf("../Subiekt.xml")
  assert IsObject(ins), "start InsERT GT"
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

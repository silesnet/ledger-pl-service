Option Explicit

include "insert-gt"
include "map-utils"

testAll

Sub testAll
  WScript.Echo "TEST InsERT GT..."
  testInsertStart
  testAddInvoice
  WScript.Echo "PASSED"
End Sub

Sub testAddInvoice
  WScript.Echo "# it should add invoice"
  Dim ins, invoice
  Set ins = insertOf("../Subiekt.xml")
  Set invoice = CreateObject("Scripting.Dictionary")
  ' invoice.Add "number", "1017"
  invoice.Add "customerId", "ABC"
  invoice.Add "items", CreateObject("Scripting.Dictionary")
  invoice.Item("items").Add 0, CreateObject("Scripting.Dictionary")
  Dim item
  Set item = invoice.Item("items").Item(0)
  item.Add "name", "Wireless +"
  item.Add "unitPrice", 50.12
  item.Add "quantity", 0.3
  item.Add "unit", "mies."
  item.Add "VAT", 100002
  WScript.Echo dumpMap(invoice, 0)
  ins.addInvoice(invoice)
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

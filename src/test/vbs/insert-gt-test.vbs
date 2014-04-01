Option Explicit

include "lib/insert-gt"
include "lib/map-utils"

testAll

Sub testAll
  WScript.Echo "TEST InsERT GT..."
  ' testInsertStart
  ' testAddInvoice
  testValidateInvoice
  WScript.Echo "PASSED"
End Sub

Sub testValidateInvoice
  WScript.Echo "# it should validate invoice"
  Dim ins, invoice, id
  Set ins = new InsertClass
  Set invoice = CreateObject("Scripting.Dictionary")
  assertNotValidInvoice ins, invoice
  invoice.Add "number", "1017"
  assertNotValidInvoice ins, invoice
  invoice.Add "customerId", "ABC"
  assertValidInvoice ins, invoice
  invoice.Add "items", CreateObject("Scripting.Dictionary")
  assertValidInvoice ins, invoice
  invoice.Item("items").Add 0, CreateObject("Scripting.Dictionary")
  assertNotValidInvoice ins, invoice
  Dim item
  Set item = invoice.Item("items").Item(0)
  item.Add "name", "Wireless +"
  assertNotValidInvoice ins, invoice
  item.Add "unitPrice", 50.12
  assertNotValidInvoice ins, invoice
  item.Add "quantity", 0.3
  assertNotValidInvoice ins, invoice
  item.Add "unit", "mies."
  assertNotValidInvoice ins, invoice
  item.Add "vatId", 100002
  assertValidInvoice ins, invoice
  id = ins.validateInvoice(invoice)
  assert (id = "1017"), "fetch invoice number"
  ' WScript.Echo dumpMap(invoice, 0)
  invoice.Item("items").Add 1, CreateObject("Scripting.Dictionary")
  assertNotValidInvoice ins, invoice
End Sub

Private Sub assertValidInvoice(ins, inv)
  ins.validateInvoice(inv)
End Sub

Private Sub assertNotValidInvoice(ins, inv)
  Dim error
  On Error Resume Next
  assertValidInvoice ins, inv
  error = Err.Number
  On Error Goto 0
  Err.Clear
  If error = 0 Then Err.Raise 999, "assertNotValidInvoice", "invoice was valid"
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
  item.Add "vatId", 100002
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

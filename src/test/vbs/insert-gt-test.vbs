Option Explicit

include "../../main/vbs/insert-gt"
include "../../main/vbs/map-utils"

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
  assertNotValidInvoice ins, invoice, "empty"
  invoice.Add "number", "1017"
  assertNotValidInvoice ins, invoice, "number added"
  invoice.Add "customerId", "ABC"
  assertNotValidInvoice ins, invoice, "customerId added"
  invoice.Add "invoiceDate", "2014-04-15"
  assertNotValidInvoice ins, invoice, "invoiceDate added"
  invoice.Add "dueDate", "2014-04-22"
  assertNotValidInvoice ins, invoice, "dueDate added"
  invoice.Add "deliveryDate", "2014-04-30"
  assertValidInvoice ins, invoice, "deliveryDate added"
  invoice.Add "items", CreateObject("Scripting.Dictionary")
  assertValidInvoice ins, invoice, "empty items added"
  invoice.Item("items").Add 0, CreateObject("Scripting.Dictionary")
  assertNotValidInvoice ins, invoice, "empty item added"
  Dim item
  Set item = invoice.Item("items").Item(0)
  item.Add "name", "Wireless +"
  assertNotValidInvoice ins, invoice, "item.name added"
  item.Add "unitPrice", 50.12
  assertNotValidInvoice ins, invoice, "item.unitPrice added"
  item.Add "quantity", 0.3
  assertNotValidInvoice ins, invoice, "item.quantity added"
  item.Add "unit", "mies."
  assertNotValidInvoice ins, invoice, "item.unit added"
  item.Add "vatId", 100002
  assertNotValidInvoice ins, invoice, "item.vatId added"
  item.Add "vatPct", 23
  assertValidInvoice ins, invoice, "item.vatPct added"
  id = ins.validateInvoice(invoice)
  assert (id = "1017"), "fetch invoice number"
  item.Item("name") = "123456789012345678901234567890123456789012345678901"
  assertNotValidInvoice ins, invoice, "item.name to 50 chars"
  item.Item("name") = "12345678901234567890123456789012345678901234567890"
  assertValidInvoice ins, invoice, "item.name 50 chars"

  ' WScript.Echo dumpMap(invoice, 0)
  invoice.Item("items").Add 1, CreateObject("Scripting.Dictionary")
  assertNotValidInvoice ins, invoice, "second item empty"
End Sub

Private Sub assertValidInvoice(ins, inv, msg)
  Dim error
  On Error Resume Next
  ins.validateInvoice(inv)
  error = Err.Number
  On Error Goto 0
  Err.Clear
  If error <> 0 Then Err.Raise 999, "assertValidInvoice", "invoice is not valid '" & msg & "'"
End Sub

Private Sub assertNotValidInvoice(ins, inv, msg)
  Dim error
  On Error Resume Next
  ins.validateInvoice(inv)
  error = Err.Number
  On Error Goto 0
  Err.Clear
  If error = 0 Then Err.Raise 999, "assertNotValidInvoice", "invoice is valid '" & msg & "'"
End Sub

Sub testAddInvoice
  WScript.Echo "# it should add invoice"
  Dim ins, invoice
  Set ins = insertOf("Subiekt.xml")
  Set invoice = CreateObject("Scripting.Dictionary")
  ' invoice.Add "number", 5018
  invoice.Add "customerId", "ABC"
  invoice.Add "invoiceDate", "2014-04-15"
  invoice.Add "dueDate", "2014-04-22"
  invoice.Add "deliveryDate", "2014-04-30"
  invoice.Add "items", CreateObject("Scripting.Dictionary")
  invoice.Item("items").Add 0, CreateObject("Scripting.Dictionary")
  Dim item
  Set item = invoice.Item("items").Item(0)
  item.Add "name", "Wireless +"
  item.Add "unitPrice", "50.5"
  item.Add "quantity", "1.2"
  item.Add "unit", "mies."
  item.Add "vatId", "100001"
  item.Add "vatPct", "23"
  ins.addInvoice(invoice)
End Sub

Sub testInsertStart
  WScript.Echo "# it should start InsERT GT application"
  Dim ins
  Set ins = insertOf("Subiekt.xml")
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

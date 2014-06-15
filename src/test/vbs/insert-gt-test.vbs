Option Explicit

include "../../main/vbs/insert-gt"
include "../../main/vbs/map-utils"

testAll

Sub testAll
  WScript.Echo "TEST InsERT GT..."
  ' testUpdateBusinessToResidentialCustomer
  ' testUpdateResidentialToBusinessCustomer
  testValidateCustomer
  ' testBoolean
  ' testUpdateBusinessCustomer
  ' testUpdateResidentialCustomer
  ' testAddBusinessCustomer
  ' testAddResidentialCustomer
  ' testInsertStart
  ' testAddInvoice
  testValidateInvoice
  WScript.Echo "PASSED"
End Sub

Sub testBoolean
  WScript.Echo "# it should recognize boolean value"
  Dim value, bool
  value = "true"
  bool = CBool(value)
  ' WScript.Echo "'" & value & "' -> " & bool
End Sub

Sub testValidateCustomer
  WScript.Echo "# it should validate customer"
  Dim ins, customer, id
  Set ins = new InsertClass
  Set customer = CreateObject("Scripting.Dictionary")
  assertNotValidCustomer ins, customer, "empty"
  customer.Add "surrogateId", "12345"
  assertNotValidCustomer ins, customer, "surrogateId added"
  customer.Add "isNew", "true"
  assertNotValidCustomer ins, customer, "isNew added"
  customer.Add "isBusiness", "false"
  assertNotValidCustomer ins, customer, "isBusiness added"
  customer.Add "name", "1234567890123456789012345678901234567890123456789012"
  assertNotValidCustomer ins, customer, "too long name added"
  customer.Item("name") = "123456789012345678901234567890123456789012345678901"
  assertNotValidCustomer ins, customer, "name added"
  customer.Item("fullName") = "Customer Full Name"
  assertNotValidCustomer ins, customer, "full name added"
  Dim address
  Set address = CreateObject("Scripting.Dictionary")
  customer.Add "address", address
  assertNotValidCustomer ins, customer, "address added"
  address.Add "street", "Street"
  assertNotValidCustomer ins, customer, "address.street added"
  address.Add "city", "City"
  assertNotValidCustomer ins, customer, "address.city added"
  address.Add "postalCode", "12345"
  assertNotValidCustomer ins, customer, "address.postalCode added"
  customer.Add "email", "name@server.com"
  assertNotValidCustomer ins, customer, "email added"
  customer.Add "publicId", "12345"
  assertValidCustomer ins, customer, "final validation"
  ' WScript.Echo dumpMap(customer, 0)
End Sub

Sub testUpdateBusinessCustomer
  Dim ins, customer, surrogateId, address
  surrogateId = testAddBusinessCustomer()
  WScript.Echo "# it should update business customer '" & surrogateId & "'"
  Set customer = CreateObject("Scripting.Dictionary")
  customer.Add "surrogateId", surrogateId
  customer.Add "isBusiness", true
  customer.Add "name", "Updated Name"
  customer.Add "fullName", "Updated Full Name"
  Set address = sampleAddress()
  address.Item("street") = "Updated Street"
  address.Item("streetNumber") = 99
  address.Item("premiseNumber") = 9
  address.Item("city") = "Updated City"
  address.Item("postalCode") = 99999
  customer.Add "address", address
  customer.Add "email", "updated@city.pl"
  customer.Add "phone", "99999999"
  customer.Add "publicId", "9" & uniqueId()
  customer.Add "vatId", "9" & uniqueId()
  customer.Add "bankAccount", "999999999999920252692626"
  Set ins = insertOf("Subiekt.xml")
  ins.updateCustomer(customer)
End Sub

Sub testUpdateResidentialCustomer
  Dim ins, customer, surrogateId, address
  surrogateId = testAddResidentialCustomer()
  WScript.Echo "# it should update residential customer '" & surrogateId & "'"
  Set customer = CreateObject("Scripting.Dictionary")
  customer.Add "surrogateId", surrogateId
  customer.Add "isBusiness", false
  customer.Add "name", "Updated Name"
  customer.Add "fullName", "Updated Full Name"
  Set address = sampleAddress()
  address.Item("street") = "Updated Street"
  address.Item("streetNumber") = 99
  address.Item("premiseNumber") = 9
  address.Item("city") = "Updated City"
  address.Item("postalCode") = 99999
  customer.Add "address", address
  customer.Add "email", "updated@city.pl"
  customer.Add "phone", "99999999"
  customer.Add "publicId", "9" & uniqueId()
  customer.Add "bankAccount", "999999999999920252692626"
  Set ins = insertOf("Subiekt.xml")
  ins.updateCustomer(customer)
End Sub

Sub testUpdateResidentialToBusinessCustomer
  Dim ins, customer, surrogateId, stamp
  surrogateId = testAddResidentialCustomer()
  WScript.Echo "# it should update residential to business customer '" & surrogateId & "'"
  Set customer = CreateObject("Scripting.Dictionary")
  customer.Add "surrogateId", surrogateId
  customer.Add "isBusiness", true
  customer.Add "name", "Updated Business Customer"
  customer.Add "fullName", "Updated Business Full Name"
  customer.Add "address", sampleAddress()
  customer.Add "email", "some@city.pl"
  customer.Add "phone", "123456789"
  stamp = uniqueId()
  customer.Add "publicId", "" & stamp
  customer.Add "vatId", "" & stamp
  customer.Add "bankAccount", "06114020040000320252692626"
  Set ins = insertOf("Subiekt.xml")
  ins.updateCustomer(customer)
End Sub

Sub testUpdateBusinessToResidentialCustomer
  Dim ins, customer, surrogateId, stamp, expected
  surrogateId = testAddBusinessCustomer()
  WScript.Echo "# it should update business to residential customer '" & surrogateId & "'"
  Set customer = CreateObject("Scripting.Dictionary")
  customer.Add "surrogateId", surrogateId
  customer.Add "isBusiness", false
  customer.Add "name", "Updated Residential"
  customer.Add "fullName", "Updated Residential Full Name"
  customer.Add "address", sampleAddress()
  customer.Add "email", "some@city.pl"
  customer.Add "phone", "123456789"
  stamp = uniqueId()
  customer.Add "publicId", "" & stamp
  customer.Add "bankAccount", "06114020040000320252692626"
  Set ins = insertOf("Subiekt.xml")
  On Error Resume Next
  ins.updateCustomer(customer)
  expected = Err.Number
  On Error Goto 0
  If expected <> 1001 Then Err.Raise 99999, "test", "expected exception but was none"
End Sub


Function testAddBusinessCustomer
  WScript.Echo "# it should add new business customer"
  Dim ins, customer, surrogateId, stamp
  Set customer = CreateObject("Scripting.Dictionary")
  stamp = uniqueId()
  surrogateId = "PL-" & stamp
  customer.Add "surrogateId", surrogateId
  customer.Add "isBusiness", true
  customer.Add "name", "Name up to 51 characters..........................X"
  customer.Add "fullName", "Name over 51 characters..........................XXXXXXXXXXX"
  customer.Add "address", sampleAddress()
  customer.Add "email", "some@city.pl"
  customer.Add "phone", "123456789"
  customer.Add "publicId", "" & stamp
  customer.Add "vatId", "" & stamp
  customer.Add "bankAccount", "06114020040000320252692626"
  Set ins = insertOf("Subiekt.xml")
  ins.addCustomer(customer)
  testAddBusinessCustomer = surrogateId
End Function

Function testAddResidentialCustomer
  WScript.Echo "# it should add new residential customer"
  Dim ins, customer, surrogateId, stamp
  Set ins = insertOf("Subiekt.xml")
  Set customer = CreateObject("Scripting.Dictionary")
  stamp = uniqueId()
  surrogateId = "PL-" & stamp
  customer.Add "surrogateId", surrogateId
  customer.Add "isBusiness", false
  customer.Add "name", "Nowak Jan"
  customer.Add "fullName", "Name over 51 characters..........................XXXXXXXXXXX"
  customer.Add "address", sampleAddress()
  customer.Add "email", "some@city.pl"
  customer.Add "phone", "123456789"
  customer.Add "publicId", "" & uniqueId()
  customer.Add "bankAccount", "06114020040000320252692626"
  ins.addCustomer(customer)
  testAddResidentialCustomer = surrogateId
End Function

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
  assertNotValidInvoice ins, invoice, "deliveryDate added"
  invoice.Add "totalNet", "50.12"
  assertValidInvoice ins, invoice, "totalNet added"
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

Private Function sampleAddress()
  Dim address
  Set address = CreateObject("Scripting.Dictionary")
  address.Add "street", "Street"
  address.Add "streetNumber", "17"
  address.Add "premiseNumber", "3"
  address.Add "city", "Opole"
  address.Add "postalCode", "12345"
  Set sampleAddress = address
End Function

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

Private Sub assertValidCustomer(ins, customer, msg)
  Dim error
  On Error Resume Next
  ins.validateCustomer(customer)
  error = Err.Number
  On Error Goto 0
  Err.Clear
  If error <> 0 Then Err.Raise 999, "assertValidCustomer", "customer is not valid '" & msg & "'"
End Sub

Private Sub assertNotValidCustomer(ins, customer, msg)
  Dim error
  On Error Resume Next
  ins.validateCustomer(customer)
  error = Err.Number
  On Error Goto 0
  Err.Clear
  If error = 0 Then Err.Raise 999, "assertNotValidCustomer", "customer is valid '" & msg & "'"
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
  invoice.Add "accountantName", "Jan Kowalski"
  invoice.Add "totalNet", "73.2"
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
  invoice.Item("items").Add 1, CreateObject("Scripting.Dictionary")
  Set item = invoice.Item("items").Item(1)
  item.Add "name", "Wireless ++"
  item.Add "unitPrice", "10.5"
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

Function uniqueId()
  ' uniqueId() = DateDiff("s", "01/01/1970 00:00:00", Now())
  uniqueId = Replace("" & Timer(), ",", "")
End Function

Sub assert(cond, msg)
  If Not cond Then
    WScript.Echo "FAILED: " & msg
    WScript.Quit -1
  End If
End Sub

Sub include(file)
  ExecuteGlobal CreateObject("Scripting.FileSystemObject").OpenTextFile(file & ".vbs").readAll()
End Sub

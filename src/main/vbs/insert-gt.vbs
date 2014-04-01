Option Explicit

Const gtaProduktSubiekt = 1
Const gtaSubiektDokumentFS = -2
Const gtaUruchomDopasuj = 0
Const gtaUruchom = 0
Const gtaUruchomNieZablokowany = 1
Const gtaUruchomWTle = 4

Function insertOf(config)
  Dim insert
  Set insert = new InsertClass
  insert.configure(config)
  Set insertOf = insert
End Function

Class InsertClass
  Private isInitialized
  Private config
  Private instance

  Private Sub Class_Initialize
    debug "creating InsERT GT"
    isInitialized = False
  End Sub

  Private Sub Class_Terminate
    debug "destroying InsERT GT"
    If isInitialized Then
      instance.Zakoncz
    End If
  End Sub

  Public Sub configure(file)
    debug "configuring InsERT GT with '" & file & "'"
    assertNotInitialized
    Dim oGT
    debug "creating GT"
    Set oGT = CreateObject("InsERT.GT")
    oGT.Produkt = gtaProduktSubiekt
    oGT.Wczytaj(file)
    Set instance = oGT.Uruchom(gtaUruchomDopasuj, gtaUruchomWTle)
    isInitialized = True
  End Sub

  Public Function validateInvoice(data)
    assertHasLength data, "number", "invoice number is missing"
    assertHasLength data, "customerId", "customer id is missing"
    If data.Exists("items") Then
      Dim items, itemKey, itemData
      Set items = data.Item("items")
      For Each itemKey In items.Keys
        Set itemData = items.Item(itemKey)
        assertHasLength itemData, "name", "item name is missing"
        assertIsNumeric itemData, "unitPrice", "unit price is missing or invalid"
        assertIsNumeric itemData, "quantity", "quantity is missing or invalid"
        assertHasLength itemData, "unit", "unit is missing"
        assertIsNumeric itemData, "vatId", "vatId is missing or invalid"
      Next
    End If
    validateInvoice = data.Item("number")
  End Function

  Public Sub addInvoice(data)
    assertInitialized
    Dim invoice, itemIdx, itemObj, itemsCol, invoiceItem
    Set invoice = instance.Dokumenty.Dodaj(gtaSubiektDokumentFS)
    invoice.Numer = data.Item("number")
    invoice.KontrahentId = data.Item("customerId")
    Set itemsCol = data.Item("items")
    For Each itemIdx In itemsCol
      debug itemIdx
      Set itemObj = itemsCol.Item(itemIdx)
      Set invoiceItem = invoice.Pozycje.DodajUslugeJednorazowa()
      invoiceItem.UslJednNazwa = itemObj.Item("name")
      invoiceItem.CenaNettoPrzedRabatem = itemObj.Item("unitPrice")
      invoiceItem.IloscJm = itemObj.Item("quantity")
      invoiceItem.Jm = itemObj.Item("unit")
      invoiceItem.VatId = itemObj.Item("vatId")
      invoice.Zapisz
      invoice.Zamknij
    Next
  End Sub

  Public Function validateCustomer(data)
  End Function

  Public Sub addCustomer(data)
    assertInitialized
  End Sub

  Private Sub assertHasLength(data, field, msg)
    If Not hasLength(data, field) Then Err.Raise 1001, "validate", msg
  End Sub

  Private Sub assertIsNumeric(data, field, msg)
    If Not isNumericValue(data, field) Then Err.Raise 1001, "validate", msg
  End Sub

  Private Function isNumericValue(data, field)
    isNumericValue = False
    If data.Exists(field) Then
      If IsNumeric(data.Item(field)) Then isNumericValue = True
    End If
  End Function

  Private Function hasLength(data, field)
    hasLength = False
    If data.Exists(field) Then
      If Len(Trim("" & data.Item(field))) > 0 Then hasLength = True
    End If
  End Function

  Private Sub assertNotInitialized
    If isInitialized Then Err.Raise 1, "InsERT GT", "already initialized"
  End Sub

  Private Sub assertInitialized
    If Not isInitialized Then Err.Raise 2, "InsERT GT", "not initialized"
  End Sub

  Private Sub debug(msg)
    ' WScript.Echo msg
  End Sub

  Sub assert(cond, msg)
    If Not cond Then
      debug "FAILED: " & msg
      Err.Raise 1001, "insert-gt", msg
    End If
  End Sub

End Class

Class FakeInsertGtClass
  Public Function validateInvoice(doc)
    validateInvoice = 1
  End Function

  Public Sub addInvoice(doc)
  End Sub

  Public Function validateCustomer(doc)
    validateCustomer = 2
  End Function

  Public Sub addCustomer(doc)
  End Sub
End Class

Class InvoiceSinkClass
  Private insertGt

  Public Sub setInsertGt(aInsertGt)
    Set insertGt = aInsertGt
  End Sub

  Public Function validate(doc)
    validate = insertGt.validateInvoice(doc)
  End Function

  Public Sub add(doc)
    insertGt.addInvoice(doc)
  End Sub
End Class

Class CustomerSinkClass
  Private insertGt

  Public Sub setInsertGt(aInsertGt)
    Set insertGt = aInsertGt
  End Sub

  Public Function validate(doc)
    validate = insertGt.validateCustomer(doc)
  End Function

  Public Sub add(doc)
    insertGt.addCustomer(doc)
  End Sub
End Class

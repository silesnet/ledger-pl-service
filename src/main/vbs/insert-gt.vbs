Option Explicit

Const gtaProduktSubiekt = 1
Const gtaSubiektDokumentFS = -2
Const gtaUruchomDopasuj = 0
Const gtaUruchom = 0
Const gtaUruchomNieZablokowany = 1
Const gtaUruchomWTle = 4
Const gtaKontrahentTypOdbiorca = 2
Const gtaPanstwoPL = 1
Const gtaPanstwoCZ = 2
Const gtaPanstwoSK = 3
Const gtaMaxName = 51

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

  Public Function invoiceId(data)
    invoiceId = data.Item("originalNumber")
  End Function

  Public Function validateInvoice(data)
    assertHasLength data, "number", "invoice number 'number' is missing"
    assertHasLength data, "originalNumber", "original invoice number 'number' is missing"
    assertHasLength data, "customerId", "customer id 'customerId' is missing"
    assertIsDate data, "invoiceDate", "invoice date 'invoiceDate' is invalid or missing"
    assertIsDate data, "dueDate", "due date 'dueDate' is invalid or missing"
    assertIsDate data, "deliveryDate", "due date 'dueDate' is invalid or missing"
    assertIsNumeric data, "totalNet", "total Net 'totalNet' is invalid or missing"
    If data.Exists("items") Then
      Dim items, itemKey, itemData
      Set items = data.Item("items")
      For Each itemKey In items.Keys
        Set itemData = items.Item(itemKey)
        assertHasLength itemData, "name", "item name 'items[].name' is missing"
        assertLengthIsUpTo itemData, "name", 50, "item name 'items[].name' is too long (max length 50)"
        assertIsNumeric itemData, "unitPrice", "unit price 'items[].unitPrice' is invalid or missing"
        assertIsNumeric itemData, "quantity", "quantity 'items[].quantity' is invalid or missing"
        assertHasLength itemData, "unit", "unit 'items[].unit' is missing"
        assertIsNumeric itemData, "vatId", "vatId 'items[].vatId' is invalid or missing"
        assertIsNumeric itemData, "vatPct", "vat percentage 'items[].vatPct' is invalid or missing"
      Next
    End If
    validateInvoice = data.Item("originalNumber")
  End Function

  Public Sub addInvoice(data)
    assertInitialized
    Dim invoice, itemIdx, itemObj, itemsCol, invoiceItem
    Set invoice = instance.Dokumenty.Dodaj(gtaSubiektDokumentFS)
    invoice.AutoPrzeliczanie = False
    invoice.Numer = data.Item("number")
    invoice.KontrahentId = data.Item("customerId")
    invoice.DataWystawienia = fromIsoDate(data.Item("invoiceDate"))
    invoice.DataZakonczeniaDostawy = fromIsoDate(data.Item("deliveryDate"))
    invoice.Wystawil = data.Item("accountantName")
    Set itemsCol = data.Item("items")
    For Each itemIdx In itemsCol
      debug itemIdx
      Set itemObj = itemsCol.Item(itemIdx)
      Set invoiceItem = invoice.Pozycje.DodajUslugeJednorazowa()
      invoiceItem.UslJednNazwa = itemObj.Item("name")
      invoiceItem.CenaNettoPrzedRabatem = toNumber(itemObj.Item("unitPrice"))
      invoiceItem.IloscJm = toNumber(itemObj.Item("quantity"))
      invoiceItem.Jm = itemObj.Item("unit")
      invoiceItem.VatId = CLng(itemObj.Item("vatId"))
      If invoiceItem.VatProcent <> CInt(itemObj.Item("vatPct")) Then
        Err.Raise 1002, "addInvoice", "vatId '" & itemObj.Item("vatId") & "' and vatPct '"  & itemObj.Item("vatPct") & "' does not match"
      End If
    Next
    invoice.Przelicz
    invoice.PlatnoscKredytKwota = invoice.KwotaDoZaplaty
    invoice.PlatnoscKredytTermin = fromIsoDate(data.Item("dueDate"))
    If invoice.WartoscNetto <> Cdbl(toNumber(data.Item("totalNet"))) Then
      Err.Raise 1002, "addInvoice", "totalNet '" & toNumber(data.Item("totalNet")) & "' does not match invoice.WartoscNetto '"  & invoice.WartoscNetto & "'"
    End If
    invoice.Zapisz
    invoice.Zamknij
  End Sub

  Public Function customerId(data)
    customerId = data.Item("id")
  End Function

  Public Function validateCustomer(data)
    assertHasLength data, "surrogateId", "'surrogateId' is missing"
    assertIsBoolean data, "isNew", "'isNew' is missing"
    assertIsBoolean data, "isBusiness", "'isBusiness' is missing"
    assertHasLength data, "name", "'name' is missing"
    If Len(data.Item("name")) > gtaMaxName Then Err.Raise 1001, "validate", "name is over " & gtaMaxName & " characters"
    assertHasLength data, "fullName", "'fullName' is missing"
    If Not data.Exists("address") Then Err.Raise 1001, "validate", "'address' is missing"
    Dim address
    Set address = data.Item("address")
    assertHasLength address, "street", "'address.street' is missing"
    assertHasLength address, "city", "'address.city' is missing"
    assertHasLength address, "postalCode", "'address.postalCode' is missing"
    ' assertHasLength data, "email", "'email' is missing"
    assertHasLength data, "publicId", "'publicId' is missing"
    validateCustomer = data.Item("id")
  End Function

  Public Sub addCustomer(data)
    assertInitialized
    Dim customer, address, phone, account
    assert (Not instance.Kontrahenci.Istnieje(data.Item("surrogateId"))), _
      "customer with surrogateId '" & data.Item("surrogateId") & "' already exists"
    Set customer = instance.Kontrahenci.Dodaj()
    customer.Typ = gtaKontrahentTypOdbiorca
    customer.Symbol = data.Item("surrogateId")
    Set address = data.Item("address")
    customer.Ulica = address.Item("street")
    customer.NrDomu = address.Item("streetNumber")
    customer.NrLokalu = address.Item("premiseNumber")
    customer.Miejscowosc = address.Item("city")
    customer.KodPocztowy = address.Item("postalCode")
    customer.Panstwo = gtaPanstwoPL
    If data.Exists("email") Then
      customer.Email = data.Item("email")
    End If
    If data.Exists("phone") Then
      Set phone = customer.Telefony.Dodaj("")
      phone.Numer = data.Item("phone")
    End If
    If data.Exists("bankAccount") Then
      Set account = customer.Rachunki.Dodaj("")
      account.Bank = "bank"
      account.Numer = data.Item("bankAccount")
    End If
    If CBool(data.Item("isBusiness")) Then
      customer.Osoba = False
      customer.Nazwa = data.Item("name")
      customer.NazwaPelna = data.Item("fullName")
      customer.REGON = data.Item("publicId")
      customer.NIP = data.Item("vatId")
    Else
      customer.Osoba = True
      customer.OsobaImie = name(data.Item("name"))
      customer.OsobaNazwisko = surname(data.Item("name"))
      customer.NazwaPelna = data.Item("fullName")
      customer.WlascicielPesel = data.Item("publicId")
    End If
    customer.Zapisz
    customer.Zamknij
  End Sub

  Public Sub updateCustomer(data)
    assertInitialized
    Dim customer, address, phone, account, i, wasResidential, updated
    assert (instance.Kontrahenci.Istnieje(data.Item("surrogateId"))), _
      "customer with surrogateId '" & data.Item("surrogateId") & "' does not exists"
    Set customer = instance.Kontrahenci.Wczytaj(data.Item("surrogateId"))
    Set address = data.Item("address")
    customer.Ulica = address.Item("street")
    customer.NrDomu = address.Item("streetNumber")
    customer.NrLokalu = address.Item("premiseNumber")
    customer.Miejscowosc = address.Item("city")
    customer.KodPocztowy = address.Item("postalCode")
    customer.Panstwo = gtaPanstwoPL
    If data.Exists("email") Then
      customer.Email = data.Item("email")
    End If
    If data.Exists("phone") Then
      updated = False
      For i = 1 To customer.Telefony.Liczba
        Set phone = customer.Telefony.Element(i)
        If phone.Nazwa = "" Then
          phone.Numer = data.Item("phone")
          updated = True
        End If
      Next
      If Not updated Then
        Set phone = customer.Telefony.Dodaj("")
        phone.Numer = data.Item("phone")
      End If
    Else
      For i = 1 To customer.Telefony.Liczba
        Set phone = customer.Telefony.Element(i)
        If phone.Nazwa = "" Then
          phone.Usun
        End If
      Next
    End If
    If data.Exists("bankAccount") Then
      updated = False
      For i = 1 To customer.Rachunki.Liczba
        Set account = customer.Rachunki.Element(i)
        If account.Bank = "bank" Then
          account.Numer = data.Item("bankAccount")
          updated = True
        End If
      Next
      If Not updated Then
        Set account = customer.Rachunki.Dodaj("")
        account.Bank = "bank"
        account.Numer = data.Item("bankAccount")
      End If
    Else
      For i = 1 To customer.Rachunki.Liczba
        Set account = customer.Rachunki.Element(i)
        If account.Bank = "bank" Then
          ' cannot remove 'Usun' as InsERT throws unknow integrity error
          account.Numer = ""
        End If
      Next
    End If
    wasResidential = customer.Osoba
    If CBool(data.Item("isBusiness")) Then
      If Not wasResidential Then
        debug "switching from residential to business"
      End If
      customer.Osoba = False
      customer.Nazwa = data.Item("name")
      customer.NazwaPelna = data.Item("fullName")
      customer.REGON = data.Item("publicId")
      customer.NIP = data.Item("vatId")
      customer.WlascicielPesel = ""
      customer.OsobaImie = ""
      customer.OsobaNazwisko = ""
    Else
      If Not wasResidential Then
        debug "switching from business to esidential"
        Err.Raise 1001, "updateCustomer", "cannot switch business customer to residential"
      End If
      customer.Osoba = True
      customer.OsobaImie = name(data.Item("name"))
      customer.OsobaNazwisko = surname(data.Item("name"))
      customer.NazwaPelna = data.Item("fullName")
      customer.WlascicielPesel = data.Item("publicId")
      customer.Nazwa = ""
      customer.NIP = ""
      customer.REGON = ""
    End If
    customer.Zapisz
    customer.Zamknij
  End Sub

  Private Function surname(fullName)
    surname = Left(fullName, InStr(fullName, " ") - 1)
  End Function

  Private Function name(fullName)
    name = Mid(fullName, InStr(fullName, " ") + 1)
  End Function

  Private Sub assertHasLength(data, field, msg)
    If Not hasLength(data, field) Then Err.Raise 1001, "validate", msg
  End Sub

  Private Sub assertIsNumeric(data, field, msg)
    If Not isNumericValue(data, field) Then Err.Raise 1001, "validate", msg
  End Sub

  Private Sub assertLengthIsUpTo(data, field, length, msg)
    If Not isLengthUpTo(data, field, length) Then Err.Raise 1001, "validate", msg
  End Sub

  Private Sub assertIsDate(data, field, msg)
    If Not isDateValue(data, field) Then Err.Raise 1001, "validate", msg
  End Sub

  Private Sub assertIsBoolean(data, field, msg)
    If Not isBoolean(data, field) Then Err.Raise 1001, "validate", msg
  End Sub

  Private Function isBoolean(data, field)
    Dim value
    isBoolean = False
    If data.Exists(field) Then
      value = CBool(data.Item(field))
      On Error Goto 0
      isBoolean = True
    End If
  End Function

  Private Function isNumericValue(data, field)
    isNumericValue = False
    If data.Exists(field) Then
      If IsNumeric(toNumber(data.Item(field))) Then isNumericValue = True
    End If
  End Function

  Private Function isDateValue(data, field)
    Dim tmp
    isDateValue = False
    If data.Exists(field) Then
      On Error Resume Next
      tmp = "" & fromIsoDate(data.Item(field))
      On Error Goto 0
      If tmp <> "" Then isDateValue = True
    End If
  End Function

  Private Function fromIsoDate(value)
    Dim tokens
    tokens = Split(value, "-")
    fromIsoDate = DateSerial(tokens(0), tokens(1), tokens(2))
  End Function

  Private Function hasLength(data, field)
    hasLength = False
    If data.Exists(field) Then
      If Len(Trim("" & data.Item(field))) > 0 Then hasLength = True
    End If
  End Function

  Private Function toNumber(value)
    toNumber = Replace(("" & value), ".", ",", 1, 1)
  End Function

  Private Function isLengthUpTo(data, field, length)
    isLengthUpTo = False
    If data.Exists(field) Then
      If Len(data.Item(field)) <= length Then isLengthUpTo = True
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
  Public Function invoiceId(data)
    invoiceId = data.Item("number")
  End Function

  Public Function validateInvoice(doc)
    validateInvoice = doc.Item("number")
  End Function

  Public Sub addInvoice(doc)
  End Sub

  Public Function customerId(data)
    customerId = data.Item("number")
  End Function

  Public Function validateCustomer(doc)
    validateCustomer = doc.Item("number")
  End Function

  Public Sub addCustomer(doc)
  End Sub

  Public Sub updateCustomer(doc)
  End Sub
End Class

Class InvoiceSinkClass
  Private insertGt

  Public Sub setInsertGt(aInsertGt)
    Set insertGt = aInsertGt
  End Sub

  Public Function docId(doc)
    docId = insertGt.invoiceId(doc)
  End Function

  Public Function validate(doc)
    validate = insertGt.validateInvoice(doc)
  End Function

  Public Sub update(doc)
    insertGt.addInvoice(doc)
  End Sub
End Class

Class CustomerSinkClass
  Private insertGt

  Public Sub setInsertGt(aInsertGt)
    Set insertGt = aInsertGt
  End Sub

  Public Function docId(doc)
    docId = insertGt.customerId(doc)
  End Function

  Public Function validate(doc)
    validate = insertGt.validateCustomer(doc)
  End Function

  Public Sub update(doc)
    If CBool(doc.Item("isNew")) Then
      insertGt.addCustomer(doc)
    Else
      insertGt.updateCustomer(doc)
    End If
  End Sub
End Class

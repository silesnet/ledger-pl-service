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
  End Function

  Public Function validateCustomer(data)
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
      invoiceItem.VatId = itemObj.Item("VAT")
      invoice.Zapisz
      invoice.Zamknij
    Next
  End Sub

  Public Sub addCustomer(data)
    assertInitialized
  End Sub

  Private Sub assertNotInitialized
    If isInitialized Then Err.Raise 1, "InsERT GT", "already initialized"
  End Sub

  Private Sub assertInitialized
    If Not isInitialized Then Err.Raise 2, "InsERT GT", "not initialized"
  End Sub

  Private Sub debug(msg)
    WScript.Echo msg
  End Sub
End Class

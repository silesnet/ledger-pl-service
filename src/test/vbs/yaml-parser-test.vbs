Option Explicit

include "../../main/vbs/yaml-parser"
include "../../main/vbs/map-utils"

testAll

Sub testAll
  WScript.Echo "TEST yaml-parser..."
  testParseEscapedChars
  testParseUtf8
  testParseLedgerInvoice
  testIterator
  testEmptyYaml
  testParsedValues
  testFetchCollection
  WScript.Echo "PASSED"
End Sub

Sub testParseEscapedChars()
  WScript.Echo "# it should parse escaped chars"
  Dim yaml
  Set yaml = yamlOf("fixtures/escaped.yml")
  Dim doc
  Set doc = yaml.nextDocument()
  assertEqual doc, "regular", UTF8_Decode("šČąĘ")
  assertEqual doc, "quoted", "'NAME'"
  assertEqual doc, "quoted2", """NAME"""
  assertEqual doc, "escaped", "\n"
End Sub

Sub testParseUtf8()
  WScript.Echo "# it should parse utf8 strings"
  Dim yaml
  Set yaml = yamlOf("fixtures/utf8.yml")
  Dim doc, expected
  Set doc = yaml.nextDocument()
  expected = UTF8_Decode("""łą'""")
  assertEqual doc, "name", UTF8_Decode("""łą'""")
End Sub

Sub testParseLedgerInvoice
  WScript.Echo "# it should parse ledger invoice"
  Dim yaml
  Set yaml = yamlOf("fixtures/ledger-invoice.yml")
  Dim doc
  Set doc = yaml.nextDocument()
  assertEqual doc, "number", "4451"
  assertEqual doc, "customerId", "AB-5578"
  assertEqual doc, "invoiceDate", "2014-04-04"
  assertEqual doc, "dueDate", "2014-04-18"
  assertEqual doc, "items.0.name", "WIRELESSmax  10/2 Mbps, 04/2014"
  assertEqual doc, "items.0.unitPrice", 48
  assertEqual doc, "items.0.quantity", 1
  assertEqual doc, "items.0.unit", "mies."
  assertEqual doc, "items.0.vatId", 100001
  assertEqual doc, "items.0.vatPct", 23
  Set doc = yaml.nextDocument()
  assertEqual doc, "number", "4452"
  assertEqual doc, "customerId", "PL-1628"
  assertEqual doc, "invoiceDate", "2014-04-04"
  assertEqual doc, "dueDate", "2014-04-18"
  assertEqual doc, "items.0.name", "WIRELESSmax  25/2 Mbps, 04/2014"
  assertEqual doc, "items.0.unitPrice", "78.5"
  assertEqual doc, "items.0.quantity", "1.2"
  assertEqual doc, "items.0.unit", "mies."
  assertEqual doc, "items.0.vatId", 100001
  assertEqual doc, "items.0.vatPct", 23
End Sub

Sub testFetchCollection
  WScript.Echo "# it should fetch collections"
  Dim yaml
  Set yaml = yamlOf("fixtures/yaml-fixture.yml")
  Dim doc
  Set doc = yaml.nextDocument()
  Dim lines
  Set lines = doc.Item("lines")
  assert lines.Count = 2, "failded to fetch lines"
  Dim idx
  For Each idx in lines
    assert fetch(lines.Item(idx), "item") <> "x", "fetch item"
  Next
End Sub

Sub testParsedValues
  WScript.Echo "# it should parse document values"
  Dim yaml
  Set yaml = yamlOf("fixtures/yaml-fixture.yml")
  Dim doc
  Set doc = yaml.nextDocument()
  assertEqual doc, "number", "1234"
  assertEqual doc, "customer.name", "Cust 1"
  assertEqual doc, "lines.1.item", "Item 1/2"
  Set doc = yaml.nextDocument()
  assertEqual doc, "number", "1235"
  assertEqual doc, "customer.name", "Cust 2"
  assertEqual doc, "lines.1.item", ""
  Set doc = yaml.nextDocument()
  assertEqual doc, "number", "1236"
  assertEqual doc, "customer.name", "Cust 3"
  assertEqual doc, "lines.0.item", "Item 3/1"
  assertEqual doc, "lines.1.item", "Item 3/2"
  assertEqual doc, "lines.1.price", "0"
End Sub

Sub testEmptyYaml
  WScript.Echo "# it should not parse empty file"
  Dim yaml
  Set yaml = yamlOf("fixtures/yaml-empty.yml")
  assert Not yaml.hasNext(), "empty file should not have next"
End Sub

Sub testIterator
  WScript.Echo "# it should iterate over all documents"
  Dim yaml
  Set yaml = yamlOf("fixtures/yaml-fixture.yml")
  Dim doc
  While yaml.hasNext()
    Set doc = yaml.nextDocument()
    assert Not doc Is Nothing, "document not parsed"
  Wend
End Sub

Sub assert(cond, msg)
  If Not cond Then
    WScript.Echo "FAILED: " & msg
    WScript.Quit -1
  End If
End Sub

Sub assertEqual(doc, field, expected)
  Dim value, cond
  expected = "" & expected
  value = fetch(doc, field)
  cond = (value = expected)
  If Not cond Then
    WScript.Echo "NOT EQUAL: expected '" & expected & "', got '" & value & "'"
  End If
  assert cond, "fetch '" & field & "'"
End Sub

Sub include(file)
  ExecuteGlobal CreateObject("Scripting.FileSystemObject").openTextFile(file & ".vbs").readAll()
End Sub

Public Function toUtf8(astr)
  Dim c, n
  Dim utftext
  utftext = ""
  If isNull(astr) = false or astr <> "" Then
    astr = Replace(astr, "’", "'") 'replacing the apostrophe
    astr = Replace(astr, "–", "-") 'replacing the emdash with minus sign
    For n = 1 To Len(astr)
      c = Asc(Mid(astr, n, 1))
      If c < 128 Then
        utftext = utftext + Mid(astr, n, 1)
      ElseIf ((c > 127) And (c < 2048)) Then
        utftext = utftext + Chr(((c \ 64) Or 192))
        utftext = utftext + Chr(((c And 63) Or 128))
      Else
        utftext = utftext + Chr(((c \ 144) Or 234))
        utftext = utftext + Chr((((c \ 64) And 63) Or 128))
        utftext = utftext + Chr(((c And 63) Or 128))
      End If
    Next
  End If
  toUtf8 = utftext
End Function

'http://p2p.wrox.com/vbscript/29099-unicode-utf-8-system-text-utf8encoding-vba.html#post272370
Function UTF8_Decode(sStr)
    Dim l, sUTF8, iChar, iChar2
    For l = 1 To Len(sStr)
        iChar = Asc(Mid(sStr, l, 1))
        If iChar > 127 Then
            If Not iChar And 32 Then ' 2 chars
            iChar2 = Asc(Mid(sStr, l + 1, 1))
            sUTF8 = sUTF8 & ChrW(((31 And iChar) * 64 + (63 And iChar2)))
            l = l + 1
        Else
            Dim iChar3
            iChar2 = Asc(Mid(sStr, l + 1, 1))
            iChar3 = Asc(Mid(sStr, l + 2, 1))
            sUTF8 = sUTF8 & ChrW(((iChar And 15) * 16 * 256) + ((iChar2 And 63) * 64) + (iChar3 And 63))
            l = l + 2
        End If
            Else
            sUTF8 = sUTF8 & Chr(iChar)
        End If
    Next
    UTF8_Decode = sUTF8
End Function

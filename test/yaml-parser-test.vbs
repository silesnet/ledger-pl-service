Option Explicit

include "lib/yaml-parser"
include "lib/map-utils"

testAll

Sub testAll
  WScript.Echo "TEST yaml-parser..."
  testIterator
  testEmptyYaml
  testParsedValues
  testFetchCollection
  WScript.Echo "PASSED"
End Sub

Sub testFetchCollection
  WScript.Echo "# it should fetch collections"
  Dim yaml
  Set yaml = yamlOf("test/fixtures/yaml-fixture.yml")
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
  Set yaml = yamlOf("test/fixtures/yaml-fixture.yml")
  Dim doc
  Set doc = yaml.nextDocument()
  assert fetch(doc, "number") = "1234", "fetch 'number' failed"
  assert fetch(doc, "customer.name") = "Cust 1", "fetch 'customer.name' failed"
  assert fetch(doc, "lines.1.item") = "Item 1/2", "fetch 'lines.1.item' failed"
  Set doc = yaml.nextDocument()
  assert fetch(doc, "number") = "1235", "fetch 'number' failed"
  assert fetch(doc, "customer.name") = "Cust 2", "fetch 'customer.name' failed"
  assert fetch(doc, "lines.1.item") = "", "fetch 'lines.1.item' failed"
  Set doc = yaml.nextDocument()
  assert fetch(doc, "number") = "1236", "fetch 'number' failed"
  assert fetch(doc, "customer.name") = "Cust 3", "fetch 'customer.name' failed"
  assert fetch(doc, "lines.0.item") = "Item 3/1", "fetch 'lines.0.item' failed"
  assert fetch(doc, "lines.1.item") = "Item 3/2", "fetch 'lines.1.item' failed"
  assert fetch(doc, "lines.1.price") = "0", "fetch 'lines.1.price' failed"
End Sub

Sub testEmptyYaml
  WScript.Echo "# it should not parse empty file"
  Dim yaml
  Set yaml = yamlOf("test/fixtures/yaml-empty.yml")
  assert Not yaml.hasNext(), "empty file should not have next"
End Sub

Sub testIterator
  WScript.Echo "# it should iterate over all documents"
  Dim yaml
  Set yaml = yamlOf("test/fixtures/yaml-fixture.yml")
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

Sub include(file)
  ExecuteGlobal CreateObject("Scripting.FileSystemObject").openTextFile(file & ".vbs").readAll()
End Sub

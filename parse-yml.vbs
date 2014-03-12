Option Explicit

Dim input, FSO, inputFile, logFile
If WScript.Arguments.Count = 1 Then
  input = WScript.Arguments.Item(0)
Else
  WScript.Echo "Usage: import-invoices.vbs <input.csv>"
  WScript.Quit -1
End If

Set FSO = CreateObject("Scripting.FileSystemObject")
Set inputFile = FSO.OpenTextFile(input, 1)
Set logFile = FSO.CreateTextFile(input & ".log")

Do Until inputFile.AtEndOfStream
  Dim line, invoice
  Do Until inputFile.AtEndOfStream Or "---" = line
    line = inputFile.ReadLine
  Loop
  If "---" = line Then
    Set invoice = parseInvoice(inputFile, line)
    logFile.WriteLine "---"
    debug fetch(invoice, "number")
    debug fetch(invoice, "customer")
    debug fetch(invoice, "customer.name")
    debug fetch(invoice, "lines")
    debug fetch(invoice, "lines.1")
    debug fetch(invoice, "lines.1.item")
    logFile.WriteLine "---"
    debug dumpMap(invoice, 0)
    debug dump("invoice", invoice, 0)
  End If
Loop

logFile.Close
inputFile.Close

WScript.Quit 0

Function parseInvoice(input, line)
  Dim lineRegex, matches
  Dim hierarchy, parent, newCurrent, newItem, itemCounter
  Dim level, key, value, isNewItem, prevLevel, prevKey, prevValue
  Set lineRegex = new RegExp
  lineRegex.Pattern = "^(\s*\-?\s*)(\S+)\s*:(.*)$"
  Set hierarchy = CreateObject("Scripting.Dictionary")
  hierarchy.Add 0, CreateObject("Scripting.Dictionary")
  prevLevel = 0
  Do
    line = input.ReadLine
    If "---" = line Or "..." = line Then Exit Do
    Set matches = lineRegex.Execute(line)
    If matches.Count > 0 Then
      level = Len(matches(0).SubMatches(0))
      key = matches(0).SubMatches(1)
      value = Trim(matches(0).SubMatches(2))
      isNewItem = (InStr(matches(0).SubMatches(0), "-") > 0)
      If level > prevLevel Then
        If "" = prevValue Then
          Set newCurrent = CreateObject("Scripting.Dictionary")
          asoc hierarchy, level, newCurrent
          asoc hierarchy.Item(prevLevel), prevKey, newCurrent
          Set parent = newCurrent
          itemCounter = 0
        Else
          WScript.Echo "Input indetation error at line: '" & line & "'"
          WScript.Quit -1
        End If
      End If
      If isNewItem Then
        Set newItem = CreateObject("Scripting.Dictionary")
        parent.Add itemcounter, newItem
        itemCounter = itemCounter + 1
        asoc hierarchy, level, newItem
      End If
      asoc hierarchy.Item(level), key, value
      prevLevel = level
      prevKey = key
      prevValue = value
    End If
  Loop
  Set parseInvoice = hierarchy.Item(0)
End Function


Sub asoc(map, key, value)
  If map.Exists(key) Then
    If IsObject(value) Then
      Set map.Item(key) = value
    Else
      map.Item(key) = value
    End If
  Else
    map.Add key, value
  End If
End Sub

Function fetch(map, keys)
  debug "LOG: " & keys
  Dim parts, part, result, firstKey, remainingKeys, value
  result = ""
  parts = Split(keys, ".", 2)
  firstKey = parts(LBound(parts))
  If IsNumeric(firstKey) Then firstKey = CInt(firstKey)
  If (UBound(parts) - LBound(parts) = 0) Then
    debug "LOG: leaf"
    If IsObject(map.Item(firstKey)) Then
      debug "LOG: object"
      result = dumpMap(map.Item(firstKey), 2)
    Else
      debug "LOG: value"
      result = map.Item(firstKey)
    End If
  Else
    debug "LOG: compound"
    remainingKeys = parts(UBound(parts))
    result = fetch(map.Item(firstKey), remainingKeys)
  End If
  fetch = result
End Function

Sub debug(value)
  logFile.WriteLine value
End Sub

Function dump(key, value, level)
  Dim result
  result = prefix(level) & key & ":"
  If IsObject(value) Then
    result = result & vbLf & dumpMap(value, level + 2)
  Else
    result = result & " " & value
  End If
  dump = result
End Function

Function dumpMap(value, level)
  Dim result
  result = ""
  If IsObject(value) Then
    Dim innerKey
    For Each innerKey In value
      If result <> "" Then result = result & vbLf
      result = result & dump(innerKey, value.Item(innerKey), level)
    Next
  Else
    result = value
  End If
  dumpMap = result
End Function

Function prefix(level)
  prefix = Left("                    ", level)
End Function

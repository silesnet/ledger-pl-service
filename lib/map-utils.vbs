Function fetch(map, keys)
  Dim parts, part, result, firstKey, remainingKeys, value
  result = ""
  parts = Split(keys, ".", 2)
  firstKey = parts(LBound(parts))
  If IsNumeric(firstKey) Then firstKey = CInt(firstKey)
  If (UBound(parts) - LBound(parts) = 0) Then
    If IsObject(map.Item(firstKey)) Then
      result = dumpMap(map.Item(firstKey), 2)
    Else
      result = map.Item(firstKey)
    End If
  Else
    remainingKeys = parts(UBound(parts))
    result = fetch(map.Item(firstKey), remainingKeys)
  End If
  fetch = result
End Function

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

Option Explicit

Const adTypeText = 2
Const adReadLine = -2
Const adCRLF = -1
Const adLF = 10
Const adCR = 13

Function yamlOf(input)
  Dim yaml
  Set yaml = new YamlParserClass
  yaml.setInput input
  Set yamlOf = yaml
End Function

Class YamlParserClass
  Private isInitialized
  Private input
  Private currentLine
  Private lineRegex

  Private Sub Class_Initialize
    debug "creating yaml parser"
    Set lineRegex = new RegExp
    lineRegex.Pattern = "^(\s*\-?\s*)(\S+)\s*:(.*)$"
    isInitialized = False
  End Sub

  Private Sub Class_Terminate
    debug "destroying yaml parser"
    If isInitialized Then
      input.Close
      debug "yaml parser input file closed"
    End If
  End Sub

  Public Sub setInput(file)
    debug "initializing yaml parser with '" & file & "'"
    assertNotInitialized
    Set input = CreateObject("ADODB.Stream")
    input.Type = adTypeText
    input.CharSet = "utf-8"
    input.LineSeparator = adLF
    input.Open
    input.LoadFromFile file
    moveToNext
    isInitialized = True
  End Sub

  Public Function hasNext
    assertInitialized
    hasNext = (Not input.EOS) And (currentLine = "---")
  End Function

  Public Function nextDocument
    assertInitialized
    Dim matches, hierarchy, parent, newCurrent, newItem, itemCounter
    Dim level, key, value, isNewItem, prevLevel, prevKey, prevValue
    Set hierarchy = CreateObject("Scripting.Dictionary")
    hierarchy.Add 0, CreateObject("Scripting.Dictionary")
    prevLevel = 0
    Do
      currentLine = readLine()
      If input.EOS Or currentLine = "---" Or currentLine = "..." Then Exit Do
      If Left(LTrim(currentLine), 1) <> "#" Then
        Set matches = lineRegex.Execute(currentLine)
        If matches.Count > 0 Then
          level = Len(matches(0).SubMatches(0))
          key = matches(0).SubMatches(1)
          value = unQuote(Trim(matches(0).SubMatches(2)))
          isNewItem = (InStr(matches(0).SubMatches(0), "-") > 0)
          If level > prevLevel Then
            If "" = prevValue Then
              Set newCurrent = CreateObject("Scripting.Dictionary")
              asoc hierarchy, level, newCurrent
              asoc hierarchy.Item(prevLevel), prevKey, newCurrent
              Set parent = newCurrent
              itemCounter = 0
            Else
              Err.Raise 10, "YamlParser#nextDocument", "Input indentation error at line: '" & currentLine & "'"
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
        Else
          Err.Raise 11, "YamlParser#nextDocument", "Invalid input data format at line '" & currentLine & "'"
        End If
      End If
    Loop
    Set nextDocument = hierarchy.Item(0)
    moveToNext
  End Function

  Private Sub asoc(map, key, value)
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

  Private Sub moveToNext
    Do Until input.EOS Or currentLine = "---" Or currentLine = "..."
      currentLine = readLine()
    Loop
  End Sub

  Private Function readLine()
    readLine = input.ReadText(adReadLine)
  End Function

  Private Sub assertNotInitialized
    If isInitialized Then Err.Raise 1, "YamlParser", "already initialized"
  End Sub

  Private Sub assertInitialized
    If Not isInitialized Then Err.Raise 2, "YamlParser", "not initialized"
  End Sub

  Private Function unQuote(value)
    If Left(value, 1) = "'" And Right(value, 1) = "'" Then
      unQuote = Replace(Mid(value, 2, Len(value) - 2), "''", "'")
    Else
      unQuote = value
    End If
  End Function

  Private Sub debug(msg)
    'WScript.Echo msg
  End Sub
End Class

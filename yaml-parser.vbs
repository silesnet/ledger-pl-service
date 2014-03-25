Option Explicit

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
    Set input = CreateObject("Scripting.FileSystemObject").OpenTextFile(file, 1)
    moveToNext
    isInitialized = True
  End Sub

  Public Function hasNext
    assertInitialized
    hasNext = (Not input.AtEndOfStream) And (currentLine = "---")
  End Function

  Public Function nextDocument
    assertInitialized
    Dim matches, hierarchy, parent, newCurrent, newItem, itemCounter
    Dim level, key, value, isNewItem, prevLevel, prevKey, prevValue
    Set hierarchy = CreateObject("Scripting.Dictionary")
    hierarchy.Add 0, CreateObject("Scripting.Dictionary")
    prevLevel = 0
    Do
      currentLine = input.ReadLine
      If input.AtEndOfStream Or currentLine = "---" Or currentLine = "..." Then Exit Do
      If Left(LTrim(currentLine), 1) <> "#" Then
        Set matches = lineRegex.Execute(currentLine)
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
    Do Until input.AtEndOfStream Or currentLine = "---" Or currentLine = "..."
      currentLine = input.ReadLine
    Loop
  End Sub

  Private Sub assertNotInitialized
    If isInitialized Then Err.Raise 1, "YamlParser", "already initialized"
  End Sub

  Private Sub assertInitialized
    If Not isInitialized Then Err.Raise 2, "YamlParser", "not initialized"
  End Sub

  Private Sub debug(msg)
    'WScript.Echo msg
  End Sub
End Class

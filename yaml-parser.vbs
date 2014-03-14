Option Explicit

Function yamlOf(input)
  Dim yaml
  Set yaml = new YamlParser
  yaml.setInput input
  Set yamlOf = yaml
End Function

Class YamlParser
  Private isInitialized
  Private input
  Private currentLine

  Public Sub setInput(file)
    WScript.Echo "initializing yaml parser with '" & file & "'"
    checkIntegrity
    Set input = CreateObject("Scripting.FileSystemObject").OpenTextFile(file, 1)
    moveToNext
    isInitialized = True
  End Sub

  Public Function hasNext
    hasNext = (Not input.AtEndOfStream) And (currentLine = "---")
  End Function

  Private Sub moveToNext
    Do Until input.AtEndOfStream Or currentLine = "---" Or currentLine = "..."
      currentLine = input.ReadLine
    Loop  
  End Sub

  Private Sub Class_Initialize
    WScript.Echo "creating yaml parser"
    isInitialized = False
  End Sub

  Private Sub Class_Terminate
    WScript.Echo "destroying yaml parser"
    If isInitialized Then
      input.Close
      WScript.Echo "yaml parser input file closed"
    End If
  End Sub

  Private Sub checkIntegrity
    If isInitialized Then Err.Raise 1, "YamlParser", "already initialized"
  End Sub

End Class
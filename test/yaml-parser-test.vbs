Option Explicit

include "../yaml-parser"

Dim yaml
Set yaml = yamlOf("yaml-fixture.yml")

Sub include(file)
    ExecuteGlobal CreateObject("Scripting.FileSystemObject").openTextFile(file & ".vbs").readAll()
End Sub


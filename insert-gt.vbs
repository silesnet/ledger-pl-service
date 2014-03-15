Option Explicit

Function insertOf(config)
  Dim insert
  Set insert = new Insert
  insert.configure(config)
  Set insertOf = insert
End Function

Class Insert
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

    End If
  End Sub

  Public Sub configure(file)
    debug "configuring InsERT GT with '" & file & "'"
    assertNotInitialized
    Dim oGT, oSubiekt
    debug "creating GT"
    Set oGT = CreateObject("InsERT.GT")
    oGT.Produkt = 1 ' Subiekt
    oGT.Wczytaj(file)
    Set instance = oGT.Uruchom(0, 0)
    isInitialized = True
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

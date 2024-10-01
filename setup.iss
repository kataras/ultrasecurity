[Setup]
AppName=UltraSecurity
AppVersion=1.0
AppPublisher=kataras
AppPublisherURL=https://github.com/kataras
DefaultDirName={autopf}\UltraSecurity
DefaultGroupName=UltraSecurity
OutputDir=.
OutputBaseFilename=UltraSecuritySetup
Compression=lzma
SolidCompression=yes

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "ultrasecurity.zip"; DestDir: "{tmp}"; Flags: deleteafterinstall

[Icons]
Name: "{group}\UltraSecurity"; Filename: "{app}\ultrasecurity.exe"
Name: "{commondesktop}\UltraSecurity"; Filename: "{app}\ultrasecurity.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\ultrasecurity.exe"; Description: "{cm:LaunchProgram,UltraSecurity}"; Flags: nowait postinstall skipifsilent

[Code]
var
  Folder: string;
  Timeout: string;

function InputQuery(const ACaption, APrompt: string; var Value: string): Boolean;
var
  Form: TForm;
  Prompt: TLabel;
  Edit: TEdit;
  OKButton, CancelButton: TButton;
begin
  Result := False;
  Form := CreateCustomForm;
  try
    Form.Caption := ACaption;
    Form.ClientWidth := 300;
    Form.ClientHeight := 120;

    Prompt := TLabel.Create(Form);
    Prompt.Parent := Form;
    Prompt.Caption := APrompt;
    Prompt.Left := 8;
    Prompt.Top := 8;
    Prompt.Width := Form.ClientWidth - 16;

    Edit := TEdit.Create(Form);
    Edit.Parent := Form;
    Edit.Left := 8;
    Edit.Top := Prompt.Top + Prompt.Height + 8;
    Edit.Width := Form.ClientWidth - 16;
    Edit.Text := Value;

    OKButton := TButton.Create(Form);
    OKButton.Parent := Form;
    OKButton.Caption := 'OK';
    OKButton.ModalResult := mrOk;
    OKButton.Left := Form.ClientWidth div 2 - OKButton.Width - 4;
    OKButton.Top := Edit.Top + Edit.Height + 8;

    CancelButton := TButton.Create(Form);
    CancelButton.Parent := Form;
    CancelButton.Caption := 'Cancel';
    CancelButton.ModalResult := mrCancel;
    CancelButton.Left := Form.ClientWidth div 2 + 4;
    CancelButton.Top := OKButton.Top;

    Form.ActiveControl := Edit;

    if Form.ShowModal = mrOk then
    begin
      Value := Edit.Text;
      Result := True;
    end;
  finally
    Form.Free;
  end;
end;

procedure InitializeWizard;
begin
  // Set default values
  Folder := 'letsgo';
  Timeout := '10s';

  // Prompt user for folder name and timeout duration with default values
  if not InputQuery('Folder Name', 'Enter the folder name to monitor:', Folder) then
    WizardForm.Close;
  if not InputQuery('Timeout Duration', 'Enter the timeout duration (e.g., 10s, 15s):', Timeout) then
    WizardForm.Close;
end;

function IsGoInstalled: Boolean;
var
  ResultCode: Integer;
begin
  Result := Exec('go', 'version', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
  Result := (ResultCode = 0);
end;

function GetGoInstallerURL: string;
begin
  if IsWin64 then
  begin
    if ProcessorArchitecture = paARM64 then
      Result := 'https://go.dev/dl/go1.23.2.windows-arm64.msi'
    else
      Result := 'https://go.dev/dl/go1.23.2.windows-amd64.msi';
  end
  else
    Result := 'https://go.dev/dl/go1.23.2.windows-386.msi';
end;

procedure InstallGo;
var
  InstallerURL: string;
  ResultCode: Integer;
begin
  InstallerURL := GetGoInstallerURL();
  Exec('powershell', '-Command "Invoke-WebRequest -Uri ' + InstallerURL + ' -OutFile go.msi"', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
  if ResultCode = 0 then
    Exec('msiexec', '/i go.msi /quiet', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
end;

procedure ExtractZipFile(ZipFile, DestDir: string);
var
  ResultCode: Integer;
begin
  Exec('powershell', '-Command "Expand-Archive -Path ' + ZipFile + ' -DestinationPath ' + DestDir + '"', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
end;

procedure CurStepChanged(CurStep: TSetupStep);
var
  ResultCode: Integer;
  SrcDir, BuildDir, LogFile: string;
begin
  if CurStep = ssPostInstall then
  begin
    if not IsGoInstalled then
    begin
      MsgBox('Go is not installed. Installing Go...', mbInformation, MB_OK);
      InstallGo;
      if not IsGoInstalled then
      begin
        MsgBox('Failed to install Go. Please install it manually and try again.', mbError, MB_OK);
        Exit;
      end;
    end;

    SrcDir := ExpandConstant('{tmp}\src');
    BuildDir := ExpandConstant('{tmp}\src\ultrasecurity');
    ExtractZipFile(ExpandConstant('{tmp}\ultrasecurity.zip'), SrcDir);

    // Verbose output for debugging
    LogFile := ExpandConstant('{tmp}\build.log');
    MsgBox('Building the executable...', mbInformation, MB_OK);
    Exec('cmd.exe', '/C cd /d "' + BuildDir + '" && go build -tags "folder timeout" -ldflags="-X main.folder=' + Folder + ' -X main.timeout=' + Timeout + ' -H=windowsgui -s -w" -o "{app}\ultrasecurity.exe" > "' + LogFile + '" 2>&1', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
    if ResultCode <> 0 then
    begin
      MsgBox('Error building the executable. Please check your Go installation and try again. See build.log for details.', mbError, MB_OK);
      ShellExec('', 'notepad.exe', LogFile, '', SW_SHOWNORMAL, ewWaitUntilTerminated, ResultCode);
      Exit;
    end;
  end;
end;

procedure CurInstallProgressChanged(CurProgress, MaxProgress: Integer);
begin
  if CurProgress = MaxProgress then
  begin
    CreateShellLink(
      ExpandConstant('{userstartup}\UltraSecurity.lnk'),
      '',
      ExpandConstant('{app}\ultrasecurity.exe'),
      '',
      '',
      '',
      0,
      SW_SHOWNORMAL);
  end;
end;

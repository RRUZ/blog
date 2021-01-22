{$SetPEFlags 1}  //  remove relocation table

unit MainSFX;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls;

type
  TFrmMain = class(TForm)
    ButtonSelDir: TButton;
    EditPath: TEdit;
    ButtonExtract: TButton;
    ProgressBarSfx: TProgressBar;
    Label1: TLabel;
    procedure ButtonSelDirClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ButtonExtractClick(Sender: TObject);
  private
    procedure Extract;
    procedure DoProgress(Sender: TObject);
  public
  end;

var
  FrmMain: TFrmMain;

implementation
{$R *.dfm}

uses
ShlObj,
ZLib,
Common;

function SelectFolderCallbackProc(hwnd: HWND; uMsg: UINT; lParam: LPARAM; lpData: LPARAM): Integer; stdcall;
begin
  if (uMsg = BFFM_INITIALIZED) then
    SendMessage(hwnd, BFFM_SETSELECTION, 1, lpData);
  Result := 0;
end;

function SelectFolder(hwndOwner: HWND;const Caption: string; var InitFolder: string): Boolean;
var
  ItemIDList: PItemIDList;
  idlRoot: PItemIDList;
  Path: PAnsiChar;
  BrowseInfo: TBrowseInfo;
begin
  Result := False;
  Path := StrAlloc(MAX_PATH);
  SHGetSpecialFolderLocation(hwndOwner, CSIDL_DRIVES, idlRoot);
  with BrowseInfo do
  begin
    hwndOwner := GetActiveWindow;
    pidlRoot := idlRoot;
    SHGetSpecialFolderLocation(hwndOwner, CSIDL_DRIVES, idlRoot);
    pszDisplayName := StrAlloc(MAX_PATH);
    lpszTitle := PAnsiChar(Caption);
    lpfn := @SelectFolderCallbackProc;
    lParam := LongInt(PAnsiChar(InitFolder));
    ulFlags := BIF_RETURNONLYFSDIRS OR BIF_USENEWUI;
  end;

  ItemIDList := SHBrowseForFolder(BrowseInfo);
  if (ItemIDList <> nil) then
    if SHGetPathFromIDList(ItemIDList, Path) then
    begin
      InitFolder := Path;
      Result := True;
    end;
end;


procedure TFrmMain.Extract;
var
  DeCompressStream: TDeCompressionStream;
  ResourceStream: TResourceStream;
  DestFileStream: TFileStream;
  FileNameDest: String;
  RecSFX: TRecSFX;
begin

  if FindResource(0, 'SFXDATA', RT_RCDATA)=0 then
  begin
    Application.MessageBox('Sorry i am empty','Warning',MB_OK+MB_ICONWARNING);
    Exit;
  end
  else
  if FindResource(0, 'SFXREC', RT_RCDATA)=0 then
  begin
    Application.MessageBox('Sorry i dont have header data','Warning',MB_OK+MB_ICONWARNING);
    Exit;
  end;

 try
    ResourceStream:= TResourceStream.Create(0,'SFXREC',RT_RCDATA);
    try
        ResourceStream.Position:=0;
        Move(ResourceStream.Memory^,RecSFX,SizeOf(RecSFX));
        ProgressBarSfx.Max:=RecSFX.Size;
    finally
      ResourceStream.Free;
    end;

    ResourceStream:= TResourceStream.Create(0,'SFXDATA',RT_RCDATA);
    try
      ProgressBarSfx.Max:=ResourceStream.Size;
      FileNameDest := EditPath.Text+ChangeFileExt(ExtractFileName(ParamStr(0)),'');
      DestFileStream := TFileStream.Create(FileNameDest,fmCreate);
      try
        DeCompressStream:=TDeCompressionStream.Create(ResourceStream);
        DeCompressStream.OnProgress:=DoProgress;
        try
           DestFileStream.CopyFrom(DeCompressStream,RecSFX.Size);
        finally
          DeCompressStream.Free;
        end;
      finally
        DestFileStream.Free;
      end;
    finally
      ResourceStream.Free;
    end;
 except on e: exception do
   Application.MessageBox(PAnsiChar(e.Message),'Error',MB_OK+MB_ICONERROR);
 end;
end;


procedure TFrmMain.ButtonExtractClick(Sender: TObject);
begin
  Extract;
end;

procedure TFrmMain.ButtonSelDirClick(Sender: TObject);
var
  Path: String;
begin
  Path:=EditPath.Text;
   if SelectFolder(Handle,'Select the output directory',Path) then
    EditPath.Text:=IncludeTrailingPathDelimiter(Path);
end;

procedure TFrmMain.DoProgress(Sender: TObject);
begin
   ProgressBarSfx.Position:=TCustomZLibStream(Sender).Position;
end;

procedure TFrmMain.FormCreate(Sender: TObject);
begin
  EditPath.Text:=IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)));
end;

//519168
end.

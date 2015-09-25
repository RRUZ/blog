unit SelectDelphiVersion;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ImgList, ComCtrls;

type
  TFrmSelDelphiVer = class(TForm)
    Label1: TLabel;
    ButtonOk: TButton;
    ButtonCancel: TButton;
    ImageList1: TImageList;
    ListViewIDEs: TListView;
  private
    { Private declarations }
  public
    { Public declarations }
    procedure LoadInstalledVersions;
  end;


implementation
{$R *.dfm}

uses
Registry,
CommCtrl,
ShellAPI;

type
  TDelphiVersions =
  (
  Delphi4,
  Delphi5,
  Delphi6,
  Delphi7,
  Delphi8,
  Delphi2005,
  Delphi2006,
  Delphi2007,
  Delphi2009,
  Delphi2010,
  DelphiXE
  );

const
  DelphiVersionsNames: array[TDelphiVersions] of string = (
    'Delphi 4',
    'Delphi 5',
    'Delphi 6',
    'Delphi 7',
    'Delphi 8',
    'BDS 2005',
    'BDS 2006',
    'RAD Studio 2007',
    'RAD Studio 2009',
    'RAD Studio 2010',
    'RAD Studio XE'
    );

  DelphiRegPaths: array[TDelphiVersions] of string = (
    '\Software\Borland\Delphi\4.0',
    '\Software\Borland\Delphi\5.0',
    '\Software\Borland\Delphi\6.0',
    '\Software\Borland\Delphi\7.0',
    '\Software\Borland\BDS\2.0',
    '\Software\Borland\BDS\3.0',
    '\Software\Borland\BDS\4.0',
    '\Software\Borland\BDS\5.0',
    '\Software\CodeGear\BDS\6.0',
    '\Software\CodeGear\BDS\7.0',
    '\Software\Embarcadero\BDS\8.0');


function RegKeyExists(const RegPath: string;const RootKey :HKEY): Boolean;
var
  Reg: TRegistry;
begin
  try
    Reg         := TRegistry.Create;
    try
      Reg.RootKey := RootKey;
      Result := Reg.KeyExists(RegPath);
    finally
      Reg.Free;
    end;
  except
    Result := False;
  end;
end;


function RegReadStr(const RegPath, RegValue:string; var Str: string;const RootKey :HKEY): Boolean;
var
  Reg: TRegistry;
begin
  try
    Reg := TRegistry.Create;
    try
      Reg.RootKey := RootKey;
      Result := Reg.OpenKey(RegPath, True);
      if Result then  Str:=Reg.ReadString(RegValue);
    finally
      Reg.Free;
    end;
  except
    Result := False;
  end;
end;



procedure ExtractIconFileToImageList(ImageList: TImageList; const Filename: string);
var
  FileInfo: TShFileInfo;
begin
  if FileExists(Filename) then
  begin
    FillChar(FileInfo, SizeOf(FileInfo), 0);
    SHGetFileInfo(PChar(Filename), 0, FileInfo, SizeOf(FileInfo), SHGFI_ICON or SHGFI_SMALLICON);
    if FileInfo.hIcon <> 0 then
    begin
      ImageList_AddIcon(ImageList.Handle, FileInfo.hIcon);
      DestroyIcon(FileInfo.hIcon);
    end;
  end;
end;

{ TFrmSelDelphiVer }
procedure TFrmSelDelphiVer.LoadInstalledVersions;
Var
 item       : TListItem;
 DelphiComp : TDelphiVersions;
 FileName   : string;
 ImageIndex : Integer;
begin
    for DelphiComp := Low(TDelphiVersions) to High(TDelphiVersions) do
    if RegKeyExists(DelphiRegPaths[DelphiComp],HKEY_CURRENT_USER)  then
    if RegReadStr(DelphiRegPaths[DelphiComp],'App',FileName,HKEY_CURRENT_USER) and FileExists(FileName) then
    begin
       item:=ListViewIDEs.Items.Add;
       item.Caption:=DelphiVersionsNames[DelphiComp];
       item.SubItems.Add(FileName);
       ExtractIconFileToImageList(ImageList1,Filename);
       ImageIndex     :=ImageList1.Count-1;
       item.ImageIndex:=ImageIndex;
    end;
end;

end.


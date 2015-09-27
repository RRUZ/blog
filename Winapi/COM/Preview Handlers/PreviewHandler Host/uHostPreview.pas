{**************************************************************************************************}
{                                                                                                  }
{ Unit uHostPreview                                                                                }
{ component for host preview handlers                                                              }
{                                                                                                  }
{ The contents of this file are subject to the Mozilla Public License Version 1.1 (the "License"); }
{ you may not use this file except in compliance with the License. You may obtain a copy of the    }
{ License at http://www.mozilla.org/MPL/                                                           }
{                                                                                                  }
{ Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF   }
{ ANY KIND, either express or implied. See the License for the specific language governing rights  }
{ and limitations under the License.                                                               }
{                                                                                                  }
{ The Original Code is uHostPreview.pas.                                                           }
{                                                                                                  }
{ The Initial Developer of the Original Code is Rodrigo Ruz V.   Copyright (C) 2013.               }
{ All Rights Reserved.                                                                             }
{                                                                                                  }
{**************************************************************************************************}

unit uHostPreview;

interface

uses
  ShlObj,
  Classes,
  Messages,
  Controls;

type
  THostPreviewHandler = class(TCustomControl)
  private
    FFileStream     : TFileStream;
    FPreviewGUIDStr : string;
    FFileName: string;
    FLoaded :Boolean;
    FPreviewHandler : IPreviewHandler;
    procedure SetFileName(const Value: string);
    procedure LoadPreviewHandler;
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
  protected
    procedure Paint; override;
  public
    property FileName: string read FFileName write SetFileName;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;


implementation

uses
 SysUtils,
 Windows,
 Graphics,
 ComObj,
 ActiveX,
 Registry,
 PropSys;

constructor THostPreviewHandler.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FPreviewHandler:=nil;
  FPreviewGUIDStr:='';
  FFileStream:=nil;
end;

procedure THostPreviewHandler.Paint;
const
  Msg = 'No preview available.';
var
  lpRect: TRect;
begin
 if (FPreviewGUIDStr<>'') and (FPreviewHandler<>nil) and not FLoaded then
 begin
  FLoaded:=True;
  FPreviewHandler.DoPreview;
  FPreviewHandler.SetFocus;
 end
 else
 if FPreviewGUIDStr='' then
 begin
   lpRect:=Rect(0, 0, Self.Width, Self.Height);
   Canvas.Brush.Style :=bsClear;
   Canvas.Font.Color  :=clWindowText;
   DrawText(Canvas.Handle, PChar(Msg) ,Length(Msg), lpRect, DT_VCENTER or DT_CENTER or DT_SINGLELINE);
 end;
end;

destructor THostPreviewHandler.Destroy;
begin
  if (FPreviewHandler<>nil) then
    FPreviewHandler.Unload;

  if FFileStream<>nil then
    FFileStream.Free;

  inherited;
end;

function GetPreviewHandlerCLSID(const AFileName: string): string;
var
  LRegistry: TRegistry;
  LKey: String;
begin
  LRegistry := TRegistry.Create();
  try
    LRegistry.RootKey := HKEY_CLASSES_ROOT;
    LKey := ExtractFileExt(AFileName) + '\shellex\{8895b1c6-b41f-4c1c-a562-0d564250836f}';
    if LRegistry.KeyExists(LKey) then
    begin
      LRegistry.OpenKey(LKey, True);
      Result:=LRegistry.ReadString('');
      LRegistry.CloseKey;
    end
    else
      Result := '';
  finally
    LRegistry.Free;
  end;
end;

procedure THostPreviewHandler.LoadPreviewHandler;
const
  GUID_ISHELLITEM = '{43826d1e-e718-42ee-bc55-a1e261c37bfe}';
var
  prc                   : TRect;
  LPreviewGUID          : TGUID;
  LInitializeWithFile   : IInitializeWithFile;
  LInitializeWithStream : IInitializeWithStream;
  LInitializeWithItem   : IInitializeWithItem;
  LIStream              : IStream;
  LShellItem            : IShellItem;
begin

  FLoaded:=False;
  FPreviewGUIDStr:=GetPreviewHandlerCLSID(FFileName);
  if FPreviewGUIDStr='' then exit;

  if FFileStream<>nil then
    FFileStream.Free;

  LPreviewGUID:= StringToGUID(FPreviewGUIDStr);

  FPreviewHandler := CreateComObject(LPreviewGUID) As IPreviewHandler;
  if (FPreviewHandler = nil) then
    exit;

  if FPreviewHandler.QueryInterface(IInitializeWithFile, LInitializeWithFile) = S_OK then
    LInitializeWithFile.Initialize(StringToOleStr(FFileName), STGM_READ)
  else
  if FPreviewHandler.QueryInterface(IInitializeWithStream, LInitializeWithStream) = S_OK then
  begin
      FFileStream := TFileStream.Create(FFileName, fmOpenRead or fmShareDenyNone);
      LIStream := TStreamAdapter.Create(FFileStream, soOwned) as IStream;
      LInitializeWithStream.Initialize(LIStream, STGM_READ);
  end
  else
  if FPreviewHandler.QueryInterface(IInitializeWithItem, LInitializeWithItem) = S_OK then
  begin
    SHCreateItemFromParsingName(PChar(FileName), nil, StringToGUID(GUID_ISHELLITEM), LShellItem);
    LInitializeWithItem.Initialize(LShellItem, 0);
  end
  else
  begin
    FPreviewHandler.Unload;
    FPreviewHandler:=nil;
    exit;
  end;

  prc := ClientRect;
  FPreviewHandler.SetWindow(Self.Handle, prc);
end;

procedure THostPreviewHandler.SetFileName(const Value: string);
begin
  FFileName := Value;
  HandleNeeded;
  LoadPreviewHandler;
end;

procedure THostPreviewHandler.WMSize(var Message: TWMSize);
var
  prc  : TRect;
begin
  inherited;
  if FPreviewHandler<>nil then
  begin
    prc := ClientRect;
    FPreviewHandler.SetRect(prc);
  end;
end;

end.

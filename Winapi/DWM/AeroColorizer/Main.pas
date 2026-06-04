unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TFrmMain = class(TForm)
    MemoLog: TMemo;
    ImageIcon: TImage;
    Timer1: TTimer;
    PanelColor: TPanel;
    LabelClassName: TLabel;
    LabelHandle: TLabel;
    CheckBoxOnTop: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure CheckBoxOnTopClick(Sender: TObject);
  private
    { Private declarations }
    procedure SetColorFromIcon(hWnd:HWND);
    procedure GetClassInfo(hWnd:HWND);
  public
    { Public declarations }
  end;

var
  FrmMain: TFrmMain;

implementation

uses
  Generics.Defaults,
  Generics.Collections;


type
 tagCOLORIZATIONPARAMS = record
	clrColor: COLORREF;  //ColorizationColor
  clrAftGlow: COLORREF;  //ColorizationAfterglow
  nIntensity: UINT;      //ColorizationColorBalance -> 0-100
	clrAftGlowBal: UINT;      //ColorizationAfterglowBalance
	clrBlurBal: UINT;      //ColorizationBlurBalance
	clrGlassReflInt: UINT;      //ColorizationGlassReflectionIntensity
	fOpaque: BOOL;
end;


 COLORIZATIONPARAMS=tagCOLORIZATIONPARAMS;
 TColorizationParams=COLORIZATIONPARAMS;
 PColorizationParams=^TColorizationParams;

 TDwmGetColorizationParameters = procedure(out parameters :TColorizationParams); stdcall;
 TDwmSetColorizationParameters = procedure(parameters :PColorizationParams;unknown:BOOL); stdcall;
 TDwmIsCompositionEnabled      = function(out pfEnabled: BOOL): HRESULT; stdcall;

var
 DwmGetColorizationParameters: TDwmGetColorizationParameters;
 DwmSetColorizationParameters: TDwmSetColorizationParameters;
 DwmIsCompositionEnabled: TDwmIsCompositionEnabled;

 hdwmapi: Cardinal;
 OldHandle: THandle;

{$R *.dfm}

function  IsAeroEnabled: Boolean;
var
  pfEnabled: BOOL;
begin
 Result:=False;
 if Assigned(DwmIsCompositionEnabled) and (DwmIsCompositionEnabled(pfEnabled)=S_OK) then
  Result:=pfEnabled;
end;

Procedure SetCompositionColor(AColor:TColor;Log:TStrings);
var
  Params: TColorizationParams;
begin
 if IsAeroEnabled then
 if (Assigned(DwmGetColorizationParameters)) and (Assigned(DwmSetColorizationParameters)) then
 begin
   AColor:=RGB(GetBValue(AColor),GetGValue(AColor),GetRValue(AColor));
   ZeroMemory(@Params,SizeOf(Params));
   DwmGetColorizationParameters(Params);
   Params.nIntensity:=70;
   Params.clrColor  :=AColor;
   DwmSetColorizationParameters(@Params,Bool(0));

   DwmGetColorizationParameters(Params);
   Log.Add(format(
   'Intensity %d - Color %.8x - Color Afterglow %.8x - Color AfterglowBalance %d - Color BlurBalance %d - Color GlassReflectionIntensity %d',
   [Params.nIntensity,Params.clrColor,Params.clrAftGlow,Params.clrAftGlowBal,Params.clrBlurBal,Params.clrGlassReflInt]));
 end;
end;

procedure IconToBitMap(AIcon:TIcon; var Bitmap: TBitmap);
begin
  Bitmap.PixelFormat:=pf24bit;
  Bitmap.Width := AIcon.Width;
  Bitmap.Height := AIcon.Height;
  Bitmap.Canvas.Draw(0, 0, AIcon);
end;

function GetMostUsedColor(Bitmap: TBitmap): TColor;
type
  pRGBTripleArray = ^TRGBTripleArray;
  TRGBTripleArray = array[0..1023] of TRGBTriple;
var
  i, j: integer;
  BmpRow: pRGBTripleArray;
  Colors: TDictionary<TColor,Integer>;
  Count: Integer;
  AColor: TColor;
begin
   Result := clBlack;
   Colors := TDictionary<TColor,Integer>.Create;
   try
      for j := 0 to Bitmap.Height-1 do
      begin
        BmpRow := Bitmap.Scanline[j];
        for i := 0 to Bitmap.Width-1 do
          begin
            AColor:=RGB(BmpRow[i].rgbtRed,BmpRow[i].rgbtGreen,BmpRow[i].rgbtBlue);
            if Colors.ContainsKey(AColor) then
              Colors.Items[AColor]:=Colors.Items[AColor]+1
            else
              Colors.Add(AColor,1);
          end;
      end;

     Count:=Colors.ToArray[0].Value;
     for AColor in Colors.Keys do
      if Colors.TryGetValue(AColor,i) and  (i>Count) then
        Result:=AColor;
   finally
    Colors.Free;
   end;
end;

function GetWindowIcon(hWnd: HWND): HICON;
begin
  Result:=GetClassLong(hWnd, GCL_HICONSM);
  if Result=0 then
    Result:=GetClassLong(hWnd, GCL_HICON);
  if Result=0 then
    Result:=SendMessage(hWnd, WM_GETICON, ICON_SMALL, 0);
  if Result=0 then
    Result:=SendMessage(hWnd, WM_GETICON, ICON_BIG, 0);
  if Result=0 then
    Result:=SendMessage(hWnd, WM_GETICON, ICON_SMALL2, 0);
end;

procedure TFrmMain.GetClassInfo(hWnd: HWND);
var
 lpClassName: PWideChar;
 nMaxCount: Integer;
begin
  nMaxCount:=1024;
  GetMem(lpClassName,nMaxCount);
  try
    GetClassName(hWnd,lpClassName,nMaxCount);
    LabelHandle.Caption:=Format('Window Handle $%.8x',[hWnd]);
    LabelClassName.Caption:=Format('Class Name %s',[lpClassName]);
  finally
    FreeMem(lpClassName);
  end;

end;

procedure TFrmMain.SetColorFromIcon(hWnd:HWND);
var
  hIHandle: HICON;
  oImg: TPicture;
  AColor: TColor;
  Bitmap: TBitmap;
begin
  hIHandle := GetWindowIcon(hWnd);
  if hIHandle=0 then exit;
  GetClassInfo(hWnd);
  oImg := TPicture.Create();
  Bitmap := TBitmap.Create;
  try
    oImg.Icon.Handle := hIHandle;
    ImageIcon.Picture.Icon.Assign(oImg.Icon);
    IconToBitMap(oImg.Icon,Bitmap);
    AColor   :=GetMostUsedColor(Bitmap);
    PanelColor.Color:=AColor;
    SetCompositionColor(AColor,MemoLog.Lines);
  finally
   oImg.Free;
   Bitmap.Free;
  end;
end;

procedure TFrmMain.CheckBoxOnTopClick(Sender: TObject);
begin
  if TCheckBox(Sender).Checked then
   FormStyle:=fsStayOnTop
  else
   FormStyle:=fsNormal;
end;

procedure TFrmMain.FormCreate(Sender: TObject);
begin
   OldHandle :=0;
   ReportMemoryLeaksOnShutdown:=True;
end;

procedure TFrmMain.Timer1Timer(Sender: TObject);
var
 NewHandle: HWND;
begin
   NewHandle:=GetForegroundWindow;
   if (NewHandle<>OldHandle) and (NewHandle<>Handle)  then
   begin
     OldHandle:=NewHandle;
     SetColorFromIcon(OldHandle);
   end;
end;

initialization

begin
  hdwmapi := LoadLibrary('dwmapi.dll');
  if (hdwmapi <> 0) then
  begin
    @DwmIsCompositionEnabled := GetProcAddress(hdwmapi, 'DwmIsCompositionEnabled');
    @DwmGetColorizationParameters := GetProcAddress(hdwmapi, LPCSTR(127));
    @DwmSetColorizationParameters := GetProcAddress(hdwmapi, LPCSTR(131));
  end;
end;

finalization
  if (hdwmapi <> 0) then
    FreeLibrary(hdwmapi);

end.

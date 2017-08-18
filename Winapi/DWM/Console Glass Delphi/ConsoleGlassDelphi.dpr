program ConsoleGlassDelphi;
// Author  : Rodrigo Ruz 2009-10-26
{$APPTYPE CONSOLE}

uses
  Windows,
  SysUtils;

type
  DWM_BLURBEHIND = record
    dwFlags: DWORD;
    fEnable: BOOL;
    hRgnBlur: HRGN;
    fTransitionOnMaximized: BOOL;
  end;

  // function to enable the glass effect
  function DwmEnableBlurBehindWindow(hWnd: hWnd; const pBlurBehind: DWM_BLURBEHIND): HRESULT; stdcall; external 'dwmapi.dll' name 'DwmEnableBlurBehindWindow';// get the handle of the console window
  function GetConsoleWindow: hWnd; stdcall;  external kernel32 name 'GetConsoleWindow';

function DWM_EnableBlurBehind(hWnd: hWnd; AEnable: Boolean; hRgnBlur: HRGN = 0;
  ATransitionOnMaximized: Boolean = False; AFlags: Cardinal = 1): HRESULT;
var
  pBlurBehind: DWM_BLURBEHIND;
begin
  pBlurBehind.dwFlags := AFlags;
  pBlurBehind.fEnable := AEnable;
  pBlurBehind.hRgnBlur := hRgnBlur;
  pBlurBehind.fTransitionOnMaximized := ATransitionOnMaximized;
  Result := DwmEnableBlurBehindWindow(hWnd, pBlurBehind);
end;

begin
  try
    DWM_EnableBlurBehind(GetConsoleWindow(), True);
    Writeln('See my glass effect');
    Writeln('Go Delphi Go');
    Readln;
  except
    on E: Exception do
      Writeln(E.Classname, ': ', E.Message);
  end;

end.

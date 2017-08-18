program DetectAeroDelphi;
{$APPTYPE CONSOLE}

// Author Rodrigo Ruz 2009-10-26
uses
  Windows,
  SysUtils;

function ISAeroEnabled: Boolean;
type
  _DwmIsCompositionEnabledFunc = function(var IsEnabled: Boolean)
    : HRESULT; stdcall;
var
  Flag: Boolean;
  DllHandle: THandle;
  OsVersion: TOSVersionInfo;
  DwmIsCompositionEnabledFunc: _DwmIsCompositionEnabledFunc;
begin
  Result := False;
  ZeroMemory(@OsVersion, SizeOf(OsVersion));
  OsVersion.dwOSVersionInfoSize := SizeOf(TOSVersionInfo);

  if ((GetVersionEx(OsVersion)) and (OsVersion.dwPlatformId = VER_PLATFORM_WIN32_NT) and
    (OsVersion.dwMajorVersion >= 6)) then // is Vista or Win7?
  begin
    DllHandle := LoadLibrary('dwmapi.dll');
    try
      if DllHandle <> 0 then
      begin
        @DwmIsCompositionEnabledFunc := GetProcAddress(DllHandle, 'DwmIsCompositionEnabled');
        if (@DwmIsCompositionEnabledFunc <> nil) then
        begin
          if DwmIsCompositionEnabledFunc(Flag) = S_OK then
            Result := Flag;
        end;
      end;
    finally
      if DllHandle <> 0 then
        FreeLibrary(DllHandle);
    end;
  end;
end;

begin
  try
    if ISAeroEnabled then
      Writeln('Aero Glass enabled')
    else
      Writeln('Aero Glass disabled');
  except
    on E: Exception do
      Writeln(E.Classname, ': ', E.Message);
  end;
  Readln;

end.

// reference https://theroadtodelphi.wordpress.com/2012/01/06/determine-genuine-windows-installation-using-delphi/
{$APPTYPE CONSOLE}

uses
  Windows,
  SysUtils;

type
  SLID = TGUID;
  _SL_GENUINE_STATE = (SL_GEN_STATE_IS_GENUINE = 0,
                       SL_GEN_STATE_INVALID_LICENSE = 1,
                       SL_GEN_STATE_TAMPERED = 2,
                       SL_GEN_STATE_LAST = 3);
  SL_GENUINE_STATE = _SL_GENUINE_STATE;

function SLIsGenuineLocal(var pAppId: SLID; var pGenuineState: SL_GENUINE_STATE; pUIOptions: Pointer): HRESULT; stdcall;
  external 'Slwga.dll' name 'SLIsGenuineLocal' delayed;

Var
  pAppId: SLID;
  pGenuineState: SL_GENUINE_STATE;
  Status: HRESULT;

begin
  try
    if Win32MajorVersion >= 6 then // Windows Vista o newer
    begin
      pAppId := StringToGUID('{55C92734-D682-4D71-983E-D6EC3F16059F}');
      Status := SLIsGenuineLocal(pAppId, pGenuineState, nil);
      if Succeeded(Status) then
        case pGenuineState of
          SL_GEN_STATE_IS_GENUINE:
            Writeln('The installation is genuine.');
          SL_GEN_STATE_INVALID_LICENSE:
            Writeln('The application does not have a valid license.');
          SL_GEN_STATE_TAMPERED:
            Writeln('The Tampered flag of the license associated with the application is set.');
          SL_GEN_STATE_LAST:
            Writeln('The state of the installation has not changed since the last time it was checked.');
        end
      else
        Writeln(SysErrorMessage(Cardinal(Status)));
    end
    else
      Writeln('OS not supported');
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Readln;

end.

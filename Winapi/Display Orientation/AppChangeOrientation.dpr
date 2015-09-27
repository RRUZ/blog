//reference https://theroadtodelphi.wordpress.com/2011/02/11/changing-screen-orientation-programmatically-using-delphi/
program AppChangeOrientation;

{$APPTYPE CONSOLE}

uses
  Windows,
  SysUtils;

const
  DM_DISPLAYORIENTATION = $00800000;
  ENUM_CURRENT_SETTINGS =-1;
  DMDO_DEFAULT : DWORD  = 0;
  DMDO_90      : DWORD  = 1;
  DMDO_180     : DWORD  = 2;
  DMDO_270     : DWORD  = 3;

procedure ChangeOrientation(NewOrientation:DWORD);
var
  dm      : TDeviceMode;
  dwTemp  : DWORD;
  dmDisplayOrientation : DWORD;
begin
   ZeroMemory(@dm, sizeof(dm));
   dm.dmSize   := sizeof(dm);
   if EnumDisplaySettings(nil, DWORD(ENUM_CURRENT_SETTINGS), dm) then
   begin
      Move(dm.dmScale,dmDisplayOrientation,SizeOf(dmDisplayOrientation));
      // swap width and height
      if Odd(dmDisplayOrientation)<>Odd(NewOrientation) then
      begin
       dwTemp := dm.dmPelsHeight;
       dm.dmPelsHeight:= dm.dmPelsWidth;
       dm.dmPelsWidth := dwTemp;
      end;

      if dmDisplayOrientation<>NewOrientation then
      begin
        Move(NewOrientation,dm.dmScale,SizeOf(NewOrientation));
        if (ChangeDisplaySettings(dm, 0)<>DISP_CHANGE_SUCCESSFUL) then
         RaiseLastOSError;
      end;
   end;
end;

begin
  try
    ChangeOrientation(DMDO_180);
    Writeln('Changed to 180');
    Readln;

    ChangeOrientation(DMDO_270);
    Writeln('Changed to 270');
    Readln;

    ChangeOrientation(DMDO_90);
    Writeln('Changed to 90');
    Readln;

    ChangeOrientation(DMDO_DEFAULT);
    Writeln('Default Orientation restored');
    Readln;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
     readln;
end.
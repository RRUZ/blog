// reference https://theroadtodelphi.wordpress.com/2013/05/31/getting-system-information-in-osx-and-ios-using-delphi-xe2-xe3-xe4-part-1/
{$APPTYPE CONSOLE}

uses
  // System.Classes,
  // System.Types,
  // Posix.Errno,
  Posix.SysTypes,
  Posix.SysSysctl,
  System.SysUtils;

// https://developer.apple.com/library/mac/#documentation/Darwin/Reference/ManPages/man3/sysctl.3.html
// https://developer.apple.com/library/mac/documentation/Darwin/Reference/ManPages/man8/sysctl.8.html

function NumberOfCPU: Integer;
var
  res: Integer;
  len: size_t;
begin
  len := SizeOf(Result);
  res := SysCtlByName('hw.ncpu', @Result, @len, nil, 0);
  if res <> 0 then
    RaiseLastOSError;
end;

function MaxProcesses: Integer;
var
  mib: array [0 .. 1] of Integer;
  res: Integer;
  len: size_t;
begin

  mib[0] := CTL_KERN;
  mib[1] := KERN_MAXPROC;

  len := SizeOf(Result);
  res := sysctl(@mib, Length(mib), @Result, @len, nil, 0);
  if res <> 0 then
    RaiseLastOSError;
end;

function MemSize: Int64;
var
  mib: array [0 .. 1] of Integer;
  res: Integer;
  len: size_t;
begin
  mib[0] := CTL_HW;
  mib[1] := HW_MEMSIZE;

  len := SizeOf(Result);
  res := sysctl(@mib, Length(mib), @Result, @len, nil, 0);
  if res <> 0 then
    RaiseLastOSError;
end;

function KernelVersion: AnsiString;
var
  mib: array [0 .. 1] of Integer;
  res: Integer;
  len: size_t;
  p: MarshaledAString; // in XE2 use  PAnsiChar
begin
  mib[0] := CTL_KERN;
  mib[1] := KERN_VERSION;
  res := sysctl(@mib, Length(mib), nil, @len, nil, 0);
  if res <> 0 then
    RaiseLastOSError;
  GetMem(p, len);
  try
    res := sysctl(@mib, Length(mib), p, @len, nil, 0);
    if res <> 0 then
      RaiseLastOSError;
    Result := p;
  finally
    FreeMem(p);
  end;
end;

procedure GetClockInfo;
type
  clockinfo = record
    hz: Integer;
    tick: Integer;
    tickadj: Integer;
    stathz: Integer;
    profhz: Integer;
  end;

  (*
    struct clockinfo {
    int	hz;	   	/* clock frequency */
    int	tick;		/* micro-seconds per hz tick */
    int	tickadj;/* clock skew rate for adjtime() */
    int	stathz;		/* statistics clock frequency */
    int	profhz;		/* profiling clock frequency */
    };
  *)

var
  mib: array [0 .. 1] of Integer;
  res: Integer;
  len: size_t;
  clock: clockinfo;
begin
  FillChar(clock, SizeOf(clock), 0);
  mib[0] := CTL_KERN;
  mib[1] := KERN_CLOCKRATE;
  len := SizeOf(clock);
  res := sysctl(@mib, Length(mib), @clock, @len, nil, 0);
  if res <> 0 then
    RaiseLastOSError;

  Writeln(Format('clock frequency             %d', [clock.hz]));
  Writeln(Format('micro-seconds per hz tick   %d', [clock.tick]));
  Writeln(Format('clock skew rate for adjtime %d', [clock.tickadj]));
  Writeln(Format('statistics clock frequency  %d', [clock.stathz]));
  Writeln(Format('profiling clock frequency   %d', [clock.profhz]));
end;

begin
  try
    Writeln(Format('max processes     %d', [MaxProcesses]));
    Writeln(Format('number of cpus    %d', [NumberOfCPU]));
    Writeln(Format('physical ram size %s', [FormatFloat('#,', MemSize)]));
    Writeln(Format('Kernel Version    %s', [KernelVersion]));
    GetClockInfo;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;

end.

//https://theroadtodelphi.wordpress.com/2013/06/29/getting-system-information-in-osx-and-ios-using-delphi-xe2-xe3-xe4-part-2/
{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.Classes,
  System.Types,
  Posix.Errno,
  Posix.SysTypes,
  Posix.SysSysctl,
  System.SysUtils;

function GetsysctlIntValue(mib: TIntegerDynArray) : integer;
var
  len : size_t;
  res : integer;
begin
   len := sizeof(Result);
   res:=sysctl(@mib[0], 2, @Result, @len, nil, 0);
   if res<>0 then
    Result:=-1;// RaiseLastOSError;
end;

function GetsysctlInt64Value(mib: TIntegerDynArray) : Int64;
var
  len : size_t;
  res : integer;
begin
   len := sizeof(Result);
   res:=sysctl(@mib[0], 2, @Result, @len, nil, 0);
   if res<>0 then
     Result:=-1; //RaiseLastOSError;
end;

function GetsysctlStrValue(mib: TIntegerDynArray) : AnsiString;
var
  len : size_t;
  p   : PAnsiChar;
  res : integer;
begin
   Result:='';
   res:=sysctl(@mib[0], 2, nil, @len, nil, 0);
   if (len>0) and (res=0)  then
   begin
     GetMem(p, len);
     try
       res:=sysctl(@mib[0], 2, p, @len, nil, 0);
       if res=0 then
        Result:=p;
     finally
       FreeMem(p);
     end;
   end;
end;

procedure  ListKernelValues;
var
  mib : TIntegerDynArray;
  i   : Integer;
begin
 Writeln('High kernel limits');
 Writeln('------------------');
 for i:=0 to KERN_MAXID-1 do
 begin
    mib:=TIntegerDynArray.Create(CTL_KERN, i);
    case CTL_KERN_NAMES[i].ctl_type of
     CTLTYPE_NODE  :  Writeln(Format('%s.%-18s %s',[CTL_NAMES[CTL_KERN].ctl_name, CTL_KERN_NAMES[i].ctl_name, '[node]']));
     CTLTYPE_OPAQUE:  Writeln(Format('%s.%-18s %s',[CTL_NAMES[CTL_KERN].ctl_name, CTL_KERN_NAMES[i].ctl_name, '[structure]']));
     CTLTYPE_INT   :  Writeln(Format('%s.%-18s %d',[CTL_NAMES[CTL_KERN].ctl_name, CTL_KERN_NAMES[i].ctl_name, GetsysctlIntValue(mib)]));
     CTLTYPE_QUAD  :  Writeln(Format('%s.%-18s %d',[CTL_NAMES[CTL_KERN].ctl_name, CTL_KERN_NAMES[i].ctl_name, GetsysctlInt64Value(mib)]));
     CTLTYPE_STRING : Writeln(Format('%s.%-18s %s',[CTL_NAMES[CTL_KERN].ctl_name, CTL_KERN_NAMES[i].ctl_name, GetsysctlStrValue(mib)]));
    end;
 end;
 Writeln;
end;

procedure  ListGenericCPU_IO_Values;
var
  mib : TIntegerDynArray;
  i   : Integer;
begin
 Writeln('Generic CPU, I/O');
 Writeln('-----------------');
 for i:=0 to HW_MAXID-1 do
 begin
    mib:=TIntegerDynArray.Create(CTL_HW, i);
    case CTL_HW_NAMES[i].ctl_type of
     CTLTYPE_NODE  :  Writeln(Format('%s.%-18s %s',[CTL_NAMES[CTL_HW].ctl_name, CTL_HW_NAMES[i].ctl_name, '[node]']));
     CTLTYPE_OPAQUE:  Writeln(Format('%s.%-18s %s',[CTL_NAMES[CTL_HW].ctl_name, CTL_HW_NAMES[i].ctl_name, '[structure]']));
     CTLTYPE_INT   :  Writeln(Format('%s.%-18s %d',[CTL_NAMES[CTL_HW].ctl_name, CTL_HW_NAMES[i].ctl_name, GetsysctlIntValue(mib)]));
     CTLTYPE_QUAD  :  Writeln(Format('%s.%-18s %d',[CTL_NAMES[CTL_HW].ctl_name, CTL_HW_NAMES[i].ctl_name, GetsysctlInt64Value(mib)]));
     CTLTYPE_STRING : Writeln(Format('%s.%-18s %s',[CTL_NAMES[CTL_HW].ctl_name, CTL_HW_NAMES[i].ctl_name, GetsysctlStrValue(mib)]));
    end;
 end;
 Writeln;
end;

procedure  ListUserLevelValues;
var
  mib : TIntegerDynArray;
  i   : Integer;
begin
 mib:=TIntegerDynArray.Create(CTL_USER, 0);
 Writeln('User-level');
 Writeln('----------');
 for i:=0 to USER_MAXID-1 do
 begin
    mib[1]:=i;
    case CTL_USER_NAMES[i].ctl_type of
     CTLTYPE_NODE  :  Writeln(Format('%s.%-18s %s',[CTL_NAMES[CTL_USER].ctl_name, CTL_USER_NAMES[i].ctl_name, '[node]']));
     CTLTYPE_OPAQUE:  Writeln(Format('%s.%-18s %s',[CTL_NAMES[CTL_USER].ctl_name, CTL_USER_NAMES[i].ctl_name, '[structure]']));
     CTLTYPE_INT   :  Writeln(Format('%s.%-18s %d',[CTL_NAMES[CTL_USER].ctl_name, CTL_USER_NAMES[i].ctl_name, GetsysctlIntValue(mib)]));
     CTLTYPE_QUAD  :  Writeln(Format('%s.%-18s %d',[CTL_NAMES[CTL_USER].ctl_name, CTL_USER_NAMES[i].ctl_name, GetsysctlInt64Value(mib)]));
     CTLTYPE_STRING : Writeln(Format('%s.%-18s %s',[CTL_NAMES[CTL_USER].ctl_name, CTL_USER_NAMES[i].ctl_name, GetsysctlStrValue(mib)]));
    end;
 end;
 Writeln;
end;

procedure  ListVMValues;
var
  mib : TIntegerDynArray;
  i   : Integer;
begin
 Writeln('Virtual memory');
 Writeln('-------------');
 for i:=0 to VM_MAXID-1 do
 begin
    mib:=TIntegerDynArray.Create(CTL_VM, i);
    case CTL_VM_NAMES[i].ctl_type of
     CTLTYPE_NODE  :  Writeln(Format('%s.%-18s %s',[CTL_NAMES[CTL_VM].ctl_name, CTL_VM_NAMES[i].ctl_name, '[node]']));
     CTLTYPE_OPAQUE:  Writeln(Format('%s.%-18s %s',[CTL_NAMES[CTL_VM].ctl_name, CTL_VM_NAMES[i].ctl_name, '[structure]']));
     CTLTYPE_INT   :  Writeln(Format('%s.%-18s %d',[CTL_NAMES[CTL_VM].ctl_name, CTL_VM_NAMES[i].ctl_name, GetsysctlIntValue(mib)]));
     CTLTYPE_QUAD  :  Writeln(Format('%s.%-18s %d',[CTL_NAMES[CTL_VM].ctl_name, CTL_VM_NAMES[i].ctl_name, GetsysctlInt64Value(mib)]));
     CTLTYPE_STRING : Writeln(Format('%s.%-18s %s',[CTL_NAMES[CTL_VM].ctl_name, CTL_VM_NAMES[i].ctl_name, GetsysctlStrValue(mib)]));
    end;
 end;
 Writeln;
end;

begin
  try
    ListKernelValues;
    ListGenericCPU_IO_Values;
    ListUserLevelValues;
    ListVMValues;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
{$APPTYPE CONSOLE}
{$DEFINE Use_Jwscl} //necessary to obtain a hash of the data using md2, md4, md5 or sha1

uses
  {$IFDEF Use_Jwscl}
  JwsclTypes,
  JwsclCryptProvider,
  {$ENDIF}
  Classes,
  SysUtils,
  ActiveX,
  ComObj,
  Variants;

type
   TMotherBoardInfo   = (Mb_SerialNumber,Mb_Manufacturer,Mb_Product,Mb_Model);
   TMotherBoardInfoSet= set of TMotherBoardInfo;
   TProcessorInfo     = (Pr_Description,Pr_Manufacturer,Pr_Name,Pr_ProcessorId,Pr_UniqueId);
   TProcessorInfoSet  = set of TProcessorInfo;
   TBIOSInfo          = (Bs_BIOSVersion,Bs_BuildNumber,Bs_Description,Bs_Manufacturer,Bs_Name,Bs_SerialNumber,Bs_Version);
   TBIOSInfoSet       = set of TBIOSInfo;
   TOSInfo            = (Os_BuildNumber,Os_BuildType,Os_Manufacturer,Os_Name,Os_SerialNumber,Os_Version);
   TOSInfoSet         = set of TOSInfo;

const //properties names to get the data
   MotherBoardInfoArr: array[TMotherBoardInfo] of AnsiString =
                        ('SerialNumber','Manufacturer','Product','Model');

   OsInfoArr         : array[TOSInfo] of AnsiString =
                        ('BuildNumber','BuildType','Manufacturer','Name','SerialNumber','Version');

   BiosInfoArr       : array[TBIOSInfo] of AnsiString =
                        ('BIOSVersion','BuildNumber','Description','Manufacturer','Name','SerialNumber','Version');

   ProcessorInfoArr  : array[TProcessorInfo] of AnsiString =
                        ('Description','Manufacturer','Name','ProcessorId','UniqueId');

type
   THardwareId  = class
   private
    FOSInfo         : TOSInfoSet;
    FBIOSInfo       : TBIOSInfoSet;
    FProcessorInfo  : TProcessorInfoSet;
    FMotherBoardInfo: TMotherBoardInfoSet;
    FBuffer         : AnsiString;
    function GetHardwareIdHex: AnsiString;
  {$IFDEF Use_Jwscl}
    function GetHashString(Algorithm: TJwHashAlgorithm; Buffer : Pointer;Size:Integer) : AnsiString;
    function GetHardwareIdMd5: AnsiString;
    function GetHardwareIdMd2: AnsiString;
    function GetHardwareIdMd4: AnsiString;
    function GetHardwareIdSHA: AnsiString;
  {$ENDIF}
   public
     //Set the properties to  be used in the generation of the hardware id
    property  MotherBoardInfo : TMotherBoardInfoSet read FMotherBoardInfo write FMotherBoardInfo;
    property  ProcessorInfo : TProcessorInfoSet read FProcessorInfo write FProcessorInfo;
    property  BIOSInfo: TBIOSInfoSet read FBIOSInfo write FBIOSInfo;
    property  OSInfo  : TOSInfoSet read FOSInfo write FOSInfo;
    property  Buffer : AnsiString read FBuffer; //return the content of the data collected in the system
    property  HardwareIdHex : AnsiString read GetHardwareIdHex; //get a hexadecimal represntation of the data collected
  {$IFDEF Use_Jwscl}
    property  HardwareIdMd2  : AnsiString read GetHardwareIdMd2; //get a Md2 hash of the data collected
    property  HardwareIdMd4  : AnsiString read GetHardwareIdMd4; //get a Md4 hash of the data collected
    property  HardwareIdMd5  : AnsiString read GetHardwareIdMd5; //get a Md5 hash of the data collected
    property  HardwareIdSHA  : AnsiString read GetHardwareIdSHA; //get a SHA1 hash of the data collected
  {$ENDIF}
    procedure GenerateHardwareId; //calculate the hardware id
    constructor  Create(Generate:Boolean=True); overload;
    Destructor  Destroy; override;
   end;

function VarArrayToStr(const vArray: variant): AnsiString;

  function _VarToStr(const V: variant): AnsiString;
  var
  Vt: integer;
  begin
   Vt := VarType(V);
      case Vt of
        varSmallint,
        varInteger  : Result := AnsiString(IntToStr(integer(V)));
        varSingle,
        varDouble,
        varCurrency : Result := AnsiString(FloatToStr(Double(V)));
        varDate     : Result := AnsiString(VarToStr(V));
        varOleStr   : Result := AnsiString(WideString(V));
        varBoolean  : Result := AnsiString(VarToStr(V));
        varVariant  : Result := AnsiString(VarToStr(Variant(V)));
        varByte     : Result := AnsiChar(byte(V));
        varString   : Result := AnsiString(V);
        varArray    : Result := VarArrayToStr(Variant(V));
      end;
  end;

var
i : integer;
begin
    Result := '[';
    if (VarType(vArray) and VarArray)=0 then
       Result := _VarToStr(vArray)
    else
    for i := VarArrayLowBound(vArray, 1) to VarArrayHighBound(vArray, 1) do
     if i=VarArrayLowBound(vArray, 1)  then
      Result := Result+_VarToStr(vArray[i])
     else
      Result := Result+'|'+_VarToStr(vArray[i]);

    Result:=Result+']';
end;

function VarStrNull(const V:OleVariant):AnsiString; //avoid problems with null strings
begin
  Result:='';
  if not VarIsNull(V) then
  begin
    if VarIsArray(V) then
       Result:=VarArrayToStr(V)
    else
    Result:=AnsiString(VarToStr(V));
  end;
end;

{ THardwareId }

constructor THardwareId.Create(Generate:Boolean=True);
begin
   inherited Create;
   CoInitialize(nil);
   FBuffer          :='';
   //Set the propeties to be used in the hardware id generation
   FMotherBoardInfo :=[Mb_SerialNumber,Mb_Manufacturer,Mb_Product,Mb_Model];
   FOSInfo          :=[Os_BuildNumber,Os_BuildType,Os_Manufacturer,Os_Name,Os_SerialNumber,Os_Version];
   FBIOSInfo        :=[Bs_BIOSVersion,Bs_BuildNumber,Bs_Description,Bs_Manufacturer,Bs_Name,Bs_SerialNumber,Bs_Version];
   FProcessorInfo   :=[];//including the processor info is expensive [Pr_Description,Pr_Manufacturer,Pr_Name,Pr_ProcessorId,Pr_UniqueId];
   if Generate then
    GenerateHardwareId;
end;

destructor THardwareId.Destroy;
begin
  CoUninitialize;
  inherited;
end;

//Main function which collect the system data.
procedure THardwareId.GenerateHardwareId;
var
  objSWbemLocator : OLEVariant;
  objWMIService   : OLEVariant;
  objWbemObjectSet: OLEVariant;
  oWmiObject      : OLEVariant;
  oEnum           : IEnumvariant;
  iValue          : LongWord;
  SDummy          : AnsiString;
  Mb              : TMotherBoardInfo;
  Os              : TOSInfo;
  Bs              : TBIOSInfo;
  Pr              : TProcessorInfo;
begin;
  objSWbemLocator := CreateOleObject('WbemScripting.SWbemLocator');
  objWMIService   := objSWbemLocator.ConnectServer('localhost','root\cimv2', '','');

  if FMotherBoardInfo<>[] then //MotherBoard info
  begin
    objWbemObjectSet:= objWMIService.ExecQuery('SELECT * FROM Win32_BaseBoard','WQL',0);
    oEnum           := IUnknown(objWbemObjectSet._NewEnum) as IEnumVariant;
    while oEnum.Next(1, oWmiObject, iValue) = 0 do
    begin
      for Mb := Low(TMotherBoardInfo) to High(TMotherBoardInfo) do
       if Mb in FMotherBoardInfo then
       begin
          SDummy:=VarStrNull(oWmiObject.Properties_.Item(MotherBoardInfoArr[Mb]).Value);
          FBuffer:=FBuffer+SDummy;
       end;
       oWmiObject:=Unassigned;
    end;
  end;

  if FOSInfo<>[] then//Windows info
  begin
    objWbemObjectSet:= objWMIService.ExecQuery('SELECT * FROM Win32_OperatingSystem','WQL',0);
    oEnum           := IUnknown(objWbemObjectSet._NewEnum) as IEnumVariant;
    while oEnum.Next(1, oWmiObject, iValue) = 0 do
    begin
      for Os := Low(TOSInfo) to High(TOSInfo) do
       if Os in FOSInfo then
       begin
          SDummy:=VarStrNull(oWmiObject.Properties_.Item(OsInfoArr[Os]).Value);
          FBuffer:=FBuffer+SDummy;
       end;
       oWmiObject:=Unassigned;
    end;
  end;

  if FBIOSInfo<>[] then//BIOS info
  begin
    objWbemObjectSet:= objWMIService.ExecQuery('SELECT * FROM Win32_BIOS','WQL',0);
    oEnum           := IUnknown(objWbemObjectSet._NewEnum) as IEnumVariant;
    while oEnum.Next(1, oWmiObject, iValue) = 0 do
    begin
      for Bs := Low(TBIOSInfo) to High(TBIOSInfo) do
       if Bs in FBIOSInfo then
       begin
          SDummy:=VarStrNull(oWmiObject.Properties_.Item(BiosInfoArr[Bs]).Value);
          FBuffer:=FBuffer+SDummy;
       end;
       oWmiObject:=Unassigned;
    end;
  end;

  if FProcessorInfo<>[] then//CPU info
  begin
    objWbemObjectSet:= objWMIService.ExecQuery('SELECT * FROM Win32_Processor','WQL',0);
    oEnum           := IUnknown(objWbemObjectSet._NewEnum) as IEnumVariant;
    while oEnum.Next(1, oWmiObject, iValue) = 0 do
    begin
      for Pr := Low(TProcessorInfo) to High(TProcessorInfo) do
       if Pr in FProcessorInfo then
       begin
          SDummy:=VarStrNull(oWmiObject.Properties_.Item(ProcessorInfoArr[Pr]).Value);
          FBuffer:=FBuffer+SDummy;
       end;
       oWmiObject:=Unassigned;
    end;
  end;

end;

function THardwareId.GetHardwareIdHex: AnsiString;
begin
    SetLength(Result,Length(FBuffer)*2);
    BinToHex(PAnsiChar(FBuffer),PAnsiChar(Result),Length(FBuffer));
end;

{$IFDEF Use_Jwscl}
function THardwareId.GetHashString(Algorithm: TJwHashAlgorithm; Buffer : Pointer;Size:Integer) : AnsiString;
var
  Hash: TJwHash;
  HashSize: Cardinal;
  HashData: Pointer;
begin
  Hash := TJwHash.Create(Algorithm);
  try
    Hash.HashData(Buffer,Size);
    HashData := Hash.RetrieveHash(HashSize);
    try
        SetLength(Result,HashSize*2);
        BinToHex(PAnsiChar(HashData),PAnsiChar(Result),HashSize);
    finally
      TJwHash.FreeBuffer(HashData);
    end;
  finally
    Hash.Free;
  end;
end;

function THardwareId.GetHardwareIdMd2: AnsiString;
begin
   Result:=GetHashString(haMD2,@FBuffer[1],Length(FBuffer));
end;

function THardwareId.GetHardwareIdMd4: AnsiString;
begin
   Result:=GetHashString(haMD4,@FBuffer[1],Length(FBuffer));
end;

function THardwareId.GetHardwareIdMd5: AnsiString;
begin
   Result:=GetHashString(haMD5,@FBuffer[1],Length(FBuffer));
end;

function THardwareId.GetHardwareIdSHA: AnsiString;
begin
   Result:=GetHashString(haSHA,@FBuffer[1],Length(FBuffer));
end;

{$ENDIF}

//testing the THardwareId object
var
  HWID : THardwareId;
  dt   : TDateTime;
begin
 try
    HWID:=THardwareId.Create(False);
    try
       dt := Now;
       HWID.GenerateHardwareId;
       dt := now - dt;
       Writeln(Format('Hardware Id Generated in %s',[FormatDateTime('hh:mm:nn.zzz',dt)]));
       Writeln(Format('%s %s',['Buffer ',HWID.Buffer]));
       Writeln('');
       Writeln(Format('%s %s',['Hex  ',HWID.HardwareIdHex]));
      {$IFDEF Use_Jwscl}
       Writeln(Format('%s %s',['Md2  ',HWID.HardwareIdMd2]));
       Writeln(Format('%s %s',['Md4  ',HWID.HardwareIdMd4]));
       Writeln(Format('%s %s',['Md5  ',HWID.HardwareIdMd5]));
       Writeln(Format('%s %s',['SHA1 ',HWID.HardwareIdSHA]));
      {$ENDIF}
      Readln;
    finally
     HWID.Free;
    end;
 except
    on E:Exception do
    begin
        Writeln(E.Classname, ':', E.Message);
        Readln;
    end;
  end;
end.
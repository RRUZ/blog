unit uRttiHelper;

interface

uses
  Rtti,
  TypInfo;

  type
     TRttiPropertyHelper = class helper for TRttiProperty
  private
    function GetSetterField: TRttiField;
    function GetGetterField: TRttiField;
  public
    property SetterField: TRttiField read GetSetterField;
    property GetterField: TRttiField read GetGetterField;
    function SetterMethod (Instance: TObject): TRttiMethod;
    function GetterMethod (Instance: TObject): TRttiMethod;
  end;


implementation

const
{$IF SizeOf(Pointer) = 4}
  PROPSLOT_MASK_F    = $000000FF;
{$ELSEIF SizeOf(Pointer) = 8}
  PROPSLOT_MASK_F    = $00000000000000FF;
{$ENDIF}


function IsField(P: Pointer): Boolean; inline;
begin
  Result := (IntPtr(P) and PROPSLOT_MASK) = PROPSLOT_FIELD;
end;

function GetCodePointer(Instance: TObject; P: Pointer): Pointer; inline;
begin
  if (IntPtr(P) and PROPSLOT_MASK) = PROPSLOT_VIRTUAL then // Virtual Method
    Result := PPointer(PNativeUInt(Instance)^ + (UIntPtr(P) and $FFFF))^
  else // Static method
    Result := P;
end;


function GetPropGetterMethod(Instance: TObject; AProp: TRttiProperty): TRttiMethod;
var
  LPropInfo: PPropInfo;
  LMethod: TRttiMethod;
  LCodeAddress: Pointer;
  LType: TRttiType;
  LocalContext: TRttiContext;
begin
  Result:=nil;
  if (AProp.IsReadable) and (AProp.ClassNameIs('TRttiInstancePropertyEx')) then
  begin
    //get the PPropInfo pointer
    LPropInfo:=TRttiInstanceProperty(AProp).PropInfo;
    if (LPropInfo<>nil) and (LPropInfo.GetProc<>nil) and not IsField(LPropInfo.GetProc) then
    begin
      //get the real address of the ,ethod
      LCodeAddress := GetCodePointer(Instance, LPropInfo^.GetProc);
      //get the Typeinfo for the current instance
      LType:= LocalContext.GetType(Instance.ClassType);
      //iterate over the methods of the instance
      for LMethod in LType.GetMethods do
      begin
         //compare the address of the currrent method against the address of the getter
         if LMethod.CodeAddress=LCodeAddress then
           Exit(LMethod);
      end;
    end;
  end;
end;

function GetPropSetterMethod(Instance: TObject; AProp: TRttiProperty): TRttiMethod;
var
  LPropInfo: PPropInfo;
  LMethod: TRttiMethod;
  LCodeAddress: Pointer;
  LType: TRttiType;
  LocalContext: TRttiContext;
begin
  Result:=nil;
  if (AProp.IsWritable) and (AProp.ClassNameIs('TRttiInstancePropertyEx')) then
  begin
    //get the PPropInfo pointer
    LPropInfo:=TRttiInstanceProperty(AProp).PropInfo;
    if (LPropInfo<>nil) and (LPropInfo.SetProc<>nil) and not IsField(LPropInfo.SetProc) then
    begin
      LCodeAddress := GetCodePointer(Instance, LPropInfo^.SetProc);
      //get the Typeinfo for the current instance
      LType:= LocalContext.GetType(Instance.ClassType);
      //iterate over the methods
      for LMethod in LType.GetMethods do
      begin
         //compare the address of the currrent method against the address of the setter
         if LMethod.CodeAddress=LCodeAddress then
           Exit(LMethod);
      end;
    end;
  end;
end;

function GetPropGetterField(AProp: TRttiProperty): TRttiField;
var
  LPropInfo: PPropInfo;
  LField: TRttiField;
  LOffset: Integer;
begin
  Result:=nil;
  //Is a readable property?
  if (AProp.IsReadable) and (AProp.ClassNameIs('TRttiInstancePropertyEx')) then
  begin
    //get the propinfo of the porperty
    LPropInfo:=TRttiInstanceProperty(AProp).PropInfo;
    //check if the GetProc represent a field
    if (LPropInfo<>nil) and (LPropInfo.GetProc<>nil) and IsField(LPropInfo.GetProc) then
    begin
      //get the offset of the field
      LOffset:= IntPtr(LPropInfo.GetProc) and PROPSLOT_MASK_F;
      //iterate over the fields of the class
      for LField in AProp.Parent.GetFields do
         //compare the offset the current field with the offset of the getter
         if LField.Offset=LOffset then
           Exit(LField);
    end;
  end;
end;

function GetPropSetterField(AProp: TRttiProperty): TRttiField;
var
  LPropInfo: PPropInfo;
  LField: TRttiField;
  LOffset: Integer;
begin
  Result:=nil;
  //Is a writable property?
  if (AProp.IsWritable) and (AProp.ClassNameIs('TRttiInstancePropertyEx')) then
  begin
    //get the propinfo of the porperty
    LPropInfo:=TRttiInstanceProperty(AProp).PropInfo;
    //check if the GetProc represent a field
    if (LPropInfo<>nil) and (LPropInfo.SetProc<>nil) and IsField(LPropInfo.SetProc) then
    begin
      //get the offset of the field
      LOffset:= IntPtr(LPropInfo.SetProc) and PROPSLOT_MASK_F;
      //iterate over the fields of the class
      for LField in AProp.Parent.GetFields do
         //compare the offset the current field with the offset of the setter
         if LField.Offset=LOffset then
           Exit(LField);
    end;
  end;
end;


{ TRttiPropertyHelper }

function TRttiPropertyHelper.GetGetterField: TRttiField;
begin
 Result:= GetPropGetterField(Self);
end;

function TRttiPropertyHelper.GetSetterField: TRttiField;
begin
 Result:= GetPropSetterField(Self);
end;

function TRttiPropertyHelper.GetterMethod(Instance: TObject): TRttiMethod;
begin
 Result:= GetPropGetterMethod(Instance, Self);
end;

function TRttiPropertyHelper.SetterMethod(Instance: TObject): TRttiMethod;
begin
 Result:= GetPropSetterMethod(Instance, Self);
end;

end.

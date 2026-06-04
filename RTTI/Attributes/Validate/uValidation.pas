unit uValidation;

interface

uses
  System.Classes,
  System.Rtti,
  System.TypInfo,
  System.SysUtils;


type
  ValidationAttribute =  class (TCustomAttribute)
  private
    function GetCustomMessage: string;  virtual;
  public
    function  Validate (AValue: TValue): Boolean; virtual;
    property  CustomMessage: string read GetCustomMessage;
  end;

  ValidTypesAttribute =  class (ValidationAttribute)
  private
    FCustomMessage: string;
    FtypeKinds: TTypeKinds;
    function GetCustomMessage: string;  override;
  public
    constructor Create(const TypeKinds: TTypeKinds); overload;
    function  Validate (AValue: TValue): Boolean; override;
  end;

  [ValidTypes([tkString, tkUString, tkUnicodeString, tkLString])]
  MandatoryAttribute =  class (ValidationAttribute)
  private
    function GetCustomMessage: string;  override;
  public
    function  Validate (AValue: TValue): Boolean; override;
  end;

  [ValidTypes([tkString, tkUString, tkUnicodeString, tkLString])]
  IPAddressAttribute =  class (ValidationAttribute)
  private
    function GetCustomMessage: string;  override;
  public
    function  Validate (AValue: TValue): Boolean; override;
  end;

  [ValidTypes([tkInteger])]
  RangeAttribute =  class (ValidationAttribute)
  private
     FMin, FMax: Integer;
    function GetCustomMessage: string;  override;
  public
    function  Validate (AValue: TValue): Boolean; override;
    constructor  Create(AMin: Integer = 0; AMax: Integer =0); overload;
  end;

  TAttributeTransDirection = (tdForward, tdBackward);

  TransformAttribute = class (TCustomAttribute)
  public
    function RunTransform(AValue: TValue; out OutValue: TValue; ADirection: TAttributeTransDirection): Boolean; virtual;
  end;

  EncryptedAttribute = class (TransformAttribute)
  public
    function RunTransform(AValue: TValue; out OutValue: TValue; ADirection: TAttributeTransDirection): Boolean; override;
  end;

   function TryValidateObject(AClass: TObject; ValidationResult: TStrings = nil): boolean;
   function TryTransformObject(AClass: TObject; ADirection: TAttributeTransDirection): boolean;

implementation

uses
  Data.DBXEncryption,
  IdCoderMIME,
  System.RegularExpressions;

function TryValidateObject(AClass: TObject; ValidationResult: TStrings = nil): boolean;
var
 LContext: TRttiContext;
 LType, LTypeAttribute: TRttiType;
 LAttr, LInnerAttribute: TCustomAttribute;
 LProp: TRttiProperty;
 sMessage: string;
 InnerValPassed: Boolean;
begin
  result := true;
  //InnerValPassed:=True;
  //extract the type info of the class
  LType:=LContext.GetType(AClass.ClassInfo);
   //iterate over the properties of the class
   for LProp in LType.GetProperties do
    if LProp.ClassNameIs('TRttiInstancePropertyEx') then
    begin
      // retrieve the attributes of the current property
      for LAttr in LProp.GetAttributes() do
      begin
         InnerValPassed:=True;
         /// retrieve the type info of the current attribute
         LTypeAttribute:=LContext.GetType(LAttr.ClassInfo);
         //iterate over the attributes of the current attribute
         for LInnerAttribute in LTypeAttribute.GetAttributes() do
           if LInnerAttribute is ValidationAttribute then
            begin
               if not ValidationAttribute(LInnerAttribute).Validate(LProp.GetValue(AClass))  then
                 begin
                  result:=false;
                  sMessage :=  Format('Failed validation %s on attribute %s property %s.%s (Hint: %s)',
                  [LInnerAttribute.ClassName, LAttr.ClassName, AClass.ClassName, LProp.Name, ValidationAttribute(LInnerAttribute).CustomMessage]) + sLineBreak;

                  if (ValidationResult<>nil) then
                    ValidationResult.Add(sMessage);
                  InnerValPassed := false;
                 end;
            end;


        //check the type of the current attribute
        if InnerValPassed then
        if LAttr is ValidationAttribute then
        begin
           //run the validation in the property using his current value as param
           if not ValidationAttribute(LAttr).Validate(LProp.GetValue(AClass)) then
           begin
            Result:=false;
            sMessage := Format('Failed validation %s on property %s.%s (Hint: %s)', [LAttr.ClassName, AClass.ClassName, LProp.Name, ValidationAttribute(LAttr).CustomMessage]);
            //store the message in the stringlist
            if ValidationResult<>nil then
              ValidationResult.Add(sMessage);
             Break;
           end;
        end;
      end;
    end;
end;

function TryTransformObject(AClass: TObject; ADirection: TAttributeTransDirection): boolean;
var
  LContext: TRttiContext;
  LType: TRttiType;
  LAttr: TCustomAttribute;
  LProp: TRttiProperty;
  OValue: TValue;
begin
  Result:=True;
  LType:=LContext.GetType(AClass.ClassInfo);
  for LProp in LType.GetProperties() do
    if LProp.ClassNameIs('TRttiInstancePropertyEx') then
    begin
      for LAttr in LProp.GetAttributes() do
        if LAttr is TransformAttribute then
        begin
          if TransformAttribute(LAttr).RunTransform(LProp.GetValue(AClass), OValue, ADirection) then
           LProp.SetValue(AClass, OValue)
          else
           Result:=False;
        end;
    end;
end;

{ ValidationAttribute }

function ValidationAttribute.GetCustomMessage: string;
begin
   Result:= '';
end;

function ValidationAttribute.Validate(AValue: TValue): Boolean;
begin
  Result := false;
end;

{ MandatoryAttribute }

function MandatoryAttribute.GetCustomMessage: string;
begin
  Result:='This member is empty';
end;

function MandatoryAttribute.Validate(AValue: TValue): Boolean;
begin
//  case AValue.Kind of
//    tkUnknown: ;
//    tkInteger: Result:= (AValue.AsInteger <> 0);
//    tkChar: ;
//    tkEnumeration: ;
//    tkFloat: ;
//    tkString: ;
//    tkSet: ;
//    tkClass: ;
//    tkMethod: ;
//    tkWChar: ;
//    tkLString: ;
//    tkWString: ;
//    tkVariant: ;
//    tkArray: ;
//    tkRecord: ;
//    tkInterface: ;
//    tkInt64: ;
//    tkDynArray: ;
//    tkUString: Result:= (AValue.AsString<>'');
//    tkClassRef: ;
//    tkPointer: ;
//    tkProcedure: ;
//  end;
  Result:= (AValue.AsString<>'');
end;

{ IPAddressAttribute }

function IPAddressAttribute.GetCustomMessage: string;
begin
 Result:='The IP Address is not valid';
end;

function IPAddressAttribute.Validate(AValue: TValue): Boolean;
begin
 Result:=TRegEx.IsMatch(AValue.AsString,
 '\b(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b');
end;

{ RangeAttribute }

constructor RangeAttribute.Create(AMin, AMax: Integer);
begin
  inherited Create();
  FMin:=AMin;
  FMax:=AMax;
end;

function RangeAttribute.GetCustomMessage: string;
begin
 Result:= Format('The member must be in this range [%d - %d]', [FMin, FMax]);
end;

function RangeAttribute.Validate(AValue: TValue): Boolean;
begin
 Result:= (AValue.AsInteger>=FMin) and (AValue.AsInteger<=FMax);
end;

{ ValidTypesAttribute }

constructor ValidTypesAttribute.Create(const TypeKinds: TTypeKinds);
begin
 FtypeKinds := TypeKinds;
 FCustomMessage := 'You must pass a valid type to this member';
end;

function ValidTypesAttribute.GetCustomMessage: string;
var
 LKind: TTypeKind;
begin
  Result:='';
  if FtypeKinds<>[] then
  begin
      for LKind in FtypeKinds do
      begin
       if Result<>'' then
        Result:= Result + ',';
        Result:=Result + TRttiEnumerationType.GetName<TTypeKind>(LKind);
      end;
      Result := FCustomMessage + ' [' + Result + ']';
  end
  else
  Result:=FCustomMessage;

end;

function ValidTypesAttribute.Validate(AValue: TValue): Boolean;
begin
  Result:= (AValue.Kind in FtypeKinds);
end;



{ TranformAttribute }

function TransformAttribute.RunTransform(AValue: TValue; out OutValue: TValue;
  ADirection: TAttributeTransDirection): Boolean;
begin
  Result:=True;
  OutValue:=AValue;
end;

{ EncryptedAttribute }

function EncryptedAttribute.RunTransform(AValue: TValue; out OutValue: TValue;
  ADirection: TAttributeTransDirection): Boolean;
var
 Cypher: TPC1Cypher;
 I: Integer;
 Data:  TArray<Byte>;
 LStream: TMemoryStream;
begin
  //encrypt
  if ADirection= tdForward then
  begin
    Data:= TEncoding.UTF8.GetBytes(AValue.AsString);
    Cypher:=TPC1Cypher.Create('87654kdjj');//
    try
     for I :=0 to Length(Data)-1 do
       Data[i] := Cypher.Cypher(Data[i]);
    finally
      Cypher.Free;
    end;

    //encode the encrypted string
    LStream:=TMemoryStream.Create;
    try
      LStream.WriteData(Data, Length(Data));
      LStream.Position:=0;
      OutValue:=TValue.From<string>(TIdEncoderMIME.EncodeStream(LStream));
    finally
      LStream.Free;
    end;
  end
  else
  //Decrypt
  begin
   //decode from MIME
   LStream:=TMemoryStream.Create;
   try
    TIdDecoderMIME.DecodeStream(AValue.AsString, LStream);
    SetLength(Data, LStream.Size);
    LStream.Position:=0;
    LStream.ReadBuffer(Data[0], Length(Data));
   finally
    LStream.Free;
   end;

   //decrypt the Data
   Cypher:=TPC1Cypher.Create('87654kdjj');
   try
     for I := 0 to Length(Data)-1 do
       Data[i] := Cypher.Decypher(Data[i]);
   finally
    Cypher.Free;
   end;

   OutValue:=TEncoding.UTF8.GetString(Data);
  end;
  Result:=True;

end;

end.

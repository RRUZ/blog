program Sample;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.RTTI,
  System.TypInfo,
  System.SysUtils,
  System.Classes,
  uRttiHelper in 'uRttiHelper.pas';

type
  // The getters and setters methods of the property must emit RTTI info this implies which depending of the visibility of these methods
  // you will need to instruct to the compiler generate RTTI info adding this sentence to your class {$RTTI EXPLICIT METHODS([vcPrivate])}
  {$RTTI EXPLICIT METHODS([vcPrivate])}
  TBar = class
  private
    FReadOnlyProp: string;
    FWriteOnlyProp: string;
    function GetReadBaseProp: string; virtual;
    procedure SetWriteBaseProp(const Value: string); virtual;
  public
    property ReadBaseProp: string read GetReadBaseProp;
    property WriteBaseProp: string write SetWriteBaseProp;
  end;

  // The getters and setters methods of the property must emit RTTI info this implies which depending of the visibility of these methods
  // you will need to instruct to the compiler generate RTTI info adding this sentence to your class {$RTTI EXPLICIT METHODS([vcPrivate])}
  {$RTTI EXPLICIT METHODS([vcPrivate])}

  TFoo = class(TBar)
  private
    function GetReadOnlyPropwGet: string;
    procedure SetWriteOnlyPropwSet(const Value: string);
    function GetReadBaseProp: string; override;
    function GetArrayProp(Index: Integer): string;
    procedure SetArrayProp(Index: Integer; const Value: string);
    function GetInteger(const Index: Integer): Integer;
    procedure SetInteger(const Index, Value: Integer);
  public
    property ReadOnlyProp: string read FReadOnlyProp;
    property WriteOnlyProp: string Write FWriteOnlyProp;
    property ReadOnlyPropwGet: string read GetReadOnlyPropwGet;
    property WriteOnlyPropwSet: string write SetWriteOnlyPropwSet;
    property ArrayProp[Index: Integer]: string read GetArrayProp write SetArrayProp; default;
    property PropIndex1: Integer Index 1 read GetInteger write SetInteger;
    property PropIndex2: Integer Index 2 read GetInteger write SetInteger;
  end;

  { TBar }

function TBar.GetReadBaseProp: string;
begin

end;

procedure TBar.SetWriteBaseProp(const Value: string);
begin

end;

// { TFoo }

function TFoo.GetArrayProp(Index: Integer): string;
begin

end;

function TFoo.GetInteger(const Index: Integer): Integer;
begin

end;

function TFoo.GetReadBaseProp: string;
begin

end;

function TFoo.GetReadOnlyPropwGet: string;
begin

end;

procedure TFoo.SetArrayProp(Index: Integer; const Value: string);
begin

end;

procedure TFoo.SetInteger(const Index, Value: Integer);
begin

end;

procedure TFoo.SetWriteOnlyPropwSet(const Value: string);
begin

end;

procedure DumpPropInfo(AClass: TObject);
var
  LContext: TRttiContext;
  LType: TRttiType;
  LProp: TRttiProperty;
  LPropInfo: PPropInfo;
begin
  // Get the typeinfo of the class
  LType := LContext.GetType(AClass.ClassInfo);

  for LProp in LType.GetProperties() do
    if LProp is TRttiInstanceProperty then
    begin
      // Get the pointer to the PPropInfo
      LPropInfo := TRttiInstanceProperty(LProp).PropInfo;
      Writeln(Format('%-18s GetProc %p SetProc %p',
        [LProp.Name, LPropInfo.GetProc, LPropInfo.SetProc]));
      Writeln(LProp.Name);
    end;
end;

// This method uses the TRttiProperty Helper  to resolve the names of the getters and setters
procedure DumpPropInfoExt(AClass: TObject);
var
  LContext: TRttiContext;
  LType: TRttiType;
  LProp: TRttiProperty;
  LPropInfo: PPropInfo;

  LField: TRttiField;
  LMethod: TRttiMethod;
begin
  LType := LContext.GetType(AClass.ClassInfo);
  for LProp in LType.GetProperties() do
    if LProp is TRttiInstanceProperty then
    begin
      LPropInfo := TRttiInstanceProperty(LProp).PropInfo;
      Writeln(Format('%-18s GetProc %p SetProc %p',
        [LProp.Name, LPropInfo.GetProc, LPropInfo.SetProc]));

      if LProp.IsReadable then
      begin
        LField := LProp.GetterField;
        if LField <> nil then
          Writeln(Format('  Getter Field Name %s', [LField.Name]))
        else
        begin
          LMethod := LProp.GetterMethod(AClass);
          if LMethod <> nil then
            Writeln(Format('  Getter Method Name %s', [LMethod.Name]))
        end;
      end;

      if LProp.IsWritable then
      begin
        LField := LProp.SetterField;
        if LField <> nil then
          Writeln(Format('  Setter Field Name %s', [LField.Name]))
        else
        begin
          LMethod := LProp.SetterMethod(AClass);
          if LMethod <> nil then
            Writeln(Format('  Setter Method Name %s', [LMethod.Name]))
        end;
      end;

    end;
end;

begin
  try
    DumpPropInfo(TFoo.Create);
    Writeln;
    DumpPropInfoExt(TFoo.Create);
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Readln;

end.

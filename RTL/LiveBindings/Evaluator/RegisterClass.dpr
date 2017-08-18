{$APPTYPE CONSOLE}

uses
  System.Rtti,
  System.TypInfo,
  System.Bindings.Consts,
  System.Bindings.EvalProtocol,
  System.Bindings.Evaluator,
  System.Bindings.EvalSys,
  System.Bindings.ObjEval,
  System.SysUtils;

Type
  TMyClass = class
    function Random(Value: Integer): Integer;
  end;

  { TMyClass }
function TMyClass.Random(Value: Integer): Integer;
begin
  Result := System.Random(Value);
end;

procedure DoIt;
Var
  LScope: IScope;
  LCompiledExpr: ICompiledBinding;
  LResult: TValue;
  LDictionaryScope: TDictionaryScope;
  M: TMyClass;
begin
  M := TMyClass.Create;
  try
    LScope := TNestedScope.Create(BasicOperators, BasicConstants);
    // add a object
    LDictionaryScope := TDictionaryScope.Create;
    LDictionaryScope.Map.Add('M', WrapObject(M));
    LScope := TNestedScope.Create(LScope, LDictionaryScope);
    LCompiledExpr := Compile('M.Random(10000000)', LScope);
    LResult := LCompiledExpr.Evaluate(LScope, nil, nil).GetValue;
    if not LResult.IsEmpty then
      Writeln(LResult.ToString);
  finally
    M.Free;
  end;
end;

begin
  try
    Randomize;
    DoIt;
  except
    on E: Exception do
      Writeln(E.Classname, ':', E.Message);
  end;
  Writeln('Press Enter to exit');
  Readln;

end.

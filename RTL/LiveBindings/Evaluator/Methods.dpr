{$APPTYPE CONSOLE}

uses
  System.Rtti,
  System.Bindings.EvalProtocol,
  System.Bindings.Evaluator,
  System.Bindings.EvalSys,
  System.Bindings.Methods,
  System.SysUtils;

procedure DoIt;
Var
  LScope : IScope;
  LCompiledExpr : ICompiledBinding;
  LResult : TValue;
  LDictionaryScope: TDictionaryScope;
begin
  LScope:= TNestedScope.Create(BasicOperators, BasicConstants);
  //add the registered methods
  LScope := TNestedScope.Create(LScope, TBindingMethodsFactory.GetMethodScope);
  LCompiledExpr:= Compile('Format("%s using the function %s, this function can take numbers like %d or %n as well","This is a formated string","Format",36, Pi)', LScope);
  LResult:=LCompiledExpr.Evaluate(LScope, nil, nil).GetValue;
  if not LResult.IsEmpty then
    Writeln(LResult.ToString);
end;

begin
 try
    DoIt;
 except
    on E:Exception do
        Writeln(E.Classname, ':', E.Message);
 end;
 Writeln('Press Enter to exit');
 Readln;
end.
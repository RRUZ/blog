{$APPTYPE CONSOLE}

uses
  System.Rtti,
  System.Bindings.EvalProtocol,
  System.Bindings.Evaluator,
  System.Bindings.EvalSys,
  System.SysUtils;

procedure DoIt;
Var
  LScope: IScope;
  LCompiledExpr: ICompiledBinding;
  LResult: TValue;
begin
  LScope := BasicOperators;
  LCompiledExpr := Compile('((1+2+3+4)*(25/5))-(10)', LScope);
  LResult := LCompiledExpr.Evaluate(LScope, nil, nil).GetValue;
  if not LResult.IsEmpty then
    Writeln(LResult.ToString);
end;

begin
  try
    DoIt;
  except
    on E: Exception do
      Writeln(E.Classname, ':', E.Message);
  end;
  Writeln('Press Enter to exit');
  Readln;

end.

{$APPTYPE CONSOLE}

uses
  System.Rtti,
  System.TypInfo,
  System.Bindings.Consts,
  System.Bindings.EvalProtocol,
  System.Bindings.Evaluator,
  System.Bindings.EvalSys,
  System.Bindings.Methods,
  System.SysUtils;

{
function IfThen(AValue: Boolean; const ATrue: Integer; const AFalse: Integer): Integer;
function IfThen(AValue: Boolean; const ATrue: Int64; const AFalse: Int64): Int64;
function IfThen(AValue: Boolean; const ATrue: UInt64; const AFalse: UInt64): UInt64;
function IfThen(AValue: Boolean; const ATrue: Single; const AFalse: Single): Single;
function IfThen(AValue: Boolean; const ATrue: Double; const AFalse: Double): Double;
function IfThen(AValue: Boolean; const ATrue: Extended; const AFalse: Extended): Extended;
}
function IfThen: IInvokable;
begin
  Result := MakeInvokable(
    function(Args: TArray<IValue>): IValue
      var
        IAValue: IValue;
        AValue: Boolean;
        IATrue, IAFalse: IValue;
     begin
        //check the number of passed parameters
        if Length(Args) <> 3 then
          raise EEvaluatorError.Create(sFormatArgError);

         IAValue:=Args[0];
         IATrue :=Args[1];
         IAFalse:=Args[2];

         //check if the parameters has values
         if IATrue.GetValue.IsEmpty or IAFalse.GetValue.IsEmpty then
          Exit(TValueWrapper.Create(nil))
         else
         //check if the parameters has the same types
         if IATrue.GetValue.Kind<>IAFalse.GetValue.Kind then
          raise EEvaluatorError.Create('The return values must be of the same type')
         else
         //check if the first parameter is boolean
         if (IAValue.GetType.Kind=tkEnumeration) and (IAValue.GetValue.TryAsType<Boolean>(AValue)) then //Boolean is returned as tkEnumeration
         begin
           if AValue then
            //return the value for True condition
            Exit(TValueWrapper.Create(IATrue.GetValue))
           else
            //return the value for the False condition
            Exit(TValueWrapper.Create(IAFalse.GetValue))
         end
         else raise EEvaluatorError.Create('The first parameter must be a boolean expression');
     end
     );
end;

procedure DoIt;
Var
  LScope : IScope;
  LCompiledExpr : ICompiledBinding;
  LResult : TValue;
  LDictionaryScope: TDictionaryScope;
begin
  LScope:= TNestedScope.Create(BasicOperators, BasicConstants);

    //add a custom method
    TBindingMethodsFactory.RegisterMethod(
        TMethodDescription.Create(
          IfThen,
          'IfThen',
          'IfThen',
          '',
          True,
          '',
          nil));

  //add the registered methods
  LScope := TNestedScope.Create(LScope, TBindingMethodsFactory.GetMethodScope);
  LCompiledExpr:= Compile('Format("The sentence is %s", IfThen(1>0,"True","False"))', LScope);
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

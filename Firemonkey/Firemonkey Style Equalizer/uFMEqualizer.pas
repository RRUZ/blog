unit uFMEqualizer;

interface

Uses
  Rtti,
  Classes,
  Generics.Collections,
  System.UITypes,
  System.UIConsts,
  FMX.Layouts,
  FMX.Types;


type
 TFMStyleLine=record
  Index   : Integer;
  IsColor : Boolean;
  Name    : string;
  Value   : string;
  Color   : TAlphaColor;
 end;

 TStyleEqualizer=class
  private
    FCount  : integer;
    FLines  : TList<TFMStyleLine>;
    FMod    : TList<TFMStyleLine>;
    FResource : TStringList;
    FStyleBook: TStyleBook;
    FLayout: TLayout;
    Context : TRttiContext;
    procedure SetStyleBook(const Value: TStyleBook);
    procedure FillList;
    function  PropIsColor(const Name, Value : string):Boolean;
 public
   property StyleBook : TStyleBook read FStyleBook write SetStyleBook;
   property Layout : TLayout read FLayout write FLayout;
   procedure Refresh;
   procedure Restore;
   procedure ChangeHSL(dH, dS, dL: Single);
   procedure ChangeRGB(dR, dG, dB: Byte);
   constructor Create; overload;
   destructor  Destroy; override;
 end;

implementation

uses
  SysUtils,
  StrUtils,
  FMX.Dialogs;

constructor TStyleEqualizer.Create;
begin
  inherited;
  FLines:=TList<TFMStyleLine>.Create;
  FMod  :=TList<TFMStyleLine>.Create;
  FResource:=TStringList.Create;
  Context :=TRttiContext.Create;
end;

destructor TStyleEqualizer.Destroy;
begin
  FLines.Free;
  FMod.Free;
  FResource.Free;
  Context.Free;
  inherited;
end;

function TStyleEqualizer.PropIsColor(const Name, Value: string): Boolean;
begin
 Result:=(CompareText(Name,'Color')=0) or (Pos('.Color',Name)>0) or (StartsText('cla',Value)) or ( (Length(Value)=9) and (Value[1]='x'));
end;

procedure TStyleEqualizer.FillList;
var
  i : integer;
  ALine : TFMStyleLine;
  p : integer;
begin
  FLines.Clear;
  FResource.Clear;
  FResource.AddStrings(FStyleBook.Resource);
  for i := 0 to FStyleBook.Resource.Count-1 do
  begin
    ALine.IsColor:=False;
    ALine.Name:='';
    ALine.Value:='';
    ALine.Color:=claNull;
    p:=Pos('=',FStyleBook.Resource[i]);
     if p>0 then
     begin
       ALine.Name :=Trim(Copy(FStyleBook.Resource[i],1,p-1));
       ALine.Value:=Trim(Copy(FStyleBook.Resource[i],p+1));
       //xFF1C1C1C
       ALine.IsColor:=PropIsColor(ALine.Name, ALine.Value);
       if ALine.IsColor then
       begin
         ALine.Index:=i;
         ALine.Color :=StringToAlphaColor(ALine.Value);
         FLines.Add(ALine);
       end;
     end;
  end;


  FMod.Clear;
  FMod.AddRange(FLines);

      {
 Stream:=TStringStream.Create;
 try
   s:=FStyleBook.Resource.Text;
   Stream.WriteString(s);
   Stream.Position:=0;
   FLayout:=TLayout(CreateObjectFromStream(nil,Stream));
 finally
  Stream.Free;
 end;

 _Process;
      }

end;



procedure TStyleEqualizer.Refresh;
Var
 i : Integer;
 s : string;
 Index :  Integer;
begin
   FStyleBook.Resource.BeginUpdate;
   try
    FStyleBook.Resource.Clear;
    FStyleBook.Resource.AddStrings(FResource);
      for i := 0 to FMod.Count-1 do
        if FMod[i].IsColor and (FLines[i].Color<>claNull) then
        begin
           AlphaColorToIdent(FMod[i].Color,s);
           Index:=FMod[i].Index;
           if FLines[i].Value<>s then
             FStyleBook.Resource[Index]:=StringReplace(FStyleBook.Resource[Index],FLines[i].Value,s,[rfReplaceAll]);
        end;
   finally
      FStyleBook.Resource.EndUpdate;
   end;
end;

procedure TStyleEqualizer.Restore;
begin
   FStyleBook.Resource.BeginUpdate;
   try
      FStyleBook.Resource.Clear;
      FStyleBook.Resource.AddStrings(FResource);
   finally
      FStyleBook.Resource.EndUpdate;
   end;
end;

procedure TStyleEqualizer.SetStyleBook(const Value: TStyleBook);
begin
  FStyleBook := Value;
  FCount:=0;
  FillList;
end;



procedure TStyleEqualizer.ChangeRGB(dR, dG, dB: Byte);
var
  i : Integer;
  v : TFMStyleLine;

begin
  for i := 0 to FLines.Count-1 do
   if FLines[i].IsColor and (FLines[i].Color<>claNull) then
    begin
      v:=FLines[i];
      TAlphaColorRec(v.Color).R:=TAlphaColorRec(v.Color).R+dR;
      TAlphaColorRec(v.Color).G:=TAlphaColorRec(v.Color).G+dG;
      TAlphaColorRec(v.Color).B:=TAlphaColorRec(v.Color).B+dB;
      if v.Color<>FMod[i].Color then
        FMod[i]:=v;
    end;
end;

procedure TStyleEqualizer.ChangeHSL(dH, dS, dL: Single);
var
  i : Integer;
  v : TFMStyleLine;
begin
  for i := 0 to FLines.Count-1 do
   if FLines[i].IsColor and (FLines[i].Color<>claNull) then
    begin
      v:=FLines[i];
      v.Color:=(FMX.Types.ChangeHSL(v.Color,dH,dS,dL));
      if v.Color<>FMod[i].Color then
        FMod[i]:=v;
    end;
end;

end.

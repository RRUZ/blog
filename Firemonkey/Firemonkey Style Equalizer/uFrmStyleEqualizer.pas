unit uFrmStyleEqualizer;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.Edit, uFMEqualizer,
  FMX.Layouts, FMX.Memo, FMX.Objects, FMX.TreeView, FMX.Colors;

{$IFNDEF MSWINDOWS}
 Sorry only windows for now
{$ENDIF}

type
  TFrmStyleEqualizer = class(TForm)
    TrackBarSat: TTrackBar;
    TrackBarLig: TTrackBar;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    BtnApply: TButton;
    BtnCancel: TButton;
    BtnSave: TButton;
    Log: TMemo;
    SaveDialog1: TSaveDialog;
    SpinBoxHue: TSpinBox;
    TrackBarHue: THueTrackBar;
    BtnRestore: TButton;
    Line1: TLine;
    Line2: TLine;
    Line3: TLine;
    SpinBoxSat: TSpinBox;
    SpinBoxLig: TSpinBox;
    Timer1: TTimer;
    Label4: TLabel;
    Line4: TLine;
    TrackBarGreen: TTrackBar;
    Label5: TLabel;
    Line5: TLine;
    TrackBarRed: TTrackBar;
    Label6: TLabel;
    Line6: TLine;
    TrackBarBlue: TTrackBar;
    Label7: TLabel;
    Line7: TLine;
    SpinBoxRed: TSpinBox;
    SpinBoxGreen: TSpinBox;
    SpinBoxBlue: TSpinBox;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure BtnApplyClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtnCancelClick(Sender: TObject);
    procedure BtnSaveClick(Sender: TObject);
    procedure TrackBarHueChange(Sender: TObject);
    procedure BtnRestoreClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure TrackBarRedChange(Sender: TObject);
  private
    StyleEqualizer   : TStyleEqualizer;
    FStyleBook: TStyleBook;
    FApplied  : Boolean;
    FIdleMSec : DWord;
    procedure SetStyleBook(const Value: TStyleBook);
    procedure GetCurrentHSLValues(var dh, ds, dl : single);
    procedure GetCurrentRGBValues(var dr, dg, db : byte);
    procedure ApplyHSLChanges;
    procedure ApplyRGBChanges;
  public
    property StyleBook : TStyleBook read FStyleBook write SetStyleBook;
  end;


implementation

Uses
  FMX.Platform,
{$IFDEF MSWINDOWS}
  Winapi.Windows,
{$ENDIF}
  System.Diagnostics;

{$R *.fmx}



{$IFDEF MSWINDOWS}
function MSecIdle: DWord;
var
   plii: TLastInputInfo;
begin
   plii.cbSize := SizeOf(plii) ;
   GetLastInputInfo(plii) ;
   Result := (GetTickCount - plii.dwTime);
   //Result := (Round(Platform.GetTick*1000) - plii.dwTime);
end;
{$ENDIF}


procedure TFrmStyleEqualizer.ApplyHSLChanges;
var
  dh, ds, dl : single;
  s : TStopwatch;
begin
   GetCurrentHSLValues(dh, ds, dl);
   s:=TStopwatch.Create;
   s.Reset;
   s.Start;
   StyleEqualizer.ChangeHSL(dh,ds,dl);
   StyleEqualizer.Refresh;
   s.Stop;
   FApplied:=True;
   Log.Lines.Add('Ellapsed ApplyHSLChanges '+IntToStr(s.ElapsedMilliseconds));
end;

procedure TFrmStyleEqualizer.ApplyRGBChanges;
var
  dr, dg, db : byte;
  s : TStopwatch;
begin
   GetCurrentRGBValues(dr, dg, db);
   if (dr>0) or (dg>0) or (db>0) then
   begin
     s:=TStopwatch.Create;
     s.Reset;
     s.Start;
     StyleEqualizer.ChangeRGB(dr,dg,db);
     StyleEqualizer.Refresh;
     s.Stop;
     FApplied:=True;
     Log.Lines.Add('Ellapsed ApplyRGBChanges '+IntToStr(s.ElapsedMilliseconds));
   end;
end;


procedure TFrmStyleEqualizer.BtnApplyClick(Sender: TObject);
begin
  ApplyHSLChanges;
  ApplyRGBChanges;
end;

procedure TFrmStyleEqualizer.BtnSaveClick(Sender: TObject);
begin
  if SaveDialog1.Execute then
    StyleBook.Resource.SaveToFile(SaveDialog1.FileName);
end;

procedure TFrmStyleEqualizer.BtnRestoreClick(Sender: TObject);
begin
  TrackBarSat.Value:=0;
  TrackBarLig.Value:=0;
  TrackBarHue.Value:=0;

  TrackBarRed.Value:=0;
  TrackBarGreen.Value:=0;
  TrackBarBlue.Value:=0;

  StyleEqualizer.Restore;
end;

procedure TFrmStyleEqualizer.BtnCancelClick(Sender: TObject);
begin
  StyleEqualizer.Restore;
  Close();
end;


procedure TFrmStyleEqualizer.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action:=TCloseAction.caFree;
end;

procedure TFrmStyleEqualizer.FormCreate(Sender: TObject);
begin
 StyleEqualizer:=TStyleEqualizer.Create;
 FApplied:=False;
 FIdleMSec:=50;
end;

procedure TFrmStyleEqualizer.FormDestroy(Sender: TObject);
begin
  StyleEqualizer.Free;
end;

procedure TFrmStyleEqualizer.GetCurrentHSLValues(var dh, ds, dl: single);
begin
   dh:=Trunc(TrackBarHue.Value);
   dh:=dh/360;

   ds:=Trunc(TrackBarSat.Value);
   ds:=ds/100;

   dl:=Trunc(TrackBarLig.Value);
   dl:=(dl/200);
end;


procedure TFrmStyleEqualizer.GetCurrentRGBValues(var dr, dg, db: byte);
begin
   dr:=Byte(Trunc(TrackBarRed.Value));
   dg:=Byte(Trunc(TrackBarGreen.Value));
   db:=Byte(Trunc(TrackBarBlue.Value));
end;


procedure TFrmStyleEqualizer.SetStyleBook(const Value: TStyleBook);
begin
  FStyleBook := Value;
  StyleEqualizer.StyleBook:=Value;
end;

procedure TFrmStyleEqualizer.Timer1Timer(Sender: TObject);
begin
  if (MSecIdle>=FIdleMSec) and not FApplied then
  begin
   ApplyHSLChanges;
   ApplyRGBChanges;
  end;
end;

procedure TFrmStyleEqualizer.TrackBarHueChange(Sender: TObject);
begin
  if Assigned(StyleEqualizer) and (MSecIdle>=FIdleMSec) then
    ApplyHSLChanges
  else
  FApplied:=False;
end;

procedure TFrmStyleEqualizer.TrackBarRedChange(Sender: TObject);
begin
  if Assigned(StyleEqualizer) and (MSecIdle>=FIdleMSec) then
    ApplyRGBChanges
  else
  FApplied:=False;
end;

end.

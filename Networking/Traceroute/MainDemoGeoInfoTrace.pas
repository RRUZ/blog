unit MainDemoGeoInfoTrace;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TFrmMainTrace = class(TForm)
    EditAddress: TEdit;
    BrnTrace: TButton;
    MemoTrace: TMemo;
    Panel1: TPanel;
    LabelTrace: TLabel;
    procedure BrnTraceClick(Sender: TObject);
  private
    procedure TraceAddress;
    procedure TraceLogCallBack(const Msg:string);
  public
    { Public declarations }
  end;

var
  FrmMainTrace: TFrmMainTrace;

implementation

uses NetHelperFuncs;

{$R *.dfm}

procedure TFrmMainTrace.BrnTraceClick(Sender: TObject);
begin
   TraceAddress;
end;

procedure TFrmMainTrace.TraceAddress;
var
  Trace: TGeoTraceThread;
begin
    if Trim(EditAddress.Text)='' then  Exit;
    Trace:=TGeoTraceThread.Create(True);
    Trace.FreeOnTerminate    :=True;
    Trace.DestAddress        :=EditAddress.Text;
    Trace.MaxHops            :=30;
    Trace.ResolveHostName    :=True;
    Trace.IcmpTimeOut        :=5000;
    Trace.MsgCallBack        :=TraceLogCallBack;
    Trace.IncludeGeoInfo     :=True;
    Trace.Start;
end;

procedure TFrmMainTrace.TraceLogCallBack(const Msg: string);
begin
  MemoTrace.Lines.Add(Msg);
  MemoTrace.Perform(WM_VSCROLL, SB_BOTTOM, 0);
end;

end.

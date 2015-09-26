unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, OleCtrls, SHDocVw;


const
  DISPID_AMBIENT_USERAGENT = -5513;

type
  TWebBrowser = class (SHDocVw.TWebbrowser, IDispatch)
  private
    FUserAgent: string;
    procedure SetUserAgent (const Value: string);
    function Invoke(DispID: Integer; const IID: TGUID; LocaleID: Integer; Flags: Word; var Params; VarResult, ExcepInfo, ArgErr: Pointer): HRESULT; stdcall;
  public
    property UserAgent: string read FUserAgent write SetUserAgent;
    constructor Create(AOwner: TComponent); override;
  end;


  TFrmMain = class(TForm)
    WebBrowser1: TWebBrowser;
    BtnGo: TButton;
    EditURL: TEdit;
    Label1: TLabel;
    CbUserAgent: TComboBox;
    Label2: TLabel;
    procedure BtnGoClick(Sender: TObject);
    procedure CbUserAgentChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure WebBrowser1DocumentComplete(ASender: TObject;
      const pDisp: IDispatch; var URL: OleVariant);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmMain: TFrmMain;

implementation

uses
  ActiveX;

{$R *.dfm}

procedure TFrmMain.BtnGoClick(Sender: TObject);
begin
  WebBrowser1.UserAgent:=CbUserAgent.Text;
  WebBrowser1.Navigate(EditURL.Text);
end;

constructor TWebBrowser.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FUserAgent:='';
end;


function TWebBrowser.Invoke(DispID: Integer; const IID: TGUID; LocaleID: Integer; Flags: Word; var Params; VarResult, ExcepInfo, ArgErr: Pointer): HRESULT;
begin
  if (FUserAgent <> '') and (Flags and DISPATCH_PROPERTYGET <> 0) and Assigned(VarResult) and (DispId=DISPID_AMBIENT_USERAGENT) then
  begin
    POleVariant(VarResult)^:= FUserAgent+#13#10;
    Result := S_OK;
  end
  else
  Result := inherited Invoke(DispID, IID, LocaleID, Flags, Params, VarResult, ExcepInfo, ArgErr);
end;

procedure TWebBrowser.SetUserAgent(const Value: string);
var
  Control: IOleControl;
begin
  FUserAgent := Value;
  if DefaultInterface.QueryInterface(IOleControl, Control) = 0 then
    Control.OnAmbientPropertyChange(DISPID_AMBIENT_USERAGENT);
end;

procedure TFrmMain.CbUserAgentChange(Sender: TObject);
begin
  WebBrowser1.UserAgent:=CbUserAgent.Text;
  WebBrowser1.Refresh;
end;

procedure TFrmMain.FormCreate(Sender: TObject);
begin
  WebBrowser1.UserAgent:=CbUserAgent.Text;
  WebBrowser1.HandleNeeded;
  WebBrowser1.Navigate('about:blank');
end;

procedure TFrmMain.WebBrowser1DocumentComplete(ASender: TObject; const pDisp: IDispatch; var URL: OleVariant);
begin
   EditURL.Text:=WebBrowser1.LocationURL;
end;

end.

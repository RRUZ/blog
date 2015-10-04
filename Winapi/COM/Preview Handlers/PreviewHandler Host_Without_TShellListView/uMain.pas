unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.OleCtnrs, uHostPreview,
  Vcl.ExtCtrls, Vcl.ComCtrls;

type
  TFrmMain = class(TForm)
    Panel1: TPanel;
    Panel3: TPanel;
    EditFileName: TEdit;
    Button1: TButton;
    OpenDialog1: TOpenDialog;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
    FPreview: THostPreviewHandler;
    procedure LoadPreview(const FileName : string);
  public
    { Public declarations }
  end;

var
  FrmMain: TFrmMain;

implementation


{$R *.dfm}

type
  THostPreviewHandlerClass=class(THostPreviewHandler);


procedure TFrmMain.Button1Click(Sender: TObject);
begin
 if OpenDialog1.Execute() then
 begin
   EditFileName.Text:= OpenDialog1.FileName;
   LoadPreview(EditFileName.Text);
 end;
end;

procedure TFrmMain.FormCreate(Sender: TObject);
begin
  ReportMemoryLeaksOnShutdown := True;
  FPreview:=nil;
end;

procedure TFrmMain.FormDestroy(Sender: TObject);
begin
  if FPreview<>nil then
   FreeAndNil(FPreview);
end;

procedure TFrmMain.LoadPreview(const FileName: string);
begin
  if FPreview<>nil then
   FreeAndNil(FPreview);

  FPreview := THostPreviewHandler.Create(Self);
  FPreview.Top := 0;
  FPreview.Left := 0;
  FPreview.Width := Panel1.ClientWidth;
  FPreview.Height := Panel1.ClientHeight;
  FPreview.Parent := Panel1;
  FPreview.Align  := alClient;
  //FPreview.FileName:='C:\Users\Dexter\Desktop\RAD Studio Projects\XE2\delphi-preview-handler\main.pas';
  //FPreview.FileName:='C:\Users\Dexter\Desktop\RAD Studio Projects\2010\SMBIOS Delphi\Docs\DSP0119.pdf';
  //FPreview.FileName:='C:\Users\Dexter\Desktop\seleccion\RePLE.msg';
  FPreview.FileName:=FileName;
  THostPreviewHandlerClass(FPreview).Paint;
end;

end.

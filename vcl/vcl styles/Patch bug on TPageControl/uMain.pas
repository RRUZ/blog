unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls, Vcl.ImgList;

type
  TFrmMain = class(TForm)
    Button1: TButton;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    ImageList1: TImageList;
    TabControl1: TTabControl;
    procedure Button1Click(Sender: TObject);
    procedure TabSet1GetImageIndex(Sender: TObject; TabIndex: Integer;
      var ImageIndex: Integer);
    procedure TabControl1GetImageIndex(Sender: TObject; TabIndex: Integer;
      var ImageIndex: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmMain: TFrmMain;

implementation

{.$DEFINE Apply_Patch}

{$R *.dfm}

Uses
  uXE2Patches,
  Vcl.Themes,
  Vcl.Styles;

procedure TFrmMain.Button1Click(Sender: TObject);
begin
  TStyleManager.SetStyle('Carbon');
end;

procedure TFrmMain.TabControl1GetImageIndex(Sender: TObject; TabIndex: Integer;
  var ImageIndex: Integer);
begin
  ImageIndex:=TabIndex+1;
end;

procedure TFrmMain.TabSet1GetImageIndex(Sender: TObject; TabIndex: Integer;
  var ImageIndex: Integer);
begin
  ImageIndex:=TabIndex+1;
end;

{$IFDEF Apply_Patch}
initialization
   TStyleManager.Engine.UnRegisterStyleHook(TCustomTabControl, TTabControlStyleHook);
   TStyleManager.Engine.RegisterStyleHook(TCustomTabControl, TMyTabControlStyleHook);

   TStyleManager.Engine.UnRegisterStyleHook(TTabControl, TTabControlStyleHook);
   TStyleManager.Engine.RegisterStyleHook(TTabControl, TMyTabControlStyleHook);

{$ENDIF}

end.

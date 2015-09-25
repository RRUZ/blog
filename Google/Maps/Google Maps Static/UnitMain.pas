unit UnitMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, IdHTTP,
  StdCtrls, ExtCtrls, XPMan, ComCtrls;

type
  TFormMain = class(TForm)
    ImageMap: TImage;
    XPManifest1: TXPManifest;
    ScrollBoxMap: TScrollBox;
    Panel1: TPanel;
    EditURL: TEdit;
    ButtonGet: TButton;
    CheckBoxRealTime: TCheckBox;
    Panel2: TPanel;
    Panel3: TPanel;
    EditWidth: TEdit;
    UpDown3: TUpDown;
    UpDown2: TUpDown;
    UpDown1: TUpDown;
    ComboBoxMapType: TComboBox;
    EditZoom: TEdit;
    ComboBoxFormat: TComboBox;
    EditHeight: TEdit;
    EditLongitude: TEdit;
    EditLatitude: TEdit;
    Label7: TLabel;
    Label6: TLabel;
    Label5: TLabel;
    Label4: TLabel;
    Label3: TLabel;
    Label2: TLabel;
    Label1: TLabel;
    CheckBoxMarker: TCheckBox;
    ProgressBar1: TProgressBar;
    IdHTTP1: TIdHTTP;
    procedure ButtonGetClick(Sender: TObject);
    procedure EditZoomChange(Sender: TObject);
    procedure ComboBoxMapTypeChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ImageMapMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ImageMapMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure IdHTTP10WorkBegin(ASender: TObject; AWorkMode: TWorkMode;
      AWorkCountMax: Integer);
    procedure IdHTTP10Work(ASender: TObject; AWorkMode: TWorkMode;
      AWorkCount: Integer);
    procedure IdHTTP10WorkEnd(ASender: TObject; AWorkMode: TWorkMode);
  private
    { Private declarations }
    SX: Integer;
    SY: Integer;
    LX: Integer;
    LY: Integer;
    function  buildUrl:string;
    procedure GetMapImage;
  public
    { Public declarations }
  end;

var
  FormMain: TFormMain;

implementation

uses
jpeg;

{$R *.dfm}

const
UrlPrefix='http://maps.google.com/maps/api/staticmap?';

function TFormMain.buildUrl: string;
begin
  Result:=UrlPrefix+'center='+EditLatitude.Text+','+EditLongitude.Text+'&zoom='+EditZoom.Text+'&size='+EditWidth.Text+'x'+EditHeight.Text+'&maptype='+ComboBoxMapType.Text+'&sensor=false&format='+ComboBoxFormat.Text;
  if CheckBoxMarker.Checked then
  Result:=Result+'&markers=color:blue|'+EditLatitude.Text+','+EditLongitude.Text;
end;

procedure TFormMain.ButtonGetClick(Sender: TObject);
begin
 GetMapImage;
end;

procedure TFormMain.ComboBoxMapTypeChange(Sender: TObject);
begin
 if CheckBoxRealTime.Checked then
 GetMapImage;
end;

procedure TFormMain.EditZoomChange(Sender: TObject);
begin
 if CheckBoxRealTime.Checked then
 GetMapImage;
end;

procedure TFormMain.FormCreate(Sender: TObject);
begin
 ScrollBoxMap.DoubleBuffered := True;
end;

procedure TFormMain.GetMapImage;
var
  StreamData :TMemoryStream;
  JPEGImage  : TJPEGImage;
begin
  EditURL.Text:=buildUrl;
  StreamData := TMemoryStream.Create;
  JPEGImage  := TJPEGImage.Create;
  try
    try
     idhttp1.Get(EditURL.Text, StreamData);
     StreamData.Seek(0,soFromBeginning);

     ImageMap.Top := 0;
     ImageMap.Left := 0;
     JPEGImage.LoadFromStream(StreamData);
     LX := (ImageMap.Width - ScrollBoxMap.ClientWidth) * -1;
     LY := (ImageMap.Height - ScrollBoxMap.ClientHeight) * -1;

     ImageMap.Picture.Assign(JPEGImage);
    Except On E : Exception Do
     MessageDlg('Exception: '+E.Message,mtError, [mbOK], 0);
    End;
  finally
    StreamData.free;
    JPEGImage.Free;
  end;
end;

procedure TFormMain.IdHTTP10Work(ASender: TObject; AWorkMode: TWorkMode;
  AWorkCount: Integer);
begin
  ProgressBar1.Position := AWorkCount;
end;

procedure TFormMain.IdHTTP10WorkBegin(ASender: TObject; AWorkMode: TWorkMode;
  AWorkCountMax: Integer);
begin
  ProgressBar1.Position := 0;
  ProgressBar1.Max      := IdHTTP1.Response.ContentLength;
end;

procedure TFormMain.IdHTTP10WorkEnd(ASender: TObject; AWorkMode: TWorkMode);
begin
  //ProgressBar1.Position := 0;
end;

procedure TFormMain.ImageMapMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
   SX := X;
   SY := Y;
end;

procedure TFormMain.ImageMapMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var NX: Integer;
    NY: Integer;
begin
    if not (ssLeft in Shift) then   Exit;
    NX := ImageMap.Left + X - SX;
    NY := ImageMap.Top + Y - SY;

    if (NX < 0) and (NX > LX) then  ImageMap.Left := NX;
    if (NY < 0) and (NY > LY) then  ImageMap.Top := NY;
end;

end.

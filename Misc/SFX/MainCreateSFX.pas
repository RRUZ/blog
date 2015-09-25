unit MainCreateSFX;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls, ZLib;

type
  TFrmCreateSFX = class(TForm)
    ButtonCreateSFX: TButton;
    OpenDialog1: TOpenDialog;
    EditFile: TEdit;
    ButtonSelect: TButton;
    ProgressBarSfx: TProgressBar;
    LabelInfo: TLabel;
    Label1: TLabel;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    RadioButton3: TRadioButton;
    RadioButton4: TRadioButton;
    procedure ButtonCreateSFXClick(Sender: TObject);
    procedure ButtonSelectClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    FSrcFileName   : string;
    FSfxFileName   : string;
    function  CreateStub:Boolean;
    function  GetCompressionLevel: TCompressionLevel;
    procedure CreateSFX;
    procedure DoProgress(Sender: TObject);
  end;

var
  FrmCreateSFX: TFrmCreateSFX;

implementation

uses Common;

{$R *.dfm}
{$R Stub.res}

procedure TFrmCreateSFX.ButtonCreateSFXClick(Sender: TObject);
begin
  if CreateStub then
   CreateSFX;
end;

procedure TFrmCreateSFX.ButtonSelectClick(Sender: TObject);
begin
   if OpenDialog1.Execute(Handle) then
   begin
     EditFile.Text:=OpenDialog1.FileName;
     FSrcFileName:=OpenDialog1.FileName;
     FSfxFileName:=ExtractFilePath(ParamStr(0))+ExtractFileName(EditFile.Text)+'.exe';
     ButtonCreateSFX.Enabled:=True;
     ButtonSelect.Enabled:=False;
   end;
end;

procedure TFrmCreateSFX.CreateSFX;
var
  SrcFileStream   : TFileStream;
  CompressedStream: TMemoryStream;
  hDestRes        : THANDLE;
  Compressor      : TCompressionStream;
  RecSFX          : TRecSFX;
begin
  SrcFileStream      := TFileStream.Create(FSrcFileName,fmOpenRead or fmShareDenyNone);
  ProgressBarSfx.Max := SrcFileStream.Size;
 try
  try
    CompressedStream:= TMemoryStream.Create;
    try
      Compressor:=TCompressionStream.Create(GetCompressionLevel,CompressedStream);
      try
        Compressor.OnProgress:=DoProgress;
        Compressor.CopyFrom(SrcFileStream,0);
      finally
        Compressor.Free;
      end;

        FillChar(RecSFX,SizeOf(RecSFX),#0);
        RecSFX.Size:=SrcFileStream.Size;
        Move(ExtractFileName(FSrcFileName)[1],RecSFX.Name,Length(ExtractFileName(FSrcFileName)));

        hDestRes:= BeginUpdateResource(PAnsiChar(FSfxFileName), False);
        if hDestRes <> 0 then
          if UpdateResource(hDestRes, RT_RCDATA,'SFXREC',0,@RecSFX,SizeOf(RecSFX)) then
             if EndUpdateResource(hDestRes,FALSE) then
             else
             RaiseLastOSError
          else
          RaiseLastOSError
        else
        RaiseLastOSError;

        hDestRes:= BeginUpdateResource(PAnsiChar(FSfxFileName), False);
        if hDestRes <> 0 then
          if UpdateResource(hDestRes, RT_RCDATA,'SFXDATA',0,CompressedStream.Memory,CompressedStream.Size) then
            if EndUpdateResource(hDestRes,FALSE) then
            begin
               LabelInfo.Caption:=
               Format('SFX Created %sOriginal Size %s %sCompressed Size %s Ratio %n %%',[#13,FormatFloat('#,',SrcFileStream.Size),#13,FormatFloat('#,',CompressedStream.Size),CompressedStream.Size*100/SrcFileStream.Size]);
               ProgressBarSfx.Position:=ProgressBarSfx.Max;
               ButtonCreateSFX.Enabled:=False;
            end
            else
            RaiseLastOSError
          else
          RaiseLastOSError
        else
        RaiseLastOSError;
    finally
      CompressedStream.Free;
    end;
  finally
    SrcFileStream.Free;
  end;
 except on e : exception do
   Application.MessageBox(PAnsiChar(e.Message),'Error',MB_OK+MB_ICONERROR);
 end;
end;


function TFrmCreateSFX.CreateStub:Boolean;
var
  StubStream: TResourceStream;
begin
  StubStream := TResourceStream.Create( HInstance, 'STUB', 'RT_RCDATA');
  try
     DeleteFile(FSfxFileName);
     StubStream.SaveToFile(FSfxFileName);
  finally
    StubStream.Free;
  end;
  Result:=FileExists(FSfxFileName);
end;


procedure TFrmCreateSFX.DoProgress(Sender: TObject);
begin
   ProgressBarSfx.Position:=TCustomZLibStream(Sender).Position;
   LabelInfo.Caption:=Format('Compressed %s bytes %n %%',[FormatFloat('#,',TCustomZLibStream(Sender).Position),100*TCustomZLibStream(Sender).Position/ProgressBarSfx.Max]);
   LabelInfo.Update;
end;

procedure TFrmCreateSFX.FormCreate(Sender: TObject);
begin
   LabelInfo.Caption:='';
end;

function TFrmCreateSFX.GetCompressionLevel: TCompressionLevel;
var
 i : Integer;
begin
  Result:=clMax;
    for i:= 0 to ComponentCount - 1 do
     if Components[i].ClassType = TRadioButton then
      if TRadioButton(Components[i]).Checked then
       Result:=TCompressionLevel(TRadioButton(Components[i]).Tag);
end;

end.

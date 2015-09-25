unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.Themes,
  Vcl.Mask, Vcl.ExtCtrls;

type
  TEdit= Class (Vcl.StdCtrls.TEdit);
  TMemo= Class (Vcl.StdCtrls.TMemo);
  TButtonedEdit= Class (Vcl.ExtCtrls.TButtonedEdit);
  TLabeledEdit= Class (Vcl.ExtCtrls.TLabeledEdit);



  TEditStyleHookColor = class(TEditStyleHook)
  private
    procedure UpdateColors;
  protected
    procedure WndProc(var Message: TMessage); override;
  public
    constructor Create(AControl: TWinControl); override;
  end;

  TMemoStyleHookColor = class(TMemoStyleHook)
  private
    procedure UpdateColors;
  protected
    procedure WndProc(var Message: TMessage); override;
  public
    constructor Create(AControl: TWinControl); override;
  end;


  TFrmMain = class(TForm)
    Edit1: TEdit;
    Edit2: TEdit;
    Memo1: TMemo;
    Memo2: TMemo;
    MaskEdit1: TMaskEdit;
    LabeledEdit1: TLabeledEdit;
    ButtonedEdit1: TButtonedEdit;
    ButtonedEdit2: TButtonedEdit;
    LabeledEdit2: TLabeledEdit;
    MaskEdit2: TMaskEdit;
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  private
  public
    { Public declarations }
  end;

var
  FrmMain: TFrmMain;

implementation

{$R *.dfm}

uses
  Vcl.Styles;

type
 TWinControlH= class(TWinControl);


constructor TEditStyleHookColor.Create(AControl: TWinControl);
begin
  inherited;
  UpdateColors;
end;

procedure TEditStyleHookColor.UpdateColors;
var
  LStyle: TCustomStyleServices;
begin
 if Control.Enabled then
 begin
  Brush.Color := TWinControlH(Control).Color;
  FontColor   := TWinControlH(Control).Font.Color;
 end
 else
 begin
  LStyle := StyleServices;
  Brush.Color := LStyle.GetStyleColor(scEditDisabled);
  FontColor := LStyle.GetStyleFontColor(sfEditBoxTextDisabled);
 end;
end;

procedure TEditStyleHookColor.WndProc(var Message: TMessage);
begin
  case Message.Msg of
    CN_CTLCOLORMSGBOX..CN_CTLCOLORSTATIC:
      begin
        UpdateColors;
        SetTextColor(Message.WParam, ColorToRGB(FontColor));
        SetBkColor(Message.WParam, ColorToRGB(Brush.Color));
        Message.Result := LRESULT(Brush.Handle);
        Handled := True;
      end;
    CM_ENABLEDCHANGED:
      begin
        UpdateColors;
        Handled := False;
      end
  else
    inherited WndProc(Message);
  end;
end;

{ TMemoStyleHookColor }

constructor TMemoStyleHookColor.Create(AControl: TWinControl);
begin
  inherited;
  UpdateColors;
end;

procedure TMemoStyleHookColor.UpdateColors;
var
  LStyle: TCustomStyleServices;
begin
 if Control.Enabled then
 begin
  Brush.Color := TWinControlH(Control).Color;
  FontColor   := TWinControlH(Control).Font.Color;
 end
 else
 begin
  LStyle := StyleServices;
  Brush.Color := LStyle.GetStyleColor(scEditDisabled);
  FontColor := LStyle.GetStyleFontColor(sfEditBoxTextDisabled);
 end;
end;

procedure TMemoStyleHookColor.WndProc(var Message: TMessage);
begin
  case Message.Msg of
    CN_CTLCOLORMSGBOX..CN_CTLCOLORSTATIC:
      begin
        UpdateColors;
        SetTextColor(Message.WParam, ColorToRGB(FontColor));
        SetBkColor(Message.WParam, ColorToRGB(Brush.Color));
        Message.Result := LRESULT(Brush.Handle);
        Handled := True;
      end;

    CM_COLORCHANGED,
    CM_ENABLEDCHANGED:
      begin
        UpdateColors;
        Handled := False;
      end
  else
    inherited WndProc(Message);
  end;
end;


procedure TFrmMain.Button1Click(Sender: TObject);
begin
 Edit1.Color:=clBlue;
end;



initialization
{
 TStyleManager.Engine.RegisterStyleHook(TCustomEdit, TEditStyleHookColor);
 TStyleManager.Engine.RegisterStyleHook(TEdit, TEditStyleHookColor);

 TStyleManager.Engine.RegisterStyleHook(TMemo, TMemoStyleHookColor);
 TStyleManager.Engine.RegisterStyleHook(TCustomMemo, TMemoStyleHookColor);

 TStyleManager.Engine.RegisterStyleHook(TCustomMaskEdit, TEditStyleHookColor);
 TStyleManager.Engine.RegisterStyleHook(TMaskEdit, TEditStyleHookColor);

 TStyleManager.Engine.RegisterStyleHook(TCustomLabeledEdit, TEditStyleHookColor);
 TStyleManager.Engine.RegisterStyleHook(TLabeledEdit, TEditStyleHookColor);
 }
 TStyleManager.Engine.RegisterStyleHook(TEdit, TEditStyleHookColor);
 TStyleManager.Engine.RegisterStyleHook(TButtonedEdit, TEditStyleHookColor);

 TStyleManager.Engine.RegisterStyleHook(TMemo, TMemoStyleHookColor);
 TStyleManager.Engine.RegisterStyleHook(TMaskEdit, TEditStyleHookColor);
 TStyleManager.Engine.RegisterStyleHook(TLabeledEdit, TEditStyleHookColor);

end.


object FrmCreateSFX: TFrmCreateSFX
  Left = 516
  Top = 480
  BorderStyle = bsSingle
  Caption = 'Create SFX'
  ClientHeight = 218
  ClientWidth = 325
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object LabelInfo: TLabel
    Left = 8
    Top = 56
    Width = 45
    Height = 13
    Caption = 'LabelInfo'
  end
  object Label1: TLabel
    Left = 8
    Top = 131
    Width = 86
    Height = 13
    Caption = 'Compress Method'
  end
  object ButtonCreateSFX: TButton
    Left = 89
    Top = 184
    Width = 75
    Height = 25
    Caption = 'Create SFX'
    Enabled = False
    TabOrder = 0
    OnClick = ButtonCreateSFXClick
  end
  object EditFile: TEdit
    Left = 8
    Top = 8
    Width = 291
    Height = 21
    Enabled = False
    TabOrder = 1
  end
  object ButtonSelect: TButton
    Left = 8
    Top = 184
    Width = 75
    Height = 25
    Caption = 'Select File'
    TabOrder = 2
    OnClick = ButtonSelectClick
  end
  object ProgressBarSfx: TProgressBar
    Left = 8
    Top = 35
    Width = 291
    Height = 17
    TabOrder = 3
  end
  object RadioButton1: TRadioButton
    Left = 8
    Top = 150
    Width = 57
    Height = 17
    Caption = 'Store'
    TabOrder = 4
  end
  object RadioButton2: TRadioButton
    Tag = 1
    Left = 71
    Top = 150
    Width = 57
    Height = 17
    Caption = 'Fastest'
    TabOrder = 5
  end
  object RadioButton3: TRadioButton
    Tag = 2
    Left = 134
    Top = 150
    Width = 58
    Height = 17
    Caption = 'Normal'
    TabOrder = 6
  end
  object RadioButton4: TRadioButton
    Tag = 3
    Left = 198
    Top = 150
    Width = 59
    Height = 17
    Caption = 'Maximum'
    Checked = True
    TabOrder = 7
    TabStop = True
  end
  object OpenDialog1: TOpenDialog
    Left = 192
    Top = 16
  end
end

object FrmMain: TFrmMain
  Left = 498
  Top = 313
  BorderStyle = bsSingle
  Caption = 'QrCode Generator'
  ClientHeight = 337
  ClientWidth = 655
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
  object Image1: TImage
    Left = 8
    Top = 8
    Width = 321
    Height = 321
  end
  object Label1: TLabel
    Left = 335
    Top = 8
    Width = 23
    Height = 13
    Caption = 'Data'
  end
  object Label2: TLabel
    Left = 335
    Top = 135
    Width = 19
    Height = 13
    Caption = 'Size'
  end
  object Label3: TLabel
    Left = 335
    Top = 181
    Width = 100
    Height = 13
    Caption = 'Error correction level'
  end
  object BtnGenerate: TButton
    Left = 572
    Top = 304
    Width = 75
    Height = 25
    Caption = 'Generate'
    TabOrder = 0
    OnClick = BtnGenerateClick
  end
  object MemoData: TMemo
    Left = 335
    Top = 24
    Width = 312
    Height = 105
    Lines.Strings = (
      'Sample Data')
    MaxLength = 2000
    ScrollBars = ssBoth
    TabOrder = 1
  end
  object EditWidth: TMaskEdit
    Left = 335
    Top = 154
    Width = 69
    Height = 21
    EditMask = '!999;1; '
    MaxLength = 3
    TabOrder = 2
    Text = '300'
  end
  object EditHeight: TMaskEdit
    Left = 412
    Top = 154
    Width = 69
    Height = 21
    EditMask = '!999;1; '
    MaxLength = 3
    TabOrder = 3
    Text = '300'
  end
  object ComboBoxErrCorrLevel: TComboBox
    Left = 337
    Top = 200
    Width = 310
    Height = 21
    Style = csDropDownList
    ItemIndex = 0
    TabOrder = 4
    Text = 'L  - [Default] Allows recovery of up to 7% data loss'
    OnChange = BtnGenerateClick
    Items.Strings = (
      'L  - [Default] Allows recovery of up to 7% data loss'
      'M - Allows recovery of up to 15% data loss'
      'Q - Allows recovery of up to 25% data loss'
      'H - Allows recovery of up to 30% data loss')
  end
end

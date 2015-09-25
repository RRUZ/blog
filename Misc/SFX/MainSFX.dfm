object FrmMain: TFrmMain
  Left = 526
  Top = 364
  BorderStyle = bsSingle
  Caption = 'Delphi SFX Extractor'
  ClientHeight = 77
  ClientWidth = 542
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
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 81
    Height = 13
    Caption = 'Output Directory'
  end
  object ButtonSelDir: TButton
    Left = 428
    Top = 20
    Width = 24
    Height = 25
    Caption = '...'
    TabOrder = 0
    OnClick = ButtonSelDirClick
  end
  object EditPath: TEdit
    Left = 8
    Top = 24
    Width = 414
    Height = 21
    Enabled = False
    TabOrder = 1
  end
  object ButtonExtract: TButton
    Left = 458
    Top = 20
    Width = 75
    Height = 25
    Caption = 'Extract'
    TabOrder = 2
    OnClick = ButtonExtractClick
  end
  object ProgressBarSfx: TProgressBar
    Left = 8
    Top = 51
    Width = 414
    Height = 17
    TabOrder = 3
  end
end

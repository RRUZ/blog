object FrmMain: TFrmMain
  Left = 665
  Top = 258
  Caption = 'Delphi Aero Colorizer'
  ClientHeight = 314
  ClientWidth = 467
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  DesignSize = (
    467
    314)
  PixelsPerInch = 96
  TextHeight = 13
  object ImageIcon: TImage
    Left = 8
    Top = 8
    Width = 58
    Height = 57
  end
  object LabelClassName: TLabel
    Left = 80
    Top = 24
    Width = 52
    Height = 13
    Caption = 'ClassName'
  end
  object LabelHandle: TLabel
    Left = 80
    Top = 5
    Width = 74
    Height = 13
    Caption = 'Window Handle'
  end
  object MemoLog: TMemo
    Left = 8
    Top = 103
    Width = 451
    Height = 191
    Anchors = [akLeft, akTop, akRight, akBottom]
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Consolas'
    Font.Style = []
    ParentFont = False
    ScrollBars = ssBoth
    TabOrder = 0
  end
  object PanelColor: TPanel
    Left = 8
    Top = 71
    Width = 58
    Height = 26
    BevelOuter = bvNone
    Caption = 'PanelColor'
    Color = clWhite
    ParentBackground = False
    ShowCaption = False
    TabOrder = 1
  end
  object CheckBoxOnTop: TCheckBox
    Left = 80
    Top = 43
    Width = 97
    Height = 17
    Caption = 'Stay on top'
    Checked = True
    State = cbChecked
    TabOrder = 2
    OnClick = CheckBoxOnTopClick
  end
  object Timer1: TTimer
    Interval = 100
    OnTimer = Timer1Timer
    Left = 264
    Top = 16
  end
end

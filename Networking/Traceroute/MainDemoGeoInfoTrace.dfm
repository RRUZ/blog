object FrmMainTrace: TFrmMainTrace
  Left = 470
  Top = 293
  Caption = 'Demo Traceroute with GeoInfo'
  ClientHeight = 416
  ClientWidth = 676
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object MemoTrace: TMemo
    Left = 0
    Top = 65
    Width = 676
    Height = 351
    Align = alClient
    Color = clBlack
    Font.Charset = ANSI_CHARSET
    Font.Color = clSilver
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
    ScrollBars = ssBoth
    TabOrder = 0
    ExplicitLeft = 8
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 676
    Height = 65
    Align = alTop
    TabOrder = 1
    object LabelTrace: TLabel
      Left = 16
      Top = 8
      Width = 80
      Height = 13
      Caption = 'Address to trace'
    end
    object BrnTrace: TButton
      Left = 415
      Top = 21
      Width = 75
      Height = 25
      Caption = 'Trace'
      TabOrder = 0
      OnClick = BrnTraceClick
    end
    object EditAddress: TEdit
      Left = 16
      Top = 27
      Width = 393
      Height = 21
      TabOrder = 1
      Text = 'theroadtodelphi.wordpress.com'
    end
  end
end

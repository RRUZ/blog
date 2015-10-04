object FrmMain: TFrmMain
  Left = 0
  Top = 0
  Caption = 'Preview Handler Host Demo'
  ClientHeight = 502
  ClientWidth = 455
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 49
    Width = 455
    Height = 453
    Align = alClient
    TabOrder = 0
    ExplicitTop = 40
    ExplicitWidth = 916
    ExplicitHeight = 638
  end
  object Panel3: TPanel
    Left = 0
    Top = 0
    Width = 455
    Height = 49
    Align = alTop
    TabOrder = 1
    ExplicitWidth = 916
    DesignSize = (
      455
      49)
    object EditFileName: TEdit
      Left = 16
      Top = 16
      Width = 345
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      Enabled = False
      TabOrder = 0
      ExplicitWidth = 810
    end
    object Button1: TButton
      Left = 367
      Top = 18
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Select File'
      TabOrder = 1
      OnClick = Button1Click
    end
  end
  object OpenDialog1: TOpenDialog
    Left = 272
    Top = 72
  end
end

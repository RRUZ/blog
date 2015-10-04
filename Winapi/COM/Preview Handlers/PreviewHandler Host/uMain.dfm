object FrmMain: TFrmMain
  Left = 0
  Top = 0
  Caption = 'Preview Handler Host Demo'
  ClientHeight = 338
  ClientWidth = 529
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
    Left = 217
    Top = 0
    Width = 312
    Height = 338
    Align = alClient
    TabOrder = 0
    ExplicitLeft = 200
    ExplicitWidth = 430
  end
  object Panel3: TPanel
    Left = 0
    Top = 0
    Width = 217
    Height = 338
    Align = alLeft
    TabOrder = 1
    object ShellListView1: TShellListView
      Left = 1
      Top = 1
      Width = 215
      Height = 336
      ObjectTypes = [otFolders, otNonFolders]
      Root = 'rfDesktop'
      Sorted = True
      Align = alClient
      ReadOnly = False
      HideSelection = False
      OnChange = ShellListView1Change
      TabOrder = 0
      ViewStyle = vsReport
      ExplicitWidth = 216
    end
  end
end

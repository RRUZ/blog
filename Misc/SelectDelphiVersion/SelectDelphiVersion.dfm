object FrmSelDelphiVer: TFrmSelDelphiVer
  Left = 487
  Top = 403
  BorderStyle = bsToolWindow
  Caption = 'Select compiler'
  ClientHeight = 157
  ClientWidth = 443
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
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 114
    Height = 13
    Caption = 'Delphi versions installed'
  end
  object ButtonOk: TButton
    Left = 279
    Top = 127
    Width = 75
    Height = 25
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 0
  end
  object ButtonCancel: TButton
    Left = 360
    Top = 127
    Width = 75
    Height = 25
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 1
  end
  object ListViewIDEs: TListView
    Left = 8
    Top = 27
    Width = 427
    Height = 94
    Columns = <
      item
        Caption = 'Version'
        Width = -1
        WidthType = (
          -1)
      end
      item
        Caption = 'Path'
        Width = -1
        WidthType = (
          -1)
      end>
    ReadOnly = True
    RowSelect = True
    SmallImages = ImageList1
    TabOrder = 2
    ViewStyle = vsReport
  end
  object ImageList1: TImageList
    Left = 88
    Top = 64
  end
end

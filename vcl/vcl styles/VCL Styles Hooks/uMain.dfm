object FrmMain: TFrmMain
  Left = 0
  Top = 0
  BorderStyle = bsSingle
  Caption = 'Demo VCL Styles'
  ClientHeight = 380
  ClientWidth = 744
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
  object ListViewStyleHooks: TListView
    Left = 8
    Top = 8
    Width = 321
    Height = 345
    Columns = <
      item
        Caption = 'Component'
        Width = 150
      end
      item
        Caption = 'Style Hook'
        Width = 150
      end>
    RowSelect = True
    TabOrder = 0
    ViewStyle = vsReport
  end
  object Panel1: TPanel
    Left = 335
    Top = 8
    Width = 394
    Height = 345
    BorderWidth = 5
    Caption = 'Panel1'
    TabOrder = 1
    object PageControl1: TPageControl
      Left = 6
      Top = 6
      Width = 382
      Height = 333
      ActivePage = TabSheet1
      Align = alClient
      TabOrder = 0
      object TabSheet1: TTabSheet
        Caption = 'TabSheet1'
        object Label1: TLabel
          Left = 8
          Top = 96
          Width = 31
          Height = 13
          Caption = 'Label1'
        end
        object Memo1: TMemo
          Left = 0
          Top = 3
          Width = 371
          Height = 89
          Lines.Strings = (
            'Memo1')
          TabOrder = 0
        end
        object Edit1: TEdit
          Left = 3
          Top = 112
          Width = 121
          Height = 21
          TabOrder = 1
          Text = 'Edit1'
        end
        object CheckBox1: TCheckBox
          Left = 130
          Top = 114
          Width = 97
          Height = 17
          Caption = 'CheckBox1'
          TabOrder = 2
        end
        object RadioButton1: TRadioButton
          Left = 240
          Top = 114
          Width = 113
          Height = 17
          Caption = 'RadioButton1'
          TabOrder = 3
        end
      end
      object TabSheet2: TTabSheet
        Caption = 'TabSheet2'
        ImageIndex = 1
      end
    end
  end
end

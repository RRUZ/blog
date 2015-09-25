object FrmMain: TFrmMain
  Left = 425
  Top = 253
  Caption = 'Active remote TCP connections'
  ClientHeight = 497
  ClientWidth = 850
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object PanelMain: TPanel
    Left = 0
    Top = 0
    Width = 850
    Height = 497
    Align = alClient
    BevelOuter = bvNone
    BorderWidth = 5
    TabOrder = 0
    object SplitterMain: TSplitter
      Left = 5
      Top = 241
      Width = 840
      Height = 7
      Cursor = crVSplit
      Align = alBottom
      ExplicitLeft = 1005
      ExplicitTop = 5
      ExplicitWidth = 291
    end
    object ListViewIPaddress: TListView
      Left = 5
      Top = 5
      Width = 840
      Height = 236
      Align = alClient
      Columns = <
        item
          Caption = 'PID'
          Width = 60
        end
        item
          Caption = 'Application'
          Width = -1
          WidthType = (
            -1)
        end
        item
          Caption = 'Protocol'
          Width = -1
          WidthType = (
            -1)
        end
        item
          Caption = 'Local Server Name'
          Width = -1
          WidthType = (
            -1)
        end
        item
          Caption = 'Local IP'
          Width = -1
          WidthType = (
            -1)
        end
        item
          Caption = 'Local Port'
          Width = -1
          WidthType = (
            -1)
        end
        item
          Caption = 'Remote Server Name'
          Width = -1
          WidthType = (
            -1)
        end
        item
          Caption = 'Remote IP'
          Width = -1
          WidthType = (
            -1)
        end
        item
          Caption = 'Remote Port'
          Width = -1
          WidthType = (
            -1)
        end
        item
          Caption = 'Status'
          Width = -1
          WidthType = (
            -1)
        end
        item
          Caption = 'Country'
          Width = -1
          WidthType = (
            -1)
        end
        item
          Caption = 'City'
          Width = -1
          WidthType = (
            -1)
        end
        item
          Caption = 'Longitude'
          Width = -1
          WidthType = (
            -1)
        end
        item
          Caption = 'Latitude'
          Width = -1
          WidthType = (
            -1)
        end>
      ReadOnly = True
      RowSelect = True
      SmallImages = ImageList1
      TabOrder = 0
      ViewStyle = vsReport
      OnClick = ListViewIPaddressClick
    end
    object PanelMap: TPanel
      Left = 5
      Top = 248
      Width = 840
      Height = 244
      Align = alBottom
      BevelOuter = bvNone
      BorderWidth = 5
      TabOrder = 1
      object WebBrowser1: TWebBrowser
        Left = 5
        Top = 33
        Width = 830
        Height = 206
        Align = alClient
        TabOrder = 0
        ExplicitLeft = 120
        ExplicitTop = 40
        ExplicitWidth = 300
        ExplicitHeight = 150
        ControlData = {
          4C000000C85500004A1500000000000000000000000000000000000000000000
          000000004C000000000000000000000001000000E0D057007335CF11AE690800
          2B2E126208000000000000004C0000000114020000000000C000000000000046
          8000000000000000000000000000000000000000000000000000000000000000
          00000000000000000100000000000000000000000000000000000000}
      end
      object Panel1: TPanel
        Left = 5
        Top = 5
        Width = 830
        Height = 28
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 1
        object Label1: TLabel
          Left = 0
          Top = 1
          Width = 20
          Height = 13
          Caption = 'Map'
        end
        object LabelType: TLabel
          Left = 188
          Top = 1
          Width = 24
          Height = 13
          Caption = 'Type'
        end
        object ComboBoxMaps: TComboBox
          Left = 37
          Top = 1
          Width = 145
          Height = 21
          Style = csDropDownList
          TabOrder = 0
          OnChange = ComboBoxMapsChange
        end
        object ComboBoxTypes: TComboBox
          Left = 218
          Top = 1
          Width = 143
          Height = 21
          Style = csDropDownList
          TabOrder = 1
          OnChange = ComboBoxTypesChange
        end
        object ButtonReload: TButton
          Left = 376
          Top = 1
          Width = 145
          Height = 21
          Caption = 'Reload Tcp connections'
          TabOrder = 2
          OnClick = ButtonReloadClick
        end
        object CheckBoxRemote: TCheckBox
          Left = 527
          Top = 0
          Width = 146
          Height = 22
          Caption = 'Only remote connections'
          Checked = True
          State = cbChecked
          TabOrder = 3
          OnClick = ButtonReloadClick
        end
      end
    end
  end
  object ImageList1: TImageList
    Height = 11
    Left = 264
    Top = 80
  end
end

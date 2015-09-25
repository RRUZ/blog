object FrmMain: TFrmMain
  Left = 635
  Top = 216
  Caption = 'Google Maps V3 Click Event - Delphi'
  ClientHeight = 550
  ClientWidth = 571
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
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 571
    Height = 550
    Align = alClient
    BevelOuter = bvNone
    BorderWidth = 5
    TabOrder = 0
    object PanelHeader: TPanel
      Left = 5
      Top = 352
      Width = 561
      Height = 193
      Align = alBottom
      TabOrder = 0
      object LabelLatitude: TLabel
        Left = 414
        Top = 15
        Width = 39
        Height = 13
        Caption = 'Latitude'
      end
      object LabelLongitude: TLabel
        Left = 287
        Top = 11
        Width = 47
        Height = 13
        Caption = 'Longitude'
      end
      object ButtonGotoLocation: TButton
        Left = 287
        Top = 57
        Width = 99
        Height = 25
        Caption = 'Go to Location '
        TabOrder = 0
        OnClick = ButtonGotoLocationClick
      end
      object Longitude: TEdit
        Left = 287
        Top = 30
        Width = 121
        Height = 21
        Enabled = False
        TabOrder = 1
        Text = '-80.135694'
      end
      object Latitude: TEdit
        Left = 414
        Top = 30
        Width = 121
        Height = 21
        Enabled = False
        TabOrder = 2
        Text = '25.767314'
      end
      object ButtonClearMarkers: TButton
        Left = 287
        Top = 88
        Width = 101
        Height = 25
        Caption = 'Clear Markers'
        TabOrder = 3
        OnClick = ButtonClearMarkersClick
      end
      object ListView1: TListView
        Left = 8
        Top = 6
        Width = 273
        Height = 179
        Columns = <
          item
            Caption = 'Longitude'
            Width = 120
          end
          item
            Caption = 'Latitude'
            Width = 120
          end>
        ReadOnly = True
        RowSelect = True
        TabOrder = 4
        ViewStyle = vsReport
      end
    end
    object WebBrowser1: TWebBrowser
      Left = 5
      Top = 5
      Width = 561
      Height = 347
      Align = alClient
      TabOrder = 1
      OnCommandStateChange = WebBrowser1CommandStateChange
      ExplicitLeft = 93
      ExplicitTop = 204
      ExplicitWidth = 838
      ExplicitHeight = 307
      ControlData = {
        4C000000FB390000DD2300000000000000000000000000000000000000000000
        000000004C000000000000000000000001000000E0D057007335CF11AE690800
        2B2E126208000000000000004C0000000114020000000000C000000000000046
        8000000000000000000000000000000000000000000000000000000000000000
        00000000000000000100000000000000000000000000000000000000}
    end
  end
  object XPManifest1: TXPManifest
    Left = 544
    Top = 216
  end
end

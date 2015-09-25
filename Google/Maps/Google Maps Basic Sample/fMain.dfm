object frmMain: TfrmMain
  Left = 427
  Top = 268
  Caption = 'GoogleMaps in Delphi'
  ClientHeight = 510
  ClientWidth = 848
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
  object WebBrowser1: TWebBrowser
    Left = 0
    Top = 137
    Width = 848
    Height = 373
    Align = alClient
    TabOrder = 0
    ExplicitLeft = 8
    ExplicitTop = 186
    ExplicitWidth = 610
    ExplicitHeight = 388
    ControlData = {
      4C000000A55700008D2600000000000000000000000000000000000000000000
      000000004C000000000000000000000001000000E0D057007335CF11AE690800
      2B2E126208000000000000004C0000000114020000000000C000000000000046
      8000000000000000000000000000000000000000000000000000000000000000
      00000000000000000100000000000000000000000000000000000000}
  end
  object PanelHeader: TPanel
    Left = 0
    Top = 0
    Width = 848
    Height = 137
    Align = alTop
    TabOrder = 1
    ExplicitWidth = 1021
    object LabelAddress: TLabel
      Left = 8
      Top = 8
      Width = 39
      Height = 13
      Caption = 'Address'
    end
    object LabelLatitude: TLabel
      Left = 8
      Top = 95
      Width = 39
      Height = 13
      Caption = 'Latitude'
    end
    object LabelLongitude: TLabel
      Left = 135
      Top = 91
      Width = 47
      Height = 13
      Caption = 'Longitude'
    end
    object ButtonGotoLocation: TButton
      Left = 262
      Top = 106
      Width = 99
      Height = 25
      Caption = 'Go to Location '
      TabOrder = 0
      OnClick = ButtonGotoLocationClick
    end
    object MemoAddress: TMemo
      Left = 6
      Top = 27
      Width = 729
      Height = 62
      Lines.Strings = (
        
          '7004 Market Place Drive, Goleta, CA 93117-5900 (Camino Real Mark' +
          'etplace)')
      ScrollBars = ssBoth
      TabOrder = 1
    end
    object ButtonGotoAddress: TButton
      Left = 741
      Top = 27
      Width = 99
      Height = 40
      Caption = 'Go to Address'
      TabOrder = 2
      OnClick = ButtonGotoAddressClick
    end
    object Longitude: TEdit
      Left = 135
      Top = 110
      Width = 121
      Height = 21
      TabOrder = 3
      Text = '-80.135694'
    end
    object Latitude: TEdit
      Left = 8
      Top = 110
      Width = 121
      Height = 21
      TabOrder = 4
      Text = '25.767314'
    end
    object CheckBoxTraffic: TCheckBox
      Left = 383
      Top = 110
      Width = 58
      Height = 17
      Caption = 'Traffic'
      TabOrder = 5
      OnClick = CheckBoxTrafficClick
    end
    object CheckBoxBicycling: TCheckBox
      Left = 447
      Top = 110
      Width = 58
      Height = 17
      Caption = 'Bicycling'
      TabOrder = 6
      OnClick = CheckBoxBicyclingClick
    end
    object CheckBoxStreeView: TCheckBox
      Left = 520
      Top = 110
      Width = 97
      Height = 17
      Caption = 'Street View'
      TabOrder = 7
      OnClick = CheckBoxStreeViewClick
    end
    object ButtonClearMarkers: TButton
      Left = 634
      Top = 106
      Width = 101
      Height = 25
      Caption = 'Clear Markers'
      TabOrder = 8
      OnClick = ButtonClearMarkersClick
    end
  end
  object XPManifest1: TXPManifest
    Left = 544
    Top = 216
  end
end

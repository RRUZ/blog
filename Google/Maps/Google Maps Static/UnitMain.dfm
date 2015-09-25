object FormMain: TFormMain
  Left = 444
  Top = 387
  Caption = 'GoogleMaps Static from delphi'
  ClientHeight = 375
  ClientWidth = 733
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
    Width = 733
    Height = 61
    Align = alTop
    TabOrder = 0
    object EditURL: TEdit
      Left = 8
      Top = 11
      Width = 554
      Height = 21
      Color = clBtnFace
      Enabled = False
      TabOrder = 0
    end
    object ButtonGet: TButton
      Left = 576
      Top = 9
      Width = 75
      Height = 25
      Caption = 'Get'
      TabOrder = 1
      OnClick = ButtonGetClick
    end
    object CheckBoxRealTime: TCheckBox
      Left = 657
      Top = 13
      Width = 75
      Height = 17
      Caption = 'Real Time'
      TabOrder = 2
    end
    object ProgressBar1: TProgressBar
      Left = 8
      Top = 38
      Width = 554
      Height = 17
      TabOrder = 3
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 61
    Width = 475
    Height = 314
    Align = alClient
    TabOrder = 1
    ExplicitTop = 53
    ExplicitHeight = 322
    object ScrollBoxMap: TScrollBox
      Left = 1
      Top = 1
      Width = 473
      Height = 312
      HorzScrollBar.Visible = False
      VertScrollBar.Visible = False
      Align = alClient
      TabOrder = 0
      ExplicitHeight = 320
      object ImageMap: TImage
        Left = 0
        Top = 0
        Width = 100
        Height = 100
        AutoSize = True
        OnMouseDown = ImageMapMouseDown
        OnMouseMove = ImageMapMouseMove
      end
    end
  end
  object Panel3: TPanel
    Left = 475
    Top = 61
    Width = 258
    Height = 314
    Align = alRight
    TabOrder = 2
    ExplicitLeft = 480
    ExplicitTop = 53
    ExplicitHeight = 322
    object Label7: TLabel
      Left = 12
      Top = 176
      Width = 47
      Height = 13
      Caption = 'Type Map'
    end
    object Label6: TLabel
      Left = 12
      Top = 149
      Width = 26
      Height = 13
      Caption = 'Zoom'
    end
    object Label5: TLabel
      Left = 12
      Top = 127
      Width = 34
      Height = 13
      Caption = 'Format'
    end
    object Label4: TLabel
      Left = 12
      Top = 95
      Width = 31
      Height = 13
      Caption = 'Height'
    end
    object Label3: TLabel
      Left = 12
      Top = 68
      Width = 28
      Height = 13
      Caption = 'Width'
    end
    object Label2: TLabel
      Left = 12
      Top = 41
      Width = 47
      Height = 13
      Caption = 'Longitude'
    end
    object Label1: TLabel
      Left = 12
      Top = 17
      Width = 39
      Height = 13
      Caption = 'Latitude'
    end
    object EditWidth: TEdit
      Left = 122
      Top = 65
      Width = 103
      Height = 21
      TabOrder = 0
      Text = '640'
    end
    object UpDown3: TUpDown
      Left = 225
      Top = 92
      Width = 16
      Height = 21
      Associate = EditHeight
      Min = 100
      Max = 1024
      Position = 480
      TabOrder = 1
    end
    object UpDown2: TUpDown
      Left = 225
      Top = 65
      Width = 16
      Height = 21
      Associate = EditWidth
      Min = 100
      Max = 1024
      Position = 640
      TabOrder = 2
    end
    object UpDown1: TUpDown
      Left = 221
      Top = 146
      Width = 16
      Height = 21
      Associate = EditZoom
      Max = 21
      Position = 10
      TabOrder = 3
    end
    object ComboBoxMapType: TComboBox
      Left = 122
      Top = 173
      Width = 121
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      ItemIndex = 0
      TabOrder = 4
      Text = 'roadmap'
      OnChange = ComboBoxMapTypeChange
      Items.Strings = (
        'roadmap'
        'satellite'
        'terrain'
        'hybrid')
    end
    object EditZoom: TEdit
      Left = 122
      Top = 146
      Width = 99
      Height = 21
      TabOrder = 5
      Text = '10'
      OnChange = EditZoomChange
    end
    object ComboBoxFormat: TComboBox
      Left = 122
      Top = 119
      Width = 121
      Height = 21
      Style = csDropDownList
      Enabled = False
      ItemHeight = 13
      ItemIndex = 0
      TabOrder = 6
      Text = 'jpg'
      Items.Strings = (
        'jpg'
        'gif'
        'png')
    end
    object EditHeight: TEdit
      Left = 122
      Top = 92
      Width = 103
      Height = 21
      TabOrder = 7
      Text = '480'
    end
    object EditLongitude: TEdit
      Left = 122
      Top = 38
      Width = 121
      Height = 21
      TabOrder = 8
      Text = '-73.998672'
    end
    object EditLatitude: TEdit
      Left = 122
      Top = 14
      Width = 121
      Height = 21
      TabOrder = 9
      Text = '40.714728'
    end
    object CheckBoxMarker: TCheckBox
      Left = 12
      Top = 208
      Width = 97
      Height = 17
      Caption = 'Marker'
      TabOrder = 10
    end
  end
  object XPManifest1: TXPManifest
    Left = 648
    Top = 256
  end
  object IdHTTP1: TIdHTTP
    AllowCookies = True
    ProxyParams.BasicAuthentication = False
    ProxyParams.ProxyPort = 0
    Request.ContentLength = -1
    Request.Accept = 'text/html, */*'
    Request.BasicAuthentication = False
    Request.UserAgent = 'Mozilla/3.0'
    HTTPOptions = [hoForceEncodeParams]
    Left = 571
    Top = 261
  end
end

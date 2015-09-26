object FrmMain: TFrmMain
  Left = 725
  Top = 149
  Caption = 'WebBrowser User-Agent Switch demo'
  ClientHeight = 588
  ClientWidth = 415
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  DesignSize = (
    415
    588)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 5
    Width = 39
    Height = 13
    Caption = 'Address'
  end
  object Label2: TLabel
    Left = 8
    Top = 51
    Width = 58
    Height = 13
    Caption = 'User- Agent'
  end
  object WebBrowser1: TWebBrowser
    Left = 8
    Top = 97
    Width = 400
    Height = 480
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 0
    OnDocumentComplete = WebBrowser1DocumentComplete
    ExplicitWidth = 360
    ControlData = {
      4C000000572900009C3100000000000000000000000000000000000000000000
      000000004C000000000000000000000001000000E0D057007335CF11AE690800
      2B2E12620A000000000000004C0000000114020000000000C000000000000046
      8000000000000000000000000000000000000000000000000000000000000000
      00000000000000000100000000000000000000000000000000000000}
  end
  object BtnGo: TButton
    Left = 375
    Top = 22
    Width = 32
    Height = 25
    Caption = 'Go'
    TabOrder = 1
    OnClick = BtnGoClick
  end
  object EditURL: TEdit
    Left = 8
    Top = 24
    Width = 361
    Height = 21
    TabOrder = 2
  end
  object CbUserAgent: TComboBox
    Left = 8
    Top = 70
    Width = 399
    Height = 21
    Style = csDropDownList
    Anchors = [akLeft, akTop, akRight]
    ItemHeight = 13
    ItemIndex = 0
    TabOrder = 3
    Text = 
      'Mozilla/5.0 (BlackBerry; U; BlackBerry 9800; en) AppleWebKit/534' +
      '.1+ (KHTML, Like Gecko) Version/6.0.0.141 Mobile Safari/534.1+'
    OnChange = CbUserAgentChange
    Items.Strings = (
      
        'Mozilla/5.0 (BlackBerry; U; BlackBerry 9800; en) AppleWebKit/534' +
        '.1+ (KHTML, Like Gecko) Version/6.0.0.141 Mobile Safari/534.1+'
      
        'Mozilla/5.0 (iPhone; U; CPU like Mac OS X; en) AppleWebKit/420+ ' +
        '(KHTML, like Gecko) Version/3.0 Mobile/1A543a Safari/419.3'
      
        'Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.8.0.1) Geck' +
        'o/20060111 Firefox/1.5.0.1'
      
        'Mozilla/5.0 (Linux; U; Android 1.1; en-gb; dream) AppleWebKit/52' +
        '5.10+ (KHTML, like Gecko) Version/3.0.4 Mobile Safari/523.12.2 '#8211 +
        ' G1 Phone'
      
        'HTC_Touch_3G Mozilla/4.0 (compatible; MSIE 6.0; Windows CE; IEMo' +
        'bile 7.11)'
      
        'Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.2.13) Gecko/20101' +
        '208 Lightning/1.0b2 Thunderbird/3.1.7'
      'Opera/9.80 (Windows NT 6.0; U; en) Presto/2.8.99 Version/11.10'
      
        'Mozilla/5.0 (compatible; MSIE 8.0; Windows NT 5.2; Trident/4.0; ' +
        'Media Center PC 4.0; SLCC1; .NET CLR 3.0.04320)'
      'Mozilla/5.0 (Windows; U; MSIE 9.0; WIndows NT 9.0; en-US))')
    ExplicitWidth = 359
  end
end

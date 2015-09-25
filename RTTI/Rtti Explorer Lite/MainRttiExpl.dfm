object FrmRTTIExplLite: TFrmRTTIExplLite
  Left = 350
  Top = 170
  ActiveControl = BtnFill
  Caption = 'RTTI Explorer Lite'
  ClientHeight = 480
  ClientWidth = 695
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
  PixelsPerInch = 96
  TextHeight = 13
  object PanelMain: TPanel
    Left = 0
    Top = 0
    Width = 695
    Height = 439
    Align = alClient
    BorderWidth = 5
    TabOrder = 0
    ExplicitLeft = 32
    ExplicitTop = 23
    ExplicitWidth = 369
    ExplicitHeight = 306
    object PageControlRtti: TPageControl
      Left = 6
      Top = 6
      Width = 683
      Height = 427
      ActivePage = TabSheetUnits
      Align = alClient
      TabOrder = 0
      object TabSheetUnits: TTabSheet
        Caption = 'Unit Based Tree'
        ExplicitLeft = 0
        ExplicitTop = 0
        ExplicitWidth = 281
        ExplicitHeight = 165
        object TreeViewRtti: TTreeView
          Left = 0
          Top = 0
          Width = 373
          Height = 399
          Align = alClient
          DoubleBuffered = True
          Indent = 19
          ParentDoubleBuffered = False
          ReadOnly = True
          TabOrder = 0
          OnChange = TreeViewRttiChange
          OnCustomDrawItem = TreeViewRttiCustomDrawItem
          OnDblClick = TreeViewRttiDblClick
          ExplicitLeft = -6
          ExplicitTop = 4
        end
        object ListViewRtti: TListView
          Left = 373
          Top = 0
          Width = 302
          Height = 399
          Align = alRight
          Columns = <
            item
              Caption = 'Key'
              Width = 150
            end
            item
              Caption = 'Value'
              Width = 150
            end>
          ReadOnly = True
          RowSelect = True
          TabOrder = 1
          ViewStyle = vsReport
          ExplicitLeft = 398
          ExplicitHeight = 372
        end
      end
      object TabSheetClasses: TTabSheet
        Caption = 'Classes Tree'
        ImageIndex = 1
        ExplicitLeft = 0
        ExplicitTop = 28
        ExplicitWidth = 0
        ExplicitHeight = 0
        object TreeViewClasses: TTreeView
          Left = 0
          Top = 0
          Width = 675
          Height = 399
          Align = alClient
          Indent = 19
          ReadOnly = True
          TabOrder = 0
          ExplicitLeft = 126
          ExplicitTop = 64
          ExplicitWidth = 121
          ExplicitHeight = 97
        end
      end
      object TabSheetSummary: TTabSheet
        Caption = 'Summary'
        ImageIndex = 3
        ExplicitWidth = 700
        ExplicitHeight = 372
        object Label1: TLabel
          Left = 16
          Top = 16
          Width = 82
          Height = 13
          Caption = 'Number of Types'
        end
        object LabelNtypes: TLabel
          Left = 144
          Top = 16
          Width = 59
          Height = 13
          Caption = 'LabelNtypes'
        end
        object Label2: TLabel
          Left = 16
          Top = 35
          Width = 89
          Height = 13
          Caption = 'Number of Classes'
        end
        object LabelNClasses: TLabel
          Left = 144
          Top = 35
          Width = 68
          Height = 13
          Caption = 'LabelNClasses'
        end
      end
    end
  end
  object PanelBottom: TPanel
    Left = 0
    Top = 439
    Width = 695
    Height = 41
    Align = alBottom
    BorderWidth = 5
    TabOrder = 1
    ExplicitTop = 412
    ExplicitWidth = 720
    DesignSize = (
      695
      41)
    object BtnFill: TButton
      Left = 10
      Top = 6
      Width = 75
      Height = 25
      Caption = 'Fill'
      TabOrder = 0
      OnClick = BtnFillClick
    end
    object BtnExpand: TButton
      Left = 91
      Top = 6
      Width = 75
      Height = 25
      Caption = 'Expand'
      TabOrder = 1
      OnClick = BtnExpandClick
    end
    object BtnCollapse: TButton
      Left = 172
      Top = 6
      Width = 75
      Height = 25
      Caption = 'Collapse'
      TabOrder = 2
      OnClick = BtnCollapseClick
    end
    object EditSearch: TEdit
      Left = 391
      Top = 6
      Width = 217
      Height = 21
      Anchors = [akTop, akRight]
      TabOrder = 3
      ExplicitLeft = 437
    end
    object BtnSearch: TButton
      Left = 614
      Top = 6
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Search'
      TabOrder = 4
      OnClick = BtnSearchClick
      ExplicitLeft = 660
    end
  end
end

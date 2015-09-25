unit uMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.Layouts, FMX.Memo,
  FMX.ExtCtrls, FMX.Objects, FMX.Edit, FMX.Menus, FMX.TabControl, FMX.ListBox;

type
  TFrmMain = class(TForm)
    StyleBook1: TStyleBook;
    BtnLoad: TButton;
    OpenDialog1: TOpenDialog;
    BtnEQ: TButton;
    Layout1: TLayout;
    TabControl1: TTabControl;
    TabItem1: TTabItem;
    TabItem2: TTabItem;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    RadioButton3: TRadioButton;
    GroupBox1: TGroupBox;
    CheckBox4: TCheckBox;
    RadioButton4: TRadioButton;
    RadioButton5: TRadioButton;
    PopupBox1: TPopupBox;
    Label1: TLabel;
    ProgressBar1: TProgressBar;
    Expander1: TExpander;
    Button2: TButton;
    Button3: TButton;
    TrackBar1: TTrackBar;
    MenuBar1: TMenuBar;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    ListBox1: TListBox;
    ListBoxItem1: TListBoxItem;
    ListBoxItem2: TListBoxItem;
    ListBoxItem3: TListBoxItem;
    ListBoxItem4: TListBoxItem;
    ListBoxItem5: TListBoxItem;
    Edit1: TEdit;
    Edit3: TEdit;
    ArcDial1: TArcDial;
    AniIndicator1: TAniIndicator;
    DropTarget1: TDropTarget;
    NumberBox1: TNumberBox;
    SpinBox1: TSpinBox;
    PlotGrid1: TPlotGrid;
    ClearingEdit1: TClearingEdit;
    Memo1: TMemo;
    procedure BtnLoadClick(Sender: TObject);
    procedure BtnEQClick(Sender: TObject);
  private
  public
  end;

var
  FrmMain: TFrmMain;

implementation

{$R *.fmx}

Uses
  uFrmStyleEqualizer;

procedure TFrmMain.BtnLoadClick(Sender: TObject);
begin
 if OpenDialog1.Execute then
  StyleBook.FileName:=OpenDialog1.FileName;
end;

procedure TFrmMain.BtnEQClick(Sender: TObject);
var
 Frm : TFrmStyleEqualizer;
begin
 Frm:=TFrmStyleEqualizer.Create(Self);
 Frm.StyleBook:=StyleBook1;
 Frm.Show;
end;

procedure EmbeddForm(AParent:TControl; AForm:TCustomForm);
var
 a: TText;
begin
  while AForm.ChildrenCount>0 do
    AForm.Children[0].Parent:=AParent;
end;

end.

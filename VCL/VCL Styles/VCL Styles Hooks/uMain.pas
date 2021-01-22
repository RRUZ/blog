unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls;

type
  TFrmMain = class(TForm)
    ListViewStyleHooks: TListView;
    PageControl1: TPageControl;
    Panel1: TPanel;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    Memo1: TMemo;
    Edit1: TEdit;
    Label1: TLabel;
    CheckBox1: TCheckBox;
    RadioButton1: TRadioButton;
    procedure FormCreate(Sender: TObject);
  private
    procedure ListStyleHooks;
  public
    { Public declarations }
  end;

var
  FrmMain: TFrmMain;

implementation

uses
  Rtti,
  Vcl.Themes,
  uVCLStyleUtils;

{$R *.dfm}

procedure TFrmMain.FormCreate(Sender: TObject);
begin
  ListStyleHooks;
end;

procedure TFrmMain.ListStyleHooks;
var
 RttiType: TRttiType;
 Item: TListItem;
 List: TStyleHookList;
 StyleClass: TStyleHookClass;
begin
  for RttiType in TRttiContext.Create.GetTypes do
    if RttiType.IsInstance and RttiType.AsInstance.MetaclassType.InheritsFrom(TComponent) then
    begin
       List:=GetRegisteredStylesHooks(RttiType.AsInstance.MetaclassType);
       if Assigned(List) then
       begin
         Item:=ListViewStyleHooks.Items.Add;
         Item.Caption:=RttiType.Name;

         for StyleClass in List do
          Item.SubItems.Add(StyleClass.ClassName);
       end;
    end;
end;

end.

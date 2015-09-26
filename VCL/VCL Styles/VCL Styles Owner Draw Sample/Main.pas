unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ImgList, Vcl.ComCtrls;

type
  TFrmMain = class(TForm)
    ListBox1: TListBox;
    ImageList1: TImageList;
    CheckBox1: TCheckBox;
    ListView1: TListView;
    procedure FormCreate(Sender: TObject);
    procedure ListBox1DrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure CheckBox1Click(Sender: TObject);
    procedure ListView1DrawItem(Sender: TCustomListView; Item: TListItem;
      Rect: TRect; State: TOwnerDrawState);
  private
    { Private declarations }

    Procedure SetOwnerDraw(Value : Boolean);
  public
    { Public declarations }
  end;

var
  FrmMain: TFrmMain;

implementation

uses
 Winapi.CommCtrl,
 Vcl.Styles,
 Vcl.Themes;

{$R *.dfm}

procedure TFrmMain.CheckBox1Click(Sender: TObject);
begin
  SetOwnerDraw(CheckBox1.Checked);
end;

procedure TFrmMain.FormCreate(Sender: TObject);
var
 i    :  integer;
 Item : TListItem;
begin
  SetOwnerDraw(CheckBox1.Checked);
  for i:=0 to 99 do
   ListBox1.Items.Add('Item '+IntToStr(i));

  for i:=0 to 99 do
  begin
    Item:= ListView1.Items.Add;
    Item.Caption:='Item '+IntToStr(i);
    Item.SubItems.Add(Item.Caption+'.1');
    Item.SubItems.Add(Item.Caption+'.2');
    Item.SubItems.Add(Item.Caption+'.3');
    Item.Checked:=Odd(i);
  end;
end;

procedure TFrmMain.ListBox1DrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
Var
 LListBox : TListBox;
 LStyles  : TCustomStyleServices;
 LDetails : TThemedElementDetails;
begin
  LListBox :=TListBox(Control);
  LStyles  :=StyleServices;

  if odSelected in State then
    LListBox.Brush.Color := LStyles.GetSystemColor(clHighlight);

  LDetails := StyleServices.GetElementDetails(tlListItemNormal);

  LListBox.Canvas.FillRect(Rect);
  Rect.Left:=Rect.Left+2;
  LStyles.DrawText(LListBox.Canvas.Handle, LDetails, LListBox.Items[Index], Rect, [tfLeft, tfSingleLine, tfVerticalCenter]);

  if odFocused In State then
  begin
    LListBox.Canvas.Brush.Color := LStyles.GetSystemColor(clHighlight);
    LListBox.Canvas.DrawFocusRect(Rect);
  end;
end;


procedure TFrmMain.ListView1DrawItem(Sender: TCustomListView; Item: TListItem;
  Rect: TRect; State: TOwnerDrawState);
var
  r         : TRect;
  rc        : TRect;
  ColIdx    : Integer;
  s         : string;
  LDetails  : TThemedElementDetails;
  LStyles   : TCustomStyleServices;
  BoxSize   : TSize;
  Spacing   : Integer;
  LColor    : TColor;
begin
  Spacing:=4;
  LStyles:=StyleServices;
  if not LStyles.GetElementColor(LStyles.GetElementDetails(ttItemNormal), ecTextColor, LColor) or  (LColor = clNone) then
  LColor := LStyles.GetSystemColor(clWindowText);

  Sender.Canvas.Brush.Color := LStyles.GetStyleColor(scListView);
  Sender.Canvas.Font.Color  := LColor;
  Sender.Canvas.FillRect(Rect);

  r := Rect;
  inc(r.Left, Spacing);
  for ColIdx := 0 to TListView(Sender).Columns.Count - 1 do
  begin
    r.Right := r.Left + Sender.Column[ColIdx].Width;

    if ColIdx > 0 then
      s := Item.SubItems[ColIdx - 1]
    else
    begin
      BoxSize.cx := GetSystemMetrics(SM_CXMENUCHECK);
      BoxSize.cy := GetSystemMetrics(SM_CYMENUCHECK);
      s := Item.Caption;
      if TListView(Sender).Checkboxes then
       r.Left:=r.Left+BoxSize.cx+3;
    end;

    if ColIdx = 0 then
    begin
      if not IsWindowVisible(ListView_GetEditControl(Sender.Handle)) and ([odSelected, odHotLight] * State <> []) then
      begin
        if ([odSelected, odHotLight] * State <> []) then
        begin
          rc:=Rect;
          if TListView(Sender).Checkboxes then
           rc.Left:=rc.Left+BoxSize.cx+Spacing;

          if not TListView(Sender).RowSelect then
           rc.Right:=Sender.Column[0].Width;

          Sender.Canvas.Brush.Color := LStyles.GetSystemColor(clHighlight);
          Sender.Canvas.FillRect(rc);
        end;
      end;
    end;

    if TListView(Sender).RowSelect then
      Sender.Canvas.Brush.Color := LStyles.GetSystemColor(clHighlight);

    LDetails := StyleServices.GetElementDetails(tlListItemNormal);
    Sender.Canvas.Brush.Style := bsClear;
    LStyles.DrawText(Sender.Canvas.Handle, LDetails, s, r, [tfLeft, tfSingleLine, tfVerticalCenter, tfEndEllipsis]);

    if (ColIdx=0) and TListView(Sender).Checkboxes then
    begin
      rc := Rect;
      rc.Top    := Rect.Top + (Rect.Bottom - Rect.Top - BoxSize.cy) div 2;
      rc.Bottom := rc.Top + BoxSize.cy;
      rc.Left   := rc.Left + Spacing;
      rc.Right  := rc.Left + BoxSize.cx;

      if Item.Checked then
       LDetails := StyleServices.GetElementDetails(tbCheckBoxUncheckedNormal)
      else
       LDetails := StyleServices.GetElementDetails(tbCheckBoxcheckedNormal);

      LStyles.DrawElement(Sender.Canvas.Handle, LDetails, Rc);
    end;

    if ColIdx=0 then
     r.Left:=Sender.Column[ColIdx].Width + Spacing
    else
     inc(r.Left, Sender.Column[ColIdx].Width);
  end;

end;


procedure TFrmMain.SetOwnerDraw(Value: Boolean);
begin
  if Value then
   ListBox1.Style:=lbOwnerDrawFixed
  else
   ListBox1.Style:=lbStandard;

   ListView1.OwnerDraw:=Value;
end;

end.

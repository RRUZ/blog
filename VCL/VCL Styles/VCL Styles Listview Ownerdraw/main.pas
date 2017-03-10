unit main;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.Generics.Collections,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.ComCtrls;

type
  TColumnType = (ctText, ctCheck, ctProgress);

  TFrmMain = class(TForm)
    LvSampleData: TListView;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure LvSampleDataDrawItem(Sender: TCustomListView; Item: TListItem;
      Rect: TRect; State: TOwnerDrawState);
  private
    FColumns  : TDictionary<string, TListColumn>;
    procedure AddColumns();
    procedure AddItems();
  public
    { Public declarations }
  end;

var
  FrmMain: TFrmMain;

implementation

{$R *.dfm}

uses
  Vcl.Themes,
  Vcl.GraphUtil;

procedure TFrmMain.AddColumns;

  Procedure AddColumn(const AColumnName : String; AWidth : Integer; AColumnType : TColumnType);
  begin
   FColumns.Add(AColumnName, LvSampleData.Columns.Add());
   FColumns[AColumnName].Caption := AColumnName;
   FColumns[AColumnName].Width   := AWidth;
   FColumns[AColumnName].Tag     := Integer(AColumnType);
  end;

begin
   FColumns  := TDictionary<string, TListColumn>.Create();
   AddColumn('Text', 150, ctText);
   AddColumn('Porc', 100, ctProgress);
   AddColumn('Text2', 150, ctText);
   AddColumn('Enabled', 100, ctCheck);
end;

procedure TFrmMain.AddItems;
const
 MaxItems = 100;
var
 LItem : TListItem;
 i : Integer;
begin
  Randomize;
  LvSampleData.Items.BeginUpdate;
  try
    for i := 0 to MaxItems - 1 do
    begin
      LItem := LvSampleData.Items.Add;
      LItem.Caption:= Format('Sample text', []);
      LItem.SubItems.Add(IntToStr(Random(101)));
      LItem.SubItems.Add(Format('Sample text 2', []));
      LItem.SubItems.Add(IntToStr(Random(2)));
    end;
  finally
    LvSampleData.Items.EndUpdate;
  end;
end;

procedure TFrmMain.FormCreate(Sender: TObject);
begin
  ReportMemoryLeaksOnShutdown := True;
  LvSampleData.OwnerDraw := True;
  LvSampleData.ViewStyle := TViewStyle.vsReport;
  AddColumns();
  AddItems();
end;

procedure TFrmMain.FormDestroy(Sender: TObject);
begin
  FColumns.Free;
end;

function ResizeRect(const ARect: TRect; const DxLeft, DxRight, DyTop, DyBottom: integer): TRect;
begin
  Result := ARect;
  Inc(Result.Left, DxLeft);
  Dec(Result.Right, DxRight);
  Inc(Result.Top, DyTop);
  Dec(Result.Bottom, DyBottom);
end;

procedure TFrmMain.LvSampleDataDrawItem(Sender: TCustomListView; Item: TListItem; Rect: TRect; State: TOwnerDrawState);
const
  ListView_Padding = 5;
var
  LRect, LRect2: TRect;
  i, p : Integer;
  LText: string;
  LSize: TSize;
  LDetails: TThemedElementDetails;
  LTextFormat : TTextFormatFlags;
  LColor : TColor;
  LStyleService : TCustomStyleServices;
  LColummnType  : TColumnType;
begin
  LStyleService  := StyleServices;
  if not LStyleService.Enabled then exit;

  Sender.Canvas.Brush.Style := bsSolid;
  Sender.Canvas.Brush.Color := LStyleService.GetSystemColor(clWindow);
  Sender.Canvas.FillRect(Rect);

  LRect := Rect;

  for i := 0 to TListView(Sender).Columns.Count - 1 do
  begin
    LColummnType := TColumnType(TListView(Sender).Columns[i].Tag);
    LRect.Right  := LRect.Left + Sender.Column[i].Width;

    LText := '';
    if i = 0 then
      LText := Item.Caption
    else
    if (i - 1) <= Item.SubItems.Count - 1 then
      LText := Item.SubItems[i - 1];

    case LColummnType of
      ctText:  begin

                  LDetails := LStyleService.GetElementDetails(tgCellNormal);
                  LColor := LStyleService.GetSystemColor(clWindowText);
                  if ([odSelected, odHotLight] * State <> []) then
                  begin
                     LDetails := LStyleService.GetElementDetails(tgCellSelected);
                     LColor := LStyleService.GetSystemColor(clHighlightText);
                     LStyleService.DrawElement(Sender.Canvas.Handle, LDetails, LRect);
                  end;

                  LRect2 := LRect;
                  LRect2.Left := LRect2.Left + ListView_Padding;

                  LTextFormat := TTextFormatFlags(DT_SINGLELINE or DT_VCENTER or DT_LEFT or DT_END_ELLIPSIS);
                  LStyleService.DrawText(Sender.Canvas.Handle, LDetails, LText, LRect2, LTextFormat, LColor);
               end;

      ctCheck: begin
                  if ([odSelected, odHotLight] * State <> []) then
                  begin
                     LDetails := LStyleService.GetElementDetails(tgCellSelected);
                     LStyleService.DrawElement(Sender.Canvas.Handle, LDetails, LRect);
                  end;

                  LSize.cx := GetSystemMetrics(SM_CXMENUCHECK);
                  LSize.cy := GetSystemMetrics(SM_CYMENUCHECK);

                  LRect2.Top    := Rect.Top + (Rect.Bottom - Rect.Top - LSize.cy) div 2;
                  LRect2.Bottom := LRect2.Top + LSize.cy;
                  LRect2.Left   := LRect.Left + ((LRect.Width - LSize.cx) div 2);
                  LRect2.Right  := LRect2.Left + LSize.cx;

                  if (LText = '1') then
                  begin
                    if ([odSelected, odHotLight] * State <> []) then
                      LDetails := LStyleService.GetElementDetails(tbCheckBoxCheckedHot)
                    else
                      LDetails := LStyleService.GetElementDetails(tbCheckBoxCheckedNormal);
                  end
                  else
                  begin
                    if ([odSelected, odHotLight] * State <> []) then
                      LDetails := LStyleService.GetElementDetails(tbCheckBoxUncheckedHot)
                    else
                      LDetails := LStyleService.GetElementDetails(tbCheckBoxUncheckedNormal);
                  end;
                  LStyleService.DrawElement(Sender.Canvas.Handle, LDetails, LRect2);
               end;


      ctProgress:
               begin
                  if ([odSelected, odHotLight] * State <> []) then
                  begin
                     LDetails := LStyleService.GetElementDetails(tgCellSelected);
                     LStyleService.DrawElement(Sender.Canvas.Handle, LDetails, LRect);
                  end;

                  LRect2   := ResizeRect(LRect, 2, 2, 2, 2);
                  LDetails := LStyleService.GetElementDetails(tpBar);
                  LStyleService.DrawElement(Sender.Canvas.Handle, LDetails, LRect2);

                  if not TryStrToInt(LText, p) then  p := 0;

                  InflateRect(LRect2, -1, -1);
                  LRect2.Right := LRect2.Left + Round(LRect2.Width * p / 100);

                  if p < 20 then
                  begin
                    Sender.Canvas.Brush.Style := bsSolid;
                    Sender.Canvas.Brush.Color := clWebFirebrick;
                    Sender.Canvas.FillRect(LRect2);
                  end
                  else
                  if p < 50 then
                  begin
                    Sender.Canvas.Brush.Style := bsSolid;
                    Sender.Canvas.Brush.Color := clWebGold;
                    Sender.Canvas.FillRect(LRect2);
                  end
                  else
                  begin
                    LDetails := LStyleService.GetElementDetails(tpChunk);
                    LStyleService.DrawElement(Sender.Canvas.Handle, LDetails, LRect2);
                  end;
                end;
    end;
    Inc(LRect.Left, Sender.Column[i].Width);
  end;
end;

end.

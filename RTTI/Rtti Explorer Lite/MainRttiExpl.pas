unit MainRttiExpl;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, Rtti, TypInfo, ExtCtrls;

type
  TFrmRTTIExplLite = class(TForm)
    TreeViewRtti: TTreeView;
    BtnFill: TButton;
    PanelMain: TPanel;
    PanelBottom: TPanel;
    PageControlRtti: TPageControl;
    TabSheetUnits: TTabSheet;
    TabSheetClasses: TTabSheet;
    BtnExpand: TButton;
    BtnCollapse: TButton;
    TreeViewClasses: TTreeView;
    EditSearch: TEdit;
    BtnSearch: TButton;
    TabSheetSummary: TTabSheet;
    Label1: TLabel;
    LabelNtypes: TLabel;
    ListViewRtti: TListView;
    Label2: TLabel;
    LabelNClasses: TLabel;
    procedure BtnFillClick(Sender: TObject);
    procedure TreeViewRttiCustomDrawItem(Sender: TCustomTreeView; Node: TTreeNode;
      State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure BtnExpandClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BtnCollapseClick(Sender: TObject);
    procedure BtnSearchClick(Sender: TObject);
    procedure TreeViewRttiChange(Sender: TObject; Node: TTreeNode);
    procedure TreeViewRttiDblClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    ctx: TRttiContext;
    procedure LoadTree;
    procedure LoadClasses;
    function  FindTextTv(Text:string;Tv:TTreeView):TTreeNode;
  public
    { Public declarations }
  end;

var
  FrmRTTIExplLite: TFrmRTTIExplLite;

  procedure ShowRttiLiteExplorer;

implementation

Const
Package_Level =0;
Unit_Level    =1;
Type_Level    =2;
Field_Level   =3;


{$R *.dfm}


procedure ShowRttiLiteExplorer;
var
 Frm:  TFrmRTTIExplLite;
begin
  Frm:= TFrmRTTIExplLite.Create(nil);
  try
   Frm.ShowModal();
  finally
   Frm.Free;
  end;
end;


procedure TFrmRTTIExplLite.BtnCollapseClick(Sender: TObject);
begin
  if PageControlRtti.ActivePage=TabSheetUnits then
  begin
     TreeViewRtti.Items.BeginUpdate;
     try
      TreeViewRtti.FullCollapse;
     finally
     TreeViewRtti.Items.EndUpdate;
     end;
  end
  else
  if PageControlRtti.ActivePage=TabSheetClasses then
  begin
     TreeViewClasses.Items.BeginUpdate;
     try
      TreeViewClasses.FullCollapse;
     finally
     TreeViewClasses.Items.EndUpdate;
     end;
  end;
end;

procedure TFrmRTTIExplLite.BtnExpandClick(Sender: TObject);
begin
  if PageControlRtti.ActivePage=TabSheetUnits then
  begin
     TreeViewRtti.Items.BeginUpdate;
     try
      TreeViewRtti.FullExpand;
     finally
     TreeViewRtti.Items.EndUpdate;
     end;
  end
  else
  if PageControlRtti.ActivePage=TabSheetClasses then
  begin
     TreeViewClasses.Items.BeginUpdate;
     try
      TreeViewClasses.FullExpand;
     finally
     TreeViewClasses.Items.EndUpdate;
     end;
  end;


end;

procedure TFrmRTTIExplLite.BtnFillClick(Sender: TObject);
begin
 LoadTree();
 LoadClasses();
end;

procedure TFrmRTTIExplLite.BtnSearchClick(Sender: TObject);
Var
 Node: TTreeNode;
begin
  if Trim(EditSearch.Text)='' then exit;

  if PageControlRtti.ActivePage=TabSheetUnits then
  begin
     Node:=FindTextTv(Trim(EditSearch.Text),TreeViewRtti);
     if Node<>nil then
     begin
      Node.MakeVisible;
      TreeViewRtti.Selected:=Node
     end
     else
     ShowMessage(Format('%s Not found',[Trim(EditSearch.Text)]));
  end
  else
  if PageControlRtti.ActivePage=TabSheetClasses then
  begin
     Node:=FindTextTv(Trim(EditSearch.Text),TreeViewClasses);
     if Node<>nil then
     begin
      Node.MakeVisible;
      TreeViewClasses.Selected:=Node
     end
     else
     ShowMessage(Format('%s Not found',[Trim(EditSearch.Text)]));
  end;

end;

function TFrmRTTIExplLite.FindTextTv(Text: string;Tv:TTreeView): TTreeNode;
var
  Node: TTreeNode;
begin
 Result:=nil;
 Tv.Items.BeginUpdate;
 try
   if  Tv.Items.Count=0 then exit;
   Node:=Tv.Selected;
   if Node=nil then
   Node:=Tv.Items[0]
   else
   Node:=Node.GetNext;

   while Node<>nil do
   begin
        if Pos(UpperCase(Text),UpperCase(Node.Text))>0 then
        begin
         Result:=Node;
         Exit;
        end
        else
        Node:=Node.GetNext;
   end;

 finally
   Tv.Items.EndUpdate;
 end;
end;


procedure TFrmRTTIExplLite.FormCreate(Sender: TObject);
begin
  ctx := TRttiContext.Create;
  LoadTree();
  LoadClasses();
end;

procedure TFrmRTTIExplLite.FormDestroy(Sender: TObject);
begin
 ctx.Free;
end;

procedure TFrmRTTIExplLite.LoadClasses;

        function FindTRttiType(lType:TRttiType):TTreeNode;
        var
          i: integer;
          Node: TTreeNode;
        begin
           Result:=nil;
           if not Assigned(lType) then exit;

             for i:=0 to TreeViewClasses.Items.Count-1 do
             begin
                Node:=TreeViewClasses.Items.Item[i];
                if Assigned(Node.Data) then
                 if lType.QualifiedName=TRttiType(Node.Data).QualifiedName then
                 begin
                  Result:=Node;
                  exit;
                 end;
             end;
        end;

        function FindFirstTRttiTypeOrphan:TTreeNode;
        var
          i: integer;
          Node: TTreeNode;
          lType: TRttiType;
        begin
           Result:=nil;
             for i:=0 to TreeViewClasses.Items.Count-1 do
             begin
                 Node:=TreeViewClasses.Items[i];
                 lType:=TRttiType(Node.Data);

                 if not Assigned(lType.BaseType) then Continue;

                 if lType.BaseType.Name<>TRttiType(Node.Parent.Data).Name then
                 begin
                   Result:=Node;
                   break;
                 end;
             end;
        end;

var
  TypeList: TArray<TRttiType>;
  lType: TRttiType;
  PNode: TTreeNode;
  Node: TTreeNode;
begin
  TreeViewClasses.Items.BeginUpdate;
  try
    TreeViewClasses.Items.Clear;

      //Add Root TObject
      lType:=ctx.GetType(TObject);
      Node:=TreeViewClasses.Items.AddObject(nil,lType.Name,lType);

      TypeList:= ctx.GetTypes;
      for lType in TypeList do
        if lType.IsInstance then
        begin
             if Assigned(lType.BaseType) then
             TreeViewClasses.Items.AddChildObject(Node,lType.Name,lType);
        end;

        LabelNClasses.Caption:=FormatFloat('#,',TreeViewClasses.Items.Count);

      Repeat
         Node:=FindFirstTRttiTypeOrphan;
         if Node=nil then break;
         PNode:=FindTRttiType(TRttiType(Node.Data).BaseType);
         Node.MoveTo(PNode,naAddChild);
      Until 1<>1;

  finally
    TreeViewClasses.Items.EndUpdate;
  end;
end;

procedure TFrmRTTIExplLite.LoadTree;

    function GetUnitName(lType: TRttiType): string;
    begin
      Result := StringReplace(lType.QualifiedName, '.' + lType.Name, '',[rfReplaceAll])
    end;

var
  lType: TRttiType;
  lMethod: TRttiMethod;
  lProperty: TRttiProperty;
  lField: TRttiField;

  PNode: TTreeNode;
  Node: TTreeNode;

  TypeList: TArray<TRttiType>;
  Units: TStrings;
  UnitName: string;

  Package: TRttiPackage;
  PackageN: TTreeNode;
begin
  TreeViewRtti.Items.BeginUpdate;
  TreeViewRtti.Items.Clear;
  Units:=TStringList.Create;
  try


   for Package in ctx.GetPackages do
   begin
     Units.Clear;
     PackageN:=TreeViewRtti.Items.Add(nil,Package.Name);

      TypeList:= Package.GetTypes;//ctx.GetTypes;
      LabelNtypes.Caption:=FormatFloat('#,',High(TypeList));
      PNode:=nil;
      for lType in TypeList do
      begin
           UnitName:=GetUnitName(lType);
           if Units.IndexOf(UnitName)<0 then
           begin
            Units.Add(UnitName);
            PNode:=TreeViewRtti.Items.AddChild(PackageN,UnitName);
           end;

           Node:=TreeViewRtti.Items.AddChildObject(PNode,lType.ToString,lType);

           for lField in lType.GetDeclaredFields do
             TreeViewRtti.Items.AddChildObject(Node,lField.ToString,lField);

           for lMethod in lType.GetDeclaredMethods do
             TreeViewRtti.Items.AddChildObject(Node,lMethod.ToString,lMethod);

           for lProperty in lType.GetDeclaredProperties do
             TreeViewRtti.Items.AddChildObject(Node,lProperty.ToString,lProperty);
      end;

    end;


  finally
    TreeViewRtti.Items.EndUpdate;
    Units.Free;
  end;
end;

procedure TFrmRTTIExplLite.TreeViewRttiChange(Sender: TObject; Node: TTreeNode);
Var
  aNode: TTreeNode;
  lTyp: TRttiType;
  lType: TRttiType;
  lMethod: TRttiMethod;
  lProperty: TRttiProperty;
  lProp: TRttiProperty;
  lField: TRttiField;

  Item: TListItem;
begin
   aNode:=TreeViewRtti.Selected;
   if aNode<>nil then
   begin

         ListViewRtti.Items.BeginUpdate;
         try
            ListViewRtti.Items.Clear;
         finally
           ListViewRtti.Items.EndUpdate;
         end;


      case aNode.Level of
      Type_Level  :
                      begin
                       lTyp   :=aNode.Data;
                       lType  :=ctx.GetType(TRttiType);

                             ListViewRtti.Items.BeginUpdate;
                             try
                                for lProperty in  lType.GetProperties do
                                begin
                                 //Ugly hack to prevent call the properties wich start with 'As' like AsInstance,AsOrdinal,AsRecord,AsSet
                                 if Copy(lProperty.Name,1,2)='As' then Continue;

                                 Item:=ListViewRtti.Items.Add;
                                 Item.Caption:=lProperty.Name;
                                 Item.SubItems.Add(lProperty.GetValue(lTyp).ToString);
                                end;
                             finally
                               ListViewRtti.Items.EndUpdate;
                             end;

                      end;

      Field_Level  :
                      begin
                         if aNode.Data=nil then  exit;

                           if TRttiObject(aNode.Data).ClassNameIs('TRttiInstanceMethodEx') then
                           begin
                               lMethod:=aNode.Data;
                               lType  :=ctx.GetType(TRttiMethod);
                               ListViewRtti.Items.BeginUpdate;
                               try
                                  for lProperty in  lType.GetProperties do
                                  begin
                                   Item:=ListViewRtti.Items.Add;
                                   Item.Caption:=lProperty.Name;
                                   //Another uggly hack, this is due a RTTI limitations, wich raise an exception when
                                   //the ReturnType,MethodKind or CallingConvention property is called and lMethod.HasExtendedInfo is false, because one of the types has not Rtti information
                                   if ( (lProperty.Name='ReturnType') or (lProperty.Name='CallingConvention') or (lProperty.Name='MethodKind')) and not lMethod.HasExtendedInfo then
                                   Item.SubItems.Add('Not supported by RTTI')
                                   else
                                   Item.SubItems.Add(lProperty.GetValue(lMethod).ToString);
                                  end;
                               finally
                                 ListViewRtti.Items.EndUpdate;
                               end;

                           end
                           else
                           if TRttiObject(Node.Data).ClassNameIs('TRttiInstancePropertyEx') then
                           begin
                               lProp  :=aNode.Data;
                               lType  :=ctx.GetType(TRttiProperty);
                               ListViewRtti.Items.BeginUpdate;
                               try
                                  for lProperty in  lType.GetProperties do
                                  begin
                                   Item:=ListViewRtti.Items.Add;
                                   Item.Caption:=lProperty.Name;
                                   Item.SubItems.Add(lProperty.GetValue(lProp).ToString);
                                  end;
                               finally
                                 ListViewRtti.Items.EndUpdate;
                               end;
                           end
                           else
                           if TRttiObject(Node.Data).ClassNameIs('TRttiInstanceFieldEx') then
                           begin
                               lField :=aNode.Data;
                               lType  :=ctx.GetType(TRttiField);

                               ListViewRtti.Items.BeginUpdate;
                               try
                                  for lProperty in  lType.GetProperties do
                                  begin
                                   Item:=ListViewRtti.Items.Add;
                                   Item.Caption:=lProperty.Name;
                                   Item.SubItems.Add(lProperty.GetValue(lField).ToString);
                                  end;
                               finally
                                 ListViewRtti.Items.EndUpdate;
                               end;
                           end;

                     end;

      end;

   end;
end;

procedure TFrmRTTIExplLite.TreeViewRttiCustomDrawItem(Sender: TCustomTreeView;
  Node: TTreeNode; State: TCustomDrawState; var DefaultDraw: Boolean);
var
  FontColor: TColor;
  BackColor: TColor;
  lType: TRttiType;
  //lMethod: TRttiMethod;
  //lProperty: TRttiProperty;
  //lField: TRttiField;
begin
  FontColor := Sender.Canvas.Font.Color;
  Sender.Canvas.Font.Color := clNavy;
  Sender.Canvas.Font.Color := FontColor;
  BackColor := clWindow;
  FontColor := clWindowText;

  case Node.Level of
    Package_Level :
      begin
       FontColor := clBlack;
       Sender.Canvas.Font.Style := [fsBold];
      end;
    
    Unit_Level :
      begin
        FontColor := clRed;
      end;
    
    Type_Level :
      begin
        lType := Node.Data;
        if lType<>nil then
        case lType.TypeKind of
          tkClass: 
            begin
              FontColor := clGreen;
              Sender.Canvas.Font.Style := [fsBold]
            End;
            else FontColor := clBlue;
        end;
      end;
    Field_Level :
      begin
        if Node.Data = nil then exit;
 
        if TRttiObject(Node.Data).ClassNameIs('TRttiInstanceMethodEx') then
        begin
          //lMethod:=Node.Data;
          FontColor := clGray;
        end
        else
        if TRttiObject(Node.Data).ClassNameIs('TRttiInstancePropertyEx') then
        begin
          //lProperty:=Node.Data;
          FontColor := clNavy;
        end;
      end;
  end;

  if (Node.Selected) then
  begin
    BackColor := clHighlight;
    FontColor := clWindow;
  end;

  Sender.Canvas.Brush.Color := BackColor;
  Sender.Canvas.Font.Color := FontColor;
  DefaultDraw := True;
end;

procedure TFrmRTTIExplLite.TreeViewRttiDblClick(Sender: TObject);

  function FindRttyType(lType:TRttiType):TTreeNode;
  var
    i: integer;
  begin
    Result := nil;
    for i:= 0 to TreeViewRtti.Items.Count-1 do
    if TreeViewRtti.Items[i].Level=Type_Level then
    begin
      Result := TreeViewRtti.Items[i];
      if Assigned(Result.Data) then
        if lType.QualifiedName = TRttiType(Result.Data).QualifiedName then
          break;
    end;
  end;

Var
  Node: TTreeNode;
  lType: TRttiType;
  lMethod: TRttiMethod;
  lProperty: TRttiProperty;
  lField: TRttiField;
begin
  Node:=TreeViewRtti.Selected;
  case Node.Level of
   Field_Level :
    begin
      if TRttiObject(Node.Data).ClassNameIs('TRttiInstanceFieldEx') then
      begin
          lField := Node.Data;
          lType := ctx.FindType(lField.FieldType.QualifiedName);
          if Assigned(lType) then
          begin
             Node := FindRttyType(lType);
             if Node <> nil then
             begin
               Node.MakeVisible;
               TreeViewRtti.Selected := Node;
             end;
          end;
      end
      else
      if TRttiObject(Node.Data).ClassNameIs('TRttiInstancePropertyEx') then
      begin
        lProperty := Node.Data;
        lType := ctx.FindType(lProperty.PropertyType.QualifiedName);
        if Assigned(lType) then
        begin
          Node := FindRttyType(lType);
          if Node<>nil then
          begin
            Node.MakeVisible;
            TreeViewRtti.Selected:=Node;
          end;
        end;
      end
      else
      if TRttiObject(Node.Data).ClassNameIs('TRttiInstanceMethodEx') then
      begin
        lMethod := Node.Data;
        if lMethod.HasExtendedInfo and (lMethod.MethodKind in [mkFunction,mkClassFunction]) then
        begin
          lType := ctx.FindType(lMethod.ReturnType.QualifiedName);
          if Assigned(lType) then
          begin
            Node := FindRttyType(lType);
            if Node <> nil then
            begin
              Node.MakeVisible;
              TreeViewRtti.Selected:=Node;
            end;
          end;
        end;
      end;
    end;
  end;
end;

end.

unit uMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ExtCtrls, StdCtrls, ImgList;

type
  TFrmMain = class(TForm)
    TreeViewFolders: TTreeView;
    ListViewFiles: TListView;
    Panel1: TPanel;
    StatusBar1: TStatusBar;
    Splitter1: TSplitter;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    ImageList1: TImageList;
    ImageList2: TImageList;
    MemoLog: TMemo;
    Panel2: TPanel;
    Label1: TLabel;
    EditComputer: TEdit;
    Label2: TLabel;
    EditPassword: TEdit;
    Label3: TLabel;
    EditUser: TEdit;
    BtnConnect: TButton;
    procedure FormCreate(Sender: TObject);
    procedure TreeViewFoldersChange(Sender: TObject; Node: TTreeNode);
    procedure FormDestroy(Sender: TObject);
    procedure BtnConnectClick(Sender: TObject);
    procedure EditComputerExit(Sender: TObject);
    procedure EditUserExit(Sender: TObject);
    procedure EditPasswordExit(Sender: TObject);
  private
    Dt: OleVariant;
    FSWbemLocator: OLEVariant;
    FWMIService: OLEVariant;
    FExtensions: TStringList;
    FComputer: string;
    FUser: string;
    FPassword: string;
    function ConnectWMI: boolean;
    procedure UpdateFolderTreeItem(Node:TTreeNode);
    procedure UpdateFileTreeItem(Node:TTreeNode);
    function VarDateToDateTime(const V: OleVariant): TDateTime;
    function GetNodeFullPath(Node:TTreeNode): string;
    function GetImageIndexExt(const Ext: string): Integer;
    property Computer:  string read FComputer;
    property User: string read FUser;
    property Password: string read FPassword;
  public
    { Public declarations }
  end;

var
  FrmMain: TFrmMain;

implementation

Uses
  ShellAPI,
  uStackTrace,
  ActiveX,
  ComObj;

const
  wbemFlagForwardOnly = $00000020;

{$R *.dfm}
procedure TFrmMain.BtnConnectClick(Sender: TObject);
begin

  if TButton(Sender).Tag=0 then
  begin
    StatusBar1.SimpleText:=Format('Connecting to %s',[Computer]);
    try
      if ConnectWMI then
      begin
        UpdateFolderTreeItem(nil);
        BtnConnect.Caption:='Disconnect';
        BtnConnect.Tag:=1;
        BtnConnect.ImageIndex:=3;

        EditComputer.Enabled:=False;
        EditUser.Enabled:=False;
        EditPassword.Enabled:=False;
      end
      else
      ShowMessage(Format('can''t establish a WMI connection to the %s server, check the log for more details',[Computer]));
    finally
      StatusBar1.SimpleText:='';
    end;
  end
  else
  if TButton(Sender).Tag=1 then
  begin
        FWMIService:=Unassigned;
        TreeViewFolders.Items.BeginUpdate;
        try
          TreeViewFolders.Items.Clear;
        finally
          TreeViewFolders.Items.EndUpdate;
        end;

        ListViewFiles.Items.BeginUpdate;
        try
         ListViewFiles.Items.Clear;
        finally
         ListViewFiles.Items.EndUpdate;
        end;

        BtnConnect.Caption:='Connect';
        BtnConnect.Tag:=0;
        BtnConnect.ImageIndex:=2;

        EditComputer.Enabled:=True;
        EditUser.Enabled:=True;
        EditPassword.Enabled:=True;
  end;
end;

function TFrmMain.ConnectWMI: Boolean;
begin
 Result:=False;
 try
    FWMIService := FSWbemLocator.ConnectServer(Computer, 'root\CIMV2', User, Password);
    Result:=True;
 except
    on E:EOleException do
        MemoLog.Lines.Add(Format('EOleException %s %x', [E.Message,E.ErrorCode]));
    on E:Exception do
        MemoLog.Lines.Add(E.Message);
 end;
end;

procedure TFrmMain.EditComputerExit(Sender: TObject);
begin
   FComputer:=EditComputer.Text;
end;

procedure TFrmMain.EditPasswordExit(Sender: TObject);
begin
  FPassword:=EditPassword.Text;
end;

procedure TFrmMain.EditUserExit(Sender: TObject);
begin
   FUser:=EditUser.Text;
end;

procedure TFrmMain.FormCreate(Sender: TObject);
begin
  FExtensions:=TStringList.Create;
  FComputer:=EditComputer.Text;
  FUser:=EditUser.Text;
  FPassword:=EditPassword.Text;
  Dt:=CreateOleObject('WbemScripting.SWbemDateTime');
  FSWbemLocator := CreateOleObject('WbemScripting.SWbemLocator');
end;

procedure TFrmMain.FormDestroy(Sender: TObject);
begin
  FExtensions.Free;
end;


function TFrmMain.GetImageIndexExt(const Ext: string): Integer;
var
  Icon: TIcon;
  FileInfo: SHFILEINFO;
begin
  ZeroMemory(@FileInfo, SizeOf(FileInfo));
  Result:=FExtensions.IndexOf(Ext);
  if Result=-1 then
  begin
    Icon := TIcon.Create;
    try
       if SHGetFileInfo(PChar('*'+Ext), FILE_ATTRIBUTE_NORMAL, FileInfo, SizeOf(FileInfo),
       SHGFI_ICON or SHGFI_SMALLICON or SHGFI_SYSICONINDEX or SHGFI_USEFILEATTRIBUTES ) <> 0 then
        begin
          Icon.Handle := FileInfo.hIcon;
          Result:=ImageList2.AddIcon(Icon);
          FExtensions.Add(Ext);
        end;
    finally
      Icon.Free;
    end;
  end;
end;

function TFrmMain.GetNodeFullPath(Node: TTreeNode): string;
begin
  Result:=Node.Text;
   if Node.Parent<>nil then
   repeat
      Node:=Node.Parent;
      Result:=Node.Text+'\'+Result;
   until Node.Parent=nil;
end;

procedure TFrmMain.TreeViewFoldersChange(Sender: TObject; Node: TTreeNode);
begin
  try
    if Assigned(Node) and (Node.Count=0) and not VarIsClear(FWMIService) then
      UpdateFolderTreeItem(Node);

    if Assigned(Node) and not VarIsClear(FWMIService) then
      UpdateFileTreeItem(Node);
  except
    on E: Exception do
     ShowMessage(Format('Message: %s: Trace %s',[E.Message, E.StackTrace]));
  end;
end;

procedure TFrmMain.UpdateFileTreeItem(Node: TTreeNode);
Var
  FWbemObjectSet: OLEVariant;
  FWbemObject: OLEVariant;
  oEnum: IEnumvariant;
  iValue: LongWord;
  sValue: String;
  Path: String;
  Drive: String;
  WmiPath: String;
  Item: TListItem;
  Wql: String;
begin
  Path    :=GetNodeFullPath(Node);
  Drive   :=ExtractFileDrive(Path);
  WmiPath :=IncludeTrailingPathDelimiter(Copy(Path,3,Length(Path)));
  WmiPath :=StringReplace(WmiPath,'\','\\',[rfReplaceAll]);

  ListViewFiles.Items.BeginUpdate;
  StatusBar1.SimpleText:=Format('Reading files from %s',[Path]);
  try
    ListViewFiles.Items.Clear;
    Wql:=Format('SELECT Name,FileSize,CreationDate,FileType FROM CIM_DataFile Where Drive="%s" AND Path="%s"',[Drive,WmiPath]);
    MemoLog.Lines.Add(Wql);
    FWbemObjectSet:= FWMIService.ExecQuery(Wql,'WQL',wbemFlagForwardOnly);
    oEnum := IUnknown(FWbemObjectSet._NewEnum) as IEnumVariant;
    while oEnum.Next(1, FWbemObject, iValue) = 0 do
    begin
      sValue:=FWbemObject.Name;
      Item:=ListViewFiles.Items.Add;
      Item.Caption:=ExtractFileName(sValue);
      Item.SubItems.Add(DateToStr(VarDateToDateTime(FWbemObject.CreationDate)));
      Item.SubItems.Add(FWbemObject.FileType);
      Item.SubItems.Add(FormatFloat('#,',FWbemObject.FileSize));
      Item.ImageIndex:=GetImageIndexExt(ExtractFileExt(sValue));
      FWbemObject:=Unassigned;
    end;
  finally
    ListViewFiles.Items.EndUpdate;
    StatusBar1.SimpleText:='';
    FWbemObjectSet:=Unassigned;
  end;
end;

procedure TFrmMain.UpdateFolderTreeItem(Node: TTreeNode);
Var
  lNode: TTreeNode;
  FWbemObjectSet: OLEVariant;
  FWbemObject: OLEVariant;
  oEnum: IEnumvariant;
  iValue: LongWord;

  sValue: string;
  Path: string;
  Drive: string;
  WmiPath: string;
  Wql: string;
begin
  if Node=nil then
  begin
    TreeViewFolders.Items.BeginUpdate;
    TreeViewFolders.Items.Clear;
    try
      FWbemObjectSet:= FWMIService.ExecQuery('SELECT Name FROM Win32_LogicalDisk','WQL',wbemFlagForwardOnly);
      oEnum := IUnknown(FWbemObjectSet._NewEnum) as IEnumVariant;
      while oEnum.Next(1, FWbemObject, iValue) = 0 do
      begin
        sValue:=Trim(FWbemObject.Name);
        lNode:=TreeViewFolders.Items.Add(nil,sValue);
        lNode.ImageIndex:=1;
        lNode.SelectedIndex:=1;
        FWbemObject:=Unassigned;
      end;
    finally
      TreeViewFolders.Items.EndUpdate;
      FWbemObjectSet:=Unassigned;
    end;
  end
  else
  begin
      TreeViewFolders.Items.BeginUpdate;
    try
      Path    :=GetNodeFullPath(Node);
      StatusBar1.SimpleText:=Format('Reading folders from %s',[Path]);
      Drive   :=ExtractFileDrive(Path);
      WmiPath :=IncludeTrailingPathDelimiter(Copy(Path,3,Length(Path)));
      WmiPath :=StringReplace(WmiPath,'\','\\',[rfReplaceAll]);
      Wql     :=Format('SELECT Name FROM CIM_Directory Where Drive="%s" AND Path="%s"',[Drive,WmiPath]);
      MemoLog.Lines.Add(Wql);
      FWbemObjectSet:= FWMIService.ExecQuery(Wql,'WQL',wbemFlagForwardOnly);
      oEnum := IUnknown(FWbemObjectSet._NewEnum) as IEnumVariant;
      while oEnum.Next(1, FWbemObject, iValue) = 0 do
      begin
        sValue:=Trim(FWbemObject.Name);
        lNode:=TreeViewFolders.Items.AddChild(Node,ExtractFileName(sValue));
        lNode.ImageIndex:=0;
        lNode.SelectedIndex:=0;
        FWbemObject:=Unassigned;
      end;
    finally
       StatusBar1.SimpleText:='';
       FWbemObjectSet:=Unassigned;
       TreeViewFolders.Items.EndUpdate;
    end;
  end;
end;

function TFrmMain.VarDateToDateTime(const V: OleVariant): TDateTime;
begin
  Result:=0;
  if VarIsNull(V) then exit;
  Dt.Value := V;
  Result:=Dt.GetVarDate;
end;

end.


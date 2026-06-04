unit UnitTest;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TForm9 = class(TForm)
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form9: TForm9;

implementation

uses
ComCtrls,
SelectDelphiVersion;

{$R *.dfm}

procedure TForm9.Button1Click(Sender: TObject);
var
  Frm: TFrmSelDelphiVer;
  item: TListItem;
  DelphiPath: string;
begin
  Frm := TFrmSelDelphiVer.Create(Self);
  try
    Frm.LoadInstalledVersions;
    if Frm.ListViewIDEs.Items.Count=0 then
        ShowMessage('Delphi is not installed in this system')
    else
    if Frm.ShowModal=mrOk then
    begin
       item:=Frm.ListViewIDEs.Selected;
       if Assigned(item) then
       begin
         DelphiPath   :=ExtractFilePath(item.SubItems[0]);
         ShowMessage(DelphiPath);
       end;
    end;
  finally
   Frm.Free;
  end;
end;



end.

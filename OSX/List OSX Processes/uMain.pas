unit uMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Rtti, System.Classes,
  System.Variants, FMX.Types, FMX.Controls, FMX.Forms, FMX.Dialogs,
  FMX.StdCtrls, FMX.Layouts, FMX.Memo, FMX.Grid;

type
  TForm25 = class(TForm)
    StringGrid1: TStringGrid;
    StringColumn1: TStringColumn;
    StringColumn2: TStringColumn;
    StringColumn3: TStringColumn;
    StringColumn4: TStringColumn;
    StringColumn5: TStringColumn;
    StringColumn6: TStringColumn;
    StringColumn7: TStringColumn;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure ListRunningApps;
  end;

var
  Form25: TForm25;

implementation

{$R *.fmx}

uses
  DateUtils,
  Macapi.AppKit,
  Macapi.Foundation,
  Macapi.ObjectiveC,
  Macapi.CocoaTypes;

type
  NSRunningApplicationEx = interface(NSObject)
    ['{96F4D9CA-0732-4557-BA1F-177958903B8F}']
    function activateWithOptions(options: NSApplicationActivationOptions): Boolean; cdecl;
    function activationPolicy: NSApplicationActivationPolicy; cdecl;
    function executableArchitecture: NSInteger; cdecl;
    function forceTerminate: Boolean; cdecl;
    function hide: Boolean; cdecl;
    function isActive: Boolean; cdecl;
    function isFinishedLaunching: Boolean; cdecl;
    function isHidden: Boolean; cdecl;
    function isTerminated: Boolean; cdecl;
    function processIdentifier: Integer; cdecl;
    function terminate: Boolean; cdecl;
    function unhide: Boolean; cdecl;

    //Added functions(properties)
    //Indicates the URL to the application's executable.
    function executableURL: NSURL; cdecl;//@property (readonly) NSURL *executableURL;
    //Indicates the name of the application.  This is dependent on the current localization of the referenced app, and is suitable for presentation to the user.
    function localizedName: NSString; cdecl;//@property (readonly) NSString *localizedName;
    //Indicates the URL to the application's bundle, or nil if the application does not have a bundle.
    function bundleURL: NSURL; cdecl;//@property (readonly) NSURL *bundleURL;
    //Indicates the CFBundleIdentifier of the application, or nil if the application does not have an Info.plist.
    function bundleIdentifier: NSString; cdecl;//@property (readonly) NSString *bundleIdentifier;
    //Indicates the date when the application was launched.  This property is not available for all applications.  Specifically, it is not available for applications that were launched without going through LaunchServices.   */
    function launchDate: NSDate;cdecl;//@property (readonly) NSDate *launchDate;
    //Returns the icon of the application.
    function icon: NSImage;cdecl;//@property (readonly) NSImage *icon;
  end;
  TNSRunningApplicationEx = class(TOCGenericImport<NSRunningApplicationClass, NSRunningApplicationEx>)  end;

procedure TForm25.FormCreate(Sender: TObject);
begin
  ListRunningApps;
end;

procedure TForm25.ListRunningApps;
var
  LWorkSpace: NSWorkspace;
  LApp: NSRunningApplicationEx;
  LFormatter: NSDateFormatter;
  i: integer;
  LArray: NSArray;
begin
  LWorkSpace:=TNSWorkspace.create;//or TNsWorkspace.Wrap(TNsWorkSpace.OCClass.sharedWorkspace);
  LArray:=LWorkSpace.runningApplications;
  //NSDateFormatter Class Reference
  //https://developer.apple.com/library/mac/#documentation/Cocoa/Reference/Foundation/Classes/NSDateFormatter_Class/Reference/Reference.html
  TNSDateFormatter.OCClass.setDefaultFormatterBehavior(NSDateFormatterBehavior10_4);
  LFormatter:=TNSDateFormatter.Create;
  LFormatter.setDateFormat(NSSTR('HH:mm:ss YYYY/MM/dd'));
  if LArray<>nil then
  begin
    StringGrid1.RowCount:=LArray.count;
   for i := 0 to LArray.count-1 do
   begin
     LApp:= TNSRunningApplicationEx.Wrap(LArray.objectAtIndex(i));
     StringGrid1.Cells[0,i]:=LApp.processIdentifier.ToString();
     if LApp.launchDate<>nil then
     StringGrid1.Cells[1,i]:=string(LFormatter.stringFromDate(LApp.launchDate).UTF8String);
     StringGrid1.Cells[2,i]:=string(LApp.localizedName.UTF8String);
     StringGrid1.Cells[3,i]:=string(LApp.executableURL.path.UTF8String);

     if LApp.bundleIdentifier<>nil then
       StringGrid1.Cells[4,i]:=string(LApp.bundleIdentifier.UTF8String);

     if LApp.bundleURL<>nil then
       StringGrid1.Cells[5,i]:=string(LApp.bundleURL.path.UTF8String);

      case LApp.executableArchitecture of
        NSBundleExecutableArchitectureI386:   StringGrid1.Cells[6,i]:='I386';
        NSBundleExecutableArchitecturePPC:   StringGrid1.Cells[6,i]:='PPC';
        NSBundleExecutableArchitecturePPC64:   StringGrid1.Cells[6,i]:='PPC64';
        NSBundleExecutableArchitectureX86_64:   StringGrid1.Cells[6,i]:='X86_64';
      end;
   end;
  end;
end;


end.

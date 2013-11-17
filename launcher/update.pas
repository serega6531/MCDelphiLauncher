unit update;

interface

uses
  Winapi.Windows, System.SysUtils,
   Vcl.Forms, Vcl.StdCtrls,
 Vcl.Imaging.pngimage,  main, ComCtrls, Vcl.Controls, System.Classes;

type
  TForm3 = class(TForm)
    Title: TLabel;
    LoadingLabel: TLabel;
    ProgressBar: TProgressBar;
    procedure processUpdate(isForceUpdate:boolean; servername:string);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form3: TForm3;

implementation

{$R *.dfm}

uses enter, ServerList, UpdateManager;

{ TForm3 }

procedure TForm3.processUpdate(isForceUpdate: boolean; servername:string);
var manager:TUpdateManager;
servers:TServerList;
begin
manager.Create;
servers.Create;

servers.getServerIdByName(servername);

manager.Destroy;
servers.Destroy;
end;

end.

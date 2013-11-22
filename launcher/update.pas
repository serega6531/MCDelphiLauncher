unit update;

interface

uses
  Winapi.Windows, System.SysUtils,
   Vcl.Forms, Vcl.StdCtrls,
 Vcl.Imaging.pngimage,  main, ComCtrls, Vcl.Controls, System.Classes, ServerData;

type
  TForm3 = class(TForm)
    Title: TLabel;
    LoadingLabel: TLabel;
    ProgressBar: TProgressBar;
    procedure processUpdate(isForceUpdate:boolean; chosenserver:TServerData);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form3: TForm3;

implementation

{$R *.dfm}

uses enter, UpdateManager;

{ TForm3 }

procedure TForm3.processUpdate(isForceUpdate: boolean; chosenserver:TServerData);
var manager:TUpdateManager;
begin
manager:=TUpdateManager.Create;

//update

manager.Destroy;
end;

end.

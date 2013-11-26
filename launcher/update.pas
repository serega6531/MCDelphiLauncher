unit update;

interface

uses
  Winapi.Windows, System.SysUtils,
   Vcl.Forms, Vcl.StdCtrls,
 Vcl.Imaging.pngimage,  main, ComCtrls, Vcl.Controls, System.Classes, ServerData,
  sSkinProvider, sLabel, acProgressBar, sButton, IdHashMessageDigest, idGlobal, Dialogs;

type
  TForm3 = class(TForm)
    sSkinProvider1: TsSkinProvider;
    ProgressBar: TsProgressBar;
    Title: TsLabel;
    LoadingLabel: TsLabel;
    CancelBtn: TsButton;
    procedure processUpdate(isForceUpdate:boolean; chosenserver:TServerData);
    procedure CancelBtnClick(Sender: TObject);
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

procedure TForm3.CancelBtnClick(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TForm3.processUpdate(isForceUpdate: boolean; chosenserver:TServerData);
var
  manager:TUpdateManager;
begin
  form1.Hide;
  form3.Show;
  manager:=TUpdateManager.Create;

  manager.init(chosenserver.getName,isForceUpdate);

  manager.Destroy;
end;

end.

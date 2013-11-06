unit settings;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, main, SHFolder;

type
  TForm2 = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Edit1: TEdit;
    Edit2: TEdit;
    Label4: TLabel;
    Label5: TLabel;
    Button1: TButton;
    Button2: TButton;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

const
  LauncherVer:string = '1';

implementation

{$R *.dfm}

function GetSpecialFolderPath(folder : integer) : string;    {Полуаем системные пути}
const
SHGFP_TYPE_CURRENT = 0;
var
path: array [0..MAX_PATH] of char;
begin
if SUCCEEDED(SHGetFolderPath(0,folder,0,SHGFP_TYPE_CURRENT,@path[0])) then
Result := path
else
ShowMessage('Cant find appdata');
end;

procedure TForm2.Button1Click(Sender: TObject);     {кнопка сохранить}
begin
if (StrToInt(Edit1.Text) > 256) AND (StrToInt(Edit2.Text) > StrToInt(Edit1.text)) then       {проверка правильности данных}
begin
MinMem:=Edit1.Text;
MaxMem:=Edit2.Text;
end
else
ShowMessage('Ошибка! Проверьте правильность введённых данных');
end;

procedure TForm2.FormCreate(Sender: TObject);
begin
Label1.Caption:='Версия лаунчера' + LauncherVer;   {вывод версии}
rootdir:='.happyminers.ru';                        {Корневая папка(.happyminers)}
appdata:=GetSpecialFolderPath(CSIDL_APPDATA);      {получаем appdata/roaming}
  files[1]:='bin\minecraft.jar';                   {Список файлов для проверки/загрузки}
  files[2]:='bin\lwjgl_util.jar';
  files[3]:='bin\lwjgl.jar';
  files[4]:='bin\jinput.jar';
  files[5]:='bin\natives\jinput-dx8.dll';
  files[6]:='bin\natives\jinput-dx8_64.dll';
  files[7]:='bin\natives\jinput-raw.dll';
  files[8]:='bin\natives\jinput-raw_64.dll';
  files[9]:='bin\natives\lwjgl.dll';
  files[10]:='bin\natives\lwjgl64.dll';
  files[11]:='bin\natives\OpenAL32.dll';
  files[12]:='bin\natives\OpenAL64.dll';
  files[13]:='mods\matmos_packaged.zip';
  files[13]:='mods\mod_worldeditcui_1.5.1_01_lite_mc1.5.1.litemod';
  files[14]:='additonal.zip';

FilesFullPatch[1]:=appdata + '\' + RootDir + '\' + files[1];       {Полные пути до файлов}
FilesFullPatch[2]:=appdata + '\' + RootDir + '\' + files[3];
FilesFullPatch[3]:=appdata + '\' + RootDir + '\' + files[3];
FilesFullPatch[4]:=appdata + '\' + RootDir + '\' + files[4];
FilesFullPatch[5]:=appdata + '\' + RootDir + '\' + files[5];
FilesFullPatch[6]:=appdata + '\' + RootDir + '\' + files[6];
FilesFullPatch[7]:=appdata + '\' + RootDir + '\' + files[7];
FilesFullPatch[8]:=appdata + '\' + RootDir + '\' + files[8];
FilesFullPatch[9]:=appdata + '\' + RootDir + '\' + files[9];
FilesFullPatch[10]:=appdata + '\' + RootDir + '\' + files[10];
FilesFullPatch[11]:=appdata + '\' + RootDir + '\' + files[11];
FilesFullPatch[12]:=appdata + '\' + RootDir + '\' + files[12];
FilesFullPatch[13]:=appdata + '\' + RootDir + '\' + files[13];
FilesFullPatch[14]:=appdata + '\' + RootDir + '\' + files[14];
end;

end.

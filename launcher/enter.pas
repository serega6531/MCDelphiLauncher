unit enter;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, Registry, shellapi;

    procedure LaunchGame();

var
  login:string;
  DoOnce:boolean;

implementation

uses main, settings;


procedure GetTreeDirs(Root: string; OutPaper: TStringList);
var
  i: Integer;
  s: string;

  procedure InsDirs(s: string; ind: Integer; Path: string; OPaper: TStringList);
  var {¬ставл€ет в Memo список вложенных директорий}
    sr: TSearchRec;
    attr: Integer;
  begin
    attr := faAnyFile;
    if DirectoryExists(Path) then
      if FindFirst(IncludeTrailingBackslash(Path) + '*.*', attr, SR) = 0 then
      begin
        repeat
          if (sr.Attr = faDirectory) and (sr.Name[Length(sr.Name)] <> '.') then
            OPaper.Insert(ind, s + sr.Name);
        until (FindNext(sr) <> 0);
        FindClose(SR);
      end
  end;

begin
  {ѕровер€ем существуетли начальный каталог}
  if not DirectoryExists(Root) then
    exit;
  {—оздаем список каталогов первой вложенности}
  if root[Length(Root)] <> '\' then
    InsDirs(root + '\', OutPaper.Count, Root, OutPaper)
  else
    InsDirs(root, OutPaper.Count, Root, OutPaper);
  i := 0;
  repeat
    s := OutPaper[i]; //в s получаем путь к уже внесенному в список кат.
    // ¬ставл€ем сразу за данной директорией в списке,
    // список вложенных в нее директорий.
    // “ем самым увеличиваем OutPaper.Lines.Count.
    // “аким образом катологи в которых поиск еще не производилс€,
    // оказываютс€ ниже и очереь до них еще дойдет.
    InsDirs(s + '\', i + 1, OutPaper[i], OutPaper);
    inc(i);
  until (i = OutPaper.Count);
end;

Function GetJavaPath:string;
var 
  dirs: TStringList;
  root:string;
begin
  if DirectoryExists('C:\Program Files\Java') then
  begin
    root:='C:\Program Files\Java';
  end
  else if DirectoryExists('C:\Program Files(x86)\Java') then
  begin
    root:='C:\Program Files(x86)\Java';
  end;
dirs := TStringList.Create;
  try
    GetTreeDirs(root, dirs);
    dirs.Sort;
    result:=dirs.Strings[dirs.Count-1];
  finally
    dirs.Free;
    Raise Exception.Create('Can''t find Java');
  end;
end;

procedure StartGame(JavaPath, Launch, MinecraftPath:string);
begin
//CreateProcess(nil,PWideChar(WideString('"' + JavaPath + '"' + Launch)),nil,nil,True,NORMAL_PRIORITY_CLASS,nil,nil,si,pi);
//ShellExecuteA(0,nil,PAnsiChar(JavaPath + 'bin\javaw.exe'),{lpParameters}nil,PAnsiChar(MinecraftPath +'\bin\'),SW_SHOWNORMAL);
//CreateProcess(JavaPath + 'bin\javaw.exe', ' Parameters', nil, nil, false, NORMAL_PRIORITY_CLASS, nil, nil, si, pi);
end;

procedure LaunchGame();
var
    Launch:string;
begin
MinMem:=settings.Form2.Edit1.Text;
MaxMem:=settings.Form2.Edit2.Text;
  begin
  {Launch:=PAnsiChar(' -Xms' + MinMem + 'm' +
            ' -Xmx' + MaxMem + 'm' +
            ' -Djava.library.path=natives' +                                   //This all for minecraft down 1.6
            ' -cp "'+ 'minecraft.jar;jinput.jar;lwjgl.jar;lwjgl_util.jar;' +
            ' net.minecraft.client.Minecraft '+ main.LaunchParams);    //ѕараметры + автоподключение
  end;}
StartGame(GetJavaPath(), Launch, (appdata + '\' + RootDir));
end;

end;
end.

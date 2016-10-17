{��Ԫ˵����FTP������Ԫ}
{Author: audix.tc.paul 2012-08-07}
{��ע1�����Ҫ��IdFTP.DirectoryListing����������uses IdAllFTPListParsers�����Ԫ�ļ�}
{��ע2����������ʹ�õ�FTP Server�ļ���ΪUTF8��ʽ����˵���д�˼���UTF8�ĺ���������}


unit UntFTPProc;

interface

uses
  IdFTP, Forms, Windows, SysUtils, Classes, Dialogs, StrUtils,
  IdFTPList, IdFTPCommon;

  //����FTP
  function FTPConnect(Host, Port, Username, Password: string): Boolean; overload;
  function FTPConnect(IdFTP: TIdFTP; Host, Port, Username, Password: string): Boolean; overload;

  //����Ŀ¼�������걣���ڵ�ǰĿ¼                  Dir1\Dir2\Dir3\
  procedure MakeDir(IdFTP: TIdFTP; Dirs: string);

  //�ϴ�
  function FTPUploadFile(IdFTP: TIdFTP; RemoteFileName, LocalFileName: string): Boolean; overload;
  function FTPUploadFile(Host, Port, UserName, Password, RemoteFileName, LocalFileName: string): Boolean; overload;
  function FTPUploadFile(Host, Port, UserName, Password, RemoteFileName, LocalFileName,CurrentDir: string): Boolean; overload;
  function FTPUploadDir(IdFTP: TIdFTP; RemoteDir, LocalDir: string): Boolean; overload;
  function FTPUploadDir(Host, Port, UserName, Password, RemoteDir, LocalDir: string): Boolean; overload;

  //����
  function FTPDownloadFile(IdFTP: TIdFTP; RemoteFileName, LocalFileName: string): Boolean; overload;
  function FTPDownloadFile(Host, Port, UserName, Password, RemoteFileName, LocalFileName: string): Boolean; overload;
  function FTPDownloadFile(Host, Port, UserName, Password, RemoteFileName, LocalFileName, CurrentDir: string): Boolean; overload;
  function FTPDownloadDir(IdFTP: TIdFTP; RemoteDir, LocalDir: string): Boolean; overload;
  function FTPDownloadDir(Host, Port, UserName, Password, RemoteDir, LocalDir: string): Boolean; overload;

  //ɾ��
  function FTPDeleteFile(IdFTP: TIdFTP; RemoteFileName: string): Boolean; overload;
  function FTPDeleteFile(Host, Port, UserName, Password, RemoteFileName: string): Boolean; overload;
  function FTPDeleteFile(Host, Port, UserName, Password, RemoteFileName, CurrentDir: string): Boolean; overload;
  function FTPDeleteDir(IdFTP: TIdFTP; RemoteDir: string): Boolean; overload;
  function FTPDeleteDir(Host, Port, UserName, Password, RemoteDir: string): Boolean; overload;

  //��ȡwindows��ʱ�ļ���
  function GetWinTempPath: String;

  //�����ļ�����ΪTiptop��������UTF-8���룬��������д��һ��
  function FTPDownFile(Host, Port, UserName, Password, LocalFileName,CurrentDir: String; RemoteFileName: UTF8String): Boolean;
  //ɾ��
  function FTPDeleteFile_u(IdFTP: TIdFTP; RemoteFileName: UTF8String): Boolean;
  function FTPDelFile(Host, Port, UserName, Password, CurrentDir: string; RemoteFileName: UTF8String): Boolean;
  //�ϴ��ļ�
  function FTPUpFile(Host, Port, UserName, Password, LocalFileName, CurrentDir: string; RemoteFileName: UTF8String): Boolean;

implementation

function FTPConnect(Host, Port, Username, Password: string): Boolean;
var
  IdFTP: TIdFTP;
begin
  Result := True;
  IdFTP := TIdFTP.Create(nil);
  try
    IdFTP.Host := Host;
    IdFTP.Port := StrToIntDef(Port, 21);
    IdFTP.Username := Username;
    IdFTP.Password := Password;
    try
      IdFTP.Connect;
    except
      Result := False;
    end;
  finally
    IdFTP.Free;
  end;
end;

function FTPConnect(IdFTP: TIdFTP; Host, Port, Username, Password: string): Boolean;
begin
  Result := True;
  IdFTP.Host := Host;
  IdFTP.Port := StrToIntDef(Port, 21);
  IdFTP.Username := Username;
  IdFTP.Password := Password;
  try
    if IdFTP.Connected then IdFTP.Disconnect;//����Ѿ����ӣ�����Ͽ���������
    IdFTP.Connect;
    IdFTP.Passive := True;
  except
    Result := False;
    Application.MessageBox(PChar('FTP���ӳ���'), '����', MB_OK + MB_ICONERROR);
  end;
end;

//����Ŀ¼������Ŀ¼                  Dir1\Dir2\Dir3\
procedure MakeDir(IdFTP: TIdFTP; Dirs: string);
  function ExistString(Strings: TStrings; Value: string): Boolean;
  var
  i: Integer;
  begin
    Result := False;
    for i := 0 to Strings.Count - 1 do
    begin
      Result := Pos(Value, Strings.ValueFromIndex[i]) <> 0;
      if Result then Break;//һ���ҵ��������˳�
    end;
  end;
var
  StringList: TStringList;
  Dir: string;
  i: Integer;
begin //��Ŀ¼�����ڣ����½�����Ŀ¼���ڣ��򲻶�
  StringList := TStringList.Create;
  i := 0;
  repeat
    Dir := Copy(Dirs, 0, Pos('\', Dirs) - 1);
    Dirs := RightStr(Dirs, Length(Dirs) - Length(Dir) - 1);
    IdFTP.Passive := True;
    IdFTP.List(StringList, '', True);//��ȡFTPĿ¼�µ���Ŀ¼
    if not ExistString(StringList, Dir) then
      IdFTP.MakeDir(Dir);
    IdFTP.ChangeDir(Dir);
    i := i + 1;//��¼������ټ�Ŀ¼
  until Pos('\', Dirs) = 0;
  //���ص�ԭĿ¼
  while i <> 0 do
  begin
    IdFTP.ChangeDirUp;
    i := i - 1;
  end;
  StringList.Free;
end;

function FTPUploadFile(IdFTP: TIdFTP; RemoteFileName, LocalFileName: string): Boolean;
begin
  Result := True;
  try
    IdFTP.Put(LocalFileName, ExtractFileName(RemoteFileName));
  except
    Result := False;
    Exit;
  end;
end;

function FTPUploadFile(Host, Port, UserName, Password, RemoteFileName, LocalFileName: string): Boolean;
var
  IdFTP: TIdFTP;
begin
  Result := True;
  IdFTP := TIdFTP.Create(nil);
  try
    IdFTP.Host := Host;
    IdFTP.Port := StrToInt(Port);
    IdFTP.Username := UserName;
    IdFTP.Password := Password;
    try
      IdFTP.Connect;
    except
      Result := False;
      ShowMessage('ftp conn error');
      Exit;
    end;
    try
      IdFTP.Put(LocalFileName, ExtractFileName(RemoteFileName));
    except
      Result := False;
      ShowMessage('ftp down error');
      Exit;
    end;
  finally
    IdFTP.Free;
  end;
end;

function FTPUploadFile(Host, Port, UserName, Password, RemoteFileName, LocalFileName,CurrentDir: string): Boolean;
var
  IdFTP: TIdFTP;
begin
  Result := True;
  IdFTP := TIdFTP.Create(nil);
  try
    IdFTP.Host := Host;
    IdFTP.Port := StrToInt(Port);
    IdFTP.Username := UserName;
    IdFTP.Password := Password;
    try
      IdFTP.Connect;
      IdFTP.ChangeDir(CurrentDir);
    except
      Result := False;
      ShowMessage('ftp conn error');
      Exit;
    end;
    try
      IdFTP.Put(LocalFileName, ExtractFileName(RemoteFileName));
    except
      Result := False;
      ShowMessage('ftp down error');
      Exit;
    end;
  finally
    IdFTP.Free;
  end;
end;

function FTPUpFile(Host, Port, UserName, Password, LocalFileName, CurrentDir: string; RemoteFileName: UTF8String): Boolean;
var
  IdFTP: TIdFTP;
begin
  Result := True;
  IdFTP := TIdFTP.Create(nil);
  try
    IdFTP.Host := Host;
    IdFTP.Port := StrToInt(Port);
    IdFTP.Username := UserName;
    IdFTP.Password := Password;
    try
      IdFTP.Connect;
      IdFTP.ChangeDir(CurrentDir);
    except
      Result := False;
      ShowMessage('ftp conn error');
      Exit;
    end;
    try
      //IdFTP.Put(LocalFileName, ExtractFileName(RemoteFileName));
      IdFTP.Put(LocalFileName, RemoteFileName);
    except
      Result := False;
      ShowMessage('ftp down error');
      Exit;
    end;
  finally
    IdFTP.Free;
  end;
end;

function FTPUploadDir(IdFTP: TIdFTP; RemoteDir, LocalDir: string): Boolean;
  function FTPUploadDir_(IdFTP: TIdFTP; RemoteDir, LocalDir: string): Boolean;
  var                   //idftp:TIdFTP;sDirName:String;sToDirName:String
    hFindFile: Cardinal;
    tfile: string;
    sCurDir: string[255];
    FindFileData: WIN32_FIND_DATA;
  begin
    //�ȱ��浱ǰĿ¼
    sCurDir:=GetCurrentDir;
    ChDir(LocalDir);
    IdFTP.ChangeDir(AnsiToUtf8(RemoteDir));
    hFindFile := FindFirstFile('*.*',FindFileData);
    Application.ProcessMessages;
    if hFindFile <> INVALID_HANDLE_VALUE then
    begin
      repeat
        tfile := FindFileData.cFileName;
        if (tfile= '.') or (tfile= '..') then
          Continue;
        if FindFileData.dwFileAttributes = FILE_ATTRIBUTE_DIRECTORY then
        begin
          try//��������ϴ���Ŀ¼�Ѿ����ڣ������쳣������ߣ�ҳ���ϲ����׳����ļ�����
            IdFTP.MakeDir(AnsiToUtf8(tfile));
          except
          end;
          FTPUploadDir_(idftp, tfile, LocalDir+ '\'+tfile);
          IdFTP.ChangeDir('..');
          Application.ProcessMessages;
        end
        else
        begin
          IdFTP.Put(tfile, AnsiToUtf8(tfile));
          Application.ProcessMessages;
        end;
      until FindNextFile(hFindFile,FindFileData) = False;
    end
    else
    begin
      ChDir(sCurDir);
      Result := false;
      Exit;
    end;
    //�ص�ԭ����Ŀ¼��
    ChDir(sCurDir);
    Result := True;
  end;
var
  temp: string;  
begin
  Result := True;
  temp := Utf8ToAnsi(IdFTP.RetrieveCurrentDir);
  RemoteDir := temp;
  if Length(RemoteDir) = 1 then
    RemoteDir := RemoteDir +  ExtractFileName(LocalDir)
  else
    RemoteDir := RemoteDir + '/' +  ExtractFileName(LocalDir);
  try
    IdFTP.MakeDir(AnsiToUtf8(ExtractFileName(LocalDir)));
  except
  end;
  FTPUploadDir_(IdFTP, RemoteDir, LocalDir);
end;

function FTPUploadDir(Host, Port, UserName, Password, RemoteDir, LocalDir: string): Boolean;
var
  IdFTP: TIdFTP;
begin
  Result := False;
  IdFTP := TIdFTP.Create(nil);
  try
    if FTPConnect(IdFTP, Host, Port, UserName, Password) then
      Result := FTPUploadDir(IdFTP, RemoteDir, LocalDir);
  finally
    IdFTP.Free;
  end;
end;

function FTPDownloadFile(IdFTP: TIdFTP; RemoteFileName, LocalFileName: string): Boolean;
begin
  Result := True;
  try
    if not DirectoryExists(ExtractFilePath(LocalFileName)) then
      ForceDirectories(ExtractFilePath(LocalFileName));
    IdFTP.Get(ExtractFileName(RemoteFileName), LocalFileName, True);
  except
    Result := False;
    Exit;
  end;
end;

function FTPDownloadFile(Host, Port, UserName, Password, RemoteFileName, LocalFileName: string): Boolean;
var
  IdFTP: TIdFTP;
begin
  Result := True;
  if not DirectoryExists(ExtractFilePath(LocalFileName)) then
    ForceDirectories(ExtractFilePath(LocalFileName));
  IdFTP := TIdFTP.Create(nil);
  try
    IdFTP.Host := Host;
    IdFTP.Port := StrToInt(Port);
    IdFTP.Username := UserName;
    IdFTP.Password := Password;
    try
      IdFTP.Connect;
      IdFTP.Passive := True;
    except
      Result := False;
      ShowMessage('ftp conn error');
      Exit;
    end;
    try
      IdFTP.Get(ExtractFileName(RemoteFileName), LocalFileName, True);
    except
      Result := False;
      ShowMessage('ftp down error');
      Exit;
    end;
  finally
    IdFTP.Free;
  end;
end;

function FTPDownloadFile(Host, Port, UserName, Password, RemoteFileName, LocalFileName, CurrentDir: string): Boolean;
var
  IdFTP: TIdFTP;
begin
  Result := True;
  if not DirectoryExists(ExtractFilePath(LocalFileName)) then
    ForceDirectories(ExtractFilePath(LocalFileName));
  IdFTP := TIdFTP.Create(nil);
  try
    IdFTP.Host := Host;
    IdFTP.Port := StrToInt(Port);
    IdFTP.Username := UserName;
    IdFTP.Password := Password;
    try
      IdFTP.Connect;
      IdFTP.Passive := True;
      IdFTP.ChangeDir(CurrentDir);
    except
      Result := False;
      ShowMessage('ftp conn error');
      Exit;
    end;
    try
      IdFTP.Get(ExtractFileName(RemoteFileName), LocalFileName, True);
    except
      Result := False;
      ShowMessage('ftp down error');
      Exit;
    end;
  finally
    IdFTP.Free;
  end;
end;

function FTPDownFile(Host, Port, UserName, Password, LocalFileName,CurrentDir: String; RemoteFileName: UTF8String): Boolean;
var
  IdFTP: TIdFTP;
begin
  Result := True;
  if not DirectoryExists(ExtractFilePath(LocalFileName)) then
    ForceDirectories(ExtractFilePath(LocalFileName));
  IdFTP := TIdFTP.Create(nil);
  try
    IdFTP.Host := Host;
    IdFTP.Port := StrToInt(Port);
    IdFTP.Username := UserName;
    IdFTP.Password := Password;
    try
      IdFTP.Connect;
      IdFTP.Passive := True;
      IdFTP.ChangeDir(CurrentDir);
    except
      Result := False;
      ShowMessage('ftp conn error');
      Exit;
    end;
    try
      IdFTP.Get(RemoteFileName, LocalFileName, True);
    except
      Result := False;
      ShowMessage('ftp down error');
      Exit;
    end;
  finally
    IdFTP.Free;
  end;
end;

function FTPDownloadDir(IdFTP: TIdFTP; RemoteDir, LocalDir: string): Boolean;
var
  IdFTP_: TIdFTP;
  i: Integer;
  RemoteFileName: string;
begin
  Result := True;     
  IdFTP_ := TIdFTP.Create(nil);
  try//�����������´���ftp���󣬸��ƹ�����һ��Ŀ¼�����һ��ftp��������������ݹ�ͻ�����ʱ�򣬾Ͳ��ᵼ����������
    IdFTP_.Host := IdFTP.Host;
    IdFTP_.Port := IdFTP.Port;
    IdFTP_.Username := IdFTP.Username;
    IdFTP_.Password := IdFTP.Password;
    IdFTP_.Connect;
    IdFTP_.Passive := True;        
    IdFTP_.ChangeDir(RemoteDir);//��ԭ��ftp��Ŀ¼�£��ٽ���Ŀ¼������RemoteDir��ȫ·��
    IdFTP_.TransferType := ftASCII;
    IdFTP_.List(nil);
    with IdFTP_.DirectoryListing do
    begin
      for i := 0 to Count - 1 do
      begin
        RemoteFileName := Items[i].FileName;
        if (RemoteFileName = '.') or (RemoteFileName = '..') then Continue;
        if Items[i].ItemType = ditDirectory then
        begin
          RemoteFileName := IdFTP_.RetrieveCurrentDir+'/'+RemoteFileName;
          FTPDownloadDir(IdFTP_, RemoteFileName, LocalDir);
        end
        else
        begin
//          LocalFileName := LocalDir + RemoteDir + RemoteFileName;// StringReplace(IdFTP_.RetrieveCurrentDir+'/'+RemoteFileName, '/', '\', [rfReplaceAll]);
//          IdFTP_.RetrieveCurrentDir    RemoteDir
          ShowMessage(RemoteDir+'  '+RemoteFileName       );
//          FTPDownloadFile(IdFTP_, RemoteFileName, LocalFileName);
        end;
      end;
    end;
  finally
    IdFTP_.Free;
  end;    
end;

function FTPDownloadDir(Host, Port, UserName, Password, RemoteDir, LocalDir: string): Boolean;
var
  IdFTP: TIdFTP;
begin
  Result := False;
  IdFTP := TIdFTP.Create(nil);
  try
    if FTPConnect(IdFTP, Host, Port, UserName, Password) then
      Result := FTPDownloadDir(IdFTP, RemoteDir, LocalDir);
  finally
    IdFTP.Free;
  end;
end;

function FTPDeleteFile(IdFTP: TIdFTP; RemoteFileName: string): Boolean;
begin
  Result := True;
  try
    IdFTP.Delete(RemoteFileName);
  except
    Result := False;
    Exit;
  end;
end;

function FTPDeleteFile(Host, Port, UserName, Password, RemoteFileName: string): Boolean;
var
  IdFTP: TIdFTP;
begin
  Result := False;
  IdFTP := TIdFTP.Create(nil);
  try
    if FTPConnect(IdFTP, Host, Port, UserName, Password) then
      Result := FTPDeleteFile(IdFTP, RemoteFileName);
  finally
    IdFTP.Free;
  end;
end;

function FTPDeleteFile(Host, Port, UserName, Password, RemoteFileName, CurrentDir: string): Boolean;
var
  IdFTP: TIdFTP;
begin
  Result := False;
  IdFTP := TIdFTP.Create(nil);
  try
    if FTPConnect(IdFTP, Host, Port, UserName, Password) then
      begin
        IdFTP.ChangeDir(CurrentDir);
        Result := FTPDeleteFile(IdFTP, RemoteFileName);
      end;
  finally
    IdFTP.Free;
  end;
end;

function FTPDelFile(Host, Port, UserName, Password, CurrentDir: string; RemoteFileName: UTF8String): Boolean;
var
  IdFTP: TIdFTP;
begin
  Result := False;
  IdFTP := TIdFTP.Create(nil);
  try
    if FTPConnect(IdFTP, Host, Port, UserName, Password) then
      begin
        IdFTP.ChangeDir(CurrentDir);
        Result := FTPDeleteFile_u(IdFTP, RemoteFileName);
      end;
  finally
    IdFTP.Free;
  end;
end;

function FTPDeleteDir(IdFTP: TIdFTP; RemoteDir: string): Boolean;
  function FTPDeleteDir_(IdFTP: TIdFTP; RemoteDir: string): Boolean;
  var
    i,DirCount: Integer;
    strName: string;
  begin
    Result := True;
    IdFTP.List(nil);
    DirCount := IdFTP.DirectoryListing.Count;
    if DirCount = 2 then
    begin
      IdFTP.ChangeDir('..');
      IdFTP.RemoveDir(RemoteDir);
      IdFTP.List(nil);
      Application.ProcessMessages;
      Exit;
    end;
    for i := 0 to 2 do
    begin
      strName := IdFTP.DirectoryListing.Items[i].FileName;
      if IdFTP.DirectoryListing.Items[i].ItemType = ditDirectory then
      begin
        if (strName = '.') or (strName = '..') then
          Continue;
        IdFTP.ChangeDir(strName);
        FTPDeleteDir(idFTP,strName);
        FTPDeleteDir(idFTP,RemoteDir);
      end
      else
      begin
        IdFTP.Delete(strName);
        Application.ProcessMessages;
        FTPDeleteDir(idFTP,RemoteDir);
      end;
    end;
  end;
var
  i: Integer;
  DirExist: Boolean;
begin
  Result := True;
  //���Ŀ¼�����ڣ���ֱ�ӷ���True
  DirExist := False;
  for i := 0 to IdFTP.DirectoryListing.Count - 1 do
  begin      
    if UpperCase(IdFTP.DirectoryListing.Items[i].FileName) = UpperCase(RemoteDir) then
    begin
      DirExist := True;
      Break;
    end;
  end;
  if not DirExist then Exit;
  
  Result := FTPDeleteDir_(IdFTP, RemoteDir);
end;

function FTPDeleteDir(Host, Port, UserName, Password, RemoteDir: string): Boolean;
var
  IdFTP: TIdFTP;
begin
  Result := False;
  IdFTP := TIdFTP.Create(nil);
  try
    if FTPConnect(IdFTP, Host, Port, UserName, Password) then
      Result := FTPDeleteDir(IdFTP, RemoteDir);
  finally
    IdFTP.Free;
  end;
end;

function GetWinTempPath: String;
var
  TempDir:array [0..255] of char;
begin
  GetTempPath(255,@TempDir);
  Result:=strPas(TempDir);
end;

function FTPDeleteFile_u(IdFTP: TIdFTP; RemoteFileName: UTF8String): Boolean;
begin
  Result := True;
  try
    IdFTP.Delete(RemoteFileName);
  except
    Result := False;
    Exit;
  end;
end;

end.

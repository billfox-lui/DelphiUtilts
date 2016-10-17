{Remark: �˵�Ԫ����д���̨��־�ļ�}
{Author: audix.tc.paul 2012-08-07}

unit UntLog;

interface

uses Dialogs, SysUtils;

  //function MakeDir:Boolean;                {����LogĿ¼}
  //procedure NewLogFile;                    {����ÿ�����־�ļ�}
  procedure AppendLogItem(Str:String);     {����־�ļ������Ŀ}

implementation

function MakeDir:Boolean;
var
  Path_Str: String;
  Dir_Str: String;
begin
  try
    GetDir(0,Path_Str);
    Dir_Str := Path_Str + '\Log';
    if not DirectoryExists(Dir_Str) then
      Result := CreateDir(Dir_Str)
    else
      Result := True;
  except
    {��ʷ��־��¼����Ҫ������ʧ�ܲ����κδ�����Ϊ�Ǿ�Ĭִ��}
    Result := False;
  end;
end;

procedure NewLogFile;
var
  F: Textfile;
  FileName: String;
  Path_Str: String;
  Dir_Str: String;
begin
  try
    GetDir(0,Path_Str);
    Dir_Str := Path_Str + '\Log';
    FileName := Dir_Str+'\'+FormatDateTime('yyyy-mm-dd',Now)+'.txt';
    if not FileExists(FileName) then
    begin
      AssignFile(F, FileName);
      ReWrite(F);
      Writeln(F, '���տ�����־���£�');
      Closefile(F);
    end;
  except
    {��ʷ��־��¼����Ҫ������ʧ�ܲ����κδ�����Ϊ�Ǿ�Ĭִ��}
  end;
end;

procedure AppendLogItem(Str:String);
var
  F: Textfile;
  FileName: String;
  Path_Str: String;
  Dir_Str: String;
begin
  try
    if not MakeDir then exit;
    GetDir(0,Path_Str);
    Dir_Str := Path_Str + '\Log';
    FileName := Dir_Str+'\'+FormatDateTime('yyyy-mm-dd',Now)+'.txt';
    if not FileExists(FileName) then NewLogFile;
    AssignFile(F, FileName);
    Append(F);
    Writeln(F, Str);
    Closefile(F);
  except
    {��ʷ��־��¼����Ҫ������ʧ�ܲ����κδ�����Ϊ�Ǿ�Ĭִ��}
  end;
end;

procedure OpenTxt(FileName:String);
var
  F: Textfile;
begin
  AssignFile(F,FileName);
  Append(F);
  Writeln(F, '����Ҫд����ı�д�뵽һ�� .txt �ļ�');
  Closefile(F);
end;

procedure ReadTxt(FileName:String);{ TODO -oPaul : ��ʱ�ò��� }
var
  F: Textfile;
  str: String;
begin
  AssignFile(F, FileName);
  Reset(F);
  Readln(F, str);
  ShowMessage('�ļ���:' + str + '��');
  Closefile(F);                                       
end;

end.

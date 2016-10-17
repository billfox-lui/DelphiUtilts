{Remark: 此单元用来写入后台日志文件}
{Author: audix.tc.paul 2012-08-07}

unit UntLog;

interface

uses Dialogs, SysUtils;

  //function MakeDir:Boolean;                {创建Log目录}
  //procedure NewLogFile;                    {产生每天的日志文件}
  procedure AppendLogItem(Str:String);     {向日志文件添加项目}

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
    {历史日志记录不重要，运行失败不做任何处理，因为是静默执行}
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
      Writeln(F, '今日考勤日志如下：');
      Closefile(F);
    end;
  except
    {历史日志记录不重要，运行失败不做任何处理，因为是静默执行}
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
    {历史日志记录不重要，运行失败不做任何处理，因为是静默执行}
  end;
end;

procedure OpenTxt(FileName:String);
var
  F: Textfile;
begin
  AssignFile(F,FileName);
  Append(F);
  Writeln(F, '将您要写入的文本写入到一个 .txt 文件');
  Closefile(F);
end;

procedure ReadTxt(FileName:String);{ TODO -oPaul : 暂时用不到 }
var
  F: Textfile;
  str: String;
begin
  AssignFile(F, FileName);
  Reset(F);
  Readln(F, str);
  ShowMessage('文件有:' + str + '行');
  Closefile(F);                                       
end;

end.

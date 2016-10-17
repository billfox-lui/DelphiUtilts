{**************************************************************
 Remark: 此单元为程序使用到的公用函数
 Author: audix.tc.paul 2012-08-07
 Log:
    #01. paul-2016/04/18 add function GetWinTempPath
    #02. paul-2016/05/13 add function GetGUID
    #03. paul-2016/05/16 add function AddLeadingZeroes,LPad
    #04. paul-2016/09/27 add funciton CurrPath
***************************************************************}

unit UntUtility;

interface
uses  IniFiles, SysUtils, Forms, StrUtils, DBGrids, ComObj, Dialogs, Controls, Variants, Windows;

procedure CreateIniFile;                                           {创建ini文件}
function ReadIniStr(Section, Ident: String):string;                {从Ini文件读取字符串}
function ReadIniInt(Section, Ident: String):Integer;               {从Ini文件读取整数}
procedure WriteIniStr(Section, Ident,Value: String);               {写入字符串到Ini文件}
function EncryptStr(Str:String):String;overload;                   {字符加密函數1}
function DecryptStr(Str:String):String;overload;                   {字符解密函數1}
function EncryptStr(const S: String; Key: Word): String;overload;  {字符加密函數2}
function DecryptStr(const S: String; Key: Word): String;overload;  {字符解密函數2}
function GetWinTempPath: String;                                   {获取windows临时文件夹} 
function GetGUID: String;                                          {产生一个GUID}
function AddLeadingZeroes(const aNumber, Length: integer): string; {整型数前面补充0}
function LPad(AString: String; AFillChar: Char; ALen: Integer): String; {字符串前面补充0}
function CurrPath: String;    {当前系统路径}


implementation

const iniFileName = 'Express.ini';
const XorKey:array[0..7] of Byte=($A1,$B7,$AC,$57,$1C,$63,$3B,$81); //字符串加密用
const C1 = 53761;
      C2 = 32618;

procedure CreateIniFile;
var
  F: Textfile;
  FileName: String;
  Path_Str: String;
  Dir_Str: String;
begin
  try
    GetDir(0,Path_Str);
    Dir_Str := Path_Str;
    FileName := Dir_Str+'\'+iniFileName;
    if not FileExists(FileName) then
    begin
      AssignFile(F, FileName);
      ReWrite(F);
      Closefile(F);
    end;
  except
    //运行失败不做任何处理，因为是静默执行
  end;
end;

function ReadIniStr(Section, Ident: String):string;
var
  MyIniFile: TInIFile;
  strReturn: String;
begin
  MyIniFile := TIniFile.Create(CurrPath+iniFileName);
  strReturn := MyIniFile.ReadString(Section, Ident, '');
  MyIniFile.Free;
  Result := strReturn;
end;

function ReadIniInt(Section, Ident: String):Integer;
var
  MyIniFile: TInIFile;
  intReturn: Integer;
begin
  MyIniFile := TIniFile.Create(CurrPath+iniFileName);
  intReturn := StrToInt(MyIniFile.ReadString(Section, Ident, '-1'));
  MyIniFile.Free;
  Result := intReturn;
end;

procedure WriteIniStr(Section, Ident,Value: String);
var
  MyIniFile: TInIFile;
begin
  MyIniFile := TIniFile.Create(CurrPath+iniFileName);
  MyIniFile.WriteString(Section, Ident, Value);
  MyIniFile.Free;
end;

function EncryptStr(Str:String):String;overload;
var
i,j:Integer;
begin
Result:='';
j:=0;
for i:=1 to Length(Str) do
   begin
     Result:=Result+IntToHex(Byte(Str[i]) xor XorKey[j],2);
     j:=(j+1) mod 8;
   end;
end;

function DecryptStr(Str:String):String;overload;
var
i,j:Integer;
begin
Result:='';
j:=0;
for i:=1 to Length(Str) div 2 do
   begin
     Result:=Result+Char(StrToInt('$'+Copy(Str,i*2-1,2)) xor XorKey[j]);
     j:=(j+1) mod 8;
   end;
end;

function EncryptStr(const S: String; Key: Word): String;overload;
var I: Integer;
begin
  Result := S;
  for I := 1 to Length(S) do begin
    Result[I] := char(byte(S[I]) xor (Key shr 8));
    Key := (byte(Result[I]) + Key) * C1 + C2;
  end;
end;

function DecryptStr(const S: String; Key: Word): String;overload;
var I: Integer;
begin
  Result := S;
  for I := 1 to Length(S) do begin
   Result[I] := char(byte(S[I]) xor (Key shr 8));
   Key := (byte(S[I]) + Key) * C1 + C2;
  end;
end;

function GetWinTempPath: String;
var
  TempDir:array [0..255] of char;
begin
  GetTempPath(255,@TempDir);
  Result:=strPas(TempDir);
end;

function GetGUID: String;
var
  tmpGUID: TGUID;
  tmpStr: String;
begin
   CreateGUID(tmpGUID);
   tmpStr := GUIDToString(tmpGUID);
   tmpStr := StringReplace(tmpStr,'-','',[rfReplaceAll]);
   result := Copy(tmpStr,2,Length(tmpStr)-2);
end;

function AddLeadingZeroes(const aNumber, Length : integer) : string;
begin
   result := Format('%.*d', [Length, aNumber]) ;
end;

function LPad(AString : String; AFillChar : Char; ALen : Integer) : String;
begin
  result := AString;
  while Length(result) < ALen Do Result := AFillChar + result;
end;

function CurrPath: String;
begin
  result := ExtractFilePath(Application.ExeName);
end;

end.

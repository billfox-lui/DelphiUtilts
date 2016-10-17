{**************************************************************
 Remark: �˵�ԪΪ����ʹ�õ��Ĺ��ú���
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

procedure CreateIniFile;                                           {����ini�ļ�}
function ReadIniStr(Section, Ident: String):string;                {��Ini�ļ���ȡ�ַ���}
function ReadIniInt(Section, Ident: String):Integer;               {��Ini�ļ���ȡ����}
procedure WriteIniStr(Section, Ident,Value: String);               {д���ַ�����Ini�ļ�}
function EncryptStr(Str:String):String;overload;                   {�ַ����ܺ���1}
function DecryptStr(Str:String):String;overload;                   {�ַ����ܺ���1}
function EncryptStr(const S: String; Key: Word): String;overload;  {�ַ����ܺ���2}
function DecryptStr(const S: String; Key: Word): String;overload;  {�ַ����ܺ���2}
function GetWinTempPath: String;                                   {��ȡwindows��ʱ�ļ���} 
function GetGUID: String;                                          {����һ��GUID}
function AddLeadingZeroes(const aNumber, Length: integer): string; {������ǰ�油��0}
function LPad(AString: String; AFillChar: Char; ALen: Integer): String; {�ַ���ǰ�油��0}
function CurrPath: String;    {��ǰϵͳ·��}


implementation

const iniFileName = 'Express.ini';
const XorKey:array[0..7] of Byte=($A1,$B7,$AC,$57,$1C,$63,$3B,$81); //�ַ���������
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
    //����ʧ�ܲ����κδ�����Ϊ�Ǿ�Ĭִ��
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

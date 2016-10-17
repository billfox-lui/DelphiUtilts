unit UntMd5;

interface

uses
  IdHashMessageDigest, IdHash, IdGlobal;

type
  TMD5 = class(TIdHashMessageDigest5);

function StrToMD5(S: String): String; overload;
function StrToMD516(S: String; L: integer): String; overload; //����16λMD5ֵ
function StrToMD532(S: String; L: integer): String; overload; //����32λMD5ֵ

implementation
function StrToMD5(S: String): String;
var
  Md5Encode: TMD5;
begin
  Md5Encode:= TMD5.Create;
  result:= Md5Encode.AsHex(Md5Encode.HashValue(S));
  Md5Encode.Free;
end;

function StrToMD516(S: String; L: integer): String;
begin
  result:= copy(StrToMD5(S),9,L);
end;

function StrToMD532(S: String; L: integer): String; overload;
begin
  result:= copy(StrToMD5(S),1,L);
end;

end.

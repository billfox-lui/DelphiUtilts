{*******************************************************************
  Remark������ܺ�����Ԫ
  Author: tc.paul 2012-08-27
  Modify: 20150929 add NewRoundTo���Delphi�����������в�׼ȷ������
          20151013 add SplitString���delphi�����split�пո������
*******************************************************************}

unit UntMISC;

interface

uses
  StrUtils, Classes, SysUtils, StdCtrls, Math;

  function DateQBEValid(strSource: String; out strRtn: String): Boolean; {�鿴�û����������QBE�Ƿ���Ч����ת��Ϊ��׼��ʽ}
  function AllISDigit(strTmp: String): Boolean;                          {�ж�һ���ַ����Ƿ�ȫ�������������}
  function IsValidDateStr(strTmp: String; out Value: String): Boolean;   {�ж�һ���ַ����Ƿ�����Ч����������}
  function SubStrConut(mStr, mSub: string): Integer;                     {����mSub�ַ�����mStr�ַ����еĸ���}
  function DateQBEList(strSource: String; Separator: char; out Value: String): Boolean; {����:����|�ָ����������͵�QBEת��Ϊ��׼��ʽ}
  function IsInt(ASource: String; out RtnValue: String): Boolean;        {�ж��ַ����Ƿ�����Ч��������}
  function IntQBEList(strSource: String; Separator: char; out Value: String): Boolean;
  function IntQBEValid(strSource: String; out strRtn: String): Boolean;                {�����ֶε�QBE�����Ƿ���ȷ}
  function IsValidTimeStr(ASource: String; out TimeStr: String): Boolean;   {�ж�һ���ַ����Ƿ�����Ч��ʱ���ʽ}
  function ComboboxValue(AComboBox: TComboBox): String;
  function ReplaceString(ASource: String): String;
  function IsFloat(ASource: String; out RtnValue: String): Boolean;      {�ж�һ���ַ����Ƿ�����Ч�ĸ�����}
  function NewRoundTo(const AValue: double; const ADigit: TRoundToRange): Double;     {�¸Ľ����������뺯��}
  procedure SplitString(Source,Deli:string; var StringList :TStringList);  {�Զ�������ַ�����TStringList,�����˱�׼����ո������}
  
implementation

function DateQBEValid(strSource: String; out strRtn: String): Boolean;
var
  strTemp: String;
  c1,c2: Char;
begin
  Result := False;
  strTemp := AnsiReplaceStr(strSource,' ','');
  if strTemp = '' then
  begin
    Result := True;
    Exit;
  end;
  if strTemp = '<>' then
  begin
    strRtn := '<>';
    Result := True;
    Exit;
  end;

  if Length(strTemp) < 6 then Exit;

  c1 := strTemp[1];
  if c1 in ['0'..'9'] then   //��һ����ĸ������
    begin
      if SubStrConut(strTemp,':')>1 then Exit;
      if SubStrConut(strTemp,'|') > 0 then if SubStrConut(strTemp,':')>0 then Exit;
      if SubStrConut(strTemp,':') >0 then
        if DateQBEList(strTemp,':',strRtn) then
        begin
          Result := True;
          Exit;
        end;
      if SubStrConut(strTemp,'|') >0 then
        if DateQBEList(strTemp,'|',strRtn) then
        begin
          Result := True;
          Exit;
        end;
      Result := IsValidDateStr(strTemp,strRtn)
    end
  else                       //��һ����ĸ��������
    begin
      if not (c1 in ['=','>','<']) then Exit;

      if c1 = '=' then
      begin
        if IsValidDateStr(RightStr(strTemp,Length(strTemp)-1),strRtn) then
          begin
            strRtn := c1 + strRtn;
            Result := True;
          end;
        Exit;
      end;

      if c1 = '>' then
      begin
        c2 := strTemp[2];
        if c2 <> '=' then
          begin
            if IsValidDateStr(RightStr(strTemp,Length(strTemp)-1),strRtn) then
              begin
                strRtn := c1 + strRtn;
                Result := True;
              end;
            Exit;
          end
        else
          begin
            if IsValidDateStr(RightStr(strTemp,Length(strTemp)-2),strRtn) then
              begin
                strRtn := c1 + c2 + strRtn;
                Result := True;
              end;
            Exit;
          end;
      end;

      if c1 = '<' then
      begin
        c2 := strTemp[2];
        if c2 in ['=','>'] then
          if IsValidDateStr(RightStr(strTemp,Length(strTemp)-2),strRtn) then
            begin
              strRtn := c1 + c2 + strRtn;
              Result := True;
            end;
        if not (c2 in ['=','>']) then
          if IsValidDateStr(RightStr(strTemp,Length(strTemp)-1),strRtn) then
            begin
              strRtn := c1 + c2 + strRtn;
              Result := True;
            end;
      end;
    end;
end;

function DateQBEList(strSource: String; Separator: char; out Value: String): Boolean;
var
  i: Integer;
  strDate: String;
begin
  Result := True;
  Value := '';
  with TStringList.Create do
  try
    Delimiter := Separator;
    DelimitedText := strSource;
    for i := 0 to Count - 1 do
      if IsValidDateStr(Strings[i],strDate) then
        if i = 0 then Value := strDate else Value := Value + Separator + strDate
      else
        begin
          Result := False;
          Break;
        end;
  finally
    Free;
  end;
end;

function AllISDigit(strTmp: String): Boolean;
var
  i: Integer;
  c: Char;
begin
  Result := True;
  for i := 1 to Length(strTmp) do
  begin
    c := strTmp[i];
    if not (c in ['0'..'9']) then
    begin
      Result := False;
      Break;
    end;
  end;
end;

function IsValidDateStr(strTmp: String; out Value: String): Boolean;
var
  str1: String;
  len: Integer;
  Date1: TDatetime;
  fs: TFormatSettings;
  c1,c2: Char;
  ymd: String;
begin
  Result := False;
  fs.ShortDateFormat := 'yyyy'+DateSeparator+'mm'+DateSeparator+'dd';
  fs.DateSeparator := DateSeparator;
  ymd := 'yyyy'+DateSeparator+'mm'+DateSeparator+'dd';
  str1 := Trim(strTmp);
  len := Length(str1);
  if not (len in [6,8,10]) then Exit;
  case len of
    6:
      begin
        str1 := '20' + LeftStr(str1,2)+DateSeparator +MidStr(str1,3,2)+DateSeparator+RightStr(str1,2);
        Result := TryStrToDate(str1,Date1,fs);
        Value := FormatDateTime(ymd,Date1,fs);
      end;
    8:
      if AllIsDigit(str1) then
        begin
          str1 := LeftStr(str1,4)+DateSeparator +MidStr(str1,5,2)+DateSeparator+RightStr(str1,2);
          Result := TryStrToDate(str1,Date1,fs);
          Value := FormatDateTime(ymd,Date1,fs);
        end
      else
        begin
          str1 :='20'+LeftStr(str1,2)+DateSeparator+MidStr(str1,4,2)+DateSeparator+RightStr(str1,2);
          Result := TryStrToDate(str1,Date1,fs);
          Value := FormatDateTime(ymd,Date1,fs);
        end;
    10:
      begin
        c1 := str1[5];
        c2 := str1[8];
        if (c1 in ['|','0'..'9']) or (c2 in ['|','0'..'9']) then
          Result := False
        else
          begin
            str1 := LeftStr(str1,4)+DateSeparator+MidStr(str1,6,2)+DateSeparator+RightStr(str1,2);
            Result := TryStrToDate(str1,Date1,fs);
            Value := FormatDateTime(ymd,Date1,fs);
          end;
      end;
  end;
end;

function SubStrConut(mStr, mSub: string): Integer; //����mSub�ַ�����mStr�ַ����еĸ���
begin
  Result := (Length(mStr) - Length(StringReplace(mStr,mSub,'',[rfReplaceAll]))) div Length(mSub);
end;

function IsInt(ASource: String; out RtnValue: String): Boolean;
var
  intTmp: Integer;
begin
  Result := TryStrToInt(ASource,intTmp);
  if Result then RtnValue := IntToStr(intTmp) else RtnValue := '';
end;

function IsFloat(ASource: String; out RtnValue: String): Boolean;
var
  dblTmp: Double;
begin
  Result := TryStrToFloat(ASource,dblTmp);
  if result then RtnValue := FloatToStr(dblTmp) else RtnValue := '';
end;

function IntQBEValid(strSource: String; out strRtn: String): Boolean;
var
  strTemp: String;
  c1,c2: Char;
begin
  Result := False;
  strTemp := AnsiReplaceStr(strSource,' ','');
  if strTemp = '' then
  begin
    Result := True;
    Exit;
  end;

  c1 := strTemp[1];
  if c1 in ['0'..'9'] then   //��һ����ĸ������
    begin
      if SubStrConut(strTemp,':')>1 then Exit;
      if SubStrConut(strTemp,'|') > 0 then if SubStrConut(strTemp,':')>0 then Exit;
      if SubStrConut(strTemp,':') >0 then
        if IntQBEList(strTemp,':',strRtn) then
        begin
          Result := True;
          Exit;
        end;
      if SubStrConut(strTemp,'|') >0 then
        if IntQBEList(strTemp,'|',strRtn) then
        begin
          Result := True;
          Exit;
        end;
      Result := IsInt(strTemp,strRtn);
    end
  else                       //��һ����ĸ��������
    begin
      if not (c1 in ['=','>','<']) then Exit;
      if Length(strTemp)<2 then Exit;
      if c1 = '=' then
      begin
        if IsInt(RightStr(strTemp,Length(strTemp)-1),strRtn) then
          begin
            strRtn := c1 + strRtn;
            Result := True;
          end;
        Exit;
      end;

      if c1 = '>' then
      begin
        c2 := strTemp[2];
        if c2 <> '=' then
          begin
            if IsInt(RightStr(strTemp,Length(strTemp)-1),strRtn) then
              begin
                strRtn := c1 + strRtn;
                Result := True;
              end;
            Exit;
          end
        else
          begin
            if Length(strTemp)<3 then Exit;
            if IsInt(RightStr(strTemp,Length(strTemp)-2),strRtn) then
              begin
                strRtn := c1 + c2 + strRtn;
                Result := True;
              end;
            Exit;
          end;
      end;

      if c1 = '<' then
      begin
        c2 := strTemp[2];
        if c2 in ['=','>'] then
        begin
          if (c2 = '>') and (Length(strTemp) = 2) then
          begin
            strRtn := c1 + c2;
            Result := True;
            Exit;
          end;
          if Length(strTemp)<3 then Exit;
          if IsInt(RightStr(strTemp,Length(strTemp)-2),strRtn) then
            begin
              strRtn := c1 + c2 + strRtn;
              Result := True;
            end;
         end;
        if not (c2 in ['=','>']) then
          if IsInt(RightStr(strTemp,Length(strTemp)-1),strRtn) then
            begin
              strRtn := c1 + strRtn;
              Result := True;
            end;
      end;
    end;
end;

function IntQBEList(strSource: String; Separator: char; out Value: String): Boolean;
var
  i: Integer;
  intReturn: String;
begin
  Result := True;
  Value := '';
  with TStringList.Create do
  try
    Delimiter := Separator;
    DelimitedText := strSource;
    for i := 0 to Count - 1 do
      if IsInt(Strings[i],intReturn) then
        if i = 0 then Value := intReturn else Value := Value + Separator + intReturn
      else
        begin
          Result := False;
          Break;
        end;
  finally
    Free;
  end;
end;

function IsValidTimeStr(ASource: String; out TimeStr: String): Boolean;   //�ж�һ���ַ����Ƿ�����Ч��ʱ���ʽ
begin
  Result := False;
  ASource := Trim(ASource);
  TimeStr := ASource;
  if Length(ASource) <> 5 then Exit;
  if not (ASource[1] in ['0'..'9']) then Exit;
  if not (ASource[2] in ['0'..'9']) then Exit;
  if ASource[3] <> ':' then Exit;
  if not (ASource[4] in ['0'..'9']) then Exit;
  if not (ASource[5] in ['0'..'9']) then Exit;
  if StrToInt(LeftStr(ASource,2))>23 then Exit;
  if StrToInt(RightStr(ASource,2))>59 then Exit;
  Result := True;
end;

function ComboboxValue(AComboBox: TComboBox): String;
begin
  if Trim(AComboBox.Text)='' then
    Result:=''
  else
    Result := LeftStr(AComboBox.Text,Pos(':',AComboBox.Text) - 1);
end;

function ReplaceString(ASource: String): String;
begin
  if Pos(#13#10,ASource) > 0 then
    Result := ASource
  else
    Result := AnsiReplaceStr(ASource,#10,#13#10);
end;

function ToUTF8Encode(str: string): string;
var
  u:UTF8String;
  ss:string;
  Len,i:Integer;
begin
  Result:='';
  u:=AnsiToUTF8(str);
  Len := Length(u);
  SetLength(ss, Len shl 1);
  BinToHex(PChar(u), PChar(ss), Len);
  for i:=1 to (Len shl 1) do
  begin
    if (i mod 2) = 0 then
    begin
      Result:=Result+ss[i];
    end
    else
      Result:=Result+'%'+ss[i];
  end;
end;

function IsVeryNear1(f: double): boolean;
var    // �жϸ���ʵ����С�������Ƿ����޽ӽ�1�����ݸ������Ĵ洢��ʽ���ж�
  zs, i:integer;
  arr: array [1..8] of byte;
  pb: Pbyte;
  pfInt: Pint64;
  fInt, tmp1, tmp2:int64;
  p: Pointer;
begin
  p := @f;
  pb := Pbyte(p);
  for i := 1 to 8 do
  begin
    arr[9 - i] := pb^;
    inc(pb);
  end;
  zs := ((arr[1] and $7f) shl 4) + ((arr[2] and $F0) shr 4) - 1023; //��������ָ��
  if zs < -1 then   // С������ǰ��λȫ��������
  begin
    result := false;
    Exit;
  end;
  pfInt := PInt64(p);
  fInt := pfInt^;
  fInt := ((fInt and $000fffffffffffff) or $0010000000000000);
  if (zs = -1) then
  begin
    if fInt = $001fffffffffffff then result := true
    else result := false;
  end
  else begin
    tmp1 := $000fffffffffffff;
    tmp2 := $001fffffffffffff;
    for i := 0 to zs do
    begin
      tmp2 := (tmp2 and tmp1);
      tmp1 := (tmp1 shr 1);
    end;
    if ((fInt and tmp2) = tmp2) then  result := true // ��С������ȫ��Ϊ1ʱ�����ΪС�����޽ӽ�1
    else result := false;
  end;
end;

// �µĸĽ����������뺯��
function NewRoundTo(const AValue: double; const ADigit: TRoundToRange): Double;
var
  ef:  double;
  i, n: integer;
  a1, intV: int64;
  f_sign: boolean;
begin
  Result := 0;
  if AValue = 0 then begin
    Result := 0;
    Exit;
  end;
  if ADigit < 0 then // ��ԼС����֮���С��λ
  begin
    if AValue > 0 then f_sign := true  // ����
    else f_sign := false;              // ����
    a1 := 1;
    for i := 1 to (-ADigit) do a1 := a1 * 10;
    ef := abs(AValue * a1 * 10);
    intV := trunc(ef);
    if isVeryNear1(ef) then inc(intV);  // ��һ���ǹؼ�
    n := (intV mod 10);
    if (n > 4) then  intV := intV - n + 10
    else intV := intV - n;
    if f_sign then  ef := intV/(a1*10)
    else ef := -1.0*intV/(a1*10);
    result := ef;
    exit;
  end;
  if ADigit = 0 then
  begin
    if frac(AValue) >= 0.5 then ef := trunc(AValue) + 1
    else ef := trunc(AValue);
    result := ef;
    exit;
  end;
  if ADigit > 0 then
  begin
    result := roundTo(AValue, ADigit);
    exit;
  end;
end;

{
  �������ܣ�ʹ���Զ���ָ��������ַ�������Stringlist����
  ����˵����
  Source: Դ�ַ���
  Deli: �Զ�������
  StringList: ���ط�����
}
procedure SplitString(Source,Deli:string; var StringList :TStringList);
var
  EndOfCurrentString: Integer;
begin
  if StringList = nil then exit;
  StringList.Clear;
  while Pos(Deli, Source)>0 do
  begin
    EndOfCurrentString := Pos(Deli, Source);
    StringList.add(Copy(Source, 1, EndOfCurrentString - 1));
    Source := Copy(Source, EndOfCurrentString + length(Deli), length(Source) - EndOfCurrentString);
  end;
  StringList.Add(source);
end;


end.

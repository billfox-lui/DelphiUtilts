{
  Author: tc.paul 2015/09/29
  Remark: Delphi 本程序数据库常用操作封装单元 Data Access Layer
}

unit UntDAL;

interface

uses StrUtils, ADODB, DB, SysUtils;

function SfbIsValid(l_sfb01,l_sfb97,l_sfb05: String; var Query: TADOQuery): Boolean;
function MoldDateIsValid(workorder,strTmp: String; var Query: TADOQuery): Boolean;
function MoldQtyIsValid(workorder,strTmp: String; var Query: TADOQuery): Boolean;
function RecordIsRepeat(l_tc_sfi04,l_tc_sfi14,l_tc_sfi13,l_tc_sfi11,l_tc_sfi15:String; var Query: TADOQuery):Boolean;
function GetDeviceTime(l_tc_sfi17,l_tc_sfi08,l_tc_sfi12: String; var Query: TADOQuery):Double;
function GetDocNo(const pre,inputdate: String; var Query: TADOQuery): String;

implementation

uses UntDBHelper, UntMsg, UntMISC;

var
  strSQL: String;

///维护新的现品票时，必须先维护同一料号编号小的工单
///para1:sfb01 工单号码
///para2:sfb97 模具编号
///para3:sfb05 产品编号
function SfbIsValid(l_sfb01,l_sfb97,l_sfb05: String; var Query: TADOQuery): Boolean;
var
  l_str1,l_str2: String;
begin
  result := true;
  l_str1 := RightStr(l_sfb01,8);
  l_str2 := LeftStr(l_sfb01,4);
  strSQL := 'SELECT min(sfb01) FROM sfb_file '+
            'WHERE sfb05 = "'+l_sfb05+'"'+
            '  AND sfb87 = "Y"'+
            '  AND sfb97 = "'+l_sfb97+'"'+
            '  AND substr(sfb01,1,4) = "'+l_str2+'"'+
            '  AND sfb04 !="8"'+
            '  AND sfb01 in ('+
            '      SELECT sfb01 FROM ('+
            '           SELECT sfb01,sfb08,nvl(sum(tc_sfi08),0) AS a '+
            '           FROM tc_sfi_file,sfb_file '+
            '           WHERE sfb01=tc_sfi04(+) '+
            '             AND sfb05 = "'+l_sfb05+'"'+
            '             AND sfb97 = "'+l_sfb97+'"'+
            '             AND sfb87 = "Y" '+
            '             AND substr(sfb01,1,4) = "'+l_str2+'"' +
            '             AND sfb04 != "8" '+
            '           GROUP BY sfb01,sfb08) '+
            '      WHERE sfb08-a>0) '+
            'ORDER BY 1';
  OpenDS(strSQL,Query);
  Query.First;
  while not Query.Eof do
  begin
    if l_str1 > RightStr(Query.Fields[0].AsString,8) then
    begin
      ShowErrMsg('工单号【'+Query.Fields[0].AsString+'】比当前工单编号小，请先输该工单现品票!');
      result := false;
      break;
    end;
    Query.Next;
  end;
  Query.Close;
end;

///判断成型时间是否正确
function MoldDateIsValid(workorder,strTmp: String; var Query: TADOQuery): Boolean;
var
  l_sfb81: String;
  tmpInt: Integer;
  l_yy,l_mm,l_dd: Word;
  fs: TFormatSettings;                 
begin
  result := true;
  if workorder = '' then Exit;
  fs.ShortDateFormat := 'yyyy'+DateSeparator+'mm'+DateSeparator+'dd';
  fs.DateSeparator := DateSeparator;
  //1.成型日期不能小于工单开立日期
  strSQL := 'SELECT to_char(sfb81,"YYYY/MM/DD") FROM sfb_file WHERE sfb01="'+workorder+'"';
  ExecuteScalar(strSQL,Query,l_sfb81);
  if strTmp < l_sfb81 then
  begin
    ShowErrMsg('成型(成会)日期['+strTmp+']不可早于工单开立日期['+l_sfb81+'],'+#13+#10+'请重新录入!');
    result:= false;
    Exit;
  end;
  //2.不可大于现行年月
  strSQL := 'SELECT sma51*12+sma52 FROM sma_file where sma00="0"';
  ExecuteScalar(strSQL,Query,tmpInt);
  DecodeDate(StrToDate(strTmp,fs),l_yy,l_mm,l_dd);
  if (l_yy*12+l_mm) > tmpInt then
  begin
    ShowErrMsg('成型(成会)年月['+IntToStr(l_yy)+'年'+IntToStr(l_mm)+'月]不可晚于现行年月, 请重新录入!');
    result:= false;
    Exit;
  end;
end;

///判断成型数量是否已经超出工单总数量（如果数量不允许录入的话，就要在保存的时候再判断一次)
function MoldQtyIsValid(workorder,strTmp: String; var Query: TADOQuery): Boolean;
var
  l_sfb08,l_tc_sfi08_s: Double;
begin
  result := true;
  if workorder = '' then Exit;
  //1.获取工单数量
  strSQL := 'SELECT sfb08 FROM sfb_file WHERE sfb01="'+workorder+'"';
  ExecuteScalar(strSQL,Query,l_sfb08);
  if l_sfb08 < 0 then l_sfb08 := 0;
  //2.获取已经录入数量
  strSQL := 'SELECT sum(tc_sfi08) FROM tc_sfi_file ' +
            'WHERE tc_sfi04="'+workorder+'"'+
            '  AND tc_sficonf!="X" AND tc_sfiacti!="N"';
  ExecuteScalar(strSQL,Query,l_tc_sfi08_s);
  if l_tc_sfi08_s < 0 then l_tc_sfi08_s := 0;
  l_tc_sfi08_s := l_tc_sfi08_s+StrToInt(strTmp);
  if l_tc_sfi08_s > l_sfb08 then
  begin
    ShowErrMsg('成型总数量['+FloatToStr(l_tc_sfi08_s)+']已经超出工单总数量['+FloatToStr(l_sfb08)+'],请确认!, 请重新录入!');
    result:= false;
    Exit;
  end;
end;

///保存前要查看一下数据是否重复
function RecordIsRepeat(l_tc_sfi04,l_tc_sfi14,l_tc_sfi13,l_tc_sfi11,l_tc_sfi15:String; var Query: TADOQuery):Boolean;
var
  l_cnt: Integer;
begin
  result := false;
  strSQL := 'SELECT COUNT(*) FROM tc_sfi_file '+
            'WHERE tc_sfi04="'+l_tc_sfi04+'"'+
            '  AND tc_sfi14="'+l_tc_sfi14+'"'+
            '  AND tc_sfi13="'+l_tc_sfi13+'"'+
            '  AND tc_sfi11="'+l_tc_sfi11+'"'+
            '  AND tc_sfi15 LIKE "'+l_tc_sfi15+'%"';
  ExecuteScalar(strSQL,Query,l_cnt);
  if l_cnt > 0 then
  begin
    ShowErrMsg('同一工单同一机台同一穴号不可同一时间成型，请确认!');
    result := true;
  end;
end;

///计算出机器工时
function GetDeviceTime(l_tc_sfi17,l_tc_sfi08,l_tc_sfi12: String; var Query: TADOQuery):Double;
begin
  result := 0;
  if (l_tc_sfi17 = '') or (StrToFloat(l_tc_sfi17) = 0) then exit;
  if (l_tc_sfi08 = '') or (StrToFloat(l_tc_sfi08) = 0) then exit;
  if (l_tc_sfi12 = '') or (StrToFloat(l_tc_sfi12) = 0) then exit;
  result := NewRoundTo(StrToFloat(l_tc_sfi17)*StrToFloat(l_tc_sfi08)*1.1/StrToFloat(l_tc_sfi12)/60,-3);
end;

///根据单据性质和录入日期产生单号
function GetDocNo(const pre,inputdate: String; var Query: TADOQuery): String;
var
  l_tc_sfi01,l_lastno: String;
  l_cnt: Integer;
begin
  l_tc_sfi01 := 'MN1J-'+MidStr(inputdate,3,2)+MidStr(inputdate,6,2);
  strSQL := 'SELECT count(*) FROM tc_sfi_file WHERE tc_sfi01 LIKE "'+l_tc_sfi01+'%"';
  ExecuteScalar(strSQL,Query,l_cnt);
  if l_cnt = 0 then
    l_tc_sfi01 := l_tc_sfi01 + '00001'
  else begin
    strSQL := 'SELECT max(tc_sfi01) FROM tc_sfi_file WHERE tc_sfi01 LIKE "'+l_tc_sfi01+'%"';
    ExecuteScalar(strSQL,Query,l_lastno);
    l_tc_sfi01 := l_tc_sfi01 + format('%.5d',[strtoint(rightstr(l_lastno,5))+1]);
  end;
  result := l_tc_sfi01;
end;


end.

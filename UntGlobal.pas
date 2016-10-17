{ *********************************************************************** }
{                                                                         }
{ Tiptop Cust Global Variable Library                                     }
{ 功能：全局变量单元                                                      }
{ Author: Audix.tc.paul                                                   }
{ CreateDate: 2012-09-20                                                  }
{                                                                         }
{ *********************************************************************** }
unit UntGlobal;

interface

uses Controls, Graphics, Windows, SysUtils, Classes;

type TCurrentStatus = (csInsert,csModify,csQuery,csDetail,csNone);  {程序当前状态:新增/修改/查询/单身/无}
type TDetailStatus = (dsInsert,dsModify,dsNone);                    {新增/修改/无}
type TBrowserStatus = Record                                        {查询后显示数据时的状态}
     ROWID: String;
     tc_sga01: String;
     RowIndex: Integer;
     RowCount: Integer;
     end;
type THeader = RECORD                  {数据库字段值-单头}
     tc_sga01: String;
     tc_sga02: TDate;
     tc_sga03: String;
     tc_sga04: String;
     tc_sgaacti: String;
     tc_sgauser: String;
     tc_sgagrup: String;
     tc_sgamodu: String;
     tc_sgadate: TDate;
    end;
type TDetail = RECORD                  {数据库字段值-单身}
     tc_sgb01: String;
     tc_sgb02: Smallint;
     tc_sgb03: String;
     tc_sgb04: String;
     tc_sgb05: String;
     tc_sgb06: String;
     tc_sgb07: String;
     tc_sgb08: Double;
    end;

var
  CurrentStatus: TCurrentStatus;        {程序当前状态}
  DetailStatus: TDetailStatus;          {单身当前状态}
  WhereCondition1: String;              {QBE组合后的查询条件-单头}
  WhereCondition2: String;              {QBE组合后的查询条件-单身}
  BrowserStatus: TBrowserStatus;        {查询后显示数据时的状态}
  myYellow: TColor;                     {浅黄色底色}
  dbs: String;                          {从命令行参数传递过来的营运中心}
  Account: String;                      {从命令行参数传递过来的用户帐号}
  tiptop_sid: String;                   {tiptop数据库sid}
  dbpass: String;                       {tiptop数据库连接密码}
  ComboBoxOldValue: Integer;            {ComboBox控件旧的ItemIndex}
  Ctrls: Array of TControl;             {需要查询的所有控件数组}
  fs: TFormatSettings;                  {日期格式统一为yyyy/mm/dd}
  tc_sga: THeader;
  tc_sga_t: THeader;                    {数据库字段临时值}
  tc_sga_o: THeader;                    {数据库字段旧值}

  tc_sgb_t: TDetail;                    {数据库字段临时值}
  tc_sgb_o: TDetail;                    {数据库字段旧值}

  DetailFields: TStringList;            {单身字段的列表}
  DetailFieldsType: TStringList;        {单身字段列表的类型}
  DetailAuth: String;                   {单身的权限标记zxw08}
  PrevRow,CurrentRow,TotalRow: Integer; {单身当前行/单身总行数}
  FTPHost,FTPPort,FTPUserName,FTPPassword,FTPDir: String;

  procedure InitGlobal;                 {初始化所有全局变量的默认初始值}
  function AllowDetailInsert: Boolean;  {单身是否有新增权限}
  function AllowDetailDelete: Boolean;  {单身是否有删除权限}

implementation

uses UntUtility;

procedure InitGlobal;
begin
  CurrentStatus := csNone;
  DetailStatus := dsNone;
  WhereCondition1 := '';
  WhereCondition2 := '';
  BrowserStatus.ROWID := '';
  BrowserStatus.tc_sga01 := '';
  BrowserStatus.RowIndex := 0;
  BrowserStatus.RowCount := 0;
  myYellow := RGB(255,255,153);
  Account := ParamStr(2);
  tiptop_sid := ParamStr(3);
  dbs := ParamStr(4);
  dbpass := ParamStr(5);
  ComboBoxOldValue := -1;
  fs.ShortDateFormat := 'yyyy/mm/dd';
  fs.DateSeparator := '/';
  DetailAuth := '';
  PrevRow := -1;
  CurrentRow := -1;
  TotalRow := 0;
  if Account = '' then  Account := 'paul';  //这个是测试帐号，正式发布的时候要取消此行代码
  //获取FTP Server参数
  FTPHost := ReadIniStr('FTP','Host');
  FTPPort := ReadIniStr('FTP','Port');
  FTPUserName := ReadIniStr('FTP','UserName');
  FTPPassword := DecryptC(ReadIniStr('FTP','Password'));
  FTPDir := ReadIniStr('FTP','Dir');
end;

function AllowDetailInsert: Boolean;
begin
  Result := False;
  if DetailAuth = '' then Exit;
  case StrToInt(DetailAuth) of
    0,1: Result := True;
  end;
end;

function AllowDetailDelete: Boolean;
begin
  Result := False;
  if DetailAuth = '' then Exit;
  case StrToInt(DetailAuth) of
    0,2: Result := True;
  end;
end;

end.

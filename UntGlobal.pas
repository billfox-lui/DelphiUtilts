{ *********************************************************************** }
{                                                                         }
{ Tiptop Cust Global Variable Library                                     }
{ ���ܣ�ȫ�ֱ�����Ԫ                                                      }
{ Author: Audix.tc.paul                                                   }
{ CreateDate: 2012-09-20                                                  }
{                                                                         }
{ *********************************************************************** }
unit UntGlobal;

interface

uses Controls, Graphics, Windows, SysUtils, Classes;

type TCurrentStatus = (csInsert,csModify,csQuery,csDetail,csNone);  {����ǰ״̬:����/�޸�/��ѯ/����/��}
type TDetailStatus = (dsInsert,dsModify,dsNone);                    {����/�޸�/��}
type TBrowserStatus = Record                                        {��ѯ����ʾ����ʱ��״̬}
     ROWID: String;
     tc_sga01: String;
     RowIndex: Integer;
     RowCount: Integer;
     end;
type THeader = RECORD                  {���ݿ��ֶ�ֵ-��ͷ}
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
type TDetail = RECORD                  {���ݿ��ֶ�ֵ-����}
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
  CurrentStatus: TCurrentStatus;        {����ǰ״̬}
  DetailStatus: TDetailStatus;          {����ǰ״̬}
  WhereCondition1: String;              {QBE��Ϻ�Ĳ�ѯ����-��ͷ}
  WhereCondition2: String;              {QBE��Ϻ�Ĳ�ѯ����-����}
  BrowserStatus: TBrowserStatus;        {��ѯ����ʾ����ʱ��״̬}
  myYellow: TColor;                     {ǳ��ɫ��ɫ}
  dbs: String;                          {�������в������ݹ�����Ӫ������}
  Account: String;                      {�������в������ݹ������û��ʺ�}
  tiptop_sid: String;                   {tiptop���ݿ�sid}
  dbpass: String;                       {tiptop���ݿ���������}
  ComboBoxOldValue: Integer;            {ComboBox�ؼ��ɵ�ItemIndex}
  Ctrls: Array of TControl;             {��Ҫ��ѯ�����пؼ�����}
  fs: TFormatSettings;                  {���ڸ�ʽͳһΪyyyy/mm/dd}
  tc_sga: THeader;
  tc_sga_t: THeader;                    {���ݿ��ֶ���ʱֵ}
  tc_sga_o: THeader;                    {���ݿ��ֶξ�ֵ}

  tc_sgb_t: TDetail;                    {���ݿ��ֶ���ʱֵ}
  tc_sgb_o: TDetail;                    {���ݿ��ֶξ�ֵ}

  DetailFields: TStringList;            {�����ֶε��б�}
  DetailFieldsType: TStringList;        {�����ֶ��б������}
  DetailAuth: String;                   {�����Ȩ�ޱ��zxw08}
  PrevRow,CurrentRow,TotalRow: Integer; {����ǰ��/����������}
  FTPHost,FTPPort,FTPUserName,FTPPassword,FTPDir: String;

  procedure InitGlobal;                 {��ʼ������ȫ�ֱ�����Ĭ�ϳ�ʼֵ}
  function AllowDetailInsert: Boolean;  {�����Ƿ�������Ȩ��}
  function AllowDetailDelete: Boolean;  {�����Ƿ���ɾ��Ȩ��}

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
  if Account = '' then  Account := 'paul';  //����ǲ����ʺţ���ʽ������ʱ��Ҫȡ�����д���
  //��ȡFTP Server����
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

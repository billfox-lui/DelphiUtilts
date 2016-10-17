{ ************************************************************************
  Author: tc.paul 2015/09/25
  Remark: Delphi ������Ϣ���õ�Ԫ
  Log:
     01. paul 2016/03/18 �������غ���
     02. paul 2016/04/15 �ɵ����أ�ȫ����ΪApplication.MessageBox
     03. paul 2016/09/27 ����ConfirmMsgYes��ConfirmMsgYes2
**************************************************************************}

unit UntMsg;

interface

uses Windows, Forms;

procedure ShowErrMsg(Msg: String);
procedure ShowWarningMsg(Msg: String);
procedure ShowAlertMsg(Msg: String);
function ConfirmMsgYes(Msg: String): Boolean;
function ConfirmMsgYes2(Msg: String): Boolean;

implementation

procedure ShowErrMsg(Msg: String);
begin
  Application.MessageBox(PChar(Msg),'������ʾ',MB_ICONHAND);
end;

procedure ShowWarningMsg(Msg: String);
begin
  Application.MessageBox(PChar(Msg),'������Ϣ',MB_ICONEXCLAMATION);
end;

procedure ShowAlertMsg(Msg: String);
begin
  Application.MessageBox(PChar(Msg),'��ʾ��Ϣ',MB_ICONINFORMATION);
end;








begin




end.
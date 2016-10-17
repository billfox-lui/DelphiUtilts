{ ************************************************************************
  Author: tc.paul 2015/09/25
  Remark: Delphi 弹出信息框复用单元
  Log:
     01. paul 2016/03/18 增加重载函数
     02. paul 2016/04/15 干掉重载，全部改为Application.MessageBox
     03. paul 2016/09/27 增加ConfirmMsgYes、ConfirmMsgYes2
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
  Application.MessageBox(PChar(Msg),'错误提示',MB_ICONHAND);
end;

procedure ShowWarningMsg(Msg: String);
begin
  Application.MessageBox(PChar(Msg),'警告信息',MB_ICONEXCLAMATION);
end;

procedure ShowAlertMsg(Msg: String);
begin
  Application.MessageBox(PChar(Msg),'提示信息',MB_ICONINFORMATION);
end;

function ConfirmMsgYes(Msg: String): Boolean;
begin
  result := false;
  if Application.MessageBox(PChar(Msg),'请确认',MB_YESNO OR MB_ICONQUESTION OR MB_DEFBUTTON2) = IDYES then result := true;
end;

function ConfirmMsgYes2(Msg: String): Boolean;
begin
  result := false;
  if Application.MessageBox(PChar(Msg),'请确认',MB_YESNO OR MB_ICONQUESTION OR MB_DEFBUTTON1) = IDYES then result := true;
end;

end.

unit UntMail;

interface
uses IdSMTP, IdMessage, Classes, SysUtils;

  function SendEmail(poBody:Tstrings; poAttachmentPath:TStrings):Integer;
  procedure SendMailLog(ErrType: Byte);

implementation

uses UntUtility;

function SendEmail(poBody:Tstrings; poAttachmentPath:TStrings):Integer;
var
  MailSubject: string;
  MailContentType:string;
  loIdMsgSend: TIdMessage;
  loSMTP: TIdSMTP;
  i: integer;
begin
  MailSubject := FormatDateTime('yyyy-mm-dd',Now) + ReadIniStr('Mail','Subject');
  MailContentType := 'content="text/html; charset=utf-8"';

  loIdMsgSend:=nil;
  loSMTP:=nil;
  try
    loIdMsgSend:=TIdMessage.Create(nil);
    loSMTP:=TIdSMTP.Create(nil);

    with loIdMsgSend do
    begin
      ContentType:=MailContentType;
      From.Text := ReadIniStr('Mail','FromAddress');
      ReplyTo.EMailAddresses := ReadIniStr('Mail','FromAddress');
      Recipients.EMailAddresses := ReadIniStr('Mail','To');
      CCList.EMailAddresses:=ReadIniStr('Mail','CC');
      Subject := MailSubject;
      Priority := mpHigh;
      ReceiptRecipient.Text :='';
      Body.Assign(poBody);
      if Assigned(poAttachmentPath) then
      begin
        for i := 0 to poAttachmentPath.Count-1 do
          TIdAttachment.Create(loIdMsgSend.MessageParts,poAttachmentPath.Strings[i]);
      end;
     end;

    with loSMTP do
    begin
      Host := ReadIniStr('Mail','SMTPHost');
      Port := ReadIniInt('Mail','SMTPPort');
      if ReadIniInt('Mail','SmtpAuthType')=1 then AuthenticationType:=atLogin else AuthenticationType:=atNone;
      Username := ReadIniStr('Mail','Username');
      Password := ReadIniStr('Mail','Password');
      try
        Connect;
        Send(loIdMsgSend);
      except
        result:=2;
        exit;
      end;
      Result:=0;
    end;
  finally
    loIdMsgSend.Free;
    loSMTP.Free;
  end;
end;

procedure SendMailLog(ErrType: Byte);
var
  LogFile: String;
  Path_Str: String;
  Dir_Str: String;
  Body: TStrings;
  AttFile: TStrings;
begin
  GetDir(0,Path_Str);
  Dir_Str := Path_Str + '\Log';
  LogFile := Dir_Str+'\'+FormatDateTime('yyyy-mm-dd',Now)+'.txt';
  if not FileExists(LogFile) then Exit;
  Body := Nil;
  AttFile := Nil;
  try
    try
      Body := TStringList.Create;
      AttFile := TStringList.Create;
      Body.Add('您好：');
      case ErrType of
        1: Body.Add('   1.后台程序在将用户从HR系统同步到考勤卡机的时候出现异常!');
        2: Body.Add('   1.后台程序在将用户从 apyi030系统同步aooi040和用户权限的时候出现异常!');
        3: Body.Add('   1.后台程序在将考勤记录下载和分析的时候出现异常!');
        4: Body.Add('   1.后台程序在将用户从HR系统同步到门禁卡机的时候出现异常!');
      end;
      Body.Add('    2.附件是程序日志记录，请参考!');
      Body.Add('    3.本邮件为系统自动发送，请勿 直接回复!');
      Body.Add('   ----------------------------------------');
      Body.Add('  祝您工作愉快！');
      AttFile.Add(LogFile);
      SendEMail(Body,AttFile)
    except
      //异常时候不做处理
    end;
  finally
    Body.Free;
    AttFile.Free;
  end;
end;

end.

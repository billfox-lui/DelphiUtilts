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
      Body.Add('���ã�');
      case ErrType of
        1: Body.Add('   1.��̨�����ڽ��û���HRϵͳͬ�������ڿ�����ʱ������쳣!');
        2: Body.Add('   1.��̨�����ڽ��û��� apyi030ϵͳͬ��aooi040���û�Ȩ�޵�ʱ������쳣!');
        3: Body.Add('   1.��̨�����ڽ����ڼ�¼���غͷ�����ʱ������쳣!');
        4: Body.Add('   1.��̨�����ڽ��û���HRϵͳͬ�����Ž�������ʱ������쳣!');
      end;
      Body.Add('    2.�����ǳ�����־��¼����ο�!');
      Body.Add('    3.���ʼ�Ϊϵͳ�Զ����ͣ����� ֱ�ӻظ�!');
      Body.Add('   ----------------------------------------');
      Body.Add('  ף��������죡');
      AttFile.Add(LogFile);
      SendEMail(Body,AttFile)
    except
      //�쳣ʱ��������
    end;
  finally
    Body.Free;
    AttFile.Free;
  end;
end;

end.

unit UntPubQBE;

interface

uses
  Forms, Controls, StdCtrls, Dialogs,SysUtils,StrUtils,Classes,cxButtonEdit,cxTextEdit,
  Messages,Windows,Graphics,ADODB,Buttons,cxGrid,ComCtrls;

  type
    TUser=Record
      Controls: TControl;
      Fieldname: String[100];
      Fieldtype: String[1];
  end;
  procedure FormCreate;
  procedure ControlEnable(aForm: TForm; bool:Boolean);
  procedure Err_Message(Code:Integer); //������Ϣ

  function StartQBE(aForm: TForm; Controls: Array of TUser):Integer;
  function GetWC:String;
  function GetWhereString(FieldName,FieldType,Str:String): String;
    {Author:Andy 2012-08-21
     ��;���õ�Sql�����Where�������
     FieldName:�ֶ�����
     FieldType:�ֶ����͡�C:�ַ���;D��������;��������Ϊ�ַ��ʹ���
     Str:�ֶ�ֵ
    ����ֵ��������False,����True
    }
  function GetServerTime(Query:TADOQuery):string;
  function GetServerDate(Query:TADOQuery):string;
  Function QBE_Change(FieldName,FieldType,Str:String):String;
    {Author:Andy2012-08-21
     ��;��ת��QBE����Ϊoracle���Խ��ܵ��﷨
     FieldName:�ֶ�����
     FieldType:�ֶ����͡�C:�ַ���;D��������;��������Ϊ�ַ��ʹ���
     ����ֵ��50X(QBE����)
    }
  Function IsExsist(Sign:String):Boolean;
    {Author:Andy 2012-08-21
     ��;���������Ƿ����Ϊ�ַ�����
     ����ֵ������ΪTrue,����False
    }
  Function Err_DistinctSign:Boolean;
    {Author:Andy 2012-08-21
     ��;������ַ������Ƿ���ڲ�ͬ�ķ���
     ����ֵ������ΪTrue,����False
    }
  Function Err_DoubleSign:Boolean;
    {Author:Andy 2012-08-21
     ��;������ַ������Ƿ������ͬ�ķ��� (*,|,?����)
     ����ֵ������ΪTrue,����False
    }
  Function SignNumber(sign:String):Boolean;
    {Author:Andy 2012-08-21
     ��;���ַ����з����Ƿ�>1
     ����ֵ������ΪFalse,����True
    }
  Function DateTypeCompare(FieldName,Str,Sqltype:String):String;
    {Author:Andy 2012-08-21
     ��;���������͵Ĵ���ʽ(to_date)
     ����ֵ���ַ���
    }
  Function IntTypeCompare(FieldName,Int_Str:String):String;
    {Author:Andy 2012-08-21
     ��;���������͵Ĵ���ʽ(������)
     ����ֵ���ַ���
    }
  Function CharTypeCompare(FieldName,Str:String):String;
    {Author:Andy 2012-08-21
     ��;���ַ����͵Ĵ���ʽ(������)
     ����ֵ���ַ���
    }
  Function GetComboboxindex(S:String):String;
  {Author:Andy 2012-08-21
     ��;�����comboboxǰ��������Ϊ��ѯ������
     ����ֵ���ַ���
    }



  procedure DisableAllControls(aForm: TForm; CheckBoxAllowGrayed:Boolean=False; ClearText: Boolean=True);  {�����пؼ�����Ϊdisable״̬����ֵ���}
  procedure EnableAllControls(aForm: TForm);   {�����пؼ�����Ϊenable״̬}
  procedure Construct(aForm: TForm; Controls: Array of TUser);overload;               {��ʼConstruct������һ}
  procedure Construct(aForm: TForm; Controls: Array of TControl);overload;            {��ʼConstruct��������}
  function GetWhereStr(aForm: TForm; Controls: Array of TUser): String;overload;      {��ȡConstruct��Ϻ��wc������һ}
  function GetWhereStr(aForm: TForm; Controls: Array of TControl): String;overload;   {��ȡConstruct��Ϻ��wc������һ}
  function GetFieldName(strHint: String): String;                                     {�ӿؼ���hint��ȡ��|ǰ����ֶ���}
  function GetFieldType(intTag: Integer): String;                                     {���ݿؼ���tagֵ��ȡ�ؼ����ֶ�����}

implementation

var
  s,t,p:String;
  errorcode:integer;
  Get_Where_Str:String;

procedure FormCreate;
begin
  Get_Where_Str:=' 1=1 ';
  errorcode:=0;
end;

procedure ControlEnable(aForm: TForm; bool:Boolean);
var
  i:Integer;
  frmComp:TComponent;
begin
  aform.Font.Charset:=ANSI_CHARSET;
  aform.Font.Color:=clWindowText;
  aform.Font.Name:='������';
  aform.Font.Size:=9;
  for i:=0 to aform.ComponentCount-1 do
  begin
    frmcomp:=aform.Components[i];
    if frmcomp is TEdit Then
    begin
      if (frmcomp as TEdit).Tag<>100 Then
      begin
        if bool Then
          (frmcomp as TEdit).Color:=clWindow
        else
          (frmcomp as TEdit).Color:=clBtnFace;
          (frmcomp as TEdit).Enabled:=bool
      end;
      (frmcomp as TEdit).Clear;
      (frmcomp as TEdit).ParentFont:=True;
    end;
    if frmcomp is TCombobox Then
    begin
      if  bool Then
         (frmcomp as TCombobox).Color:=clWindow
      else
         (frmcomp as TCombobox).Color:=clBtnFace;
      (frmcomp as TCombobox).Text:='';
      (frmcomp as TCombobox).Enabled:=bool;
      (frmcomp as TCombobox).ParentFont:=True;
    end;
    if frmcomp is TCheckBox Then
    begin
      (frmcomp as TCheckbox).Enabled:=bool;
      (frmcomp as TCheckbox).ParentFont:=True;
    end;
    if frmcomp is TRadioButton Then
    begin
      (frmcomp as TRadioButton).Enabled:=bool;
      (frmcomp as TRadioButton).ParentFont:=True;
    end;
    if frmcomp is TSpeedButton Then
    begin
      (frmcomp as TSpeedButton).Enabled:=bool;
      (frmcomp as TSpeedButton).ParentFont:=True;
    end;
    if frmcomp is TButton Then
    begin
      (frmcomp as TButton).Enabled:=bool;
      (frmcomp as TButton).ParentFont:=True;
    end;
    if frmcomp is TLabel Then
    begin
      (frmcomp as TLabel).ParentFont:=True;
    end;
    if frmcomp is TpageControl Then
    begin
      (frmcomp as TpageControl).ParentFont:=True;
    end;
    if frmcomp is Tgroupbox Then
    begin
      (frmcomp as Tgroupbox).ParentFont:=True;
    end;
    if frmcomp is TcxButtonEdit Then
    begin
       if  bool Then
         (frmcomp as TcxButtonEdit).Style.Color:=clWindow
      else
         (frmcomp as TcxButtonEdit).Style.Color:=clBtnFace;
      (frmcomp as TcxButtonEdit).Clear;
      (frmcomp as TcxButtonEdit).Enabled:=bool;
      (frmcomp as TcxButtonEdit).ParentFont:=True;
    end
  end;
end;

Function StartQBE(aForm: TForm; Controls: Array of TUser):Integer;
var
  i: integer;
  controlstr:String;
  fieldname:String;
  fieldtype:String;
  frmComp:TComponent;
begin
  FormCreate;
  for i := Low(Controls) to High(Controls) do
  begin
    frmComp:=Controls[i].Controls;
    fieldname:=Controls[i].Fieldname;
    fieldtype:=Controls[i].Fieldtype;
    if ( frmComp is TcxButtonEdit) then  //buttonEdit
      controlstr:=(frmComp as TcxButtonEdit).Text
    else if ( frmComp is TEdit) then     //Edit
      controlstr:=(frmComp as TEdit).Text
    else if (frmComp is TCombobox) then //Combobox
      begin
        controlstr:=(frmComp as TCombobox).Text;
        if controlstr<>'' Then
        begin
          controlstr:=GetComboboxindex(controlstr);
          if controlstr='' then
          begin
            errorcode:=105;
            Err_Message(errorcode);
            break;
          end;
        end;
      end
    else if (frmComp is TCheckbox) then //Checkbox
    begin
      if (frmComp as TCheckbox).Checked then
        controlstr:='Y'
      else
        controlstr:='N';
    end
    else begin
      errorcode:=101;
      Err_Message(errorcode);
      break;
    end;
    GetWhereString(Fieldname,fieldtype,controlstr);
  end;
  Result:=errorcode;
end;

function GetWC:String;
begin
  Result:='';
  Result:=Get_Where_Str;
  Get_Where_Str:=' ';
end;

function GetWhereString(FieldName,FieldType,Str:String): String;
begin
  Result:='';
  if Trim(Str)<>'' then
    Get_Where_Str:=Get_Where_Str+' and '+QBE_Change(FieldName,FieldType,Str);
  Result:=Get_Where_Str;
end;

function QBE_Change(FieldName,FieldType,Str:String):String;
Begin
  Result:='';
  s:=Trim(Str);
  //�ж��Ƿ��ж��ڲ�ͬ���ַ�
  IF Not Err_distinctSign Then
  begin
    errorcode:=102;
    Err_Message(errorcode);
    exit;
  end;
  //�ж��Ƿ��ж�����ͬ���ַ�   /������*������
  IF Not Err_DoubleSign Then
  begin
    errorcode:=103;
    Err_Message(errorcode);
    exit;
  end;
  //��ʼ��
  Result:='';
  IF Trim(FieldType)='D' Then
    Result:=DateTypeCompare(FieldName,s,'O');
  IF Trim(FieldType)='C' Then
    Result:=CharTypeCompare(FieldName,s);
 IF Trim(FieldType)='I' Then
    Result:=IntTypeCompare(FieldName,s);
End;

Function IsExsist(Sign:String):Boolean;
Begin
  Result:=AnsiContainsStr(s,Sign)
End;

Function Err_distinctSign:Boolean;
Var
  i:Integer;
Begin
  i:=0;
  IF IsExsist('=') and Not IsExsist('>') and Not IsExsist('<') Then i:=i+1;
  //IF IsExsist('==') Then i:=i+1;
  IF IsExsist('>') and Not IsExsist('=') and Not IsExsist('<') Then i:=i+1;
  IF IsExsist('<') and Not IsExsist('=') and Not IsExsist('>') Then i:=i+1;
  IF IsExsist('>=') Then i:=i+1;
  IF IsExsist('<=') Then i:=i+1;
  IF IsExsist('<>') Then i:=i+1;
  IF IsExsist('!=') Then i:=i+1;
  IF IsExsist(':') Then i:=i+1;
  IF IsExsist('..') Then i:=i+1;
  IF IsExsist('*') Then i:=i+1;
  IF IsExsist('?') Then i:=i+1;
  IF IsExsist('|') Then i:=i+1;
  IF i>1 Then
    Result:=False
  Else
   Result:=true;
End;

Function Err_DoubleSign:Boolean;
Begin
  Result:=False;
  IF Not SignNumber('==') Then Result:=True;
  IF Not SignNumber('>') Then Result:=True;
  IF Not SignNumber('<') Then Result:=True;
  IF Not SignNumber('>=') Then Result:=True;
  IF Not SignNumber('<=') Then Result:=True;
  IF Not SignNumber('<>') Then Result:=True;
  IF Not SignNumber('!=') Then Result:=True;
  IF Not SignNumber(':') Then Result:=True;
  IF Not SignNumber('..') Then Result:=True;
End;

Function SignNumber(sign:String):Boolean;
Var i,j:Integer;
    Str:String;
Begin
  Result:=False;
  str:=s; j:=0;
  While Length(str)>0 Do
    Begin
      i:=pos(sign,str); j:=j+1;
      str:=Copy(str,i+1,(Length(str)-i));
      IF j>1 Then
        Begin
          Result:=False;
          Break;
        End
      Else
        Result:=True;
    End;
End;

Function CharTypeCompare(FieldName,Str:String):String;
var g,i:integer;
    x,y,h,s:String;
    sl:TStringList;
Begin
  Result:='';
  x:='';y:='';
  s:=Str;
  //��ȡǰ1λʱ
  t:=LeftStr(s,1);
  h:=LeftStr(s,2);
  p:=Copy(s,2,(Length(s)-1));
  IF s='' Then Result:='';
  IF (t<>'=') and (t<>'>') and (t<>'<') and (t<>'*')
    and (t<>'?') and (t<>':') and (t<>'|') and (h<>'<>')
    and (h<>'<=') and (h<>'>=') and (h<>'==')
    and (h<>'..') and (h<>'!=')  Then
    Result:=FieldName+' = '+''''+s+'''';
  //=
  IF (t='=') and (p='') Then Result:=FieldName+' is Null';
  IF (t='=') and (p<>'') Then Result:=FieldName+' = '+''''+p+'''';
  //>
  IF (t='>') Then Result:=FieldName+' > '+''''+p+'''';
  //<
  IF (t='<') Then Result:=FieldName+' < '+''''+p+'''';
  //��ȡǰ2λʱ
  t:=LeftStr(s,2);
  p:=Copy(s,3,(Length(s)-2));
  //>=
  IF (t='>=') Then Result:=FieldName+' >= '+''''+p+'''';
  //<=
  IF (t='<=') Then Result:=FieldName+' <= '+''''+p+'''';
  //>= or !=
  //IF (t='<>') or (t='!=') Then Result:=FieldName+' <> '+''''+p+'''';
  IF (t='<>') or (t='!=') Then Result:=FieldName+' is not null';  //paul �޸�Ϊis not null

  //==
  IF (t='==') Then Result:=FieldName+' = '+''''+p+'''';
  //�����ַ� ? : .. * |
  IF IsExsist(':') Then
  Begin
    g:=pos(':',s);
    x:=LeftStr(s,g-1);
    y:=rightStr(s,(length(s)-g));
    Result:=FieldName+' Between '+''''+X+''''+' and '+''''+Y+'''';
  End;
  IF IsExsist('..') Then
  Begin
    g:=pos('..',s);
    x:=LeftStr(s,g-1);
    y:=rightStr(s,(length(s)-g-1));
    Result:=FieldName+' Between '+''''+X+''''+' and '+''''+Y+'''';
  End;
  IF IsExsist('?') Then
  Begin
    Result:=FieldName+' Like '+''''+AnsireplaceText(s,'?','_')+'''';
  End;
  IF IsExsist('*') Then
  Begin
    Result:=FieldName+' Like '+''''+AnsireplaceText(s,'*','%')+'''';
  End;
  IF IsExsist('|') Then
  Begin
    sl:=TStringList.Create;
    s:=StringReplace(s,'|',#13#10,[rfReplaceAll]);
    sl.Text:=s;  //���ָ���ַ�����sl��
    For i:=0 to sl.Count-1 do
      IF (i<>(sl.Count-1)) Then
        x:=x+''''+sl[i]+''''+','
      Else
        x:=x+''''+sl[i]+'''';
    Result:=FieldName+' IN ('+x+')';
    FreeAndNil(sl);
  End;
End;

Function IntTypeCompare(FieldName,Int_Str:String):String;
var g,i:integer;
    x,y,h,s:String;
    sl:TStringList;
Begin
  Result:='';
  x:='';y:='';
  s:=Int_Str;
  //��ȡǰ1λʱ
  t:=LeftStr(s,1);
  h:=LeftStr(s,2);
  p:=Copy(s,2,(Length(s)-1));
  IF s='' Then Result:='';
  IF (t<>'=') and (t<>'>') and (t<>'<') and (t<>'*')
    and (t<>'?') and (t<>':') and (t<>'|') and (h<>'<>')
    and (h<>'<=') and (h<>'>=') and (h<>'==')
    and (h<>'..') and (h<>'!=')  Then
    Result:=FieldName+' = '+''+s+'';
  //=
  IF (t='=') and (p='') Then Result:=FieldName+' is Null';
  IF (t='=') and (p<>'') Then Result:=FieldName+' = '+''+p+'';
  //>
  IF (t='>') Then Result:=FieldName+' > '+''+p+'';
  //<
  IF (t='<') Then Result:=FieldName+' < '+''+p+'';
  //��ȡǰ2λʱ
  t:=LeftStr(s,2);
  p:=Copy(s,3,(Length(s)-2));
  //>=
  IF (t='>=') Then Result:=FieldName+' >= '+''+p+'';
  //<=
  IF (t='<=') Then Result:=FieldName+' <= '+''+p+'';
  //>= or !=

  //IF (t='<>') or (t='!=') Then Result:=FieldName+' <> '+''+p+'';
  IF (t='<>') or (t='!=') Then Result:=FieldName+' is not null';  //paul ���Ϊis not null

  //==
  IF (t='==') Then Result:=FieldName+' = '+''+p+'';
  //�����ַ� ? : .. * |
  IF IsExsist(':') Then
  Begin
    g:=pos(':',s);
    x:=LeftStr(s,g-1);
    y:=rightStr(s,(length(s)-g));
    Result:=FieldName+' Between '+''+X+''+' and '+''+Y+'';
  End;
  IF IsExsist('..') Then
  Begin
    g:=pos('..',s);
    x:=LeftStr(s,g-1);
    y:=rightStr(s,(length(s)-g-1));
    Result:=FieldName+' Between '+''+X+''+' and '+''+Y+'';
  End;
  IF IsExsist('?') Then
  Begin
    Result:=FieldName+' Like '+''+AnsireplaceText(s,'?','_')+'';
  End;
  IF IsExsist('*') Then
  Begin
    Result:=FieldName+' Like '+''+AnsireplaceText(s,'*','%')+'';
  End;
  IF IsExsist('|') Then
  Begin
    sl:=TStringList.Create;
    s:=StringReplace(s,'|',#13#10,[rfReplaceAll]);
    sl.Text:=s;  //���ָ���ַ�����sl��
    For i:=0 to sl.Count-1 do
      IF (i<>(sl.Count-1)) Then
        x:=x + sl[i] + ','
      Else
        x:=x + sl[i];
    Result:=FieldName+' IN (' + x + ')';
    FreeAndNil(sl);
  End;
End;

function DateTypeCompare(FieldName,Str,Sqltype:String):String;
var
   g,i:integer;
   x,y,d,h:String;
   sl:TStringList;
Begin
  Result:='';
  x:='';y:='';
  s:=Trim(Str);
  //��ȡǰ1λʱ
  t:=LeftStr(s,1);
  h:=LeftStr(s,2);
  p:=Copy(s,2,(Length(s)-1));
  d:='to_Date('+''''+p+''''+','+''''+'yyyy/mm/dd'+'''' +')';
  IF s='' Then Result:='';
  IF (t<>'=') and (t<>'>') and (t<>'<') and (t<>'*')
    and (t<>'?') and (t<>':') and (t<>'|') and (h<>'<>')
    and (h<>'<=') and (h<>'>=') and (h<>'==')
    and (h<>'..') and (h<>'!=')  Then
  Begin
    if Sqltype='O' Then
      d:='to_Date('+''''+s+''''+','+''''+'yyyy/mm/dd'+'''' +')'
    else
      d:='('+''''+s+''''+')';
    Result:=FieldName+' = '+d;
    //�ж���������
    {p_len:=length(s);
    if (p_len>10) Or (p_len<6) Then
      begin
        errorcode:=104;
        Err_Message(errorcode);
      end
    else
      begin
        p_m:=p_len mod 2;
        if p_m<>0 then
        begin
          errorcode:=104;
          Err_Message(errorcode);
        end;
      end;  }
  End;
  //=
  IF (t='=') and (p='') Then Result:=FieldName+' is Null';
  IF (t='=') and (p<>'') Then Result:=FieldName+' = '+d;
  //>
  IF (t='>') Then Result:=FieldName+' > '+d;
  //<
  IF (t='<') Then Result:=FieldName+' < '+d;
  //��ȡǰ2λʱ
  t:=LeftStr(s,2);
  p:=Copy(s,3,(Length(s)-2));
  if Sqltype='O' Then
    d:='to_Date('+''''+p+''''+','+''''+'yyyy/mm/dd'+'''' +')'
  else
    d:='('+''''+p+''''+')';
  //>=
  IF (t='>=') Then Result:=FieldName+' >= '+d;
  //<=
  IF (t='<=') Then Result:=FieldName+' <= '+d;
  //>= or !=
  //IF (t='<>') or (t='!=') Then Result:=FieldName+' <> '+d;
  IF (t='<>') or (t='!=') Then Result:=FieldName+' is not null';  //paul ��Ϊis not null

  //==
  IF (t='==') Then Result:=FieldName+' = '+d;
  //�����ַ� ? : .. * |
  IF IsExsist(':') Then
  Begin
    g:=pos(':',s);
    if Sqltype='O' Then
      begin
        x:='to_Date('+''''+LeftStr(s,g-1)+''''+','+''''+'yyyy/mm/dd'+'''' +')';
        y:='to_Date('+''''+rightStr(s,(length(s)-g))+''''+','+''''+'yyyy/mm/dd'+'''' +')';
      end
    else
      begin
        x:='('+''''+LeftStr(s,g-1)+''''+')';
        y:='('+''''+rightStr(s,(length(s)-g))+''''+')';
      end;
      Result:=FieldName+' Between '+X+' and '+Y;
  End;
  IF IsExsist('..') Then
  Begin
    g:=pos('..',s);
    if Sqltype='O' Then
      begin
        x:='to_Date('+''''+LeftStr(s,g-1)+''''+','+''''+'yyyy/mm/dd'+'''' +')';
        y:='to_Date('+''''+rightStr(s,(length(s)-g-1))+''''+','+''''+'yyyy/mm/dd'+'''' +')';
      end
    else
      begin
        x:='('+''''+LeftStr(s,g-1)+''''+')';
        y:='('+''''+rightStr(s,(length(s)-g-1))+''''+')';
      end;
    Result:=FieldName+' Between '+X+' and '+Y;
    //�ж���������
   { p_len:=length(LeftStr(s,g-1));
    if (p_len>10) Or (p_len<6) Then
      begin
        errorcode:=104;
        Err_Message(errorcode);
      end
    else
      begin
        p_m:=p_len mod 2;
        if p_m<>0 then
        begin
          errorcode:=104;
          Err_Message(errorcode);
        end; }
    end;
    {p_len:=length(rightStr(s,(length(s)-g-1)));
    if (p_len>10) Or (p_len<6) Then
      begin
        errorcode:=104;
        Err_Message(errorcode);
      end
    else
      begin
        p_m:=p_len mod 2;
        if p_m<>0 then
        begin
          errorcode:=104;
          Err_Message(errorcode);
        end;
      end;
  End;}
  IF IsExsist('|') Then
  Begin
    sl:=TStringList.Create;
    s:=StringReplace(s,'|',#13#10,[rfReplaceAll]);
    sl.Text:=s;  //���ָ���ַ�����sl��
    for i:=0 to sl.Count-1 do
    begin
      if (i<>(sl.Count-1)) then
        begin
         if Sqltype='O' Then
            x:=x+'to_Date('+''''+sl[i]+''''+','+''''+'yyyy/mm/dd'+'''' +')'+','
         else
            x:=x+'('+''''+sl[i]+''''+')'+','
         end
      else
        begin
          if Sqltype='O' Then
            x:=x+'to_Date('+''''+sl[i]+''''+','+''''+'yyyy/mm/dd'+'''' +')'
          else
            x:=x+'('+''''+sl[i]+''''+')'
        end;
     { p_len:=length(sl[i]);
      if (p_len>10) Or (p_len<6) Then
      begin
        errorcode:=104;
        Err_Message(errorcode);
      end
    else
      begin
        p_m:=p_len mod 2;
        if p_m<>0 then
        begin
          errorcode:=104;
          Err_Message(errorcode);
        end;
      end; }
    end;
    Result:=FieldName+' In ('+x+')';  
    FreeAndNil(sl);
  End;

End;

procedure Err_Message(Code:Integer);
Var
  Msg:String;
begin
  Case Code of
    0:  Msg:='�����޴���';
    101:Msg:='������û�ж���ؼ�������';
    102:Msg:='�����в����ж����ͬ���ַ�����';
    103:Msg:='�����в����ж����ͬ���ַ�����';
    104:Msg:='�������������';
    105:Msg:='��Ч��ComboBox���';
  End;
  MessageBox(0,pchar(Msg),'��Ϣ',MB_OK);
end;

function GetComboboxindex(S:String):String;
var
  p_pos:Integer;
begin
  if Trim(s)='' Then
  begin
    Result:='';
    exit;
  end;
  p_pos:=pos(':',S);
  Result:=leftStr(S,p_pos-1);
end;

function GetServerDate(Query:TADOQuery):string;
begin
   with Query Do
   begin
     Close;
     SQL.Text:='select to_char(sysdate, ''YYYY/MM/DD'') from sys.dual';
     Open;
     if RecordCount<=0 then Result:=''
     else Result:=Fields[0].AsString;
     Close;
   end;
end;

function GetServerTime(Query:TADOQuery):string;
begin
  with Query Do
  begin
    Close;
    SQL.Text:='select to_char(sysdate, ''HH:MI:SS'')from sys.dual';
    Open;
    if RecordCount<=0 then Result:=''
    else Result:=Fields[0].AsString;
    Close;
  end;
end;

procedure DisableAllControls(aForm: TForm; CheckBoxAllowGrayed:Boolean=False; ClearText: Boolean=True);   {�����пؼ�����Ϊdisable״̬}
var
  i:Integer;
  frmComp:TComponent;
begin
  for i:=0 to aform.ComponentCount-1 do
  begin
    frmComp:=aform.Components[i];
    if frmComp is TEdit Then
    begin
      TEdit(frmComp).Color := clBtnFace;
      TEdit(frmComp).Enabled := False;
      if ClearText then TEdit(frmComp).Clear;
      Continue;
    end;

    if frmComp is TCombobox Then
    begin
      TComboBox(frmComp).Color := clBtnFace;
      TComboBox(frmComp).Enabled := False;
      if ClearText then TComboBox(frmComp).ItemIndex := -1;
      Continue;
    end;

    if frmComp is TCheckBox Then
    begin
      TCheckBox(frmComp).AllowGrayed := CheckBoxAllowGrayed;
      if CheckBoxAllowGrayed then
         TCheckBox(frmComp).State := cbGrayed
      else
        begin
          if ClearText then TCheckBox(frmComp).Checked := False;
        end;
      TCheckBox(frmComp).Enabled := False;
      Continue;
    end;

    if frmComp is TRadioButton Then
    begin
      TRadioButton(frmComp).Enabled := False;
      Continue;
    end;

    if frmComp is TSpeedButton Then
    begin
      //TSpeedButton(frmComp).Visible := False;
      TSpeedButton(frmComp).Enabled := False;
      Continue
    end;

    if frmComp is TButton Then
    begin
      TButton(frmComp).Enabled := False;
      Continue;
    end;

    if frmComp is TBitBtn then
    begin
      TBitBtn(frmComp).Enabled := False;
      Continue;
    end;

    if frmComp is TMemo then
    begin
      TMemo(frmComp).Enabled := False;
      TMemo(frmComp).Color := clBtnFace;
      if ClearText then TMemo(frmComp).Clear;
      Continue;
    end;

    if frmComp is TGroupBox then
    begin
       if TGroupBox(frmComp).Name <> 'GroupBox1' then
         TGroupBox(frmComp).Enabled := False;
    end;
  end;
end;

procedure EnableAllControls(aForm: TForm);   {�����пؼ�����Ϊenable״̬}
var
  i:Integer;
  frmComp:TComponent;
begin
  for i:=0 to aform.ComponentCount-1 do
  begin
    frmComp:=aform.Components[i];
    if frmComp is TEdit Then
    begin
      TEdit(frmComp).Color := clBtnFace;
      TEdit(frmComp).Enabled := True;
      Continue;
    end;

    if frmComp is TCombobox Then
    begin
      TComboBox(frmComp).Color := clBtnFace;
      TComboBox(frmComp).Enabled := True;
      Continue;
    end;

    if frmComp is TCheckBox Then
    begin
      TCheckBox(frmComp).Enabled := True;
      Continue;
    end;

    if frmComp is TRadioButton Then
    begin
      TRadioButton(frmComp).Enabled := True;
      Continue;
    end;

    if frmComp is TMemo then
    begin
      TMemo(frmComp).Enabled := True;
      TMemo(frmComp).Color := clBtnFace;
      Continue;
    end;

    if frmComp is TGroupBox then
    begin
      TGroupBox(frmComp).Enabled := True;
      Continue
    end;

    if frmComp is TSpeedButton then
    begin
      TSpeedButton(frmComp).Enabled := True;
      Continue;
    end;
  end;
end;

procedure Construct(aForm: TForm; Controls: Array of TUser);    {��ʼ��Construct����}
var
  i: integer;
  frmComp:TComponent;
begin
  for i := Low(Controls) to High(Controls) do
  begin
    frmComp:=Controls[i].Controls;

    if frmComp is TGroupBox then
    begin
      TGroupBox(frmComp).Enabled := True;
      Continue;
    end;

    if frmComp is TEdit then
    begin
      TEdit(frmComp).Color := clWindow;
      TEdit(frmComp).Enabled := True;
      TEdit(frmComp).Clear;
      if i = 0 then TEdit(frmComp).SetFocus;
      Continue;
    end;

    if frmComp is TCombobox Then
    begin
      TComboBox(frmComp).Color := clWindow;
      TComboBox(frmComp).Enabled := True;
      TComboBox(frmComp).Text := '';
      TComboBox(frmComp).Style := csDropDown;
      if i = 0 then TComboBox(frmComp).SetFocus;
      Continue;
    end;

    if frmComp is TCheckBox Then
    begin
      TCheckBox(frmComp).AllowGrayed := True;
      TCheckBox(frmComp).Enabled := True;
      TCheckBox(frmComp).State := cbGrayed;
      if i = 0 then TCheckBox(frmComp).SetFocus;
      Continue;
    end;

    if frmComp is TSpeedButton Then
    begin
      TSpeedButton(frmComp).Enabled := True;
      Continue;
    end;

    if frmComp is TButton Then
    begin
      TButton(frmComp).Enabled := True;
      Continue;
    end;

    if frmComp is TBitBtn then
    begin
      TBitBtn(frmComp).Enabled := True;
      Continue;
    end;

    if frmComp is TMemo then
    begin
      TMemo(frmComp).Color := clWindow;
      TMemo(frmComp).Clear;
      if i = 0 then TMemo(frmComp).SetFocus;
      Continue;
    end;
    
  end;
end;

procedure Construct(aForm: TForm; Controls: Array of TControl);    {��ʼ��Construct����}
var
  i: integer;
  frmComp:TComponent;
begin
  for i := Low(Controls) to High(Controls) do
  begin
    frmComp:=Controls[i];
    if frmComp = Nil then Continue;

    if frmComp is TGroupBox then
    begin
      TGroupBox(frmComp).Enabled := True;
      Continue;
    end;

    if frmComp is TEdit then
    begin
      TEdit(frmComp).Color := clWindow;
      TEdit(frmComp).Enabled := True;
      TEdit(frmComp).Clear;
      Continue;
    end;

    if frmComp is TCombobox Then
    begin
      TComboBox(frmComp).Color := clWindow;
      TComboBox(frmComp).Enabled := True;
      TComboBox(frmComp).Text := '';
      TcomboBox(frmComp).Style := csDropDown;
      if i = 0 then TComboBox(frmComp).SetFocus;
      Continue;
    end;

    if frmComp is TCheckBox Then  //�ڽ���Construct��ʱ������CheckBox������״̬
    begin
      TCheckBox(frmComp).AllowGrayed := True;
      TCheckBox(frmComp).Enabled := True;
      TCheckBox(frmComp).State := cbGrayed;
      if i = 0 then TCheckBox(frmComp).SetFocus;
      Continue;
    end;

    if frmComp is TSpeedButton Then
    begin
      if TSpeedButton(frmComp).Tag = 1 then
      begin
        TSpeedButton(frmComp).Visible := True;
        TSpeedButton(frmComp).Enabled := True;
      end;
      Continue;
    end;

    if frmComp is TButton Then
    begin
      TButton(frmComp).Enabled := True;
      Continue;
    end;

    if frmComp is TBitBtn then
    begin
      TBitBtn(frmComp).Enabled := True;
      Continue;
    end;

    if frmComp is TMemo then
    begin
      TMemo(frmComp).Color := clWindow;
      TMemo(frmComp).Clear;
      if i = 0 then TMemo(frmComp).SetFocus;
      Continue;
    end;
    
  end;
end;

function GetWhereStr(aForm: TForm; Controls: Array of TUser): String;
var
  i: integer;
  ControlStr:String;
  FieldName:String;
  FieldType:String;
  frmComp:TComponent;
  strTmp: String;
begin
  strTmp := ' 1=1';
  for i := Low(Controls) to High(Controls) do
  begin
    ControlStr := '';
    frmComp:=Controls[i].Controls;
    FieldName:=Controls[i].Fieldname;
    FieldType:=Controls[i].Fieldtype;

    if (frmComp is TEdit) then
    begin
      ControlStr:=(frmComp as TEdit).Text;
      if ControlStr <> '' then strTmp := strTmp + ' AND '+ QBE_Change(FieldName,FieldType,ControlStr);
      Continue;
    end;

    if (frmComp is TCombobox) then
    begin
      ControlStr:=GetComboboxindex((frmComp as TCombobox).Text);
      if ControlStr <> '' then strTmp := strTmp + ' AND '+ QBE_Change(FieldName,FieldType,ControlStr);
      Continue;
    end;

    if (frmComp is TCheckbox) then
    begin
      case  TCheckbox(frmComp).State of
        cbChecked:ControlStr:='Y';
        cbGrayed: ControlStr:= '';
        cbUnchecked: ControlStr:= 'N';
      end;
      if ControlStr <> '' then strTmp := strTmp + ' AND '+ QBE_Change(FieldName,FieldType,ControlStr);
      Continue;
    end;
    if FieldName = '' then Continue;
  end;
  if Length(strTmp) > 4 then strTmp := RightStr(strTmp,Length(strTmp)-9);
  Result:=strTmp;
end;

function GetFieldName(strHint: String): String;
begin
  if (strHint = '') or (Pos('|',strHint)= 0) then
    Result := ''
  else
    Result := LeftStr(strHint,Pos('|',strHint)-1);
end;

function GetFieldType(intTag: Integer): String;
begin

  case (intTag mod 100) of
    1: Result := 'C';
    2: Result := 'I';
    3: Result := 'D';
  else
    Result := 'C';
  end;
end;

function GetWhereStr(aForm: TForm; Controls: Array of TControl): String;
var
  i: integer;
  ControlStr:String;
  FieldName:String;
  FieldType:String;
  frmComp:TComponent;
  strTmp: String;
begin
  strTmp := ' 1=1';
  for i := Low(Controls) to High(Controls) do
  begin
    ControlStr := '';
    frmComp:=Controls[i];
    if frmComp = Nil then Continue;
    if (frmComp is TEdit) then
    begin
      ControlStr:=(frmComp as TEdit).Text;
      FieldName := GetFieldName((frmComp as TEdit).Hint);
      FieldType := GetFieldType((frmComp as TEdit).Tag);
      if ControlStr <> '' then strTmp := strTmp + ' AND '+ QBE_Change(FieldName,FieldType,ControlStr);
      Continue;
    end;

    if (frmComp is TCombobox) then
    begin
      ControlStr:=GetComboboxindex((frmComp as TCombobox).Text);
      FieldName := GetFieldName((frmComp as TCombobox).Hint);
      FieldType := GetFieldType((frmComp as TCombobox).Tag);
      if ControlStr <> '' then strTmp := strTmp + ' AND '+ QBE_Change(FieldName,FieldType,ControlStr);
      Continue;
    end;

    if (frmComp is TCheckbox) then
    begin
      case  TCheckbox(frmComp).State of
        cbChecked:ControlStr:='Y';
        cbGrayed: ControlStr:= '';
        cbUnchecked: ControlStr:= 'N';
      end;
      FieldName := GetFieldName((frmComp as TCheckbox).Hint);
      FieldType := GetFieldType((frmComp as TCheckbox).Tag);
      if ControlStr <> '' then strTmp := strTmp + ' AND '+ QBE_Change(FieldName,FieldType,ControlStr);
      Continue;
    end;
    if FieldName = '' then Continue;
  end;
  if Length(strTmp) > 4 then strTmp := RightStr(strTmp,Length(strTmp)-9);
  Result:=strTmp;
end;



end.

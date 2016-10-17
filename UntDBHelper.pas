{ ************************************************************************
  Author: tc.paul 2013/04/25
  Remark: Delphi ADO���ݿⳣ�ò�����װ��Ԫ
  Log: ���ݿ������صķ�װ��������Ҫ�ص㣺��˫���Ŵ���SQL statement�ĵ�����
**************************************************************************}

unit UntDBHelper;

interface

uses StrUtils, ADODB, DB, Classes;

function ConvertSQL(strSQL: String): String;
function ExecuteSQL(strSQL: String; var Query: TADOQuery): Boolean;
function ExecuteScalar(strSQL: String; var Query: TADOQuery; out Value: Integer): Boolean;overload;
function ExecuteScalar(strSQL: String; var Query: TADOQuery; out Value: Single): Boolean;overload;
function ExecuteScalar(strSQL: String; var Query: TADOQuery; out Value: Double): Boolean;overload;
function ExecuteScalar(strSQL: String; var Query: TADOQuery; out Value: String): Boolean;overload;
function ExecuteScalar(strSQL: String; var Query: TADOQuery; out Value: TDatetime): Boolean;overload;
function OpenDS(strSQL: String; var Query: TADOQuery): Boolean;
function GetList(strSQL: String; var Query: TADOQuery):TStringList;

implementation

function ConvertSQL(strSQL: String): String;
begin
  Result := AnsiReplaceStr(strSQL,'"',#39);
end;

function ExecuteSQL(strSQL: String; var Query: TADOQuery): Boolean;
begin
  if Query.State <> dsInactive then Query.Close;
  Query.SQL.Text := ConvertSQL(strSQL);
  try
    Query.ExecSQL;
    Result := True;
  except
    raise;
    Result := False;
  end;
end;

function ExecuteScalar(strSQL: String; var Query: TADOQuery; out Value: Integer): Boolean;overload;
begin
  with Query do
  begin
    if State <> dsInactive then Close;
    SQL.Text := ConvertSQL(strSQL);
    try
      Open;
      if RecordCount > 0 then Value := Fields[0].AsInteger else Value := -9999;
      Close;
      Result := True;
    except
      raise;
      Result := False;
    end;
  end;
end;

function ExecuteScalar(strSQL: String; var Query: TADOQuery; out Value: Single): Boolean;overload;
begin
  with Query do
  begin
    if State <> dsInactive then Close;
    SQL.Text := ConvertSQL(strSQL);
    try
      Open;
      if RecordCount > 0 then Value := Fields[0].AsFloat else Value := -9999;
      Close;
      Result := True;
    except
      raise;
      Result := False;
    end;
  end;
end;

function ExecuteScalar(strSQL: String; var Query: TADOQuery; out Value: Double): Boolean;overload;
begin
  with Query do
  begin
    if State <> dsInactive then Close;
    SQL.Text := ConvertSQL(strSQL);
    try
      Open;
      if RecordCount > 0 then Value := Fields[0].AsFloat else Value := -9999;
      Close;
      Result := True;
    except
      raise;
      Result := False;
    end;
  end;
end;

function ExecuteScalar(strSQL: String; var Query: TADOQuery; out Value: String): Boolean;overload;
begin
  with Query do
  begin
    if State <> dsInactive then Close;
    SQL.Text := ConvertSQL(strSQL);
    try
      Open;
      if RecordCount > 0 then Value := Fields[0].AsString else Value := '';
      Close;
      Result := True;
    except
      raise;
      Result := False;
    end;
  end;
end;

function ExecuteScalar(strSQL: String; var Query: TADOQuery; out Value: TDatetime): Boolean;overload;
begin
  with Query do
  begin
    if State <> dsInactive then Close;
    SQL.Text := ConvertSQL(strSQL);
    try
      Open;
      if RecordCount > 0 then Value := Fields[0].AsDateTime;
      Close;
      Result := True;
    except
      raise;
      Result := False;
    end;
  end;
end;

function OpenDS(strSQL: String; var Query: TADOQuery): Boolean;
begin
  with Query do
  begin
    if State <> dsInactive then Close;
    SQL.Text := ConvertSQL(strSQL);
    try
      Open;
      Result := True;
    except
      raise;
      Result := False;
    end;
  end;
end;

//��ȡ���ݿ���ĳһ�е�����ֵ��һ��TStringList��
function GetList(strSQL: String; var Query: TADOQuery):TStringList;
begin
  result := TStringList.Create;
  OpenDS(strSQL,Query);
  while not Query.Eof do
  begin
    result.Add(Query.Fields[0].AsString);
    Query.Next;
  end;
end;


end.

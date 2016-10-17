{ *********************************************************************** }
{                                                                         }
{ Tiptop Cust User Interface Library                                      }
{ 功能：封装Form UI相关函数                                               }
{ Author: Audix.tc.paul                                                   }
{ CreateDate: 2012-09-21                                                  }
{                                                                         }
{ *********************************************************************** }

unit UntUI;

interface

uses
  StdCtrls, SysUtils, StrUtils, Classes, Graphics, Forms, Buttons, cxGridTableView;

  function ComboboxValue(AComboBox: TComboBox): String;overload;      {取ComboBox的Text字符串:前面的数据值}
  function ComboboxValue(ASource: String): String;overload;           {取ComboBox的Text字符串:前面的数据值}
  procedure SetVCLStatus(FrmComp:TComponent; const Status: Byte);     {设定控件状态1:必输2:非必输3:不可输入}
  procedure ClearForm(AForm: TForm);                                  {清空窗体上控件的内容值}
  procedure DisableAllVCL(AForm: TForm);                              {Disable用户输入区所有控件}
  procedure EnableAllVCL(AForm: TForm; BGGrayed: Boolean = True);     {Enable用户输入区所有控件}
  procedure DisableAllGroupBox(AForm: TForm);                         {disable所有的groupbox控件}
  procedure EnableAllGroupBox(AForm: TForm);                          {Enable所有的groupbox控件}
  procedure Construct(aForm: TForm);                                  {设定查询控件为输入}  

implementation

uses UntGlobal, UntShowData;

function ComboboxValue(AComboBox: TComboBox): String;
begin
  if Trim(AComboBox.Text)='' then
    Result:=''
  else
    Result := LeftStr(AComboBox.Text,Pos(':',AComboBox.Text) - 1);
end;

function ComboboxValue(ASource: String): String;
begin
  if Trim(ASource)='' then
    Result:=''
  else
    Result := LeftStr(ASource,Pos(':',ASource) - 1);
end;

procedure SetVCLStatus(FrmComp:TComponent; const Status: Byte);
begin
  if FrmComp is TEdit then
  begin
    case Status of
      1:
        begin
          TEdit(FrmComp).Enabled := True;
          TEdit(FrmComp).Color := myYellow;
        end;
      2:
        begin
          TEdit(FrmComp).Enabled := True;
          TEdit(FrmComp).Color := clWindow;
        end;
    else
      begin
        TEdit(FrmComp).Enabled := False;
        TEdit(FrmComp).Color := clBtnFace;
      end;
    end;
    Exit;
  end;

  if FrmComp is TComboBox then
  begin
    case Status of
      1:
        begin
          TComboBox(FrmComp).Enabled := True;
          TComboBox(FrmComp).Color := myYellow;
        end;
      2:
        begin
          TComboBox(FrmComp).Enabled := True;
          TComboBox(FrmComp).Color := clWindow;
        end;
    else
      begin
        TComboBox(FrmComp).Enabled := False;
        TComboBox(FrmComp).Color := clBtnFace;
      end;
    end;
    Exit;
  end;

  if FrmComp is TCheckBox then
  begin
    case Status of
      1:TCheckBox(FrmComp).Enabled := True;
      2:TCheckBox(FrmComp).Enabled := True;
    else
      TCheckBox(FrmComp).Enabled := False;
    end;
    Exit;
  end;

  if FrmComp is TSpeedButton then
  begin
    case Status of
      1:TSpeedButton(FrmComp).Enabled := True;
      2:TSpeedButton(FrmComp).Enabled := True;
    else
      TSpeedButton(FrmComp).Enabled := False;
    end;
    Exit;
  end;
end;


procedure ClearForm(AForm: TForm);
var
  i: integer;
  frmComp:TComponent;
begin
  for i := 0 to AForm.ComponentCount-1 do
  begin
    frmComp := AForm.Components[i];
    if frmComp is TEdit then
    begin
      TEdit(frmComp).Clear;
      Continue;
    end;

    if frmComp is TCheckBox then
    begin
      TCheckBox(frmComp).Checked := False;
      Continue;
    end;

    if frmComp is TComboBox then
    begin
      TComboBox(frmComp).ItemIndex := -1;
      Continue;
    end;

    if frmComp is TMemo then
    begin
      TMemo(frmComp).Clear;
      Continue;
    end;
  end;
end;

procedure DisableAllVCL(AForm: TForm);
var
  i:Integer;
  frmComp:TComponent;
begin
  for i:=0 to Aform.ComponentCount-1 do
  begin
    frmComp:=Aform.Components[i];
    if frmComp is TEdit Then
    begin
      TEdit(frmComp).Color := clBtnFace;
      TEdit(frmComp).Enabled := False;
      Continue;
    end;

    if frmComp is TCombobox Then
    begin
      TComboBox(frmComp).Color := clBtnFace;
      TComboBox(frmComp).Enabled := False;
      Continue;
    end;

    if frmComp is TCheckBox Then
    begin
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
      if TSpeedButton(frmComp).Name = 'btnOK' then Continue;
      if TSpeedButton(frmComp).Name = 'btnCancel' then Continue;
      if TSpeedButton(frmComp).Name = 'btnConfirm' then Continue;
      if TSpeedButton(frmComp).Name = 'btnUndoConfirm' then Continue;
      if TSpeedButton(frmComp).Name = 'btnNGItem' then Continue;
      TSpeedButton(frmComp).Enabled := False;
      Continue;
    end;

    if frmComp is TMemo then
    begin
      TMemo(frmComp).Enabled := False;
      TMemo(frmComp).Color := clBtnFace;
      Continue;
    end;

    if frmComp is TGroupBox then
    begin
      TGroupBox(frmComp).Enabled := False;
    end;
  end;
end;

procedure EnableAllVCL(AForm: TForm; BGGrayed: Boolean = True);
var
  i:Integer;
  frmComp:TComponent;
begin
  for i:=0 to Aform.ComponentCount-1 do
  begin
    frmComp:=Aform.Components[i];
    if frmComp is TEdit Then
    begin
      TEdit(frmComp).Enabled := True;
      if BGGrayed then TEdit(frmComp).Color := clBtnFace else TEdit(frmComp).Color := clWindow;
      Continue;
    end;

    if frmComp is TCombobox Then
    begin
      TComboBox(frmComp).Enabled := True;
      if BGGrayed then TComboBox(frmComp).Color := clBtnFace else TComboBox(frmComp).Color := clWindow;
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

    if frmComp is TSpeedButton Then
    begin
      TSpeedButton(frmComp).Enabled := True;
      Continue
    end;

    if frmComp is TMemo then
    begin
      TMemo(frmComp).Enabled := True;
      if BGGrayed then TMemo(frmComp).Color := clBtnFace else TMemo(frmComp).Color := clWindow;
      Continue;
    end;

    if frmComp is TGroupBox then
    begin
      TGroupBox(frmComp).Enabled := False;
    end;
  end;
end;

procedure DisableAllGroupBox(AForm: TForm);
var
  i:Integer;
begin
  for i:=0 to Aform.ComponentCount-1 do
    if Aform.Components[i] is TGroupBox then TGroupBox(Aform.Components[i]).Enabled := False;
end;

procedure EnableAllGroupBox(AForm: TForm);
var
  i:Integer;
begin
  for i:=0 to Aform.ComponentCount-1 do
    if Aform.Components[i] is TGroupBox then TGroupBox(Aform.Components[i]).Enabled := True;
end;

procedure Construct(aForm: TForm); 
var
  i: integer;
begin
  for i := Low(Ctrls) to High(Ctrls) do
  begin
    if Ctrls[i] = Nil then Continue;
    SetVCLStatus(Ctrls[i],1);
  end;
end;



end.

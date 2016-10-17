{ ***********************************************************************
 Delphi User Interface Extened Library
 功能：封装Form UI相关函数
 Author: audix.tc.paul 2015-11-16
 Log:
     01. paul 2016/04/15 增加函数:SetComboItemsFromConfig
     02. paul 2016/05/03 增加函数:FixDBGridColumnsWidth、AutoFitDBGridColumnsWidth
     03. paul 2016/05/11 增加函数:FindComponentEx(通过控件的Name找到控件本身)
 *********************************************************************** }

unit UntUIExt;

interface

uses
  Forms, Classes, StdCtrls, Graphics, Buttons, Controls, TypInfo, Windows,
  SysUtils, DBGrids;

type TInputStatus = (MustInput, EnableInput, DisableInput);

procedure ClearForm(form: TForm);
procedure DisableControls(AForm: TForm);
procedure EnableControls(form: TForm; BGGrayed: Boolean = false);
procedure SetForm3D(form: TForm; ctl3d: boolean = false);
procedure SetInputStatus(Comps: array of TComponent; ts: TInputStatus);
procedure SetComboIndex(var combo: TComboBox; text: String);
procedure SetComboItemsFromConfig(var combo: TComboBox; iniSection: string; iniCountTitle: string);
procedure FixDBGridColumnsWidth(const DBGrid: TDBGrid);
procedure AutoFitDBGridColumnsWidth(const DBGrid: TDBGrid);
function FindComponentEx(const Name: string): TComponent;


implementation

uses UntUtility;

procedure ClearForm(form: TForm);
var
  i: integer;
  frmComp:TComponent;
begin
  for i := 0 to form.ComponentCount-1 do
  begin
    frmComp := form.Components[i];
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

procedure DisableControls(AForm: TForm);
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

procedure EnableControls(form: TForm; BGGrayed: Boolean = false);
var
  i:Integer;
  frmComp:TComponent;
begin
  for i:=0 to form.ComponentCount-1 do
  begin
    frmComp:=form.Components[i];
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

procedure SetForm3D(form: TForm; ctl3d: boolean = false);
var
  i:Integer;
  frmComp:TComponent;
  PropInfo: PPropInfo;
begin
  for i:=0 to form.ComponentCount-1 do
  begin
    frmComp:=form.Components[i];
    //具有Ctl3D属性的先设置Ctl3D属性
    PropInfo := GetPropInfo(frmComp.ClassInfo, 'Ctl3D');
    if Assigned(PropInfo) then
    begin
      SetOrdProp(frmComp, PropInfo,  Longint(ctl3d));
    end;
    //对于下面的这些奇葩再单独修理
    if frmComp is TCombobox Then
    begin
      TComboBox(frmComp).BevelKind := bkFlat;
      Continue;
    end;
  end;
end;

procedure SetInputStatus(Comps: array of TComponent; ts: TInputStatus);
var
  Loop: Integer;
  PropInfo: PPropInfo;
  color : TColor;
begin
  for Loop := Low(Comps) to High(Comps) do
  begin
      PropInfo := GetPropInfo(Comps[Loop].ClassInfo, 'Color');
      if Assigned(PropInfo) then
      begin
        case ts of
          MustInput :
            begin
              color := RGB(255,255,153);
              SetOrdProp(Comps[Loop], PropInfo,  Longint(color));
              TControl(Comps[Loop]).Enabled := True;
            end;
          EnableInput:
            begin
              color := clWindow;
              SetOrdProp(Comps[Loop], PropInfo,  Longint(color));
              TControl(Comps[Loop]).Enabled := True;
            end;
          DisableInput:
            begin
              color := clBtnFace;
              SetOrdProp(Comps[Loop], PropInfo,  Longint(color));
              TControl(Comps[Loop]).Enabled := False;;
            end;
        end;
      end;
  end;
end;

procedure SetComboIndex(var combo: TComboBox; text: String);
var
  i: integer;
begin
  combo.ItemIndex := -1;
  for i:= 0 to combo.Items.Count -1 do
    if combo.Items[i] = text then
    begin
      combo.ItemIndex := i;
      break;
    end;
end;

procedure SetComboItemsFromConfig(var combo: TComboBox; iniSection: string; iniCountTitle: string);
var
  i: integer;
  list: TStrings;
begin
  list := TStringList.Create;
  for i := 1 to ReadIniInt(iniSection,iniCountTitle) do
    list.Add(ReadIniStr(iniSection,IntToStr(i)));
  if list.Count > 0 then
  begin
    combo.Items.Clear;
    combo.Items.Assign(list);
  end;
  list.Free;
end;

procedure FixDBGridColumnsWidth(const DBGrid: TDBGrid);
var
  i : integer;
  TotWidth : integer;
  VarWidth : integer;
  OsWidth : integer;
  ResizableColumnCount : integer;
  AColumn : TColumn;
begin
  TotWidth := 0;
  ResizableColumnCount := 0;

  for i := 0 to DBGrid.Columns.Count - 1 do
  begin
    TotWidth := TotWidth + DBGrid.Columns[i].Width;
    Inc(ResizableColumnCount);
  end;

  //add 1px for the column separator line
  if dgColLines in DBGrid.Options then
    TotWidth := TotWidth + DBGrid.Columns.Count;

  //add indicator column width
  if dgIndicator in DBGrid.Options then
    TotWidth := TotWidth + IndicatorWidth;

  //width vale "left"
  VarWidth :=  DBGrid.ClientWidth - TotWidth;

  //Equally distribute VarWidth
  //to all auto-resizable columns
  if ResizableColumnCount > 0 then
    VarWidth := varWidth div ResizableColumnCount;

  for i := 0 to DBGrid.Columns.Count -1 do
  begin
    AColumn := DBGrid.Columns[i];
    AColumn.Width := AColumn.Width + VarWidth;
  end;

  //把差异部分修改掉
  TotWidth := 0;
  for i := 0 to DBGrid.Columns.Count -1 do
    TotWidth := TotWidth + DBGrid.Columns[i].Width;
  if dgColLines in DBGrid.Options then
    TotWidth := TotWidth + DBGrid.Columns.Count;
  if dgIndicator in DBGrid.Options then
    TotWidth := TotWidth + IndicatorWidth;
  OsWidth := DBGrid.ClientWidth - TotWidth;
  DBGrid.Columns[0].Width := DBGrid.Columns[0].Width + OsWidth;
end;

procedure AutoFitDBGridColumnsWidth(const DBGrid: TDBGrid);
var
  i: integer;
  TotWidth,CellWidth,OsWidth: integer;
begin
  TotWidth := DBGrid.ClientWidth;
  //1px ColLine
  if dgColLines in DBGrid.Options then
    TotWidth := TotWidth - DBGrid.Columns.Count;
  if dgIndicator in DBGrid.Options then
    TotWidth := TotWidth - IndicatorWidth;
  CellWidth := TotWidth div DBGrid.Columns.Count;
  for i := 0 to DBGrid.Columns.Count -1 do
    DBGrid.Columns[i].Width := CellWidth;
  //把运算中多出来的部分放在第一列上面
  OsWidth := TotWidth - CellWidth * DBGrid.Columns.Count;
  DBGrid.Columns[0].Width := DBGrid.Columns[0].Width + OsWidth;
end;

function FindComponentEx(const Name: string): TComponent;
var
  FormName: string;
  CompName: string;
  P: Integer;
  Found: Boolean;
  Form: TForm;
  I: Integer;
begin
  Form := Nil;
  // Split up in a valid form and a valid component name
  P := Pos('.', Name);
  if P = 0 then
  begin
    raise Exception.Create('No valid form name given');
  end;
  FormName := Copy(Name, 1, P - 1);
  CompName := Copy(Name, P + 1, High(Integer));
  Found := False;
  // find the form
  for I := 0 to Screen.FormCount - 1 do
  begin
    Form := Screen.Forms[I];
    // case insensitive comparing
    if AnsiSameText(Form.Name, FormName) then
    begin
      Found := True;
      Break;
    end;
  end;
  if Found then
  begin
    for I := 0 to Form.ComponentCount - 1 do
    begin
      Result := Form.Components[I];
      if AnsiSameText(Result.Name, CompName) then Exit;
    end;
  end;
  Result := nil;
end;



end.

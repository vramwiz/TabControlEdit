unit TabControlEdit;

{
  TabControlEdit.pas
  ------------------
  �g���^ TTabControlEdit �R���|�[�l���g

  �T�v:
    �{���j�b�g�́A�W���� TTabControl �R���|�[�l���g���g�����A
    �^�u�̃L���v�V�������_�u���N���b�N�܂��͎w�葀��ɂ��
    �ҏW�ł���@�\��ǉ����܂��B

  ��ȋ@�\:
    - �^�u����TEdit�Œ��ڕҏW�\
    - �ҏW�J�n���A�I�����A�L�����Z�����̃C�x���g���
      �ETEditTabControlBegin = �ҏW�J�n���̃R�[���o�b�N
      �ETEditTabControlEnd   = �ҏW�I�����̃R�[���o�b�N
      �EOnEditCancel         = �ҏW�L�����Z�����̃C�x���g
    - �ҏW�p�|�b�v�A�b�v���j���[�Ή�
    - �}�E�X�z�C�[���A�t�H�[�J�X�A�L�[����Ȃǂ�K�؂ɏ���

  �g�p���@:
    - �t�H�[���� TTabControlEdit ��z�u���邾���œ��삵�܂��B
    - �ҏW�Ώۂ̃^�u�����[�U�[���_�u���N���b�N����ƁA�ҏW���[�h�ɂȂ�܂��B
    - �ҏW������AOnEditEnd �C�x���g�ŐV�������O���擾�ł��܂��B


}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls,Vcl.ComCtrls, Vcl.Menus;

type TEditTabControlBegin = procedure (Sender : TObject; var EditStr : string) of object;
type TEditTabControlEnd = procedure (Sender : TObject;const  EditStr : string) of object;


//--------------------------------------------------------------------------//
//  �^�u�R���g���[���̖��̂�ҏW�\�ɂ���g���^�u�R���g���[���N���X        //
//--------------------------------------------------------------------------//
type
  TTabControlEdit = class(TTabControl)
	private
		{ Private �錾 }
    FEdit        : TEdit;
    FProc        : TWndMethod;
    FPopMenu     : TPopupMenu;      // �|�b�v�A�b�v���j���[���ꎞ�Ҕ�
    FEditing     : Boolean;         // True;�ҏW��

    FOnEditBegin : TEditTabControlBegin;
    FOnEditEnd   : TEditTabControlEnd;
    FOnEditCancel: TNotifyEvent;
    // �O������̕ҏW�L���I������
    procedure EditEnd();
    // �O������̕ҏW��������
    procedure EditCancel();

    // �z�C�[���X�N���[���C�x���g
    procedure WMMousewheel(var Msg: TMessage); message WM_MOUSEWHEEL;

    procedure DraRectClear(cv: TCanvas; TabIndex: Integer; Rect: TRect);
    // �w�i�h��Ԃ��̕`���s�̂ݏ������O��������g����悤��
    procedure DrawRect(Canvas: TCanvas; TabIndex: Integer; Rect: TRect;Active: Boolean);
    // �w�肵���̈�Ƀ^�u�̑�`��`��
    procedure DrawRectPolygon(Canvas: TCanvas;Rect: TRect);
    procedure TextOut(Canvas: TCanvas;Rect: TRect;Active: Boolean;const str : string);

    procedure OnEditExit(Sender: TObject);
    procedure OnEditKeyPress(Sender: TObject; var Key: Char);
    procedure SetTabColorStriped(const Value: Boolean);
  protected
    procedure DoEditBegin(var EditStr : string);virtual;
    procedure DoEditEnd(const EditStr : string);virtual;
    procedure DoEditCencel();virtual;
    procedure Change();override;
    procedure DblClick;override;
    procedure DrawTab(TabIndex: Integer; const Rect: TRect; Active: Boolean); override;
    // �E�C���h�E���b�Z�[�W���t�b�N
    procedure WMProc(var Msg:TMessage);
    procedure WMUserFocusSelf(var Msg: TMessage);
  public
		{ Public �錾 }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy;override;
    // �O������ҏW�J�n��Ԃ�
    procedure BeginEdit();
    // True : �ҏW��
    property Editing : Boolean read FEditing;
    // True:���ږ��ɔw�i�F��ς���
    property TabColorStriped : Boolean write SetTabColorStriped;
    // �ҏW�J�n�C�x���g
    property OnEditBegin : TEditTabControlBegin read FOnEditBegin write FOnEditBegin;
    // �ҏW��L���ɂ��ďI������C�x���g
    property OnEditEnd    : TEditTabControlEnd read FOnEditEnd write FOnEditEnd;
    // �ҏW�𖳌��ɂ��ďI������C�x���g
    property OnEditCancel    : TNotifyEvent read FOnEditCancel write FOnEditCancel;
  published
    property OnDblClick;
  end;

implementation

const
  COLOR_CURSOL = clNavy;
  WM_USER_FOCUSSELF = WM_USER + 100;

{ TTabControlEdit }

procedure TTabControlEdit.Change;
begin
  EditCancel();
  inherited;
end;

constructor TTabControlEdit.Create(AOwner: TComponent);
begin
  inherited;

  FProc := WindowProc;
  WindowProc := WMProc;

  ControlStyle := ControlStyle + [csClickEvents];

  FEdit := TEdit.Create(Self);
  FEdit.Parent := Self;
  FEdit.Visible := False;
  FEdit.OnExit := OnEditExit;
  FEdit.OnKeyPress := OnEditKeyPress;
end;

procedure TTabControlEdit.DblClick;
begin
  inherited;
  BeginEdit();
end;

destructor TTabControlEdit.Destroy;
begin
  WindowProc := FProc;
  FEdit.Free;
  inherited;
end;

procedure TTabControlEdit.DraRectClear(cv: TCanvas; TabIndex: Integer;  Rect: TRect);
begin
  cv.Brush.Style := bsSolid;
  cv.Brush.Color := clBtnFace;
  cv.FillRect(Rect);
end;

procedure TTabControlEdit.DrawRect(Canvas: TCanvas; TabIndex: Integer;Rect: TRect; Active: Boolean);
var
  cv : TCanvas;
  cF,cB : TColor;     // �ʏ펞�̕����F�Ɣw�i�F
begin
  cv := Canvas;
  if TabIndex mod 2 = 0 then begin
    cb := $00FFF0F0;
    cF := clBlack;
  end
  else begin
    cb := $00FFC0C0;
    cF := clBlack;
  end;
  if Active  then begin
    CB := COLOR_CURSOL ;
    CF := clWhite;
  end;

  cv.Brush.Color:= cB;
  cv.Font.Color := cF;
  DrawRectPolygon(cv,Rect);
end;

procedure TTabControlEdit.DrawRectPolygon(Canvas: TCanvas; Rect: TRect);
var
  p : array[0..4] of TPoint;
begin
  p[0].X := Rect.Left;
  p[0].Y := Rect.Bottom;
  p[1].X := Rect.Left + 2;
  p[1].Y := Rect.Top;
  p[2].X := Rect.Right - 2;
  p[2].Y := Rect.Top;
  p[3].X := Rect.Right;
  p[3].Y := Rect.Bottom;
  p[4].X := Rect.Left;
  p[4].Y := Rect.Bottom;
  Canvas.Polygon(p);
end;

procedure TTabControlEdit.DrawTab(TabIndex: Integer; const Rect: TRect;
  Active: Boolean);
var
  cv : TCanvas;
  s : string;
begin
  inherited;
  cv := Canvas;
  s := Tabs.Strings[TabIndex];
  //DraRectClear(cv,TabIndex,Rect);
  DrawRect(cv,TabIndex,Rect,Active);
  TextOut(cv,Rect,Active,s);
end;

procedure TTabControlEdit.EditCancel;
begin
  if not Visible then exit;
  FEdit.Visible := False;
  if FPopMenu<> nil then PopupMenu := FPopMenu;       // �|�b�v���j���[�𕜌�
  FEditing := False;
  DoEditCencel();
  // �t�H�[�J�X�𒼐ڈړ������A�x���ő���
  PostMessage(Self.Handle, WM_USER_FOCUSSELF, 0, 0);
end;

procedure TTabControlEdit.EditEnd;
var
  i : Integer;
begin
  i :=TabIndex;
  if i =-1 then exit;
  DoEditEnd(FEdit.Text);
  Tabs[i] := FEdit.Text;
  FEdit.Visible := False;
  PopupMenu := FPopMenu;
  Self.SetFocus;
  FEditing := False;
end;


procedure TTabControlEdit.BeginEdit;
var
  str : string;
  i : Integer;
begin
  if FEdit.Visible then EditEnd();        // �ҏW���̏ꍇ�A�ҏW���ʂ�L���ɂ��Ă���ҏW
  FPopMenu := PopupMenu;
  PopupMenu := nil;
  FEditing := True;
  i := TabIndex;
  if i = -1 then exit;
  str := Tabs[i];
  DoEditBegin(str);
  if FEdit <> nil then begin
    FEdit.Left := TabRect(TabIndex).Left;
    FEdit.Top := 0;                       // �\�����W�v�Z
    FEdit.Width := TabRect(TabIndex).Width;
  end;
  FEdit.Text := str;
  FEdit.Visible := True;
  //FEdit.AutoSize := true;
  FEdit.SelectAll;
  FEdit.SetFocus;
end;

procedure TTabControlEdit.OnEditExit(Sender: TObject);
begin
  EditCancel();
end;

procedure TTabControlEdit.OnEditKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #$0d then begin
    EditEnd();
    Key := #0;
  end;
  if Key = #$1b then begin
    EditCancel();
    Key := #0;
  end;
end;

//--------------------------------------------------------------------------//
//  True:�Ǝ��̕`�揈�����s��                                               //
//--------------------------------------------------------------------------//
procedure TTabControlEdit.SetTabColorStriped(const Value: Boolean);
begin
  OwnerDraw := Value;
  if Value then  Style := tsButtons;
  
end;

procedure TTabControlEdit.TextOut(Canvas: TCanvas; Rect: TRect; Active: Boolean;  const str: string);
var
  cv : TCanvas;
begin
  cv := Canvas;
  if Active then begin
    cv.Brush.Color := COLOR_CURSOL ;
    cv.Font.Color  := clWhite;
  end;
  cv.Brush.Style := bsClear;
  cv.TextOut(Rect.Left+5,Rect.Top+3,str);

end;

procedure TTabControlEdit.DoEditEnd(const EditStr: string);
begin
  if Assigned(FOnEditEnd) then begin
    FOnEditEnd(Self,EditStr);
  end;
end;

procedure TTabControlEdit.DoEditBegin(var EditStr: string);
begin
  if Assigned(FOnEditBegin) then begin
    FOnEditBegin(Self,EditStr);
  end;
end;


procedure TTabControlEdit.DoEditCencel;
begin
  if Assigned(FOnEditCancel) then begin
    FOnEditCancel(Self);
  end;
end;

const TCM_GETITEMCOUNT = $1304;        // �^�u�̌����擾���ǉ����ɑ����Ă���
      TCM_DELETEITEM   = $1308;        // �^�u�폜

procedure TTabControlEdit.WMMousewheel(var Msg: TMessage);
var
  i,d : Integer;
begin
  d := shortint(HiWord(Msg.wParam));
  i := TabIndex;
  if (d > 0) then begin                // �z�C�[������
    // left
    if i < 1 then exit;
    Dec(i);
    TabIndex := i;
    Change();
  end
  else begin                           // �z�C�[����O
    //  right
    if i >= Tabs.Count then exit;
    Inc(i);
    TabIndex := i;
    Change();
  end;
end;

procedure TTabControlEdit.WMProc(var Msg: TMessage);
begin
  FProc(Msg);                             // ���̃v���Z�X�ɂ�����
  case Msg.Msg of
    WM_HSCROLL       :EditCancel;
    TCM_DELETEITEM   :EditCancel;
    WM_SIZE          :EditCancel;
    WM_USER_FOCUSSELF:WMUserFocusSelf(Msg);
  end;
end;

procedure TTabControlEdit.WMUserFocusSelf(var Msg: TMessage);
begin
  if CanFocus then Self.SetFocus;
end;

end.

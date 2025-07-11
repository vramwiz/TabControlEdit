unit TabControlEdit;

{
  TabControlEdit.pas
  ------------------
  拡張型 TTabControlEdit コンポーネント

  概要:
    本ユニットは、標準の TTabControl コンポーネントを拡張し、
    タブのキャプションをダブルクリックまたは指定操作により
    編集できる機能を追加します。

  主な機能:
    - タブ名をTEditで直接編集可能
    - 編集開始時、終了時、キャンセル時のイベントを提供
      ・TEditTabControlBegin = 編集開始時のコールバック
      ・TEditTabControlEnd   = 編集終了時のコールバック
      ・OnEditCancel         = 編集キャンセル時のイベント
    - 編集用ポップアップメニュー対応
    - マウスホイール、フォーカス、キー操作などを適切に処理

  使用方法:
    - フォームに TTabControlEdit を配置するだけで動作します。
    - 編集対象のタブをユーザーがダブルクリックすると、編集モードになります。
    - 編集完了後、OnEditEnd イベントで新しい名前を取得できます。


}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls,Vcl.ComCtrls, Vcl.Menus;

type TEditTabControlBegin = procedure (Sender : TObject; var EditStr : string) of object;
type TEditTabControlEnd = procedure (Sender : TObject;const  EditStr : string) of object;


//--------------------------------------------------------------------------//
//  タブコントロールの名称を編集可能にする拡張タブコントロールクラス        //
//--------------------------------------------------------------------------//
type
  TTabControlEdit = class(TTabControl)
	private
		{ Private 宣言 }
    FEdit        : TEdit;
    FProc        : TWndMethod;
    FPopMenu     : TPopupMenu;      // ポップアップメニューを一時待避
    FEditing     : Boolean;         // True;編集中

    FOnEditBegin : TEditTabControlBegin;
    FOnEditEnd   : TEditTabControlEnd;
    FOnEditCancel: TNotifyEvent;
    // 外部からの編集有効終了処理
    procedure EditEnd();
    // 外部からの編集無効処理
    procedure EditCancel();

    // ホイールスクロールイベント
    procedure WMMousewheel(var Msg: TMessage); message WM_MOUSEWHEEL;

    procedure DraRectClear(cv: TCanvas; TabIndex: Integer; Rect: TRect);
    // 背景塗りつぶしの描画代行のみ処理を外部からも使えるように
    procedure DrawRect(Canvas: TCanvas; TabIndex: Integer; Rect: TRect;Active: Boolean);
    // 指定した領域にタブの台形を描画
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
    // ウインドウメッセージをフック
    procedure WMProc(var Msg:TMessage);
    procedure WMUserFocusSelf(var Msg: TMessage);
  public
		{ Public 宣言 }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy;override;
    // 外部から編集開始状態に
    procedure BeginEdit();
    // True : 編集中
    property Editing : Boolean read FEditing;
    // True:項目毎に背景色を変える
    property TabColorStriped : Boolean write SetTabColorStriped;
    // 編集開始イベント
    property OnEditBegin : TEditTabControlBegin read FOnEditBegin write FOnEditBegin;
    // 編集を有効にして終了するイベント
    property OnEditEnd    : TEditTabControlEnd read FOnEditEnd write FOnEditEnd;
    // 編集を無効にして終了するイベント
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
  cF,cB : TColor;     // 通常時の文字色と背景色
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
  if FPopMenu<> nil then PopupMenu := FPopMenu;       // ポップメニューを復元
  FEditing := False;
  DoEditCencel();
  // フォーカスを直接移動せず、遅延で送る
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
  if FEdit.Visible then EditEnd();        // 編集中の場合、編集結果を有効にしてから編集
  FPopMenu := PopupMenu;
  PopupMenu := nil;
  FEditing := True;
  i := TabIndex;
  if i = -1 then exit;
  str := Tabs[i];
  DoEditBegin(str);
  if FEdit <> nil then begin
    FEdit.Left := TabRect(TabIndex).Left;
    FEdit.Top := 0;                       // 表示座標計算
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
//  True:独自の描画処理を行う                                               //
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

const TCM_GETITEMCOUNT = $1304;        // タブの個数を取得※追加時に送られてくる
      TCM_DELETEITEM   = $1308;        // タブ削除

procedure TTabControlEdit.WMMousewheel(var Msg: TMessage);
var
  i,d : Integer;
begin
  d := shortint(HiWord(Msg.wParam));
  i := TabIndex;
  if (d > 0) then begin                // ホイールを奥
    // left
    if i < 1 then exit;
    Dec(i);
    TabIndex := i;
    Change();
  end
  else begin                           // ホイール手前
    //  right
    if i >= Tabs.Count then exit;
    Inc(i);
    TabIndex := i;
    Change();
  end;
end;

procedure TTabControlEdit.WMProc(var Msg: TMessage);
begin
  FProc(Msg);                             // 元のプロセスにも送る
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

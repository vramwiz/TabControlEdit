unit MainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,TabControlEdit, Vcl.StdCtrls, Vcl.Menus;

type
  TFormMain = class(TForm)
    PopupMenu1: TPopupMenu;
    N1: TMenuItem;
    Memo1: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure N1Click(Sender: TObject);
  private
    { Private �錾 }
    FTabControl : TTabControlEdit;
    procedure TabEditBegin(Sender: TObject; var EditStr: string);
    procedure TabEditEnd(Sender: TObject; const EditStr: string);
    procedure TabEditCancel(Sender: TObject);

  public
    { Public �錾 }
  end;

var
  FormMain: TFormMain;

implementation

{$R *.dfm}

procedure TFormMain.FormCreate(Sender: TObject);
begin
  FTabControl := TTabControlEdit.Create(Self);
  FTabControl.Parent := Self;
  FTabControl.Align := alClient;
  //FTabControl.TabColorStriped := true;     // �^�u���ɐF�������ύX
  FTabControl.PopupMenu := PopupMenu1;

  Memo1.Parent := FTabControl; // �����s�V�����������Ȃ�
  Memo1.Align := alClient;

  // �C�x���g�o�^
  FTabControl.OnEditBegin := TabEditBegin;
  FTabControl.OnEditEnd := TabEditEnd;
  FTabControl.OnEditCancel := TabEditCancel;
end;

procedure TFormMain.FormShow(Sender: TObject);
begin
  FTabControl.Tabs.Add('�^�u1');
  FTabControl.Tabs.Add('�^�u2');
  FTabControl.Tabs.Add('�^�u3');
end;

procedure TFormMain.N1Click(Sender: TObject);
begin
  if FTabControl.TabIndex >= 0 then
    FTabControl.BeginEdit();
end;

procedure TFormMain.TabEditBegin(Sender: TObject; var EditStr: string);
begin
  Memo1.Lines.Add('EditBegin:  ' + EditStr);
end;

procedure TFormMain.TabEditEnd(Sender: TObject; const EditStr: string);
begin
  Memo1.Lines.Add('EditEnd:  ' + EditStr);
end;

procedure TFormMain.TabEditCancel(Sender: TObject);
begin
  Memo1.Lines.Add('EditCancel');
end;

end.

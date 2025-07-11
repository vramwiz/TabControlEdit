program TabControlEditSample;

uses
  Vcl.Forms,
  MainForm in 'MainForm.pas' {FormMain},
  TabControlEdit in 'TabControlEdit.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormMain, FormMain);
  Application.Run;
end.

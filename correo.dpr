program correo;

uses
  Vcl.Forms,
  correopop in 'correopop.pas' {fCorreoPop},
  Vcl.Themes,
  Vcl.Styles;

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Auric');
  Application.CreateForm(TfCorreoPop, fCorreoPop);
  Application.Run;
end.

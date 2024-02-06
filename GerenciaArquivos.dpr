program GerenciaArquivos;

uses
  System.StartUpCopy,
  FMX.Forms,
  Main.View in 'Main.View.pas' {FormMain},
  DW.Permissions.Helpers in 'DW.Permissions.Helpers.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFormMain, FormMain);
  Application.Run;
end.

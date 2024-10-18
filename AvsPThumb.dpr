program AvsPThumb;

uses
  Vcl.Forms,
  avisynth in 'avisynth.pas',
  system.Math,
  AvisynthGrabber in 'AvisynthGrabber.pas',
  Main in 'Main.pas' {Form1},
  SingleInstance in 'SingleInstance.pas',
  Vcl.Themes,
  Vcl.Styles;

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  // disable all exceptions (e.g. float div zero)
  system.math.SetExceptionMask(exAllArithmeticExceptions);
  Application.Run;
end.

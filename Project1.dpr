program Project1;

uses
  Forms,
  Unit1 in 'Unit1.pas' {frmHivePal};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmHivePal, frmHivePal);
  Application.Run;
end.

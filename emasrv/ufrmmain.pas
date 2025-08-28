unit ufrmmain;

{$mode objfpc}{$H+}

interface

uses
  Classes,
  SysUtils,
  Forms,
  Controls,
  Graphics,
  Dialogs,
  ExtCtrls,
  ComCtrls,
  StdCtrls;

type

  { Tfrmmain }

  Tfrmmain = class(TForm)
    imgLogo: TImage;
    lblOS: TLabel;
    lblCpu: TLabel;
    mmoLog: TMemo;
    pc: TPageControl;
    pnlHead: TPanel;
    sb: TStatusBar;
    tmr: TTimer;
    tsLog: TTabSheet;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure tmrTimer(Sender: TObject);
  private

  public

  end;

var
  frmmain: Tfrmmain;

implementation

{$R *.lfm}

{ Tfrmmain }

uses
  udmsrv,
  mormot.core.json,
  mormot.core.variants,
  mormot.net.client;

procedure Tfrmmain.tmrTimer(Sender: TObject);
var
  doc: Tdocvariantdata;
begin
  doc.initjson(httpget('http://127.0.0.1:5959/sysinfo'));

  with doc, sb do
  begin
    self.Caption := S['AppTitle'];
    lblcpu.Caption := S['cpu'];
    lblos.Caption := S['os'];
    panels[0].Text := S['AppUnit'];
    panels[1].Text := S['AppVer'];
    panels[2].Text := S['memused'];
  end;
end;

procedure Tfrmmain.FormCreate(Sender: TObject);
begin

end;

procedure Tfrmmain.FormShow(Sender: TObject);
begin
  lblcpu.left := imglogo.Width+10;
  lblos.left := imglogo.Width+10;
  tmrTimer(tmr);
end;

end.

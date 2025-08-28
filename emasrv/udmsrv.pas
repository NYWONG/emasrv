unit udmsrv;
{$define HASMAINFORM}
{$mode ObjFPC}{$H+}

interface

uses
  Classes,
  SysUtils,
  mormot.core.os,
  mormot.core.variants,
  mormot.core.Data,
  mormot.core.Text,
  mormot.core.perf,
  mormot.core.unicode,
  mormot.DB.sql,
  mormot.DB.sql.OleDB,
  mormot.DB.sql.odbc,
  mormot.DB.sql.postgres,
  mormot.DB.sql.sqlite3,
  mormot.DB.raw.sqlite3,
  mormot.DB.raw.sqlite3.static,
  Menus,
  rtcLog,
  rtcInfo,
  rtcConn,
  rtcSystem,
  ExtCtrls,
  rtcHttpSrv,
  rtcDataSrv,
  UniqueInstance,
  ulazautoupdate;

type

  { Tdmsrv }

  Tdmsrv = class(TDataModule)
    au: TLazAutoUpdate;
    pm: TPopupMenu;
    rtcdp: TRtcDataProvider;
    rtchs: TRtcHttpServer;
    ti: TTrayIcon;
    ui: TUniqueInstance;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
    procedure rtcdpCheckRequest(Sender: TRtcConnection);
    procedure rtcdpDataReceived(Sender: TRtcConnection);
    procedure tiDblClick(Sender: TObject);
  private

  public
    procedure srvStart();
    procedure srvStop();
  end;

var
  dmsrv: Tdmsrv;
  gPath: string;
  gConfig: TDocVariantData;
  gDblist: TRawUtf8list;

procedure doLog(const aMsg: string);

implementation

{$R *.lfm}

uses
  {$ifdef HASMAINFORM}
  ufrmmain,
  {$endif}
  dateutils;
{ Tdmsrv }
procedure doLog(const aMsg: string);
begin
  {$ifdef HASMAINFORM}
  if frmmain<>nil then
    frmmain.mmolog.Lines.add(aMsg);
  {$endif}
  xlog(amsg);
end;

procedure Tdmsrv.rtcdpCheckRequest(Sender: TRtcConnection);
begin
  with Sender, request, gConfig do
    if (s['AppPath'] = filename) and wsupgrade then
    begin
      accept;
      response.wsupgrade := True;
      Write();
    end
    else
      accept;
end;

procedure Tdmsrv.rtcdpDataReceived(Sender: TRtcConnection);
begin
  with Sender, request do
    if filename = '/sysinfo' then
    begin
      gconfig.MergeObject(_Json(SystemInfoJson));
      response.contenttype := 'application/json;charset=utf-8';
      Write(gconfig.tojson);
    end
    else if filename = '/date' then
        Write(formatdatetime('yyyy-mm-dd hh:nn:ss.zzz', now));
end;

procedure Tdmsrv.tiDblClick(Sender: TObject);
begin
  {$ifdef HASMAINFORM}
  if frmmain.showing then
    frmmain.hide
  else
    frmmain.Show;
  {$endif}
end;

procedure Tdmsrv.DataModuleCreate(Sender: TObject);
begin
  srvStart;
end;

procedure Tdmsrv.DataModuleDestroy(Sender: TObject);
begin
  srvStop;
end;

procedure Tdmsrv.srvStart();
begin
  with rtchs do
  begin
    listen;
  end;
end;

procedure Tdmsrv.srvStop();
begin
  rtchs.stoplistennow;
end;

initialization
  startlog;
  gPath := exeversion.ProgramFilePath;
  gConfig.initjson(AnyTextFileToRawUtf8(gPath+'config.dat'));
  gDblist := TRawUtf8list.Create(True);
  with gconfig, exeversion.Version do
  begin
    if not exists('AppTitle') then
    begin
      s['AppTitle'] := '测试管理系统名称';
      s['AppUnit'] := '测试使用单位名称';
      s['AppAddr'] := '127.0.0.1';
      s['AppPort'] := '5959';
      s['AppPath'] := '/ws';
      SaveToJsonFile(gPath+'config.dat');
    end;
    GetExecutableVersion;
    s['AppVer'] := formatutf8('%.%.%.%', [major, Minor, Release, Build]);
  end;


finalization
  gDblist.Free;
  stoplog;
end.

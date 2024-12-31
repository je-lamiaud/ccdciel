unit cu_autoguider;

{
Copyright (C) 2015 Patrick Chevalley

http://www.ap-i.net
pch@ap-i.net

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>. 

}

{$mode objfpc}{$H+}

interface

uses u_global, LCLIntf, u_translation, cu_mount, cu_camera, BGRABitmap, cu_fits, fu_internalguider, cu_astrometry,
  Forms, Classes, SysUtils, ExtCtrls;

type

  T_autoguider = class(TThread)
  protected
    FTargetHost,FTargetPort,FErrorDesc,FRecvData,FLastError : string;
    FVersion,FMsgVersion,FStatus : String;
    FSettleTmin,FSettleTmax: Integer;
    FSettlePix: double;
    FRunning, FRecovering,FDithering,FStopGuiding: boolean;
    FProgramPath,FProgramName: string;
    FStartedProgram: boolean;
    FState: TAutoguiderState;
    FAutoguiderType: TAutoguiderType;
    FTimeout : integer;
    FStarLostCancelExposure, FStarLostTimeoutRestart,FStarLostTimeoutCancel: integer;
    FMaxGuideDrift : double;
    FCancelExposure,FMaxDriftAbort : boolean;
    FRestartDelay,FMaxDriftAbortNum,FDriftRestartCount : integer;
    FStarLostCount: integer;
    FStarLostTime: double;
    FRAdistance,FDecdistance,FStarmass: double;
    FonShowMessage: TNotifyMsg;
    FonConnect: TNotifyEvent;
    FonConnectError: TNotifyEvent;
    FonDisconnect: TNotifyEvent;
    FonStatusChange: TNotifyEvent;
    FonGuideStat: TNotifyEvent;
    StarLostTimer: TTimer;
    FMount: T_mount;
    FCamera: T_camera;
    FGuideBmp: TBGRABitmap;
    FGuideFits: Tfits;
    Finternalguider: Tf_internalguider;
    Fastrometry: TAstrometry;
    Fdelay: single;
    procedure msg(txt:string; level: integer); // Only from main thread, use displaymessage() otherwise
    procedure StarLostTimerTimer(Sender: TObject);
    procedure StatusChange;
    procedure ProcessDisconnectSyn;
    procedure ProcessDisconnect;
    procedure DisplayMessage(txt:string);
    procedure ProcessEvent(txt:string); virtual; abstract;
    procedure StarLostTimerTimer(Sender: TObject); virtual; abstract;
    procedure CancelExposure;
    procedure AbortTarget;
    procedure GuideStat(dra,dde,sm:double);
  public
    Constructor Create;
    Destructor Destroy; override;
    Procedure Connect(cp1: string; cp2:string=''; cp3:string=''; cb1:boolean=False); virtual; abstract;
    procedure Disconnect; virtual; abstract;
    procedure Shutdown; virtual; abstract;
    procedure ConnectGear; virtual; abstract;
    procedure SettleTolerance(pixel:double; mintime,maxtime: integer); virtual; abstract;
    procedure Calibrate; virtual; abstract;
    procedure Guide(onoff:boolean; recalibrate:boolean=false); virtual; abstract;
    procedure Pause(onoff:boolean; settle:boolean=true); virtual; abstract;
    procedure Dither(pixel:double; raonly:boolean; waittime:double); virtual; abstract;
    function GetLockPosition(out x,y: double):boolean; virtual; abstract;
    procedure SetLockPosition(x,y: double); virtual; abstract;
    function SpectroSetGuideStar(GuideRa,GuideDec:double):boolean; virtual; abstract;
    function SpectroSetTarget(TargetRa,TargetDec: double): boolean; virtual; abstract;
    function WaitBusy(maxwait:integer=5):boolean; virtual; abstract;
    function WaitGuiding(maxwait:integer=5):boolean; virtual; abstract;
    function WaitDithering(maxwait:integer=5):boolean; virtual; abstract;
    procedure ResetDriftRestartCount;
    property AutoguiderType: TAutoguiderType read FAutoguiderType;
    property Terminated;
    property Mount: T_mount read FMount write FMount;
    property Camera: T_camera read FCamera write FCamera;
    property Running: boolean read FRunning;
    property Recovering: boolean read FRecovering;
    property Dithering: boolean read FDithering;
    property TargetHost : string read FTargetHost;
    property TargetPort : string read FTargetPort;
    property Timeout : integer read FTimeout write FTimeout;
    property LastError : string read FLastError;
    property ErrorDesc : string read FErrorDesc write FErrorDesc;
    property Status : string read FStatus;
    property State : TAutoguiderState read FState;
    property RestartDelay : integer read FRestartDelay;
    property RAdistance: double read FRAdistance;
    property Decdistance: double read FDecdistance;
    property Starmass: double read FStarmass;
    property GuideBmp: TBGRABitmap read FGuideBmp write FGuideBmp;
    property GuideFits: Tfits read FGuideFits write FGuideFits;
    property InternalGuider: Tf_internalguider read Finternalguider write Finternalguider;
    property Astrometry: TAstrometry read Fastrometry write FAstrometry;
    property onConnect: TNotifyEvent read FonConnect  write FonConnect;
    property onConnectError: TNotifyEvent read FonConnectError  write FonConnectError;
    property onDisconnect: TNotifyEvent read FonDisconnect  write FonDisconnect;
    property onShowMessage: TNotifyMsg read FonShowMessage write FonShowMessage;
    property onStatusChange: TNotifyEvent read FonStatusChange write FonStatusChange;
    property onGuideStat: TNotifyEvent read FonGuideStat write FonGuideStat;
  end;

implementation

Constructor T_autoguider.Create ;
begin
// start suspended to let time to the main thread to set the parameters
inherited create(true);
freeonterminate:=true;
FRunning:=false;
FRecovering:=false;
FDithering:=false;
FStatus:='Disconnected';
FState:=GUIDER_DISCONNECTED;
FStartedProgram:=false;
FTimeout:=500;
FLastError:='';
FErrorDesc:='';
FRecvData:='';
FSettlePix:=1.0;
FSettleTmin:=5;
FSettleTmax:=60;
StarLostTimer:=TTimer.Create(nil);
StarLostTimer.Enabled:=false;
StarLostTimer.Interval:=10000;
StarLostTimer.OnTimer:=@StarLostTimerTimer;
FStarLostCancelExposure:=0;
FStarLostTimeoutRestart:=0;
FStarLostTimeoutCancel:=1800;
FMaxGuideDrift:=config.GetValue('/Autoguider/Recovery/MaxGuideDrift',100.0);
FCancelExposure:=config.GetValue('/Autoguider/Recovery/CancelExposure',false);
FRestartDelay:=config.GetValue('/Autoguider/Recovery/RestartDelay',15);
FStarLostTime:=0;
FStarLostCount:=0;
FRAdistance:=0;
FDecdistance:=0;
FStarmass:=0;
Fdelay:=0;
end;

Destructor T_autoguider.Destroy;
begin
  StarLostTimer.Free;
  inherited Destroy;
end;

procedure T_autoguider.msg(txt:string; level: integer);
begin
  if Assigned(FonShowMessage)and(GetCurrentThreadId=MainThreadID) then FonShowMessage(txt, level);
end;

procedure T_autoguider.DisplayMessage(txt:string);
begin
if FErrorDesc='' then
  FErrorDesc:=rsAutoguider+': '+txt
else
  FErrorDesc:=FErrorDesc+crlf+rsAutoguider+': '+txt;
PostMessage(MsgHandle, LM_CCDCIEL, M_AutoguiderMessage, 0);
end;

procedure T_autoguider.StatusChange;
begin
 PostMessage(MsgHandle, LM_CCDCIEL, M_AutoguiderStatusChange, 0);
end;

procedure T_autoguider.ProcessDisconnect;
begin
Synchronize(@ProcessDisconnectSyn);
end;

procedure T_autoguider.ProcessDisconnectSyn;
begin
 if assigned(FonDisconnect) then FonDisconnect(self);
end;

procedure T_autoguider.CancelExposure;
begin
 PostMessage(MsgHandle, LM_CCDCIEL, M_AutoguiderCancelExposure, 0);
end;

procedure T_autoguider.AbortTarget;
begin
 PostMessage(MsgHandle, LM_CCDCIEL, M_AutoguiderAbortTarget, 0);
end;

procedure T_autoguider.ResetDriftRestartCount;
begin
 FDriftRestartCount:=0;
end;

procedure T_autoguider.GuideStat(dra,dde,sm:double);
begin
 FRAdistance:=dra;
 FDecdistance:=dde;
 FStarmass:=sm;
 PostMessage(MsgHandle, LM_CCDCIEL, M_AutoguiderGuideStat, 0);
end;


end.


unit cu_rotator;

{$mode objfpc}{$H+}

{
Copyright (C) 2017 Patrick Chevalley

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

interface

uses u_global, indiapi, u_utils, u_translation,
  Classes, SysUtils;

type

T_rotator = class(TComponent)
 private
 protected
    FRotatorInterface: TDevInterface;
    FStatus: TDeviceStatus;
    FonMsg,FonDeviceMsg: TNotifyMsg;
    FonAngleChange: TNotifyEvent;
    FonStatusChange: TNotifyEvent;
    FTimeOut: integer;
    Fdevice: string;
    FAutoLoadConfig: boolean;
    procedure msg(txt: string; level:integer=3);
    procedure SetReverse(value:boolean);
    function GetReverse:boolean;
    procedure SetDriverReverse(value:boolean); virtual; abstract;
    function GetDriverReverse:boolean; virtual; abstract;
    function  GetAngle:double; virtual; abstract;
    procedure SetAngle(p:double); virtual; abstract;
    procedure SetTimeout(num:integer); virtual; abstract;
  public
    constructor Create(AOwner: TComponent);override;
    destructor  Destroy; override;
    Procedure Connect(cp1: string; cp2:string=''; cp3:string=''; cp4:string=''; cp5:string=''; cp6:string=''); virtual; abstract;
    Procedure Disconnect; virtual; abstract;
    Procedure Halt; virtual; abstract;
    Procedure Sync(angle:double); virtual; abstract;
    property DeviceName: string read FDevice;
    property RotatorInterface: TDevInterface read FRotatorInterface;
    property Status: TDeviceStatus read FStatus;
    property Timeout: integer read FTimeout write SetTimeout;
    property AutoLoadConfig: boolean read FAutoLoadConfig write FAutoLoadConfig;
    property Angle: double read GetAngle write SetAngle;
    property Reverse: Boolean read GetReverse write SetReverse;
    property onMsg: TNotifyMsg read FonMsg write FonMsg;
    property onDeviceMsg: TNotifyMsg read FonDeviceMsg write FonDeviceMsg;
    property onAngleChange: TNotifyEvent read FonAngleChange write FonAngleChange;
    property onStatusChange: TNotifyEvent read FonStatusChange write FonStatusChange;
end;

implementation

constructor T_rotator.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FStatus := devDisconnected;
end;

destructor  T_rotator.Destroy;
begin
  inherited Destroy;
end;

procedure T_rotator.SetReverse(value:boolean);
begin
  SetDriverReverse(value);           // in driver
  if Assigned(FonAngleChange) then FonAngleChange(self);
end;

function T_rotator.GetReverse:boolean;
begin
  result:=GetDriverReverse;   // in driver
end;

procedure T_rotator.msg(txt: string; level:integer=3);
begin
  if Assigned(FonMsg) then FonMsg(Fdevice+': '+txt,level);
end;

end.


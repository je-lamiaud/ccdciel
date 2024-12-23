unit cu_planetarium_none;

{$mode objfpc}{$H+}

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
{
  null planetarium interface
}

interface

uses u_global, cu_planetarium,
     Classes, SysUtils, Forms;

type

  TPlanetarium_none = class(TPlanetarium)
  private
    started: boolean;
  protected
    procedure Execute; override;
    procedure ProcessDataSyn; override;
  public
    Constructor Create;
    procedure Connect(cp1,cp2,cp3,cp4: string; cb1:boolean=False); override;
    procedure Disconnect; override;
    procedure Shutdown; override;
    function Cmd(const Value: string):string; override;
    function ShowImage(fn: string; fovdeg:double=0):boolean; override;
    function DrawFrame(frra,frde,frsizeH,frsizeV,frrot: double):boolean; override;
    function GetEqSys: double; override;
    function Search(sname: string; out sra,sde,v_solar,vpa_solar: double): boolean; override;
    procedure ShowAstrometry(sra,sde: double); override;
    procedure ClearData; override;
  end;


implementation

/////////////////// TPlanetarium_none ///////////////////////////

Constructor TPlanetarium_none.Create ;
begin
inherited Create;
started:=false;
FPlanetariumType:=plaNONE;
end;

procedure TPlanetarium_none.Connect(cp1,cp2,cp3,cp4: string; cb1:boolean=False);
begin
  if started then exit;
  Start;
end;

procedure TPlanetarium_none.Disconnect;
begin
 Terminate;
end;


procedure TPlanetarium_none.Shutdown;
begin
end;

function TPlanetarium_none.GetEqSys: double;
begin
  result:=0
end;

procedure TPlanetarium_none.Execute;
begin
started:=true;
try
 if Terminated then exit;
 // main loop
 repeat
    if terminated then break;
    sleep(1000);
 until false;
FRunning:=false;
FStatus:=false;
finally
  terminate;
  Synchronize(@SyncOnDisconnect);
end;
end;

procedure TPlanetarium_none.ProcessDataSyn;
begin
end;

function TPlanetarium_none.Cmd(const Value: string):string;
begin
result:='';
end;

function TPlanetarium_none.ShowImage(fn: string; fovdeg:double=0):boolean;
begin
  result:=false;
end;

function TPlanetarium_none.DrawFrame(frra,frde,frsizeH,frsizeV,frrot: double):boolean;
begin
  result:=false;
end;

function TPlanetarium_none.Search(sname: string; out sra,sde,v_solar,vpa_solar: double): boolean;
begin
  result:=false;
end;

procedure TPlanetarium_none.ShowAstrometry(sra,sde: double);
begin
end;

procedure TPlanetarium_none.ClearData;
begin
  FRecvData:='';
  Fra:=NullCoord;
  Fde:=NullCoord;
  Fpa:=NullCoord;
  Fmagn:=NullCoord;
  Fobjname:='';
end;

end.

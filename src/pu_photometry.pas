unit pu_photometry;

{$mode objfpc}{$H+}

{
Copyright (C) 2019 Patrick Chevalley

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

uses  u_translation, u_global, UScaleDPI,
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, SpinEx, ExtCtrls;

type

  { Tf_photometry }

  Tf_photometry = class(TForm)
    ButtonSetRefMag: TButton;
    ButtonClose: TButton;
    RefMag: TFloatSpinEditEx;
    GroupBoxRefStar: TGroupBox;
    GroupBoxMeasurement: TGroupBox;
    Memo1: TMemo;
    Panel1: TPanel;
    procedure ButtonCloseClick(Sender: TObject);
    procedure ButtonSetRefMagClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
  private
    Fmag: double;
    FMagnitudeCalibrationChange, FClosePhotometry: TNotifyEvent;
    procedure SetMag(value:double);
  public
    StarX, StarY, hfd: double;
    procedure SetLang;
    property mag: double read Fmag write SetMag;
    property onMagnitudeCalibrationChange: TNotifyEvent read FMagnitudeCalibrationChange write FMagnitudeCalibrationChange;
    property onClosePhotometry : TNotifyEvent read FClosePhotometry write FClosePhotometry;
  end;

var
  f_photometry: Tf_photometry;

implementation

{$R *.lfm}

{ Tf_photometry }

procedure Tf_photometry.FormCreate(Sender: TObject);
begin
   ScaleDPI(Self);
   SetLang;
   Fmag:=NullCoord;
   hfd:=-1;
end;

procedure Tf_photometry.SetLang;
begin
  Caption:=rsPhotometry;
  GroupBoxMeasurement.Caption:=rsMeasurement;
  GroupBoxRefStar.Caption:=rsUseAsReferen;
  ButtonSetRefMag.Caption:=rsSetMagnitude;
  ButtonClose.Caption:=rsClose;
end;

procedure Tf_photometry.ButtonCloseClick(Sender: TObject);
begin
  Close;
end;

procedure Tf_photometry.SetMag(value:double);
begin
  Fmag:=value;
  RefMag.Value:=Fmag;
end;

procedure Tf_photometry.ButtonSetRefMagClick(Sender: TObject);
begin
  if Fmag<>NullCoord then begin
    if MagnitudeCalibration=NullCoord then
       MagnitudeCalibration:=RefMag.Value-Fmag
    else
       MagnitudeCalibration:=RefMag.Value-Fmag+MagnitudeCalibration;
    if Assigned(FMagnitudeCalibrationChange) then FMagnitudeCalibrationChange(Self);
  end;
end;

procedure Tf_photometry.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
 if Assigned(FClosePhotometry) then FClosePhotometry(Self);
end;

end.


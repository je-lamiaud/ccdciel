unit fu_internalguider;

{$mode objfpc}{$H+}

{
Copyright (C) 2022 Patrick Chevalley & Han Kleijn

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

uses   UScaleDPI, Dialogs, u_translation, u_global, u_utils,
  Classes, SysUtils, FileUtil, Forms, Graphics, Controls, StdCtrls, ExtCtrls, Spin,
  math,LCLintf, ComCtrls;


type
  xy_guiderlist =array of array of double;

type
  { Tf_internalguider }

  Tf_internalguider = class(TFrame)
    ButtonCalibrate: TButton;
    ButtonStart: TButton;
    ButtonStop: TButton;
    disable_guiding1: TCheckBox;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    label_estimate1: TLabel;
    measure_method2: TCheckBox;
    minimum_moveDEC1: TFloatSpinEdit;
    pa1: TEdit;
    pier_side1: TEdit;
    minimum_moveRA1: TFloatSpinEdit;
    Label9: TLabel;
    pixelsize1: TEdit;
    pulsegainEast1: TEdit;
    pulsegainNorth1: TEdit;
    pulsegainSouth1: TEdit;
    pulsegainWest1: TEdit;
    ra_hysteresis1: TSpinEdit;
    dec_hysteresis1: TSpinEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label4: TLabel;
    ra_gain1: TSpinEdit;
    scale1: TUpDown;
    unitarcseconds1: TCheckBox;
    xy_trend1: TImage;
    xy_Panel1: TImage;
    Label3: TLabel;
    led: TShape;
    Panel2: TPanel;
    PageControl1: TPageControl;
    Panel1: TPanel;
    Panel3: TPanel;
    dec_gain1: TSpinEdit;
    TabSheet2: TTabSheet;
    TabSheet1: TTabSheet;
    Title: TLabel;
    procedure ButtonCalibrateClick(Sender: TObject);
    procedure ButtonStartClick(Sender: TObject);
    procedure ButtonStopClick(Sender: TObject);
    procedure scale1Changing(Sender: TObject; var AllowChange: Boolean);
  private
    { private declarations }
    thescale : double;
    FonStart, FonStop, FonCalibrate: TNotifyEvent;
    procedure SetLed (cl : tcolor);

    procedure SetRA_hysteresis(value:integer);
    function GetRA_hysteresis:integer;
    procedure SetDEC_hysteresis(value:integer);
    function GetDEC_hysteresis:integer;
    function GetRAgain:integer;

    procedure SetRAgain(value:integer);
    function GetDECgain:integer;
    procedure SetDECgain(value:integer);
    function GetpulsegainEastsetting:double;
    procedure SetpulsegainEastsetting(value:double);
    function GetpulsegainWestsetting:double;
    procedure SetpulsegainWestsetting(value:double);
    function GetpulsegainNorthsetting:double;
    procedure SetpulsegainNorthsetting(value:double);
    function GetpulsegainSouthsetting:double;
    procedure SetpulsegainSouthsetting(value:double);
    function Getpier_sidesetting:string;
    procedure Setpier_sidesetting(value:string);
    function GetPAsetting:double;
    procedure SetPixelSize(value:double);
    function GetPixelSize:double;
    procedure SetPAsetting(value:double);
    function Getminimum_moveRA:double;
    procedure Setminimum_moveRA(value:double);
    function Getminimum_moveDEC:double;
    procedure Setminimum_moveDEC(value:double);
    function Getdisableguiding: boolean;
    function GetUseArcSeconds: boolean;
    procedure SetUseArcSeconds(value:boolean);
    function GetScale:integer;
    procedure SetScale(value:integer);

  public
    { public declarations }
    constructor Create(aOwner: TComponent); override;
    destructor  Destroy; override;
    procedure SetLang;
    procedure draw_xy(xy_trend :xy_guiderlist);//draw XY points
    procedure draw_trend(xy_trend :xy_guiderlist);//draw trend
    procedure trend_message(message1,message2 :string);//clear trend and place message
    property onStart: TNotifyEvent read FonStart write FonStart;
    property onStop: TNotifyEvent read FonStop write FonStop;
    property onCalibrate: TNotifyEvent read FonCalibrate write FonCalibrate;
    property RA_hysteresis: integer read GetRA_hysteresis write SetRA_hysteresis;
    property DEC_hysteresis: integer read GetDEC_hysteresis write SetDEC_hysteresis;
    property RAgain: integer read GetRAgain write SetRAgain;
    property DECgain: integer read GetDECgain write SetDECgain;
    property disable_guiding: boolean read Getdisableguiding;
    property use_arcsec: boolean read GetUseArcseconds write SetUseArcSeconds;
    property pulsegainEast: double read GetpulsegainEastsetting write SetpulsegainEastsetting; // movement in arcsec/second. Found by the calibration
    property pulsegainWest: double read GetpulsegainWestsetting write SetpulsegainWestsetting; // movement in arcsec/second. Found by the calibration
    property pulsegainNorth: double read GetpulsegainNorthsetting write SetpulsegainNorthsetting; // movement in arcsec/second. Found by the calibration
    property pulsegainSouth: double read GetpulsegainSouthsetting write SetpulsegainSouthsetting; // movement in arcsec/second. Found by the calibration
    property pixel_size: double read GetPixelSize write SetPixelSize; // scale in arcsec/pixel.
    property pier_side: string read Getpier_sidesetting write Setpier_sidesetting; // movement in arcsec/second. Found by the calibration
    property PA : double read GetPAsetting write SetPAsetting;// Guider image orientation in radians. Found by the calibration
    property minimum_moveRA : double read Getminimum_moveRA write Setminimum_moveRA;//to ignore seeing
    property minimum_moveDEC : double read Getminimum_moveDEC write Setminimum_moveDEC;//to ignore seeing
    property trend_scale: integer read Getscale write Setscale;
  end;

implementation

{$R *.lfm}

{ Tf_internalguider }

constructor Tf_internalguider.Create(aOwner: TComponent);
begin
 inherited Create(aOwner);
 {$ifdef lclcocoa}
 Title.Color:=clWindowFrame;
 {$endif}
 ScaleDPI(Self);
 SetLang;
end;

destructor  Tf_internalguider.Destroy;
begin
 inherited Destroy;
end;


procedure Tf_internalguider.SetLang;
begin
  Title.Caption:='Internal guider';
end;

function Tf_internalguider.Getdisableguiding:boolean;
begin
  result:=disable_guiding1.checked;
end;

function Tf_internalguider.GetUseArcSeconds:boolean;
begin
  result:=unitarcseconds1.checked;
end;

procedure Tf_internalguider.SetUseArcSeconds(value:boolean);
begin
  unitarcseconds1.checked:=value;
end;

function Tf_internalguider.GetRA_hysteresis:integer;
begin
  result:=ra_hysteresis1.Value;
end;

procedure Tf_internalguider.SetRA_hysteresis(value:integer);
begin
  ra_hysteresis1.Value:=value;
end;

function Tf_internalguider.GetDec_hysteresis:integer;
begin
  result:=dec_hysteresis1.Value;
end;

procedure Tf_internalguider.SetDec_hysteresis(value:integer);
begin
  dec_hysteresis1.Value:=value;
end;

function Tf_internalguider.GetpulsegainEASTsetting:double;
begin
  result:=strtofloat(pulsegainEAST1.text);
end;

procedure Tf_internalguider.SetpulsegainEastsetting(value:double);
begin
  pulsegainEAST1.text:=floattostrF(value,FFgeneral,0,2);
end;

function Tf_internalguider.GetpulsegainWestsetting:double;
begin
  result:=strtofloat(pulsegainWest1.text);
end;

procedure Tf_internalguider.SetpulsegainWestsetting(value:double);
begin
  pulsegainWest1.text:=floattostrF(value,FFgeneral,0,2);
end;

function Tf_internalguider.GetpulsegainNorthsetting:double;
begin
  result:=strtofloat(pulsegainNorth1.text);
end;

procedure Tf_internalguider.SetpulsegainNorthsetting(value:double);
begin
  pulsegainNorth1.text:=floattostrF(value,FFgeneral,0,2);
end;

function Tf_internalguider.GetpulsegainSouthsetting:double;
begin
  result:=strtofloat(pulsegainSouth1.text);
end;

procedure Tf_internalguider.SetpulsegainSouthsetting(value:double);
begin
  pulsegainSouth1.text:=floattostrF(value,FFgeneral,0,2);
end;

function Tf_internalguider.Getpier_sidesetting:string;
begin
  result:=pier_side1.text;
end;

procedure Tf_internalguider.SetPixelSize(value:double);
begin
  pixelsize1.text:=floattostrF(value,FFgeneral,0,2);
end;

function Tf_internalguider.GetPixelSize:double;
begin
  result:=strtofloat(pixelsize1.text);
end;

procedure Tf_internalguider.Setpier_sidesetting(value:string);
begin
  pier_side1.text:=value;
end;

function Tf_internalguider.GetPAsetting:double;
begin
  result:=strtofloat(PA1.text);
end;

procedure Tf_internalguider.SetPAsetting(value:double);
begin
  PA1.text:=floattostrF(value,FFgeneral,3,1);
end;

function Tf_internalguider.Getminimum_moveRA:double;
begin
  result:=minimum_moveRA1.value;
end;

procedure Tf_internalguider.Setminimum_moveRA(value:double);
begin
  minimum_moveRA1.value:=value;
end;

function Tf_internalguider.Getminimum_moveDEC:double;
begin
  result:=minimum_moveDEC1.value;
end;

procedure Tf_internalguider.Setminimum_moveDEC(value:double);
begin
  minimum_moveDEC1.value:=value;
end;

function Tf_internalguider.GetRAgain:integer;
begin
  result:=ra_gain1.Value;
end;

procedure Tf_internalguider.SetRAgain(value:integer);
begin
  ra_gain1.Value:=value;
end;

function Tf_internalguider.GetDECgain:integer;
begin
  result:=dec_gain1.Value;
end;

procedure Tf_internalguider.SetDECgain(value:integer);
begin
  dec_gain1.Value:=value;
end;

function Tf_internalguider.GetScale:integer;
begin
  result:=scale1.position;
end;

procedure Tf_internalguider.SetScale(value:integer);
begin
  scale1.position:=value;
  // thescale:=1;

  case value of 6: thescale:=0.25;
                5: thescale:=0.5;
                4: thescale:=1.0;
                3: thescale:=2.0;
                2: thescale:=4.0;
                1: thescale:=8.0;
                0: thescale:=16.0;
  end;

 draw_xy(nil);//plot xy values
 draw_trend(nil);// plot trends

end;

procedure Tf_internalguider.SetLed(cl: tcolor);
begin
  led.Brush.Color:=cl;
end;


procedure Tf_internalguider.ButtonStartClick(Sender: TObject);
begin
  setled(clgreen);
  ButtonCalibrate.enabled:=false;
  if Assigned(FonStart) then FonStart(self);
end;

procedure Tf_internalguider.ButtonStopClick(Sender: TObject);
begin
  if Assigned(FonStop) then FonStop(self);
  setled(clGray);
  ButtonCalibrate.enabled:=true;
  ButtonStart.enabled:=true;
end;


procedure Tf_internalguider.scale1Changing(Sender: TObject;
  var AllowChange: Boolean);
begin
  trend_scale:=scale1.position;//trigger a redraw trend
end;



procedure Tf_internalguider.ButtonCalibrateClick(Sender: TObject);
begin
  setled(clYellow);
  ButtonStart.enabled:=false;
  if Assigned(FonCalibrate) then FonCalibrate(self);
end;


procedure Tf_internalguider.draw_xy(xy_trend :xy_guiderlist);
var
 i,w2,h2,diameter, lenb,x,y,counter :integer;
 rms_ra,rms_dec,mean_ra,mean_dec,scale,scale2 :double;
 scaleunit : string;
const
    len=2;
begin
 with xy_panel1 do
 begin
   w2:= width div 2;
   h2:= height div 2;

   {clear}
   Canvas.Pen.width :=1;{thickness lines}
   Canvas.pen.color:=clScrollbar;
   canvas.font.color:=clBtntext;
   canvas.brush.color:=clmenu;
   canvas.rectangle(0,0, width,height);
   canvas.Brush.Style:=bsClear;{transparent style}
   canvas.moveto(0,h2);{cross}
   canvas.lineto(width,h2);{cross}

   canvas.moveto(w2,0);{cross}
   canvas.lineto(w2,height);

   diameter:=round(20);
   canvas.Ellipse(w2-diameter, h2-diameter, w2+diameter, h2+diameter);
   diameter:=round(40);
   canvas.Ellipse(w2-diameter, h2-diameter, w2+diameter, h2+diameter);
   diameter:=round(60);
   canvas.Ellipse(w2-diameter, h2-diameter, w2+diameter, h2+diameter);


   if ((use_arcsec=false) or (pixel_size=0)) then
   begin
      scale:=1/thescale;
      scale2:=1;
      scaleunit:=' px';
   end
   else
   begin
      scale:=pixel_size/thescale;
      scale2:=pixel_size;
      scaleunit:=' "';
   end;
   canvas.textout(w2,h2+20-10,floattostrF(2*scale,FFgeneral,0,1));
   canvas.textout(w2,h2+40-10,floattostrF(4*scale,FFgeneral,0,1));
   canvas.textout(w2,h2+60-10,floattostrF(6*scale,FFgeneral,0,1)+scaleunit);

   //draw xy graph
   lenb:=length(xy_trend)-1;
   counter:=0;
   rms_ra:=0;
   mean_ra:=0;
   mean_dec:=0;
   for i:=0 to lenb do
   begin
     if xy_trend[i,0]<1E99 then //valid data
     begin
     x:=w2+round(xy_trend[i,0]*10*thescale) ;
     y:=h2-round(xy_trend[i,1]*10*thescale);

     x:=min(max(0,x),width);
     y:=min(max(0,y),height);
     if i<6 then Canvas.pen.color:=clBtnText else  Canvas.pen.color:=clGrayText;

     if i<>0 then canvas.lineto(x,y) else canvas.moveto(x,y);
     canvas.Ellipse(x-len,y-len,x+1+len,y+1+len);{circle, the y+1,x+1 are essential to center the circle(ellipse) at the middle of a pixel. Otherwise center is 0.5,0.5 pixel wrong in x, y}
     mean_ra:=mean_ra+xy_trend[i,0];
     mean_dec:=mean_dec+xy_trend[i,1];
     inc(counter)
    end;
   end;

   if counter>0 then // calculate the RMS error of the variation around the mean value;
   begin // report the RMS values
     mean_ra:=mean_ra/counter;//mean or average value
     mean_dec:=mean_dec/counter;
     rms_ra:=0;
     rms_dec:=0;
     for i:=0 to counter-1 do
     begin
       rms_ra:=rms_ra+sqr(xy_trend[i,0]-mean_ra);
       rms_dec:=rms_dec+sqr(xy_trend[i,1]-mean_dec);
     end;
     rms_ra:=sqrt(rms_ra/counter);
     rms_dec:=sqrt(rms_dec/counter);

     canvas.textout(1,h2,'α  '+floattostrF(scale2*rms_ra,FFgeneral,2,1));
     canvas.textout(w2+2,2,'δ  '+floattostrF(scale2*rms_dec,FFgeneral,2,1));
   end;
 end;
end;

procedure Tf_internalguider.trend_message(message1,message2 :string);//clear trend and place message
begin
 with xy_trend1 do
 begin
   canvas.brush.color:=clmenu;
   canvas.rectangle(0,0, width,height);
   canvas.font.color:=clblue;
   canvas.textout(5,10,message1);
   canvas.textout(5,35,message2);
 end;
end;


procedure Tf_internalguider.draw_trend(xy_trend :xy_guiderlist);//draw trend.
var
 i, h2, lenb, x, y, counter :integer;
 scale: double;
 scaleunit : string;
const
    len=2;
begin
 with xy_trend1 do
 begin
   h2:= height div 2;

   {clear}
   Canvas.pen.color:=clScrollbar;
   canvas.font.color:=clBtntext;
   canvas.brush.color:=clmenu;
   canvas.rectangle(0,0, width,height);
   canvas.Brush.Style:=bsClear;{transparent style}
   Canvas.Pen.width :=1;{thickness lines}

   for i:=-2 to 2 do
   begin
     canvas.moveto(0,h2+I*20);{lines}
     canvas.lineto(width,h2+i*20);{lines}
   end;

   if ((use_arcsec=false) or (pixel_size=0)) then
   begin
      scale:=1/thescale;
      scaleunit:=' px';
   end
   else
   begin
      scale:=pixel_size/thescale;
      scaleunit:=' "';
   end;
   canvas.textout(0,h2+20-10,floattostrF(-2*scale,FFgeneral,0,1));
   canvas.textout(0,h2+40-10,floattostrF(-4*scale,FFgeneral,0,1));
   canvas.textout(0,h2-20-10,'+'+floattostrF(+2*scale,FFgeneral,0,1));
   canvas.textout(0,h2-40-10,'+'+floattostrF(+4*scale,FFgeneral,0,1)+scaleunit);



   Canvas.Pen.width :=2;{thickness lines}
   lenb:=length(xy_trend)-1;
   Canvas.pen.color:=clBlue;
   canvas.font.color:=clBlue;
   canvas.textout(5,0,'α');

   //draw DEC trend
   Canvas.pen.color:=clRed;
   canvas.font.color:=clRed;
   canvas.textout(15,0,'δ');
   counter:=lenb;
   for i:=lenb downto 0  do
   begin
     if xy_trend[i,0]<1E99 then //valid data
     begin
       y:=h2-round(xy_trend[i,1]*10*thescale);
       y:=min(max(0,y),height);
       x:=width-counter*((width-5) div lenb)-15;
       if counter<>lenb then canvas.lineto(x,y) else canvas.moveto(x,y);
       dec(counter);
     end;
   end;

   //drawDEC  corrective action
   Canvas.pen.color:=clRED;
   counter:=lenb;
   for i:=lenb downto 0  do
   begin
     if xy_trend[i,0]<1E99 then //valid data
     begin
       y:=h2-round(xy_trend[i,3]*10*thescale) ;
       y:=min(max(0,y),height);
       x:=width-counter*((width-5) div lenb)-15;
       canvas.moveto(x-1,h2);{one pixel behind to allow both RA and DEC action to be drawn}
       canvas.lineto(x-1,y);
       dec(counter);
     end;
   end;

   //draw RA trend
   Canvas.pen.color:=clBlue;
   counter:=lenb;
   for i:=lenb downto 0  do
   begin
     if xy_trend[i,0]<1E99 then //valid data
     begin
       y:=h2-round(xy_trend[i,0]*10*thescale) ;
       y:=min(max(0,y),height);
       x:=width-counter*((width-5) div lenb)-15;
       if counter<>lenb then canvas.lineto(x,y) else canvas.moveto(x,y);
       dec(counter);
     end;
   end;
   //draw RA corrective action
   counter:=lenb;
   for i:=lenb downto 0  do
   begin
     if xy_trend[i,0]<1E99 then //valid data
     begin
       y:=h2-round(xy_trend[i,2]*10*thescale) ;
       y:=min(max(0,y),height);
       x:=width-counter*((width-5) div lenb)-15;
       canvas.moveto(x+1,h2);{one pixel before to allow both RA and DEC action to be drawn}
       canvas.lineto(x+1,y);
       dec(counter);
     end;
   end;
 end;
end;



end.

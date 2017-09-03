﻿unit Frequency_Generator;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,DSI2C, Math;

type
  TForm3 = class(TForm)
    Button1: TButton;
    GroupBox1: TGroupBox;
    ComboBox1: TComboBox;
    Edit1: TEdit;
    Label1: TLabel;
    ComboBox2: TComboBox;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  Procedure SetFrequency_on(Hertz:real;channel:integer);
  Procedure SetFrequency_on_level(Hertz:real;channel:integer;level:real);   //flexible Frequency and voltage high level add by Jiayi
  Procedure SetFrequency_on_highlevel(Hertz:real;channel:integer;level:real);
  Procedure SetFrequency_off;
  procedure SendVolt(port: integer; volt: single);
  Procedure output_off(outnum:integer);
var
  Form3: TForm3;
  IICopen:boolean;
  PowerIO_data: array[0..11] of byte;

const
PowerIOadress_0_15=$40;
PowerIOadress_16_23=$42;
MUXIICadress=$E0;
PowerIOmuxadres=$08;

implementation

{$R *.dfm}

Procedure MUXtoSignalGen;
begin
//Configuration of backplane IIC multiplexer
set_start;
Send_Byte_Then_Chk_ACK(MUXIICadress);
Send_Byte_Then_Chk_ACK(PowerIOmuxadres);
Set_stop;
End;

Procedure sendSPI40(data:int64);
var
data1,data2,data3,data4,data5:byte;
begin
data1:=data shr 32;
data2:=data shr 24;
data2:=data2 and $00FF;
data3:=data shr 16;
data3:= data3 and $0000FF;
data4:=data shr 8;
data4:= data4 and $000000FF;
data5:= data and $00000000FF;

MUXtoSignalGen;

Set_start;
Send_Byte_Then_Chk_ACK($04);
Send_Byte_Then_Chk_ACK(data1);
Send_Byte_Then_Chk_ACK(data2);
Send_Byte_Then_Chk_ACK(data3);
Send_Byte_Then_Chk_ACK(data4);
Send_Byte_Then_Chk_ACK(data5);
Set_stop;
end;

Procedure sendSPI32(data:longword);
var
data1,data2,data3,data4:byte;
begin
data1:=data shr 24;
data2:=data shr 16;
data2:=data2 and $00FF;
data3:=data shr 8;
data3:= data3 and $0000FF;
data4:= data and $000000FF;

MUXtoSignalGen;

Set_start;
Send_Byte_Then_Chk_ACK($04);
Send_Byte_Then_Chk_ACK(data1);
Send_Byte_Then_Chk_ACK(data2);
Send_Byte_Then_Chk_ACK(data3);
Send_Byte_Then_Chk_ACK(data4);
Set_stop;
end;

procedure DAC_SPIfreq;
begin
MUXtoSignalGen;
Set_start;
Send_Byte_Then_Chk_ACK($50);
Send_Byte_Then_Chk_ACK($F0);
Send_Byte_Then_Chk_ACK($02);  //115 kHz
Set_stop;
end;

Procedure I2CtoSPI_write (data1:byte; data2:byte);
Begin
        MUXtoSignalGen;
        Set_start;
        Send_Byte_Then_Chk_ACK($50);
        Send_Byte_Then_Chk_ACK($01);
        Send_Byte_Then_Chk_ACK(data1);
        Send_Byte_Then_Chk_ACK(data2);
        Set_stop;
End;

procedure SendVolt(port: integer; volt: single);
var
I2Cmux : integer;
I2CtoSPIbridge : integer;
Final_DAC : integer;
Divide : single;
Rounded : integer;
MSB_data : integer;
LSB_data :integer;
channel : integer;
HI_channel: byte;
begin
Divide:= volt/0.00122100122100;  //calculate the 12 bit
Rounded := Round(Divide); //Rounded result

        Case port of
        0 : Begin Final_DAC := Rounded ;        channel:=$FE; End;
        1 : Begin Final_DAC := Rounded + 4096 ; channel:=$FD; End;
        2 : Begin Final_DAC := Rounded + 8192 ; channel:=$FB; End;
        3 : Begin Final_DAC := Rounded + 12288; channel:=$F7; End;
        4 : Begin Final_DAC := Rounded + 16384; channel:=$EF; End;
        5 : Begin Final_DAC := Rounded + 20480; channel:=$DF; End;
        6 : Begin Final_DAC := Rounded + 24576; channel:=$BF; End;
        7 : Begin Final_DAC := Rounded + 28672; channel:=$7F; End;
        End;

        DAC_SPIfreq;
        MSB_data := Final_DAC shr 8;
        LSB_data := Final_DAC and $00FF;
        //update channel
        HI_channel :=HI_channel and channel;
        //DAC_PowerDown (HI_channel);
        sleep(5);
        I2CtoSPI_write (MSB_data,LSB_data);
end;

Procedure powerIO_busexpander(adres:byte;data1:byte;data2:byte);
Begin
        Set_start;
        Send_Byte_Then_Chk_ACK(adres);
        Send_Byte_Then_Chk_ACK($02);                                    //Comand byte output port 0, auto increment
        Send_Byte_Then_Chk_ACK(data1);
        Send_Byte_Then_Chk_ACK(data2);
        Set_stop;
end;

Procedure output_on(outnum:integer);
var
busexpander:integer;
busoutput:integer;
busexpander_adres:integer;
busoutput_byte1:byte;
busoutput_byte2:byte;
begin
        busoutput_byte1:=$00;
        busoutput_byte2:=$00;
        busexpander:=trunc(outnum/16);                                   //calculate  busexpander
        busoutput:=outnum-(busexpander*16);                                   //Calculate  output
        Case busexpander  of
                0: busexpander_adres:=PowerIOadress_0_15;
                1: busexpander_adres:=PowerIOadress_16_23;
                End;
        Case busoutput of
                0: busoutput_byte1:=$01;
                1: busoutput_byte1:=$02;
                2: busoutput_byte1:=$04;
                3: busoutput_byte1:=$08;
                4: busoutput_byte1:=$10;
                5: busoutput_byte1:=$20;
                6: busoutput_byte1:=$40;
                7: busoutput_byte1:=$80;
                8: busoutput_byte2:=$01;
                9: busoutput_byte2:=$02;
                10: busoutput_byte2:=$04;
                11: busoutput_byte2:=$08;
                12: busoutput_byte2:=$10;
                13: busoutput_byte2:=$20;
                14: busoutput_byte2:=$40;
                15: busoutput_byte2:=$80;
                End;
//update output
        MUXtoSignalGen;
        PowerIO_data[(busexpander*2)]:=PowerIO_data[(busexpander*2)] or busoutput_byte1;
        PowerIO_data[(busexpander*2)+1]:=PowerIO_data[(busexpander*2)+1] or busoutput_byte2;
        powerIO_busexpander(busexpander_adres,PowerIO_data[(busexpander*2)],PowerIO_data[(busexpander*2)+1]);
end;

Procedure output_off(outnum:integer);
var
busexpander:integer;
busoutput:integer;
busexpander_adres:integer;
busoutput_byte1:byte;
busoutput_byte2:byte;
begin
        busoutput_byte1:=$FF;
        busoutput_byte2:=$FF;
        busexpander:=trunc(outnum/16);                                    //calculate  busexpander
        busoutput:=outnum-(busexpander*16);                               //Calculate  output
        Case busexpander  of
        0: busexpander_adres:=PowerIOadress_0_15;
        1: busexpander_adres:=PowerIOadress_16_23;
        End;
        Case busoutput of
        0: busoutput_byte1:=$FE;
        1: busoutput_byte1:=$FD;
        2: busoutput_byte1:=$FB;
        3: busoutput_byte1:=$F7;
        4: busoutput_byte1:=$EF;
        5: busoutput_byte1:=$DF;
        6: busoutput_byte1:=$BF;
        7: busoutput_byte1:=$7F;
        8: busoutput_byte2:=$FE;
        9: busoutput_byte2:=$FD;
        10: busoutput_byte2:=$FB;
        11: busoutput_byte2:=$F7;
        12: busoutput_byte2:=$EF;
        13: busoutput_byte2:=$DF;
        14: busoutput_byte2:=$BF;
        15: busoutput_byte2:=$7F;
        End;
//update output
        MUXtoSignalGen;
        PowerIO_data[(busexpander*2)]:=PowerIO_data[(busexpander*2)] and busoutput_byte1;
        PowerIO_data[(busexpander*2)+1]:=PowerIO_data[(busexpander*2)+1] and busoutput_byte2;
        powerIO_busexpander(busexpander_adres,PowerIO_data[(busexpander*2)],PowerIO_data[(busexpander*2)+1]);
end;

Procedure busexpander_output(adres:byte);
Begin
        Set_start;
        Send_Byte_Then_Chk_ACK(adres);
        Send_Byte_Then_Chk_ACK($06);                                    //Comand byte output port 0, auto increment
        Send_Byte_Then_Chk_ACK($00);
        Send_Byte_Then_Chk_ACK($00);
        Set_stop;
End;

Procedure initialize_powerIO;
var
X:integer;
begin
        MUXtoSignalGen;
        busexpander_output(PowerIOadress_0_15);
        busexpander_output(PowerIOadress_16_23);
        powerIO_busexpander(PowerIOadress_0_15,$00,$00);
        powerIO_busexpander(PowerIOadress_16_23,$00,$00);
        For X:=0 to 11 do
                begin
                PowerIO_data[x]:=$00;
                End;
End;

procedure TForm3.FormClose(Sender: TObject; var Action: TCloseAction);
var
i:integer;
begin
for I := 1 to 23 do
begin
SendVolt(i-1,0.1);
output_off(i);
end;
end;

Procedure TForm3.FormCreate(Sender: TObject);
var
i:integer;
begin
{dsi2c.speed :=20;  //IIC speed on 28kHz
IICopen:=Init_Controller('噅⁁A');
If not IICopen then
Begin
showmessage('no or wrong application board');
halt(1);
End;}
initialize_powerIO;

for I := 1 to 23 do
begin
SendVolt(i-1,0.1);
output_off(i);
end;

end;

Procedure SetFrequency_on(Hertz:real;channel:integer);
var
divider:integer;
dataint:int64;
lednr:integer;
begin
divider := round(50e6 / Hertz);
dataint:= round(Power(2,channel-1));
dataint:= (dataint  shl 32) or divider  ;
sendSPI40(dataint);
//sendSPI32(divider);

Case channel of
        1: lednr:=0;
        2: lednr:=2;
        3: lednr:=4;
        4: lednr:=6;
        5: lednr:=16;
        6: lednr:=19;
        7: lednr:=20;
        8: lednr:=22;
        End;
SendVolt(channel-1,5);
output_on(lednr);
end;

Procedure SetFrequency_on_level(Hertz:real;channel:integer;level:real);
var
divider:integer;
dataint:int64;
lednr:integer;
begin
divider := round(50e6 / Hertz);
dataint:= round(Power(2,channel-1));
dataint:= (dataint  shl 32) or divider  ;
sendSPI40(dataint);
//sendSPI32(divider);

Case channel of
        1: lednr:=1;
        2: lednr:=3;
        3: lednr:=5;
        4: lednr:=7;
        5: lednr:=17;
        6: lednr:=18;
        7: lednr:=21;
        8: lednr:=23;
        End;
SendVolt(channel-1,level);
output_on(lednr);

end;

Procedure SetFrequency_on_highlevel(Hertz:real;channel:integer;level:real);
var
divider:integer;
dataint:int64;
lednr:integer;
begin
divider := round(50e6 / Hertz);
dataint:= round(Power(2,channel-1));
dataint:= (dataint  shl 32) or divider  ;
sendSPI40(dataint);
//sendSPI32(divider);

Case channel of
        1: lednr:=0;
        2: lednr:=2;
        3: lednr:=4;
        4: lednr:=6;
        5: lednr:=16;
        6: lednr:=19;
        7: lednr:=20;
        8: lednr:=22;
        End;
SendVolt(channel-1,level);
output_on(lednr);

end;

Procedure SetFrequency_off;
var
i:integer;
begin
for I := 1 to 23 do
begin
output_off(i);
SendVolt(i-1,0.1);
end;
end;

procedure TForm3.Button1Click(Sender: TObject);
var
Frequency:integer;
channel:integer;
begin
Frequency := strtoint (edit1.Text);

  if combobox1.text = 'kHz' then
     Frequency := round(Frequency * 1e3)
  else if combobox1.text = 'MHz' then
     Frequency := round(Frequency * 1e6);

Channel:= strtoint (combobox2.Text);
if Frequency > 50e6 then
    showmessage('Maximum frequency is 50 MHz')
else
 begin
   SetFrequency_on(Frequency,channel);
end;
end;


end.

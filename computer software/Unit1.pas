unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  System.ImageList, Vcl.ImgList, Vcl.Imaging.pngimage, Unit2, Jpeg, D2XXUnit,DSI2C,Frequency_Generator;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    Image4: TImage;
    Image5: TImage;
    Image6: TImage;
    Image7: TImage;
    Image8: TImage;
    Image9: TImage;
    Image10: TImage;
    Image11: TImage;
    Image12: TImage;
    Image13: TImage;
    Image14: TImage;
    Image15: TImage;
    Image16: TImage;
    Image17: TImage;
    Image18: TImage;
    Image19: TImage;
    Image20: TImage;
    Image21: TImage;
    Image22: TImage;
    Image23: TImage;
    Image24: TImage;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    CheckBox5: TCheckBox;
    CheckBox6: TCheckBox;
    CheckBox7: TCheckBox;
    CheckBox8: TCheckBox;
    Image25: TImage;
    Edit1: TEdit;
    Edit2: TEdit;
    Button3: TButton;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Edit3: TEdit;
    Image26: TImage;
    Button4: TButton;
    Button6: TButton;
    Button8: TButton;
    CheckBox9: TCheckBox;
    procedure Image1Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
//    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Image2Click(Sender: TObject);
    procedure Image3Click(Sender: TObject);
    procedure I2c_sendint(data:integer);
    function  I2c_receiveint() : Int64;
    procedure FormCreate(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure I2c_send2byte(data:integer);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);

  private
    procedure Clearimage();
    procedure Test(channel_target:integer; channel_MCU:integer);
    procedure Test_doubledvoltage(channel_target: integer; channel_MCU: integer);
    procedure showresult0();
    procedure showresult1();
    procedure showresult2();
    procedure showresult3();
    procedure showresult4();
    procedure showresult5();
    procedure showresult6();
    procedure showresult7();
    procedure changevoltage(voltage: single; channel_MCU:integer);
    procedure showimage(channel_target: integer; item: integer; result: boolean);
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}


procedure TForm1.Button1Click(Sender: TObject);
var i:integer;
    voltage,frequency:single;
begin
    ShowMessage(ExtractFilePath(ParamStr(0)));
    voltage:=StrToFloat(Edit3.Text);
    frequency:=StrToFloat(Edit2.Text);

    if (frequency<1) or (frequency>300) then
    begin
    ShowMessage('Please input a frequency between 1kHz and 300kHz');
    exit;
    end;

    if (voltage<2) or (voltage>4.5) then
    begin
    ShowMessage('Please input a number between 2V and 4.5V');
    exit;
    end;


   form1.Clearimage;
   form1.Update;
   for I := 1 to 23 do
   begin
      output_off(i);
   end;

   if(checkbox1.Checked) then              /////////check if the board need to test the channel 1
   begin
      if checkbox9.Checked then
          Test_doubledvoltage(1,0)
      else
          Test(1,0);
   end;
   if(checkbox2.Checked) then              ////////check if the board need to test the channel 2
   begin
      if checkbox9.Checked then
          Test_doubledvoltage(2,1)
      else
          Test(2,1);

   end;
   if(checkbox3.Checked) then              ////////check if the board need to test the channel 3
   begin
      if checkbox9.Checked then
          Test_doubledvoltage(3,4)
      else
          Test(3,4);
   end;
   if(checkbox4.Checked) then              ////////check if the board need to test the channel 4
   begin
      if checkbox9.Checked then
          Test_doubledvoltage(4,5)
      else
          Test(4,5);
   end;
   if(checkbox5.Checked) then              ////////check if the board need to test the channel 5
   begin
       if checkbox9.Checked then
          Test_doubledvoltage(5,7)
      else
          Test(5,7);
   end;
   if(checkbox6.Checked) then             ////////check if the board need to test the channel 6
   begin
      if checkbox9.Checked then
          Test_doubledvoltage(6,6)
      else
          Test(6,6);
   end;
   if(checkbox7.Checked) then            ////////check if the board need to test the channel 7
   begin
      if checkbox9.Checked then
          Test_doubledvoltage(7,3)
      else
          Test(7,3);
   end;
   if(checkbox8.Checked) then         ////////check if the board need to test the channel 8
   begin
      if checkbox9.Checked then
          Test_doubledvoltage(8,2)
      else
          Test(8,2);
   end;
end;

/////////set frequency, voltage and channel to default
procedure TForm1.Button3Click(Sender: TObject);
begin
     Edit1.Text:='50';
     Edit2.Text:='50';
     Edit3.Text:='4.5';
     CheckBox1.Checked:=true;
     CheckBox2.Checked:=true;
     CheckBox3.Checked:=true;
     CheckBox4.Checked:=true;
     CheckBox5.Checked:=true;
     CheckBox6.Checked:=true;
     CheckBox7.Checked:=true;
     CheckBox8.checked:=true;
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
    Reset_MCU;
end;

//Send command to DAC
procedure TForm1.Button5Click(Sender: TObject);
var voltage:single;
    data_transfer:word;
    data_transfer1,data_transfer2:byte;
begin
    SetFrequency_on_highlevel(100*1e3,7,4.5);
     voltage:=StrToFloat(Edit3.Text);
end;


procedure TForm1.changevoltage(voltage: single; channel_MCU:integer);
var  data_transfer:word;
     data_transfer1,data_transfer2:byte;
     channel_DAC:byte;
begin
case channel_MCU of
     0:channel_DAC:=$00;
     1:channel_DAC:=$02;
     2:channel_DAC:=$04;
     3:channel_DAC:=$06;
     4:channel_DAC:=$07;
     5:channel_DAC:=$05;
     6:channel_DAC:=$03;
     7:channel_DAC:=$01;

end;
     data_transfer:=0;
     data_transfer:=round(voltage/10*$3ff);
     data_transfer1:=data_transfer shr 2 and $ff;
     data_transfer2:=data_transfer shl 6 and $ff;
     Set_Start_1;
     Send_Byte_Then_Chk_ACK($90);
     Send_Byte_Then_Chk_ACK(channel_DAC);
     Send_Byte_Then_Chk_ACK(data_transfer1);
     Send_Byte_Then_Chk_ACK(data_transfer2);
     Set_Stop_1;
end;

procedure TForm1.Button6Click(Sender: TObject);
begin
     Reset_DAC;
end;

procedure TForm1.Button7Click(Sender: TObject);
var
       i:integer;



begin
       for I := 1 to 23 do
       begin
           output_off(i);
       end;
          Test(2,1);
end;

procedure TForm1.Test(channel_target: integer; channel_MCU: integer);
var voltage,frequency,dutycycle:single;
    data_transfer:word;
    data_transfer1,data_transfer2:byte;
    time1,time2:int64;
    error: single;
    I: integer;
begin
     voltage:=StrToFloat(Edit3.Text);
     frequency:=StrToFloat(Edit2.Text);
     dutycycle:= StrToFloat(Edit1.Text);
     ///send command to testing target
     SetFrequency_on_level(frequency*1e3,channel_target,voltage); ///////change the frequency of channel 7
     ////////////test the voltage
     Reset_MCU;
     Reset_DAC;
     changevoltage(voltage-1,channel_MCU);
     I2c_send2byte(channel_MCU);
        sleep(50);
        if( frequency<0.1) then
        begin
           sleep(250);
        end;
        if( frequency<0.01) then
        begin
           sleep(2700);
        end;
        time1:=I2c_receiveint();
        sleep(20);
        time2:=I2c_receiveint();

        if (time1>2094967295) or (time2>2094967295) then
        begin
             Reset_MCU;
             changevoltage(0.5, channel_MCU);
             showimage(channel_target,2,false);
        end
        else
        begin
             changevoltage(voltage+0.5,channel_MCU);
             I2c_send2byte(channel_MCU);
             sleep(50);
             if(frequency<0.1) then
             begin
                 sleep(250);
             end;
             if( frequency<0.01) then
             begin
                 sleep(2700);
             end;
             time1:=I2c_receiveint();
             sleep(20);
             time2:=I2c_receiveint();

             if (time1<>4294967295) or (time2<>4294967295) then
             begin
                  changevoltage(0,channel_MCU);
                  showimage(channel_target,2,false);
             end
             else
             begin
                  showimage(channel_target,2,true);
             end;

        end;

        Form1.Update;
       /////test the frequency
        changevoltage(0.7,channel_MCU);
        Reset_MCU;
        I2c_send2byte(channel_MCU);
        sleep(50);
        if(frequency<0.1) then
        begin
           sleep(250);
        end;
        if( frequency<0.01) then
        begin
           sleep(2700);
        end;
        time1:=I2c_receiveint();
        sleep(20);
        time2:=I2c_receiveint();

        if ((abs(60000.0/frequency-(time1+time2) )/(60000.0/frequency) < 0.01) or (abs(60000.0/frequency-(time1+time2))<5))then
        begin
             showimage(channel_target,0,true);
        end
        else
        begin
             showimage(channel_target,0,false);
        end;


        if((abs(((time1+time2)/2-time1)/(time1+time2)*2)<0.05) or (((time1+time2)/2-time1)<5)) and (time1<>4294967295) then
        begin
             showimage(channel_target,1,true);
        end
        else
        begin
             showimage(channel_target,1,false);
        end;
        //Edit4.Text:=InttoStr(time1);
        //Edit5.Text:=InttoStr(time2);

        for I := 1 to 23 do
       begin
           SendVolt(i-1,0.1);
           output_off(i);
       end;
end;


//test the result with the doubled voltage
procedure TForm1.Test_doubledvoltage(channel_target: integer; channel_MCU: integer);
var voltage,frequency,dutycycle:single;
    data_transfer:word;
    data_transfer1,data_transfer2:byte;
    time1,time2:int64;
    error: single;
    I: integer;
begin
     voltage:=StrToFloat(Edit3.Text);
     frequency:=StrToFloat(Edit2.Text);
     dutycycle:= StrToFloat(Edit1.Text);
     ///send command to testing target
     SetFrequency_on_highlevel(frequency*1e3,channel_target,voltage); ///////change the frequency of channel
     ////////////test the voltage
     Reset_MCU;
     Reset_DAC;
     changevoltage(voltage*2-1,channel_MCU);
     I2c_send2byte(channel_MCU);
        sleep(50);
        if( frequency<0.1) then
        begin
           sleep(250);
        end;
        if( frequency<0.01) then
        begin
           sleep(2700);
        end;
        time1:=I2c_receiveint();
        sleep(20);
        time2:=I2c_receiveint();

        if (time1>2094967295) or (time2>2094967295) then
        begin
             Reset_MCU;
             changevoltage(0.5, channel_MCU);
             showimage(channel_target,2,false);
        end
        else
        begin
             changevoltage(voltage*2+0.5,channel_MCU);
             I2c_send2byte(channel_MCU);
             sleep(50);
             if(frequency<0.1) then
             begin
                 sleep(250);
             end;
             if( frequency<0.01) then
             begin
                 sleep(2700);
             end;
             time1:=I2c_receiveint();
             sleep(20);
             time2:=I2c_receiveint();

             if (time1<>4294967295) or (time2<>4294967295) then
             begin
                  changevoltage(0,channel_MCU);
                  showimage(channel_target,2,false);
             end
             else
             begin
                  showimage(channel_target,2,true);
             end;

        end;

        Form1.Update;
       /////test the frequency
        changevoltage(1.5,channel_MCU);
        Reset_MCU;
        I2c_send2byte(channel_MCU);
        sleep(50);
        if(frequency<0.1) then
        begin
           sleep(250);
        end;
        if( frequency<0.01) then
        begin
           sleep(2700);
        end;
        time1:=I2c_receiveint();
        sleep(20);
        time2:=I2c_receiveint();

        if ((abs(60000.0/frequency-(time1+time2) )/(60000.0/frequency) < 0.01) or (abs(60000.0/frequency-(time1+time2))<5))then
        begin
             showimage(channel_target,0,true);
        end
        else
        begin
             showimage(channel_target,0,false);
        end;


        if((abs(((time1+time2)/2-time1)/(time1+time2)*2)<0.05) or (((time1+time2)/2-time1)<5)) and (time1<>4294967295) then
        begin
             showimage(channel_target,1,true);
        end
        else
        begin
             showimage(channel_target,1,false);
        end;
        //Edit4.Text:=InttoStr(time1);
        //Edit5.Text:=InttoStr(time2);

        for I := 0 to 23 do
       begin
           SendVolt(i-1,0.1);
           output_off(i);
       end;
end;


//////a procedure to show the image
///channel_target: the number of channel on target board
///item :  0 means frequency    1 means duty cycle     2 means voltage
///result: 0 means cross        1 means tick
procedure Tform1.showimage(channel_target: integer; item: integer; result: boolean);
begin
     case channel_target of
     1:
         case item of
         0:
            if result then

            Image1.Picture.LoadFromFile(ExtractFilePath(ParamStr(0))+'picture\tick.png')
            else
            Image1.Picture.LoadFromFile(ExtractFilePath(ParamStr(0))+'picture\cross.png');
         1:
            if result then
            Image2.Picture.LoadFromFile(ExtractFilePath(ParamStr(0))+'picture\tick.png')
            else
            Image2.Picture.LoadFromFile(ExtractFilePath(ParamStr(0))+'picture\cross.png');
         2:
            if result then
            Image3.Picture.LoadFromFile(ExtractFilePath(ParamStr(0))+'picture\tick.png')
            else
            Image3.Picture.LoadFromFile(ExtractFilePath(ParamStr(0))+'picture\cross.png');
         end;

     2:
         case item of
         0:
            if result then
            Image4.Picture.LoadFromFile(ExtractFilePath(ParamStr(0))+'picture\tick.png')
            else
            Image4.Picture.LoadFromFile(ExtractFilePath(ParamStr(0))+'picture\cross.png');
         1:
            if result then
            Image5.Picture.LoadFromFile(ExtractFilePath(ParamStr(0))+'picture\tick.png')
            else
            Image5.Picture.LoadFromFile(ExtractFilePath(ParamStr(0))+'picture\cross.png');
         2:
            if result then
            Image6.Picture.LoadFromFile(ExtractFilePath(ParamStr(0))+'picture\tick.png')
            else
            Image6.Picture.LoadFromFile(ExtractFilePath(ParamStr(0))+'picture\cross.png');
         end;

     3:
         case item of
         0:
            if result then
            Image7.Picture.LoadFromFile(ExtractFilePath(ParamStr(0))+'picture\tick.png')
            else
            Image7.Picture.LoadFromFile(ExtractFilePath(ParamStr(0))+'picture\cross.png');
         1:
            if result then
            Image8.Picture.LoadFromFile(ExtractFilePath(ParamStr(0))+'picture\tick.png')
            else
            Image8.Picture.LoadFromFile(ExtractFilePath(ParamStr(0))+'picture\cross.png');
         2:
            if result then
            Image9.Picture.LoadFromFile(ExtractFilePath(ParamStr(0))+'picture\tick.png')
            else
            Image9.Picture.LoadFromFile(ExtractFilePath(ParamStr(0))+'picture\cross.png');
         end;

     4:
         case item of
         0:
            if result then
            Image10.Picture.LoadFromFile(ExtractFilePath(ParamStr(0))+'picture\tick.png')
            else
            Image10.Picture.LoadFromFile(ExtractFilePath(ParamStr(0))+'picture\cross.png');
         1:
            if result then
            Image11.Picture.LoadFromFile(ExtractFilePath(ParamStr(0))+'picture\tick.png')
            else
            Image11.Picture.LoadFromFile(ExtractFilePath(ParamStr(0))+'picture\cross.png');
         2:
            if result then
            Image12.Picture.LoadFromFile(ExtractFilePath(ParamStr(0))+'picture\tick.png')
            else
            Image12.Picture.LoadFromFile(ExtractFilePath(ParamStr(0))+'picture\cross.png');
         end;

     5:
         case item of
         0:
            if result then
            Image13.Picture.LoadFromFile(ExtractFilePath(ParamStr(0))+'picture\tick.png')
            else
            Image13.Picture.LoadFromFile(ExtractFilePath(ParamStr(0))+'picture\cross.png');
         1:
            if result then
            Image14.Picture.LoadFromFile(ExtractFilePath(ParamStr(0))+'picture\tick.png')
            else
            Image14.Picture.LoadFromFile(ExtractFilePath(ParamStr(0))+'picture\cross.png');
         2:
            if result then
            Image15.Picture.LoadFromFile(ExtractFilePath(ParamStr(0))+'picture\tick.png')
            else
            Image15.Picture.LoadFromFile(ExtractFilePath(ParamStr(0))+'picture\cross.png');
         end;

     6:
         case item of
         0:
            if result then
            Image16.Picture.LoadFromFile(ExtractFilePath(ParamStr(0))+'picture\tick.png')
            else
            Image16.Picture.LoadFromFile(ExtractFilePath(ParamStr(0))+'picture\cross.png');
         1:
            if result then
            Image17.Picture.LoadFromFile(ExtractFilePath(ParamStr(0))+'picture\tick.png')
            else
            Image17.Picture.LoadFromFile(ExtractFilePath(ParamStr(0))+'picture\cross.png');
         2:
            if result then
            Image18.Picture.LoadFromFile(ExtractFilePath(ParamStr(0))+'picture\tick.png')
            else
            Image18.Picture.LoadFromFile(ExtractFilePath(ParamStr(0))+'picture\cross.png');
         end;

     7:
         case item of
         0:
            if result then
            Image19.Picture.LoadFromFile(ExtractFilePath(ParamStr(0))+'picture\tick.png')
            else
            Image19.Picture.LoadFromFile(ExtractFilePath(ParamStr(0))+'picture\cross.png');
         1:
            if result then
            Image20.Picture.LoadFromFile(ExtractFilePath(ParamStr(0))+'picture\tick.png')
            else
            Image20.Picture.LoadFromFile(ExtractFilePath(ParamStr(0))+'picture\cross.png');
         2:
            if result then
            Image21.Picture.LoadFromFile(ExtractFilePath(ParamStr(0))+'picture\tick.png')
            else
            Image21.Picture.LoadFromFile(ExtractFilePath(ParamStr(0))+'picture\cross.png');
         end;
     8:
         case item of
         0:
            if result then
            Image22.Picture.LoadFromFile(ExtractFilePath(ParamStr(0))+'picture\tick.png')
            else
            Image22.Picture.LoadFromFile(ExtractFilePath(ParamStr(0))+'picture\cross.png');
         1:
            if result then
            Image23.Picture.LoadFromFile(ExtractFilePath(ParamStr(0))+'picture\tick.png')
            else
            Image23.Picture.LoadFromFile(ExtractFilePath(ParamStr(0))+'picture\cross.png');
         2:
            if result then
            Image24.Picture.LoadFromFile(ExtractFilePath(ParamStr(0))+'picture\tick.png')
            else
            Image24.Picture.LoadFromFile(ExtractFilePath(ParamStr(0))+'picture\cross.png');
         end;

     end;
end;

procedure TForm1.Button8Click(Sender: TObject);
begin
    form3.Show;
end;

procedure TForm1.Image1Click(Sender: TObject);
begin
    form1.showresult0;
end;

procedure TForm1.Image2Click(Sender: TObject);
begin
    form1.showresult0;
end;

procedure TForm1.Image3Click(Sender: TObject);
begin
    form1.showresult0;
end;

procedure Tform1.Clearimage();
begin
    image1.Picture:=nil;
    image2.Picture:=nil;
    image3.Picture:=nil;
    image4.Picture:=nil;
    image5.Picture:=nil;
    image6.Picture:=nil;
    image7.Picture:=nil;
    image8.Picture:=nil;
    image9.Picture:=nil;
    image10.Picture:=nil;
    image11.Picture:=nil;
    image12.Picture:=nil;
    image13.Picture:=nil;
    image14.Picture:=nil;
    image15.Picture:=nil;
    image16.Picture:=nil;
    image17.Picture:=nil;
    image18.Picture:=nil;
    image19.Picture:=nil;
    image20.Picture:=nil;
    image21.Picture:=nil;
    image22.Picture:=nil;
    image23.Picture:=nil;
    image24.Picture:=nil;
end;


procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
var
       i:integer;
begin
       for I := 1 to 23 do
       begin
           SendVolt(i-1,0.1);
           output_off(i);
       end;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
       a:boolean;
begin
dsI2C.speed:=150;
a:=Init_Controller('123 A');
////check whether the
if a=false then
begin
   ShowMessage('Failed connection to the test board, please close the program and try again.');
end;
end;



procedure TForm1.I2c_sendint(data:integer);
var
data0,data1,data2,data3:byte;
begin
        data0:=(data shr 24) and $ff;
        data1:=(data shr 16) and $ff;
        data2:=(data shr 8) and $ff;
        data3:=(data shr 0) and $ff;
        Set_start_1;  //SDA is valid on both edges of the SCL (only used for I2C communication via LPC824)
        Send_Byte_Then_Chk_ACK($22); //send slave address
        Send_Byte_Then_Chk_ACK(data0);    //send data
        Send_Byte_Then_Chk_ACK(data1);    //send data
        Send_Byte_Then_Chk_ACK(data2);    //send data
        Send_Byte_Then_Chk_ACK(data3);    //send data
        Set_stop_1;  //reset SCL setting(used for normal I2C communication), SDA data changes on falling edge of the SCL
end;

procedure TForm1.I2c_send2byte(data:integer);
var
data0,data1:byte;
begin
        data0:=(data shr 8) and $ff;
        data1:=(data shr 0) and $ff;
        Set_start_1;  //SDA is valid on both edges of the SCL (only used for I2C communication via LPC824)
        Send_Byte_Then_Chk_ACK($22); //send slave address
        Send_Byte_Then_Chk_ACK(data0);    //send data
        Send_Byte_Then_Chk_ACK(data1);    //send data
        Set_stop_1;  //reset SCL setting(used for normal I2C communication), SDA data changes on falling edge of the SCL
end;

function TForm1.I2c_receiveint() : Int64;
var Data1,Data2,Data3,Data4,Data5: byte;
    time1: Int64;
begin
         Set_start_1;  //SDA is valid on both edges of the SCL (only used for I2C communication via LPC824)
         Send_Byte_Then_Chk_ACK($23); //send slave addres
          sleep(100);
         Read_Byte_Then_Chk_ACK(Data1);
         Set_stop_1;

         //sleep(100);
         Set_start_1;
         Send_Byte_Then_Chk_ACK($23); //send slave address
         sleep(100);
         Read_Byte_Then_Chk_ACK(Data2);
         Set_stop_1;  //reset SCL setting(used for normal I2C communication), SDA data changes on falling edge of the SCL

         Set_start_1;
         Send_Byte_Then_Chk_ACK($23); //send slave address
         sleep(100);
         Read_Byte_Then_Chk_ACK(Data3);
         Set_stop_1;  //reset SCL setting(used for normal I2C communication), SDA data changes on falling edge of the SCL

         Set_start_1;  //SDA is valid on both edges of the SCL (only used for I2C communication via LPC824)
         Send_Byte_Then_Chk_ACK($23); //send slave address
         sleep(100);
         Read_Byte_Then_Chk_ACK(Data4);
         Set_stop_1;

         Set_start_1;  //SDA is valid on both edges of the SCL (only used for I2C communication via LPC824)
         Send_Byte_Then_Chk_ACK($23); //send slave address
         sleep(100);
         Read_Byte_Then_Chk_ACK(Data5);
         Set_stop_1;
         time1:=0;
         Data1:=(Data1 shr 1);   //right shift data for 1 bit, I do not know why
         Data2:=(Data2 shr 1);
         Data3:=(Data3 shr 1);
         Data4:=(Data4 shr 1);
         Data5:=(Data5 shr 1);
         time1:=time1 or ((Data1 and $ff) shl 28) or ((Data2 and $ff) shl 21) or ((Data3 and $ff) shl 14) or ((Data4 and $ff) shl 7) or ((Data5 and $ff) shl 0);
         //time1:=time1 or ((Data1 and $ff) shl 21) or ((Data2 and $ff) shl 14) or ((Data3 and $ff) shl 7) or ((Data4 and $ff) shl 0);
         Result := time1;
end;

procedure Tform1.showresult0();
begin
    Form2.Show;
    Form2.Caption:='Test result of channel 0'
end;

procedure Tform1.showresult1();
begin
    Form2.Show;
    Form2.Caption:='Test result of channel 1'
end;

procedure Tform1.showresult2();
begin
end;

procedure Tform1.showresult3();
begin
end;

procedure Tform1.showresult4();
begin
end;

procedure Tform1.showresult5();
begin
end;

procedure Tform1.showresult6();
begin
end;

procedure Tform1.showresult7();
begin
end;

end.

unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TfrmHivePal = class(TForm)
    btnLoad: TButton;
    btnSave: TButton;
    btnSaveAs: TButton;
    dlgOpen: TOpenDialog;
    lblPageNum: TLabel;
    chkAllow: TCheckBox;
    PalBars: TPaintBox;
    pickRed: TShape;
    pickGreen: TShape;
    pickBlue: TShape;
    PalMenu: TPaintBox;
    Shape1: TShape;
    selLength: TComboBox;
    lblLength: TLabel;
    editLength: TEdit;
    dlgColour: TColorDialog;
    Shape2: TShape;
    lblAddress: TLabel;
    editAddress: TEdit;
    editColour: TEdit;
    btnCopy: TButton;
    btnPaste: TButton;
    btnGradient: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormPaint(Sender: TObject);
    procedure btnLoadClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure chkAllowClick(Sender: TObject);
    procedure PalBarsPaint(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure lblLengthClick(Sender: TObject);
    procedure selLengthChange(Sender: TObject);
    procedure PalMenuPaint(Sender: TObject);
    procedure Shape2MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Shape1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure editLengthKeyPress(Sender: TObject; var Key: Char);
    procedure PalMenuMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PalBarsMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PalMenuMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure btnCopyClick(Sender: TObject);
    procedure btnPasteClick(Sender: TObject);
  private
    { Private declarations }
    Bitmap: TBitmap;
    procedure Plot(X, Y, Color: Integer);
    procedure DrawPic;
    procedure ScrubPic;
    function MdToPal(col: word): integer;
    procedure ShowRom;
    function MdValid(col: word): boolean;
    procedure ShowMenu;
  public
    { Public declarations }
  end;

var
  frmHivePal: TfrmHivePal;
  filepath: string;
  rombuffer, copybuffer: array of word;
  currentpage, maxpage, menustart, menulength, menucurrent,
  menucurrentwidth: integer;

const
  scale: integer = 8;

implementation

{$R *.dfm}

function ColorToRGBQuad(Color: TColor): TRGBQuad;
asm
// INPUT:  EAX = Color
// OUTPUT: EAX = RGBQuad
  or        eax,eax
  jns       @1
  and       eax,$FF
  push      eax
  call      Windows.GetSysColor  // perform "ColorToRGB"
@1:
  bswap     eax
  mov       al,$FF            // set "Reserved" / Alpha part of RGBQuad to 255
  ror       eax,8
end;

{ TfrmHivePal }

procedure TfrmHivePal.Plot(X, Y, Color: Integer);
var Pixel: PRGBQuad;
begin
  // no range checks here to improve speed, so Bitmap should be initialized
  // and X, Y must be valid coordinates
  Pixel := Bitmap.ScanLine[Y];
  Inc(Pixel, X);
  Pixel^ := TRGBQuad(ColorToRGBQuad(Color));
end;

procedure TfrmHivePal.FormCreate(Sender: TObject);
begin
  // create DIB
  FreeAndNil(Bitmap);
  Bitmap := TBitmap.Create;
  Bitmap.Width := 32;
  Bitmap.Height := 32;
  Bitmap.PixelFormat := pf32bit;
  Invalidate;
  DrawPic;
  KeyPreview := true; // Allow keypresses on main form.
end;

procedure TfrmHivePal.DrawPic;
begin
  StretchBlt(
    Canvas.Handle,
    frmHivePal.ClientWidth-(Bitmap.Width*scale)-8,
    8,
    Bitmap.Width * scale,
    Bitmap.Height * scale,
    Bitmap.Canvas.Handle,
    0,
    0,
    Bitmap.Width,
    Bitmap.Height,
    SRCCOPY
  );
end;

procedure TfrmHivePal.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FreeAndNil(Bitmap); // Clear bitmap from memory on close.
  FreeAndNil(PalBars);
end;

procedure TfrmHivePal.FormPaint(Sender: TObject);
begin
  DrawPic;
end;

procedure TfrmHivePal.ScrubPic;
var x, y: integer;
begin 
  for y := 0 to Bitmap.Height - 1 do
    begin
    for x := 0 to Bitmap.Width - 1 do
      Plot(x, y, clBtnFace);
    end;
end;

procedure TfrmHivePal.btnLoadClick(Sender: TObject);
var
  myfile: file;
begin
  if dlgOpen.Execute then
    begin
    filepath := dlgOpen.FileName;       // Remember file location.
    AssignFile(myfile,filepath);
    FileMode := fmOpenRead;
    Reset(myfile,2);
    SetLength(rombuffer,FileSize(myfile));
    BlockRead(myfile,rombuffer[0],FileSize(myfile));
    CloseFile(myfile);
    currentpage := 0;
    maxpage := (Length(rombuffer)-1) div (Bitmap.Width*Bitmap.Height);
    lblPageNum.Caption := 'Page '+IntToStr(currentpage)+'/'+IntToStr(maxpage);
    if maxpage > 0 then lblPageNum.Visible := true
    else lblPageNum.Visible := false;
    ScrubPic;
    ShowRom;
    end;
end;

function TfrmHivePal.MdToPal(col: word): integer;
var r, g, b: byte;
const lumin: array[0..15] of byte =
  (0,0,36,36,72,72,109,109,145,145,182,182,218,218,255,255);
begin
  col := swap(col);
  b := lumin[hi(col) and $F];
  g := lumin[lo(col) shr 4];
  r := lumin[lo(col) and $F];
  Result := r + (g*$100) + (b*$10000);
end;

procedure TfrmHivePal.ShowRom;
var k, startloc: integer;
begin
  startloc := currentpage * Bitmap.Width * Bitmap.Height;
  for k := 0 to (Bitmap.Width*Bitmap.Height)-1 do
    begin
    if k+startloc < Length(rombuffer) then
      begin
      if (MdValid(rombuffer[k+startloc]) = true) or chkAllow.Checked = true then
        Plot(k mod Bitmap.Width, k div Bitmap.Width, MdToPal(rombuffer[k+startloc]))
      else Plot(k mod Bitmap.Width, k div Bitmap.Width, clBtnFace);
      end
    else Plot(k mod Bitmap.Width, k div Bitmap.Width, clBtnFace);
    end;
  DrawPic;
end;

procedure TfrmHivePal.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin 
  if key = VK_PRIOR then
    begin
    if currentpage > 0 then dec(currentpage);
    end;
  if key = VK_NEXT then
    begin
    if currentpage < maxpage then inc(currentpage);
    end;
  if key = VK_HOME then currentpage := 0;
  if key = VK_END then currentpage := maxpage;
  lblPageNum.Caption := 'Page '+IntToStr(currentpage)+'/'+IntToStr(maxpage);
  ShowRom;
end;

function TfrmHivePal.MdValid(col: word): boolean;
begin
  col := swap(col) and $F111;
  if col > 0 then Result := false
  else Result := true;
end;

procedure TfrmHivePal.chkAllowClick(Sender: TObject);
begin
  ShowRom;
end;

procedure TfrmHivePal.PalBarsPaint(Sender: TObject);
var w, h, k: integer;
begin
  w := PalBars.Width div 8;
  h := PalBars.Height div 3;
  for k := 0 to 7 do
    begin
    PalBars.Canvas.Pen.Color := MdToPal($200*k); // red
    PalBars.Canvas.Brush.Color := PalBars.Canvas.Pen.Color;
    PalBars.Canvas.Rectangle(w*k, 0, (w*k)+w, h);
    end;        
  for k := 0 to 7 do
    begin
    PalBars.Canvas.Pen.Color := MdToPal($2000*k); // green
    PalBars.Canvas.Brush.Color := PalBars.Canvas.Pen.Color;
    PalBars.Canvas.Rectangle(w*k, h, (w*k)+w, h*2);
    end;
  for k := 0 to 7 do
    begin
    PalBars.Canvas.Pen.Color := MdToPal(2*k); // blue
    PalBars.Canvas.Brush.Color := PalBars.Canvas.Pen.Color;
    PalBars.Canvas.Rectangle(w*k, h*2, (w*k)+w, h*3);
    end;
end;

procedure TfrmHivePal.btnSaveClick(Sender: TObject);
var myfile: file;
begin
  if FileExists(filepath) then
    begin
    AssignFile(myfile,filepath);
    FileMode := fmOpenReadWrite;
    Reset(myfile,2);
    BlockWrite(myfile,rombuffer[0],Length(rombuffer));
    CloseFile(myfile);
    end
  else ShowMessage('File has been moved or deleted.');
end;

procedure TfrmHivePal.lblLengthClick(Sender: TObject);
var ind: integer;
begin
  ind := selLength.ItemIndex;
  if lblLength.Caption = 'Length (hex)' then
    begin
    lblLength.Caption := 'Length (dec)';
    selLength.Items[1] := '16';
    selLength.Items[2] := '32';
    selLength.Items[3] := '48';
    selLength.Items[4] := '64';
    selLength.ItemIndex := ind;
    if editLength.Text <> '' then
      editLength.Text := IntToStr(StrToInt('$'+editLength.Text));
    end
  else
    begin
    lblLength.Caption := 'Length (hex)';
    selLength.Items[1] := '10';
    selLength.Items[2] := '20';
    selLength.Items[3] := '30';
    selLength.Items[4] := '40';
    selLength.ItemIndex := ind;  
    if editLength.Text <> '' then
      editLength.Text := IntToHex(StrToInt(editLength.Text),1);
    end;
end;

procedure TfrmHivePal.selLengthChange(Sender: TObject);
begin
  if selLength.ItemIndex = 5 then editLength.Visible := true // Show length
  else editLength.Visible := false;       // textbox if "other" is selected.
end;

procedure TfrmHivePal.ShowMenu;
var k, w, h: integer;
  palonly: word;
begin
  if (menulength < 65) and (menulength > 0) and (Length(rombuffer) > 0) then
    begin
    w := PalMenu.Width div 16;
    h := PalMenu.Height div 4;
    PalMenu.Canvas.Brush.Style := bsSolid;
    PalMenu.Canvas.Pen.Style := psSolid;
    PalMenu.Canvas.Brush.Color := clBtnFace;
    PalMenu.Canvas.FillRect(PalMenu.ClientRect);
    for k := 0 to menulength-1 do
      begin
      PalMenu.Canvas.Pen.Color := MdToPal(rombuffer[menustart+k]);
      PalMenu.Canvas.Brush.Color := PalMenu.Canvas.Pen.Color;
      PalMenu.Canvas.Rectangle(w*(k mod 16), h*(k div 16), (w*(k mod 16))+w, (h*(k div 16))+h);
      end;
    PalMenu.Canvas.Brush.Style := bsClear;
    PalMenu.Canvas.Pen.Color := clWhite;
    PalMenu.Canvas.Rectangle(w*(menucurrent mod 16), h*(menucurrent div 16),
      (w*(menucurrent mod 16))+(w*(menucurrentwidth+1)), (h*(menucurrent div 16))+h);
    PalMenu.Canvas.Pen.Style := psDot;
    PalMenu.Canvas.Pen.Color := clBlack;
    PalMenu.Canvas.Rectangle(w*(menucurrent mod 16), h*(menucurrent div 16),
      (w*(menucurrent mod 16))+(w*(menucurrentwidth+1)), (h*(menucurrent div 16))+h);
    Shape2.Brush.Color := MdToPal(rombuffer[menustart+menucurrent]);
    palonly := rombuffer[menustart+menucurrent] and $EE0E;
    pickBlue.Left := (Lo(palonly)*15)+PalBars.Left;
    pickGreen.Left := ((palonly shr 12)*15)+PalBars.Left;
    PickRed.Left := ((Hi(palonly) and $E)*15)+PalBars.Left;
    editColour.Text := IntToHex(Swap(rombuffer[menustart+menucurrent]),4);  
    editAddress.Text := IntToHex(menustart*2, 1);
    ShowRom;
    end;
end;

procedure TfrmHivePal.PalMenuPaint(Sender: TObject);
begin
  ShowMenu;
end;

procedure TfrmHivePal.Shape2MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var buf: word;
begin
  if dlgColour.Execute and (Length(rombuffer) > 0) then
    begin
    buf := rombuffer[menustart+menucurrent];
    buf := buf and $F1FF; // red
    buf := buf + (((GetRValue(dlgColour.Color) div 16) and $E) shl 8);
    buf := buf and $1FFF; // green
    buf := buf + (((GetGValue(dlgColour.Color) div 16) and $E) shl 12);
    buf := buf and $FFF1; // blue           
    buf := buf + ((GetBValue(dlgColour.Color) div 16) and $E);
    rombuffer[menustart+menucurrent] := buf;
    ShowMenu;
    end;
end;

procedure TfrmHivePal.Shape1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var pos: integer;
begin
  pos := ((Y div scale)*Bitmap.Width)+(X div scale);
  pos := pos+(currentpage*Bitmap.Width*Bitmap.Height);
  if pos < Length(rombuffer) then
    begin
    if selLength.ItemIndex = 0 then // Auto
      begin
      menulength := 1;
      while (menulength < 64) and (MdValid(rombuffer[pos+menulength]) = true) do
        inc(menulength); // inc menulength until it hits invalid colour or runs out of space.
      end
    else if (selLength.ItemIndex > 0) and (selLength.ItemIndex < 5) then // $10, $20, $30 or $40
      menulength := selLength.ItemIndex*16
    else if selLength.ItemIndex = 5 then
      begin
      if editLength.Text = '' then editLength.Text := '1';
      if lblLength.Caption = 'Length (hex)' then menulength := StrToInt('$'+editLength.Text)
      else menulength := StrToInt(editLength.Text);
      if menulength > 64 then menulength := 64;
      end;
    menucurrent := 0;
    menucurrentwidth := 0;
    menustart := pos;
    if menustart+menulength > Length(rombuffer) then
      menulength := Length(rombuffer)-menustart; // Shorten menulength if overflow.
    ShowMenu;
    end;
end;

procedure TfrmHivePal.editLengthKeyPress(Sender: TObject; var Key: Char);
begin
  if lblLength.Caption = 'Length (hex)' then
    begin
    case key of
      '0'..'9', 'a'..'f', 'A'..'F', #8: ;   // Allow hex nums & backspace.
      else key := #0;                       // Else do nothing.
      end;
    end
  else
    begin  
    case key of
      '0'..'9', #8: ;                       // Allow dec nums & backspace.
      else key := #0;                       // Else do nothing.
      end;
    end;
end;

procedure TfrmHivePal.PalMenuMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var w, h, pick: integer;
begin
  w := PalMenu.Width div 16;
  h := PalMenu.Height div 4;
  pick := (X div w)+((Y div h)*16);
  if Button = mbLeft then
    begin
    if pick < menulength then menucurrent := pick;
    menucurrentwidth := 0;
    end;
  ShowMenu;
end;  

procedure TfrmHivePal.PalMenuMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);  
var w, h, pick: integer;
begin 
  w := PalMenu.Width div 16;
  h := PalMenu.Height div 4;
  pick := (X div w)+((Y div h)*16);
  if ((Y div h) = (menucurrent div 16)) and // Check selection is on same row.
  (pick <> menucurrent) then // Check selection is wider than 1.
    begin
    menucurrentwidth := Abs(pick-menucurrent);
    if pick < menucurrent then menucurrent := pick;
    end;
  ShowMenu;
end;

procedure TfrmHivePal.PalBarsMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var buf: word;
begin
  if Length(rombuffer) > 0 then
  begin
  buf := rombuffer[menustart+menucurrent];
  if Y div 35 = 0 then                // red
    begin
    buf := buf and $F1FF;
    buf := buf + ((X div 30) shl 9);
    end
  else if Y div 35 = 1 then           // green
    begin
    buf := buf and $1FFF;
    buf := buf + ((X div 30) shl 13);
    end
  else                                // blue
    begin
    buf := buf and $FFF1;
    buf := buf + ((X div 30) shl 1);
    end;
  rombuffer[menustart+menucurrent] := buf;
  ShowMenu;
  end;
end;

procedure TfrmHivePal.btnCopyClick(Sender: TObject);
begin
  Setlength(copybuffer,menucurrentwidth+1);
  copybuffer := Copy(rombuffer, menustart+menucurrent, menucurrentwidth+1);
end;

procedure TfrmHivePal.btnPasteClick(Sender: TObject);
var i: integer;
begin
   for i := 0 to Length(copybuffer)-1 do
    begin
    if menucurrent+i < menulength then
      rombuffer[menustart+menucurrent+i] := copybuffer[i];
    end;
   ShowMenu;
end;

end.

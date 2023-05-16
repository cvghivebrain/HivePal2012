object frmHivePal: TfrmHivePal
  Left = 192
  Top = 121
  HorzScrollBar.Visible = False
  VertScrollBar.Visible = False
  BorderStyle = bsSingle
  Caption = 'HivePal 2.0 by Hivebrain'
  ClientHeight = 345
  ClientWidth = 601
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  OnPaint = FormPaint
  PixelsPerInch = 96
  TextHeight = 13
  object lblPageNum: TLabel
    Left = 576
    Top = 272
    Width = 17
    Height = 13
    Alignment = taRightJustify
    Caption = '0/0'
    Visible = False
  end
  object PalBars: TPaintBox
    Left = 8
    Top = 184
    Width = 240
    Height = 105
    OnMouseDown = PalBarsMouseDown
    OnPaint = PalBarsPaint
  end
  object pickRed: TShape
    Left = 8
    Top = 184
    Width = 30
    Height = 35
    Brush.Style = bsClear
    Pen.Color = clLime
    Pen.Width = 2
  end
  object pickGreen: TShape
    Left = 8
    Top = 219
    Width = 30
    Height = 35
    Brush.Style = bsClear
    Pen.Color = 33023
    Pen.Width = 2
  end
  object pickBlue: TShape
    Left = 8
    Top = 254
    Width = 30
    Height = 35
    Brush.Style = bsClear
    Pen.Color = clYellow
    Pen.Width = 2
  end
  object PalMenu: TPaintBox
    Left = 8
    Top = 8
    Width = 320
    Height = 136
    OnMouseDown = PalMenuMouseDown
    OnMouseUp = PalMenuMouseUp
    OnPaint = PalMenuPaint
  end
  object Shape1: TShape
    Left = 337
    Top = 8
    Width = 256
    Height = 256
    Brush.Style = bsClear
    Pen.Style = psClear
    OnMouseDown = Shape1MouseDown
  end
  object lblLength: TLabel
    Left = 8
    Top = 296
    Width = 59
    Height = 13
    Caption = 'Length (hex)'
    OnClick = lblLengthClick
  end
  object Shape2: TShape
    Left = 256
    Top = 184
    Width = 73
    Height = 105
    OnMouseDown = Shape2MouseDown
  end
  object lblAddress: TLabel
    Left = 128
    Top = 296
    Width = 38
    Height = 13
    Caption = 'Address'
  end
  object btnLoad: TButton
    Left = 336
    Top = 288
    Width = 81
    Height = 49
    Caption = 'Load File or ROM'
    TabOrder = 0
    WordWrap = True
    OnClick = btnLoadClick
  end
  object btnSave: TButton
    Left = 424
    Top = 288
    Width = 81
    Height = 49
    Caption = 'Save Changes'
    TabOrder = 1
    OnClick = btnSaveClick
  end
  object btnSaveAs: TButton
    Left = 512
    Top = 288
    Width = 81
    Height = 49
    Caption = 'Save File As...'
    TabOrder = 2
  end
  object chkAllow: TCheckBox
    Left = 336
    Top = 272
    Width = 129
    Height = 17
    Caption = 'Show invalid palettes'
    TabOrder = 3
    OnClick = chkAllowClick
  end
  object selLength: TComboBox
    Left = 8
    Top = 312
    Width = 65
    Height = 21
    ItemHeight = 13
    ItemIndex = 0
    TabOrder = 4
    Text = 'Auto'
    OnChange = selLengthChange
    Items.Strings = (
      'Auto'
      '10'
      '20'
      '30'
      '40'
      'Other')
  end
  object editLength: TEdit
    Left = 80
    Top = 312
    Width = 33
    Height = 21
    MaxLength = 2
    TabOrder = 5
    Visible = False
    OnKeyPress = editLengthKeyPress
  end
  object editAddress: TEdit
    Left = 128
    Top = 312
    Width = 89
    Height = 21
    TabOrder = 6
    Text = '0'
  end
  object editColour: TEdit
    Left = 272
    Top = 256
    Width = 41
    Height = 21
    TabOrder = 7
    Text = '0'
  end
  object btnCopy: TButton
    Left = 8
    Top = 152
    Width = 57
    Height = 25
    Caption = 'Copy'
    TabOrder = 8
    OnClick = btnCopyClick
  end
  object btnPaste: TButton
    Left = 72
    Top = 152
    Width = 57
    Height = 25
    Caption = 'Paste'
    TabOrder = 9
    OnClick = btnPasteClick
  end
  object btnGradient: TButton
    Left = 136
    Top = 152
    Width = 89
    Height = 25
    Caption = 'Create Gradient'
    Enabled = False
    TabOrder = 10
  end
  object dlgOpen: TOpenDialog
    Left = 336
    Top = 216
  end
  object dlgColour: TColorDialog
    Left = 368
    Top = 216
  end
end

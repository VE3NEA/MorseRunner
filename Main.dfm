object MainForm: TMainForm
  Left = 238
  Top = 115
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Morse Runner'
  ClientHeight = 413
  ClientWidth = 700
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Icon.Data = {
    0000010002002020100000000000E80200002600000010101000000000002801
    00000E0300002800000020000000400000000100040000000000800200000000
    0000000000000000000000000000000000000000800000800000008080008000
    0000800080008080000080808000C0C0C0000000FF0000FF000000FFFF00FF00
    0000FF00FF00FFFF0000FFFFFF00000000000000000008800000000000000000
    0000000000000770000000000000000000000000000777777000000000000000
    000000000777FF8777700000000000000000000777FF70888777700000000000
    00080777FF70F7708887777000000000000777FF70F770F70F88877000000000
    0007FF70F770F70FF8870000000000000008788770F70FF88700787800000000
    00000778870FF8870078887000000000000000077FF88700788FF88700000000
    00000000077700788FFCCF8700000000000000000070788FFCCCCCF870000000
    00000000007888FCCCCCCCF88700000000000000000780CCCCCCCCCF87000000
    09999900000780CCCCCCCCCF8870000998FFF8990000780CCCCCCCC0F8700099
    FFFCFFF99000780CCCCCC0088770009FFFFFFFCF90000780CFC008877000098F
    F0FFFFFF89000780C0088770000009FFFF0FFFFFF900007808877000000009FC
    FFF90000F900007887700000000009FFFFFFFFFFF9000007700000000000098F
    FFFFFFFF89000000000000000000009FCFFFFFCF900000000000000000000099
    FFFCFFF990000000000000000000000998FCF899000000000000000000000000
    0999990000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000FFFF9FFFFFFE07FFFFF801FFFFE0007FFF80
    001FFE00000FFE00000FFE00000FFE00000FFF80000FFFE00007FFF80007FFFC
    0003FFFC0001F83E0001E00E0000C007000080030001800380070001801F0001
    C07F0001C1FF0001E7FF0001FFFF8003FFFF8003FFFFC007FFFFE00FFFFFF83F
    FFFFFEFFFFFFFC7FFFFFFC7FFFFF280000001000000020000000010004000000
    0000C00000000000000000000000000000000000000000000000000080000080
    00000080800080000000800080008080000080808000C0C0C0000000FF0000FF
    000000FFFF00FF000000FF00FF00FFFF0000FFFFFF0000000000770000000000
    0007F7750000000007F8778775000007887778887000000078788F0087000000
    008800FF8850000000078FCCCF70001115003CCCC88501F8F91084CCC4F71F8F
    FF1007C4780018F77785087800001FFFFF75000000005988F810000000000117
    71000000000000005000000000000000500000000000FF3F0000FC0F0000F003
    0000E0030000F0030000FC010000FE010000C30000008100000001830000008F
    000000FF000001FF000083FF0000E7FF0000E7FF0000}
  KeyPreview = True
  Menu = MainMenu1
  OldCreateOrder = False
  Position = poDesktopCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  OnKeyPress = FormKeyPress
  OnKeyUp = FormKeyUp
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel1: TBevel
    Left = 0
    Top = 0
    Width = 700
    Height = 2
    Align = alTop
  end
  object Panel1: TPanel
    Left = 0
    Top = 294
    Width = 700
    Height = 119
    Align = alBottom
    BevelInner = bvRaised
    BevelOuter = bvLowered
    TabOrder = 0
    object Label1: TLabel
      Left = 16
      Top = 12
      Width = 17
      Height = 13
      Caption = 'Call'
    end
    object SpeedButton4: TSpeedButton
      Tag = 1
      Left = 12
      Top = 68
      Width = 61
      Height = 17
      Caption = 'F1  CQ'
      OnClick = SendClick
    end
    object SpeedButton5: TSpeedButton
      Tag = 2
      Left = 76
      Top = 68
      Width = 61
      Height = 17
      Caption = 'F2  <#>'
      OnClick = SendClick
    end
    object SpeedButton6: TSpeedButton
      Tag = 3
      Left = 140
      Top = 68
      Width = 61
      Height = 17
      Caption = 'F3  TU'
      OnClick = SendClick
    end
    object SpeedButton7: TSpeedButton
      Tag = 4
      Left = 204
      Top = 68
      Width = 61
      Height = 17
      Caption = 'F4  <my>'
      OnClick = SendClick
    end
    object SpeedButton8: TSpeedButton
      Tag = 5
      Left = 12
      Top = 92
      Width = 61
      Height = 17
      Caption = 'F5  <his>'
      OnClick = SendClick
    end
    object SpeedButton9: TSpeedButton
      Tag = 6
      Left = 76
      Top = 92
      Width = 61
      Height = 17
      Caption = 'F6  B4'
      OnClick = SendClick
    end
    object SpeedButton10: TSpeedButton
      Tag = 7
      Left = 140
      Top = 92
      Width = 61
      Height = 17
      Caption = 'F7  ?'
      OnClick = SendClick
    end
    object SpeedButton11: TSpeedButton
      Tag = 8
      Left = 204
      Top = 92
      Width = 61
      Height = 17
      Caption = 'F8  NIL'
      OnClick = SendClick
    end
    object Label2: TLabel
      Left = 172
      Top = 12
      Width = 22
      Height = 13
      Caption = 'RST'
    end
    object Label3: TLabel
      Left = 224
      Top = 12
      Width = 14
      Height = 13
      Caption = 'Nr.'
    end
    object Bevel2: TBevel
      Left = 277
      Top = 6
      Width = 2
      Height = 107
    end
    object Edit1: TEdit
      Left = 12
      Top = 28
      Width = 149
      Height = 28
      AutoSelect = False
      CharCase = ecUpperCase
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      MaxLength = 12
      ParentFont = False
      TabOrder = 0
      OnChange = Edit1Change
      OnEnter = Edit1Enter
      OnKeyPress = Edit1KeyPress
    end
    object Edit2: TEdit
      Left = 168
      Top = 28
      Width = 45
      Height = 28
      AutoSelect = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      MaxLength = 3
      ParentFont = False
      TabOrder = 1
      OnEnter = Edit2Enter
      OnKeyPress = Edit2KeyPress
    end
    object Edit3: TEdit
      Left = 220
      Top = 28
      Width = 45
      Height = 28
      AutoSelect = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      MaxLength = 4
      ParentFont = False
      TabOrder = 2
      OnKeyPress = Edit3KeyPress
    end
    object Panel2: TPanel
      Left = 529
      Top = 8
      Width = 163
      Height = 31
      BevelOuter = bvLowered
      Caption = '00:00:00'
      Color = clBlack
      Font.Charset = ANSI_CHARSET
      Font.Color = 14151712
      Font.Height = -24
      Font.Name = 'Arial'
      Font.Style = []
      ParentFont = False
      TabOrder = 3
    end
    object Panel3: TPanel
      Left = 292
      Top = 35
      Width = 225
      Height = 61
      BevelOuter = bvLowered
      TabOrder = 4
      object PaintBox1: TPaintBox
        Left = 1
        Top = 1
        Width = 223
        Height = 59
        Align = alClient
        Color = clInfoBk
        ParentColor = False
        OnPaint = PaintBox1Paint
      end
    end
    object Panel4: TPanel
      Left = 292
      Top = 8
      Width = 114
      Height = 21
      BevelOuter = bvLowered
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clRed
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 5
    end
    object Panel7: TPanel
      Left = 412
      Top = 8
      Width = 104
      Height = 21
      BevelOuter = bvLowered
      TabOrder = 6
    end
    object Panel8: TPanel
      Left = 292
      Top = 103
      Width = 225
      Height = 9
      Cursor = crHandPoint
      Hint = 'RIT'
      BevelOuter = bvLowered
      ParentShowHint = False
      ShowHint = True
      TabOrder = 7
      OnMouseDown = Panel8MouseDown
      object Shape2: TShape
        Left = 81
        Top = 1
        Width = 32
        Height = 7
        Cursor = crHandPoint
        Brush.Color = 12902431
        OnMouseDown = Shape2MouseDown
      end
    end
    object Panel11: TPanel
      Left = 529
      Top = 44
      Width = 163
      Height = 68
      BevelOuter = bvLowered
      Caption = '0'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -19
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 8
      object ListView1: TListView
        Left = 1
        Top = 1
        Width = 161
        Height = 66
        Align = alClient
        BorderStyle = bsNone
        Columns = <
          item
            Width = 41
          end
          item
            Caption = 'Raw'
          end
          item
            Caption = 'Verified'
          end>
        ColumnClick = False
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        Items.ItemData = {
          05900000000300000000000000FFFFFFFFFFFFFFFF02000000FFFFFFFF000000
          00035000740073000000000000000000000000000000FFFFFFFFFFFFFFFF0200
          0000FFFFFFFF00000000044D0075006C00740000000000000000000000000000
          00FFFFFFFFFFFFFFFF02000000FFFFFFFF0000000005530063006F0072006500
          00000000000000000000FFFFFFFFFFFFFFFFFFFFFFFF}
        ReadOnly = True
        RowSelect = True
        ParentFont = False
        TabOrder = 0
        TabStop = False
        ViewStyle = vsReport
      end
    end
  end
  object Panel5: TPanel
    Left = 0
    Top = 286
    Width = 700
    Height = 8
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
  end
  object Panel6: TPanel
    Left = 0
    Top = 2
    Width = 488
    Height = 284
    Align = alClient
    BevelOuter = bvNone
    BorderStyle = bsSingle
    TabOrder = 2
    object Shape1: TShape
      Left = 0
      Top = 0
      Width = 484
      Height = 239
      Align = alClient
      Brush.Color = 16711401
      Pen.Style = psClear
    end
    object Label14: TLabel
      Left = 76
      Top = 60
      Width = 310
      Height = 40
      Caption = 'Morse Runner 1.68'
      Font.Charset = ANSI_CHARSET
      Font.Color = 12369084
      Font.Height = -35
      Font.Name = 'Arial'
      Font.Style = [fsBold, fsItalic]
      ParentFont = False
      Transparent = True
    end
    object Label12: TLabel
      Left = 71
      Top = 56
      Width = 310
      Height = 40
      Caption = 'Morse Runner 1.68'
      Font.Charset = ANSI_CHARSET
      Font.Color = clAqua
      Font.Height = -35
      Font.Name = 'Arial'
      Font.Style = [fsBold, fsItalic]
      ParentFont = False
      Transparent = True
    end
    object Label13: TLabel
      Left = 70
      Top = 55
      Width = 310
      Height = 40
      Caption = 'Morse Runner 1.68'
      Font.Charset = ANSI_CHARSET
      Font.Color = clGreen
      Font.Height = -35
      Font.Name = 'Arial'
      Font.Style = [fsBold, fsItalic]
      ParentFont = False
      Transparent = True
    end
    object Label15: TLabel
      Left = 106
      Top = 108
      Width = 245
      Height = 13
      Caption = 'Copyright '#169' 2004-2006 Alex Shovkoplyas, VE3NEA'
      Transparent = True
    end
    object Label16: TLabel
      Left = 198
      Top = 128
      Width = 61
      Height = 13
      Caption = 'FREEWARE'
      Transparent = True
    end
    object RichEdit1: TRichEdit
      Left = 0
      Top = 239
      Width = 484
      Height = 41
      TabStop = False
      Align = alBottom
      BorderStyle = bsNone
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Courier New'
      Font.Style = []
      ParentFont = False
      ReadOnly = True
      ScrollBars = ssVertical
      TabOrder = 0
      Visible = False
      Zoom = 100
    end
  end
  object Panel9: TPanel
    Left = 488
    Top = 2
    Width = 212
    Height = 284
    Align = alRight
    BevelOuter = bvNone
    TabOrder = 3
    object GroupBox3: TGroupBox
      Left = 9
      Top = 170
      Width = 194
      Height = 81
      Caption = ' Band Conditions '
      TabOrder = 0
      object Label11: TLabel
        Left = 144
        Top = 16
        Width = 34
        Height = 13
        Caption = 'Activity'
      end
      object CheckBox2: TCheckBox
        Left = 12
        Top = 58
        Width = 45
        Height = 17
        TabStop = False
        Caption = 'QSB'
        Checked = True
        State = cbChecked
        TabOrder = 0
        OnClick = CheckBoxClick
      end
      object CheckBox3: TCheckBox
        Left = 12
        Top = 38
        Width = 45
        Height = 17
        TabStop = False
        Caption = 'QRM'
        Checked = True
        State = cbChecked
        TabOrder = 1
        OnClick = CheckBoxClick
      end
      object CheckBox4: TCheckBox
        Left = 12
        Top = 18
        Width = 45
        Height = 17
        TabStop = False
        Caption = 'QRN'
        Checked = True
        State = cbChecked
        TabOrder = 2
        OnClick = CheckBoxClick
      end
      object CheckBox5: TCheckBox
        Left = 76
        Top = 18
        Width = 53
        Height = 17
        TabStop = False
        Caption = 'Flutter'
        Checked = True
        State = cbChecked
        TabOrder = 3
        OnClick = CheckBoxClick
      end
      object CheckBox6: TCheckBox
        Left = 76
        Top = 40
        Width = 45
        Height = 17
        TabStop = False
        Caption = 'LID'#39's'
        Checked = True
        State = cbChecked
        TabOrder = 4
        OnClick = CheckBoxClick
      end
      object SpinEdit3: TSpinEdit
        Left = 144
        Top = 32
        Width = 37
        Height = 22
        TabStop = False
        MaxLength = 1
        MaxValue = 9
        MinValue = 1
        TabOrder = 5
        Value = 3
        OnChange = SpinEdit3Change
      end
    end
    object GroupBox1: TGroupBox
      Left = 9
      Top = 6
      Width = 194
      Height = 159
      Caption = ' Station '
      TabOrder = 1
      object Label4: TLabel
        Left = 12
        Top = 20
        Width = 17
        Height = 13
        Caption = 'Call'
      end
      object Label5: TLabel
        Left = 156
        Top = 48
        Width = 27
        Height = 13
        Caption = 'WPM'
      end
      object Label6: TLabel
        Left = 12
        Top = 48
        Width = 52
        Height = 13
        Caption = 'CW Speed'
      end
      object Label7: TLabel
        Left = 12
        Top = 76
        Width = 45
        Height = 13
        Caption = 'CW Pitch'
      end
      object Label9: TLabel
        Left = 12
        Top = 104
        Width = 68
        Height = 13
        Caption = 'RX Bandwidth'
      end
      object VolumeSlider1: TVolumeSlider
        Left = 89
        Top = 132
        Width = 60
        Height = 20
        Hint = '-15.0 dB'
        ShowHint = True
        Margin = 5
        Value = 0.750000000000000000
        Overloaded = False
        OnChange = VolumeSlider1Change
        OnDblClick = VolumeSliderDblClick
        DbScale = 60.000000000000000000
        Db = -15.000000000000000000
      end
      object Label18: TLabel
        Left = 12
        Top = 134
        Width = 53
        Height = 13
        Caption = 'Mon. Level'
      end
      object Edit4: TEdit
        Left = 36
        Top = 16
        Width = 89
        Height = 21
        TabStop = False
        CharCase = ecUpperCase
        TabOrder = 0
        Text = 'VE3NEA'
        OnChange = Edit4Change
      end
      object SpinEdit1: TSpinEdit
        Left = 88
        Top = 44
        Width = 65
        Height = 22
        TabStop = False
        MaxLength = 3
        MaxValue = 120
        MinValue = 10
        TabOrder = 1
        Value = 30
        OnChange = SpinEdit1Change
      end
      object CheckBox1: TCheckBox
        Left = 140
        Top = 18
        Width = 45
        Height = 17
        TabStop = False
        Caption = 'QSK'
        Checked = True
        State = cbChecked
        TabOrder = 2
        OnClick = CheckBox1Click
      end
      object ComboBox1: TComboBox
        Left = 88
        Top = 72
        Width = 65
        Height = 21
        Style = csDropDownList
        DropDownCount = 12
        TabOrder = 3
        TabStop = False
        OnChange = ComboBox1Change
        Items.Strings = (
          '300 Hz'
          '350 Hz'
          '400 Hz'
          '450 Hz'
          '500 Hz'
          '550 Hz'
          '600 Hz'
          '650 Hz'
          '700 Hz'
          '750 Hz'
          '800 Hz'
          '850 Hz'
          '900 Hz')
      end
      object ComboBox2: TComboBox
        Left = 88
        Top = 100
        Width = 65
        Height = 21
        Style = csDropDownList
        DropDownCount = 12
        TabOrder = 4
        TabStop = False
        OnChange = ComboBox2Change
        Items.Strings = (
          '100 Hz'
          '150 Hz'
          '200 Hz'
          '250 Hz'
          '300 Hz'
          '350 Hz'
          '400 Hz'
          '450 Hz'
          '500 Hz'
          '550 Hz'
          '600 Hz')
      end
    end
    object Panel10: TPanel
      Left = 0
      Top = 253
      Width = 212
      Height = 31
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 2
      object Label8: TLabel
        Left = 173
        Top = 9
        Width = 19
        Height = 13
        Caption = 'min.'
      end
      object Label10: TLabel
        Left = 103
        Top = 9
        Width = 12
        Height = 13
        Caption = 'for'
      end
      object SpinEdit2: TSpinEdit
        Left = 122
        Top = 7
        Width = 45
        Height = 22
        TabStop = False
        MaxLength = 2
        MaxValue = 240
        MinValue = 1
        TabOrder = 0
        Value = 30
        OnChange = SpinEdit2Change
      end
      object ToolBar1: TToolBar
        Left = 13
        Top = 5
        Width = 84
        Height = 24
        Align = alNone
        ButtonWidth = 65
        Caption = 'ToolBar1'
        Images = ImageList1
        Indent = 3
        List = True
        ShowCaptions = True
        TabOrder = 1
        object ToolButton1: TToolButton
          Tag = 1
          Left = 3
          Top = 0
          AllowAllUp = True
          Caption = '   Run   '
          DropdownMenu = PopupMenu1
          Grouped = True
          ImageIndex = 0
          Style = tbsDropDown
          OnClick = RunBtnClick
        end
      end
    end
  end
  object AlSoundOut1: TAlSoundOut
    SamplesPerSec = 11025
    BufCount = 8
    OnBufAvailable = AlSoundOut1BufAvailable
    Left = 88
    Top = 196
  end
  object MainMenu1: TMainMenu
    Left = 356
    Top = 148
    object File1: TMenuItem
      Caption = 'File'
      OnClick = File1Click
      object ViewScoreTable1: TMenuItem
        Caption = 'View Score Table'
        OnClick = ViewScoreTable1Click
      end
      object ViewScoreBoardMNU: TMenuItem
        Caption = 'View Hi-Score web page...'
        OnClick = ViewScoreBoardMNUClick
      end
      object N5: TMenuItem
        Caption = '-'
      end
      object AudioRecordingEnabled1: TMenuItem
        Caption = 'Audio Recording Enabled'
        OnClick = AudioRecordingEnabled1Click
      end
      object PlayRecordedAudio1: TMenuItem
        Caption = 'Play Recorded Audio'
        Enabled = False
        OnClick = PlayRecordedAudio1Click
      end
      object N8: TMenuItem
        Caption = '-'
      end
      object Exit1: TMenuItem
        Caption = 'Exit'
        OnClick = Exit1Click
      end
    end
    object Run1: TMenuItem
      Caption = 'Run'
      object PileUp1: TMenuItem
        Tag = 1
        Caption = 'Pile-Up'
        ShortCut = 120
        OnClick = RunMNUClick
      end
      object SingleCalls1: TMenuItem
        Tag = 2
        Caption = 'Single Calls'
        OnClick = RunMNUClick
      end
      object Competition1: TMenuItem
        Tag = 3
        Caption = 'WPX Competition'
        OnClick = RunMNUClick
      end
      object HSTCompetition2: TMenuItem
        Tag = 4
        Caption = 'HST Competition'
        ShortCut = 16504
        OnClick = RunMNUClick
      end
      object N4: TMenuItem
        Caption = '-'
      end
      object Stop1MNU: TMenuItem
        Caption = 'Stop'
        Enabled = False
        OnClick = StopMNUClick
      end
    end
    object Send1: TMenuItem
      Caption = 'Send'
      object CQ1: TMenuItem
        Tag = 1
        Caption = 'CQ'
        ShortCut = 112
        OnClick = SendClick
      end
      object Number1: TMenuItem
        Tag = 2
        Caption = 'Number'
        ShortCut = 113
        OnClick = SendClick
      end
      object TU1: TMenuItem
        Tag = 3
        Caption = 'TU'
        ShortCut = 114
        OnClick = SendClick
      end
      object MyCall1: TMenuItem
        Tag = 4
        Caption = 'My Call'
        ShortCut = 115
        OnClick = SendClick
      end
      object HisCall1: TMenuItem
        Tag = 5
        Caption = 'His Call'
        ShortCut = 116
        OnClick = SendClick
      end
      object QSOB41: TMenuItem
        Tag = 6
        Caption = 'QSO B4'
        ShortCut = 117
        OnClick = SendClick
      end
      object N1: TMenuItem
        Tag = 7
        Caption = '<?>'
        ShortCut = 118
        OnClick = SendClick
      end
      object AGN1: TMenuItem
        Tag = 8
        Caption = 'NIL'
        ShortCut = 119
        OnClick = SendClick
      end
    end
    object Settings1: TMenuItem
      Caption = 'Settings'
      OnClick = Settings1Click
      object Call1: TMenuItem
        Caption = 'Call...'
        OnClick = Call1Click
      end
      object QSK1: TMenuItem
        Caption = 'QSK'
        OnClick = QSK1Click
      end
      object CWSpeed1: TMenuItem
        Caption = 'CW Speed'
        object N10WPM1: TMenuItem
          Tag = 10
          Caption = '10 WPM'
          OnClick = NWPMClick
        end
        object N15WPM1: TMenuItem
          Tag = 15
          Caption = '15 WPM'
          OnClick = NWPMClick
        end
        object N20WPM1: TMenuItem
          Tag = 20
          Caption = '20 WPM'
          OnClick = NWPMClick
        end
        object N25WPM1: TMenuItem
          Tag = 25
          Caption = '25 WPM'
          OnClick = NWPMClick
        end
        object N30WPM1: TMenuItem
          Tag = 30
          Caption = '30 WPM'
          OnClick = NWPMClick
        end
        object N35WPM1: TMenuItem
          Tag = 35
          Caption = '35 WPM'
          OnClick = NWPMClick
        end
        object N40WPM1: TMenuItem
          Tag = 40
          Caption = '40 WPM'
          OnClick = NWPMClick
        end
        object N45WPM1: TMenuItem
          Tag = 45
          Caption = '45 WPM'
          OnClick = NWPMClick
        end
        object N50WPM1: TMenuItem
          Tag = 50
          Caption = '50 WPM'
          OnClick = NWPMClick
        end
        object N55WPM1: TMenuItem
          Tag = 55
          Caption = '55 WPM'
          OnClick = NWPMClick
        end
        object N60WPM1: TMenuItem
          Tag = 60
          Caption = '60 WPM'
          OnClick = NWPMClick
        end
      end
      object CWBandwidth1: TMenuItem
        Caption = 'CW Pitch'
        object N300Hz1: TMenuItem
          Caption = '300 Hz'
          OnClick = Pitch1Click
        end
        object N350Hz1: TMenuItem
          Tag = 1
          Caption = '350 Hz'
          OnClick = Pitch1Click
        end
        object N400Hz1: TMenuItem
          Tag = 2
          Caption = '400 Hz'
          OnClick = Pitch1Click
        end
        object N450Hz1: TMenuItem
          Tag = 3
          Caption = '450 Hz'
          OnClick = Pitch1Click
        end
        object N500Hz1: TMenuItem
          Tag = 4
          Caption = '500 Hz'
          OnClick = Pitch1Click
        end
        object N550Hz1: TMenuItem
          Tag = 5
          Caption = '550 Hz'
          OnClick = Pitch1Click
        end
        object N600Hz1: TMenuItem
          Tag = 6
          Caption = '600 Hz'
          OnClick = Pitch1Click
        end
        object N650Hz1: TMenuItem
          Tag = 7
          Caption = '650 Hz'
          OnClick = Pitch1Click
        end
        object N700Hz1: TMenuItem
          Tag = 8
          Caption = '700 Hz'
          OnClick = Pitch1Click
        end
        object N750Hz1: TMenuItem
          Tag = 9
          Caption = '750 Hz'
          OnClick = Pitch1Click
        end
        object N800Hz1: TMenuItem
          Tag = 10
          Caption = '800 Hz'
          OnClick = Pitch1Click
        end
        object N850Hz1: TMenuItem
          Tag = 11
          Caption = '850 Hz'
          OnClick = Pitch1Click
        end
        object N900Hz1: TMenuItem
          Tag = 12
          Caption = '900 Hz'
          OnClick = Pitch1Click
        end
      end
      object CWBandwidth2: TMenuItem
        Caption = 'CW Bandwidth'
        object N100Hz1: TMenuItem
          Caption = '100 Hz'
          OnClick = Bw1Click
        end
        object N150Hz1: TMenuItem
          Tag = 1
          Caption = '150 Hz'
          OnClick = Bw1Click
        end
        object N200Hz1: TMenuItem
          Tag = 2
          Caption = '200 Hz'
          OnClick = Bw1Click
        end
        object N250Hz1: TMenuItem
          Tag = 3
          Caption = '250 Hz'
          OnClick = Bw1Click
        end
        object N300Hz2: TMenuItem
          Tag = 4
          Caption = '300 Hz'
          OnClick = Bw1Click
        end
        object N350Hz2: TMenuItem
          Tag = 5
          Caption = '350 Hz'
          OnClick = Bw1Click
        end
        object N400Hz2: TMenuItem
          Tag = 6
          Caption = '400 Hz'
          OnClick = Bw1Click
        end
        object N450Hz2: TMenuItem
          Tag = 7
          Caption = '450 Hz'
          OnClick = Bw1Click
        end
        object N500Hz2: TMenuItem
          Tag = 8
          Caption = '500 Hz'
          OnClick = Bw1Click
        end
        object N550Hz2: TMenuItem
          Tag = 9
          Caption = '550 Hz'
          OnClick = Bw1Click
        end
        object N600Hz2: TMenuItem
          Tag = 10
          Caption = '600 Hz'
          OnClick = Bw1Click
        end
      end
      object MonLevel1: TMenuItem
        Tag = -30
        Caption = 'Mon. Level'
        object N30dB1: TMenuItem
          Tag = -60
          Caption = '-60 dB'
          OnClick = SelfMonClick
        end
        object N20dB1: TMenuItem
          Tag = -40
          Caption = '-40 dB'
          OnClick = SelfMonClick
        end
        object N10dB1: TMenuItem
          Tag = -20
          Caption = '-20 dB'
          OnClick = SelfMonClick
        end
        object N0dB1: TMenuItem
          Caption = '0 dB'
          OnClick = SelfMonClick
        end
        object N10dB2: TMenuItem
          Tag = 20
          Caption = '+20 dB'
          OnClick = SelfMonClick
        end
      end
      object N6: TMenuItem
        Caption = '-'
      end
      object QRN1: TMenuItem
        Caption = 'QRN'
        OnClick = LIDS1Click
      end
      object QRM1: TMenuItem
        Caption = 'QRM'
        OnClick = LIDS1Click
      end
      object QSB1: TMenuItem
        Caption = 'QSB'
        OnClick = LIDS1Click
      end
      object Flutter1: TMenuItem
        Caption = 'Flutter'
        OnClick = LIDS1Click
      end
      object LIDS1: TMenuItem
        Caption = 'LIDS'
        OnClick = LIDS1Click
      end
      object Activity1: TMenuItem
        Caption = 'Activity'
        object N11: TMenuItem
          Tag = 1
          Caption = '1'
          OnClick = Activity1Click
        end
        object N21: TMenuItem
          Tag = 2
          Caption = '2'
          OnClick = Activity1Click
        end
        object N31: TMenuItem
          Tag = 3
          Caption = '3'
          OnClick = Activity1Click
        end
        object N41: TMenuItem
          Tag = 4
          Caption = '4'
          OnClick = Activity1Click
        end
        object N51: TMenuItem
          Tag = 5
          Caption = '5'
          OnClick = Activity1Click
        end
        object N61: TMenuItem
          Tag = 6
          Caption = '6'
          OnClick = Activity1Click
        end
        object N71: TMenuItem
          Tag = 7
          Caption = '7'
          OnClick = Activity1Click
        end
        object N81: TMenuItem
          Tag = 8
          Caption = '8'
          OnClick = Activity1Click
        end
        object N91: TMenuItem
          Tag = 9
          Caption = '9'
          OnClick = Activity1Click
        end
      end
      object N7: TMenuItem
        Caption = '-'
      end
      object Duration1: TMenuItem
        Caption = 'Duration'
        object N5min1: TMenuItem
          Tag = 5
          Caption = '5 min'
          OnClick = Duration1Click
        end
        object N10min1: TMenuItem
          Tag = 10
          Caption = '10 min'
          OnClick = Duration1Click
        end
        object N15min1: TMenuItem
          Tag = 15
          Caption = '15 min'
          OnClick = Duration1Click
        end
        object N30min1: TMenuItem
          Tag = 30
          Caption = '30 min'
          OnClick = Duration1Click
        end
        object N60min1: TMenuItem
          Tag = 60
          Caption = '60 min'
          OnClick = Duration1Click
        end
        object N90min1: TMenuItem
          Tag = 90
          Caption = '90 min'
          OnClick = Duration1Click
        end
        object N120min1: TMenuItem
          Tag = 120
          Caption = '120 min'
          OnClick = Duration1Click
        end
      end
      object Operator1: TMenuItem
        Caption = 'HST Operator...'
        OnClick = Operator1Click
      end
    end
    object Help1: TMenuItem
      Caption = 'Help'
      object WebPage1: TMenuItem
        Caption = 'Web Page...'
        OnClick = WebPage1Click
      end
      object Readme1: TMenuItem
        Caption = 'Readme...'
        OnClick = Readme1Click
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object About1: TMenuItem
        Caption = 'About...'
        OnClick = About1Click
      end
    end
  end
  object PopupMenu1: TPopupMenu
    Left = 356
    Top = 176
    object PileupMNU: TMenuItem
      Tag = 1
      Caption = 'Pile-Up'
      Default = True
      OnClick = RunMNUClick
    end
    object SingleCallsMNU: TMenuItem
      Tag = 2
      Caption = 'Single Calls'
      OnClick = RunMNUClick
    end
    object CompetitionMNU: TMenuItem
      Tag = 3
      Caption = 'WPX Competition'
      OnClick = RunMNUClick
    end
    object HSTCompetition1: TMenuItem
      Tag = 4
      Caption = 'HST Competition'
      OnClick = RunMNUClick
    end
    object N3: TMenuItem
      Caption = '-'
    end
    object StopMNU: TMenuItem
      Caption = 'Stop'
      Enabled = False
      OnClick = StopMNUClick
    end
  end
  object ImageList1: TImageList
    Left = 384
    Top = 176
    Bitmap = {
      494C010102000800080010001000FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000400000001000000001002000000000000010
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000008484840000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000008484840084848400000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000848484000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000084848400848484000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00008484840084848400FFFFFF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000FF000000000000848484008484840000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000084848400FFFFFF0084848400FFFFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000FF000000FF0000000000008484840084848400000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000084848400FFFFFF00C6C6C60084848400FFFFFF0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000FF000000FF000000FF00000000000084848400848484000000
      0000000000000000000000000000000000000000000000000000000000000000
      000084848400FFFFFF00C6C6C600C6C6C60084848400FFFFFF00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000FF000000FF000000FF000000FF000000000000848484008484
      8400000000000000000000000000000000000000000000000000000000000000
      000084848400FFFFFF00C6C6C600C6C6C600C6C6C60084848400FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000FF000000FF000000FF000000FF000000FF0000000000008484
      8400848484000000000000000000000000000000000000000000000000000000
      000084848400FFFFFF00C6C6C600C6C6C600C6C6C600C6C6C600848484000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000FF000000FF000000FF000000FF000000FF000000FF00000000
      0000000000000000000000000000000000000000000000000000000000000000
      000084848400FFFFFF00C6C6C600C6C6C600C6C6C600C6C6C600C6C6C6008484
      8400000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000FF000000FF000000FF000000FF000000FF0000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000084848400FFFFFF00C6C6C600C6C6C600C6C6C600C6C6C600848484000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000FF000000FF000000FF000000FF000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000084848400FFFFFF00C6C6C600C6C6C600C6C6C60084848400000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000FF000000FF000000FF00000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000084848400FFFFFF00C6C6C600C6C6C6008484840000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000FF000000FF0000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000084848400FFFFFF00C6C6C600848484000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000FF000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000084848400FFFFFF0084848400000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000848484008484840000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000848484000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      2800000040000000100000000100010000000000800000000000000000000000
      000000000000000000000000FFFFFF00FBFFFFFF00000000F1FFF7FF00000000
      F0FFF1FF00000000F07FF0FF00000000F03FF07F00000000F01FF03F00000000
      F00FF01F00000000F007F01F00000000F00FF00F00000000F01FF01F00000000
      F03FF03F00000000F07FF07F00000000F0FFF0FF00000000F1FFF1FF00000000
      F3FFF3FF00000000F7FFF7FF0000000000000000000000000000000000000000
      000000000000}
  end
  object AlWavFile1: TAlWavFile
    Left = 384
    Top = 204
  end
end

object FrmSelecaoPeriodo: TFrmSelecaoPeriodo
  Left = 0
  Top = 0
  BorderStyle = bsToolWindow
  Caption = 'Sele'#231#227'o de Per'#237'odo'
  ClientHeight = 179
  ClientWidth = 472
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  TextHeight = 15
  object Label1: TLabel
    Left = 8
    Top = 136
    Width = 182
    Height = 15
    Caption = '* Double click para escrever a data'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = [fsItalic]
    ParentFont = False
    Layout = tlCenter
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 8
    Width = 225
    Height = 113
    Caption = 'In'#237'cio'
    TabOrder = 0
    object DtPcWin10Inicio: TDatePicker
      Left = 19
      Top = 65
      Width = 186
      Date = 45277.000000000000000000
      DateFormat = 'dd/mm/yyyy'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Segoe UI'
      Font.Style = []
      TabOrder = 1
      TabStop = False
      OnChange = DtPcWin10InicioChange
    end
    object DtPcInicio: TDateTimePicker
      Left = 19
      Top = 26
      Width = 186
      Height = 23
      Date = 45277.000000000000000000
      Time = 0.675166412038379300
      ImeName = 'DtPcInicio'
      ParseInput = True
      ParentShowHint = False
      ShowHint = False
      TabOrder = 0
      OnChange = DtPcInicioChange
      OnKeyPress = DtPcInicioKeyPress
    end
  end
  object GroupBox2: TGroupBox
    Left = 239
    Top = 8
    Width = 225
    Height = 113
    Caption = 'Final'
    TabOrder = 1
    object DtPcWin10Final: TDatePicker
      Left = 19
      Top = 65
      Width = 186
      Date = 45277.000000000000000000
      DateFormat = 'dd/mm/yyyy'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Segoe UI'
      Font.Style = []
      TabOrder = 1
      TabStop = False
      OnChange = DtPcWin10FinalChange
    end
    object DtPcFinal: TDateTimePicker
      Left = 19
      Top = 26
      Width = 186
      Height = 23
      Date = 45277.000000000000000000
      Time = 0.675166412038379300
      ParseInput = True
      TabOrder = 0
      OnChange = DtPcFinalChange
      OnKeyPress = DtPcFinalKeyPress
    end
  end
  object BtnSelecionarPeriodo: TButton
    Left = 296
    Top = 136
    Width = 168
    Height = 30
    Caption = 'Selecionar Per'#237'odo '#55358#56402
    TabOrder = 2
    OnClick = BtnSelecionarPeriodoClick
  end
end

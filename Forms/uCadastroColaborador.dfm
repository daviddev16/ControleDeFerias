object FrmCadastroColaborador: TFrmCadastroColaborador
  Left = 0
  Top = 0
  Caption = 'Cadastro de Colaborador'
  ClientHeight = 295
  ClientWidth = 442
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  TextHeight = 15
  object EdtLogin: TLabeledEdit
    Left = 8
    Top = 32
    Width = 145
    Height = 23
    EditLabel.Width = 33
    EditLabel.Height = 15
    EditLabel.Caption = 'Login:'
    TabOrder = 0
    Text = ''
  end
  object EdtDescricao: TLabeledEdit
    Left = 184
    Top = 32
    Width = 250
    Height = 23
    EditLabel.Width = 92
    EditLabel.Height = 15
    EditLabel.Caption = 'Nome Completo:'
    TabOrder = 1
    Text = ''
  end
  object StaticText1: TStaticText
    Left = 8
    Top = 64
    Width = 69
    Height = 19
    Caption = 'Observa'#231#227'o:'
    TabOrder = 2
  end
  object MmObservacao: TMemo
    Left = 8
    Top = 80
    Width = 426
    Height = 89
    TabOrder = 3
  end
  object BtnCadastrar: TButton
    Left = 359
    Top = 262
    Width = 75
    Height = 25
    Caption = 'Cadastrar'
    TabOrder = 4
    OnClick = BtnCadastrarClick
  end
  object NmbEdtPrevisaoDias: TNumberBox
    Left = 8
    Top = 208
    Width = 121
    Height = 23
    Decimal = 0
    LargeStep = 1.000000000000000000
    MinValue = 1.000000000000000000
    MaxValue = 31.000000000000000000
    TabOrder = 5
    Value = 15.000000000000000000
  end
  object StaticText2: TStaticText
    Left = 8
    Top = 190
    Width = 187
    Height = 19
    Caption = 'N'#250'mero inicial previsto para f'#233'rias:'
    TabOrder = 6
  end
end

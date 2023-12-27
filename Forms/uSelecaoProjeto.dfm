object FrmSelecaoProjeto: TFrmSelecaoProjeto
  Left = 0
  Top = 0
  BorderStyle = bsToolWindow
  Caption = 'FrmSelecaoProjeto'
  ClientHeight = 288
  ClientWidth = 355
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnShow = FormShow
  TextHeight = 15
  object Label1: TLabel
    Left = 8
    Top = 19
    Width = 106
    Height = 15
    Caption = 'Projetos associados:'
  end
  object SpeedButton1: TSpeedButton
    Left = 166
    Top = 251
    Width = 23
    Height = 22
    Caption = '<'
    OnClick = SpeedButton1Click
  end
  object SpeedButton2: TSpeedButton
    Left = 166
    Top = 223
    Width = 23
    Height = 22
    Caption = '>'
    OnClick = SpeedButton2Click
  end
  object Label2: TLabel
    Left = 195
    Top = 19
    Width = 89
    Height = 15
    Caption = 'Lista de projetos:'
  end
  object LsBxColabProjetos: TListBox
    Left = 8
    Top = 40
    Width = 152
    Height = 233
    ItemHeight = 15
    TabOrder = 0
  end
  object LsBxTodosProjetos: TListBox
    Left = 195
    Top = 40
    Width = 152
    Height = 241
    ItemHeight = 15
    TabOrder = 1
  end
end

object FrmOpcoes: TFrmOpcoes
  Left = 0
  Top = 0
  Caption = 'FrmOpcoes'
  ClientHeight = 224
  ClientWidth = 595
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnShow = FormShow
  DesignSize = (
    595
    224)
  TextHeight = 15
  object GpBxCores: TGroupBox
    Left = 8
    Top = 8
    Width = 579
    Height = 81
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Cores de Status'
    DockSite = True
    TabOrder = 0
    object PnStatusAberto: TPanel
      Left = 16
      Top = 22
      Width = 177
      Height = 39
      BevelOuter = bvNone
      Caption = 'PnStatusAberto'
      ShowCaption = False
      TabOrder = 0
      DesignSize = (
        177
        39)
      object LblStatusAberto: TLabel
        Left = 0
        Top = 0
        Width = 117
        Height = 15
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Sem per'#237'odo de f'#233'rias:'
      end
      object ClBxStatusAberto: TColorBox
        Left = 0
        Top = 18
        Width = 177
        Height = 22
        HelpType = htKeyword
        Anchors = [akLeft, akTop, akRight]
        ParentShowHint = False
        ShowHint = False
        TabOrder = 0
      end
    end
    object PnStatusAndamento: TPanel
      Left = 199
      Top = 22
      Width = 177
      Height = 39
      BevelOuter = bvNone
      Caption = 'PnStatusAberto'
      ShowCaption = False
      TabOrder = 1
      DesignSize = (
        177
        39)
      object LblStatusAndamento: TLabel
        Left = 0
        Top = 0
        Width = 168
        Height = 15
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Preenchimento em andamento:'
      end
      object ClBxStatusAndamento: TColorBox
        Left = 0
        Top = 18
        Width = 177
        Height = 22
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 0
      end
    end
    object PnStatusFinalizado: TPanel
      Left = 382
      Top = 22
      Width = 177
      Height = 39
      BevelOuter = bvNone
      Caption = 'PnStatusAberto'
      ShowCaption = False
      TabOrder = 2
      DesignSize = (
        177
        39)
      object LblStatusFinalizado: TLabel
        Left = 0
        Top = 0
        Width = 138
        Height = 15
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Preenchimento finalizado:'
      end
      object ClBxStatusFinalizado: TColorBox
        Left = 0
        Top = 18
        Width = 177
        Height = 22
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 0
      end
    end
  end
  object BtnSalvarCfg: TButton
    Left = 440
    Top = 191
    Width = 147
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Salvar configura'#231#227'o'
    TabOrder = 1
    OnClick = BtnSalvarCfgClick
    ExplicitTop = 595
  end
  object GpBxCfgPeriod: TGroupBox
    Left = 8
    Top = 95
    Width = 579
    Height = 81
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Configura'#231#245'es de per'#237'odos:'
    DockSite = True
    TabOrder = 2
    object PnVlMaxDaC: TPanel
      Left = 16
      Top = 24
      Width = 185
      Height = 41
      BevelOuter = bvNone
      Caption = 'PnVlMaxDaC'
      ShowCaption = False
      TabOrder = 0
      DesignSize = (
        185
        41)
      object LblMaxDiasAComprir: TLabel
        Left = 0
        Top = 0
        Width = 170
        Height = 15
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Valor m'#225'ximo de dias a comprir:'
      end
      object SpnVlMaxDiasAComprir: TSpinEdit
        Left = 0
        Top = 17
        Width = 185
        Height = 24
        Anchors = [akLeft, akRight, akBottom]
        MaxValue = 365
        MinValue = 1
        TabOrder = 0
        Value = 0
      end
    end
    object PnPeriodoMinDFerias: TPanel
      Left = 207
      Top = 24
      Width = 210
      Height = 41
      BevelOuter = bvNone
      Caption = 'PnSpnVlMaxDaC'
      ShowCaption = False
      TabOrder = 1
      DesignSize = (
        210
        41)
      object LblPeriodoMinDFerias: TLabel
        Left = 0
        Top = 0
        Width = 213
        Height = 15
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Per'#237'odo m'#237'nimo de f'#233'rias (em dias):'
        ExplicitWidth = 188
      end
      object SpnPeriodoMinDFerias: TSpinEdit
        Left = 0
        Top = 17
        Width = 210
        Height = 24
        Anchors = [akLeft, akRight, akBottom]
        MaxValue = 365
        MinValue = 1
        TabOrder = 0
        Value = 0
      end
    end
  end
end

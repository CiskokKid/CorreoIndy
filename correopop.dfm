object fCorreoPop: TfCorreoPop
  Left = 0
  Top = 0
  Caption = 'fCorreoPop'
  ClientHeight = 325
  ClientWidth = 540
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 540
    Height = 41
    Align = alTop
    TabOrder = 0
    object Button1: TButton
      Left = 72
      Top = 2
      Width = 89
      Height = 35
      Caption = 'Recibir'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      OnClick = Button1Click
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 41
    Width = 540
    Height = 284
    Align = alClient
    TabOrder = 1
    object Memo1: TMemo
      Left = 1
      Top = 1
      Width = 538
      Height = 231
      Align = alClient
      Lines.Strings = (
        'Memo1')
      TabOrder = 0
    end
    object Panel3: TPanel
      Left = 1
      Top = 232
      Width = 538
      Height = 51
      Align = alBottom
      TabOrder = 1
      object Panel4: TPanel
        Left = 1
        Top = 1
        Width = 536
        Height = 24
        Align = alTop
        TabOrder = 0
        object ProgressBar1: TProgressBar
          Left = 1
          Top = 1
          Width = 534
          Height = 22
          Align = alClient
          TabOrder = 0
        end
      end
    end
  end
end

object FormMain: TFormMain
  Left = 0
  Top = 0
  Caption = #32232#38598#21487#33021#12394#12479#12502#12467#12531#12488#12525#12540#12523
  ClientHeight = 231
  ClientWidth = 505
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Memo1: TMemo
    Left = 168
    Top = 88
    Width = 185
    Height = 89
    Lines.Strings = (
      'Memo1')
    TabOrder = 0
  end
  object PopupMenu1: TPopupMenu
    Left = 240
    Top = 136
    object N1: TMenuItem
      Caption = #32232#38598
      ShortCut = 113
      OnClick = N1Click
    end
  end
end

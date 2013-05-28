object Form4: TForm4
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Minecraft launcher'
  ClientHeight = 570
  ClientWidth = 573
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnActivate = FormActivate
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 32
    Top = 24
    Width = 235
    Height = 13
    Caption = #1044#1086#1073#1088#1086' '#1087#1086#1078#1072#1083#1086#1074#1072#1090#1100' '#1085#1072' '#1089#1077#1088#1074#1077#1088' happyminers.ru, '
  end
  object Button1: TButton
    Left = 368
    Top = 496
    Width = 169
    Height = 41
    Caption = #1042#1086#1081#1090#1080' '#1074' '#1080#1075#1088#1091
    TabOrder = 0
    OnClick = Button1Click
  end
  object Memo1: TMemo
    Left = 72
    Top = 104
    Width = 433
    Height = 329
    TabOrder = 1
  end
end

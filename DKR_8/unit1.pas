unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Buttons,
  StdCtrls, ExtCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    BitBtn4: TBitBtn;
    Edit1: TEdit;
    Edit2: TEdit;
    Image1: TImage;
    Label1: TLabel;
    Memo1: TMemo;
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure BitBtn3Click(Sender: TObject);
    procedure BitBtn4Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    function CheckNumber(const NumStr: string; var Value: integer): boolean;
    procedure ShowError(const Msg: string);
  public
    { public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

// ПРИНУДИТЕЛЬНАЯ ПРИВЯЗКА КНОПОК
procedure TForm1.FormCreate(Sender: TObject);
begin
  BitBtn1.OnClick := @BitBtn1Click;
  BitBtn2.OnClick := @BitBtn2Click;
  BitBtn3.OnClick := @BitBtn3Click;
  BitBtn4.OnClick := @BitBtn4Click;
end;

// Функция проверки числа с границами
function TForm1.CheckNumber(const NumStr: string; var Value: integer): boolean;
var
  Temp: Int64;  // Используем 64-битный тип для проверки переполнения
  Code: integer;
begin
  Result := False;

  // Проверка на пустую строку
  if NumStr = '' then
  begin
    ShowError('Поле не заполнено');
    Exit;
  end;

  // Проверка на наличие букв и запрещённых символов
  Val(NumStr, Temp, Code);
  if Code <> 0 then
  begin
    ShowError('Введите целое число (только цифры и знак минус)');
    Exit;
  end;

  // Проверка границ целого числа (Integer)
  if (Temp < -2147483648) or (Temp > 2147483647) then
  begin
    ShowError('Число выходит за допустимые границы!' + sLineBreak +
              'Допустимый диапазон: от -2 147 483 648 до 2 147 483 647');
    Exit;
  end;

  Value := Temp;
  Result := True;
end;

procedure TForm1.ShowError(const Msg: string);
begin
  Memo1.Lines.Add('ОШИБКА: ' + Msg);
end;

// Сложение
procedure TForm1.BitBtn1Click(Sender: TObject);
var
  a, b, sum: integer;
begin
  if not CheckNumber(Edit1.Text, a) then Exit;
  if not CheckNumber(Edit2.Text, b) then Exit;

  // Проверка переполнения при сложении
  if (a > 0) and (b > 0) and (a > MaxInt - b) then
  begin
    ShowError('Результат сложения слишком большой!');
    Exit;
  end;
  if (a < 0) and (b < 0) and (a < -MaxInt - 1 - b) then
  begin
    ShowError('Результат сложения слишком маленький!');
    Exit;
  end;

  sum := a + b;
  Memo1.Lines.Add(IntToStr(a) + ' + ' + IntToStr(b) + ' = ' + IntToStr(sum));
end;

// Вычитание
procedure TForm1.BitBtn2Click(Sender: TObject);
var
  a, b, result: integer;
begin
  if not CheckNumber(Edit1.Text, a) then Exit;
  if not CheckNumber(Edit2.Text, b) then Exit;

  // Проверка переполнения при вычитании
  if (b < 0) and (a > MaxInt + b) then
  begin
    ShowError('Результат вычитания слишком большой!');
    Exit;
  end;
  if (b > 0) and (a < -MaxInt - 1 + b) then
  begin
    ShowError('Результат вычитания слишком маленький!');
    Exit;
  end;

  result := a - b;
  Memo1.Lines.Add(IntToStr(a) + ' - ' + IntToStr(b) + ' = ' + IntToStr(result));
end;

// Умножение
procedure TForm1.BitBtn3Click(Sender: TObject);
var
  a, b, result: integer;
begin
  if not CheckNumber(Edit1.Text, a) then Exit;
  if not CheckNumber(Edit2.Text, b) then Exit;

  // Проверка переполнения при умножении
  if (a <> 0) and (b <> 0) then
  begin
    if (abs(a) > MaxInt div abs(b)) then
    begin
      ShowError('Результат умножения слишком большой!');
      Exit;
    end;
  end;

  result := a * b;
  Memo1.Lines.Add(IntToStr(a) + ' × ' + IntToStr(b) + ' = ' + IntToStr(result));
end;

// Деление
procedure TForm1.BitBtn4Click(Sender: TObject);
var
  a, b: integer;
  result: double;
begin
  if not CheckNumber(Edit1.Text, a) then Exit;
  if not CheckNumber(Edit2.Text, b) then Exit;

  if b = 0 then
  begin
    ShowError('Деление на ноль невозможно');
    Exit;
  end;

  result := a / b;

  if a mod b = 0 then
    Memo1.Lines.Add(IntToStr(a) + ' ÷ ' + IntToStr(b) + ' = ' + IntToStr(a div b))
  else
    Memo1.Lines.Add(IntToStr(a) + ' ÷ ' + IntToStr(b) + ' = ' + FormatFloat('0.##', result));
end;

end.

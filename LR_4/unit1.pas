unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    btnBackspace: TButton;
    btn4: TButton;
    btn5: TButton;
    btn6: TButton;
    btnMul: TButton;
    btnInv: TButton;
    btn1: TButton;
    btn2: TButton;
    btn3: TButton;
    btnSub: TButton;
    btnEqual: TButton;
    btnCe: TButton;
    btnPoint: TButton;
    btnAdd: TButton;
    btn0: TButton;
    btnClear: TButton;
    btnSqrt: TButton;
    btn7: TButton;
    btn8: TButton;
    btn9: TButton;
    btnDiv: TButton;
    btnSquare: TButton;
    Edit1: TEdit;

    procedure btn0Click(Sender: TObject);
    procedure btn1Click(Sender: TObject);
    procedure btn2Click(Sender: TObject);
    procedure btn3Click(Sender: TObject);
    procedure btn4Click(Sender: TObject);
    procedure btn5Click(Sender: TObject);
    procedure btn6Click(Sender: TObject);
    procedure btn7Click(Sender: TObject);
    procedure btn8Click(Sender: TObject);
    procedure btn9Click(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
    procedure btnBackspaceClick(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
    procedure btnDivClick(Sender: TObject);
    procedure btnEqualClick(Sender: TObject);
    procedure btnInvClick(Sender: TObject);
    procedure btnMulClick(Sender: TObject);
    procedure btnPointClick(Sender: TObject);
    procedure btnSqrtClick(Sender: TObject);
    procedure btnSquareClick(Sender: TObject);
    procedure btnSubClick(Sender: TObject);
    procedure btnCeClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

//глобальные переменные
var
  a: real;      //первое число или результат
  op: char;     //операция: +,-,*,/
  fl: boolean;  //true=начать ввод нового числа
  err: boolean; //флаг ошибки

//прототипы (forward)
procedure doop; forward;
procedure dop(newop: char); forward;

//обновляем экран
procedure Upd;
begin
  if err then
    Form1.Edit1.Text := 'ошибка'
  else
    Form1.Edit1.Text := FloatToStr(a);
end;

//очистка всего
procedure TForm1.btnClearClick(Sender: TObject);
begin
  a := 0;
  op := #0;
  fl := True;
  err := False;
  Edit1.Text := '0';
end;

//добавление цифры или запятой
procedure addch(s: string);
begin
  if err then
  begin
    Form1.btnClearClick(nil);
    Exit;
  end;
  if fl then
  begin
    Form1.Edit1.Text := '';
    fl := False;
  end;
  Form1.Edit1.Text := Form1.Edit1.Text + s;
end;

//преобразование текста из Edit1 в число
function getn(var x: double): boolean;
begin
  Result := TryStrToFloat(Form1.Edit1.Text, x);
end;

//выполнение сохраненной операции
procedure doop;
var
  b: double;
begin
  if (not err) and (op <> #0) then
  begin
    if getn(b) then
    begin
      case op of
        '+': a := a + b;
        '-': a := a - b;
        '*': a := a * b;
        '/':
          if b = 0 then
            err := True
          else
            a := a / b;
      end;
      if err then
        Upd
      else
      begin
        op := #0;
        fl := True;
        Form1.Edit1.Text := FloatToStr(a);
      end;
    end
    else
    begin
      err := True;
      Upd;
    end;
  end;
end;

//сохранение оператора
procedure dop(newop: char);
begin
  if err then
  begin
    Form1.btnClearClick(nil);
    Exit;
  end;
  if (op <> #0) and (not fl) then
    doop;
  if getn(a) then
  begin
    op := newop;
    fl := True;
  end
  else
  begin
    err := True;
    Upd;
  end;
end;

//цифры
procedure TForm1.btn0Click(Sender: TObject); begin addch('0'); end;
procedure TForm1.btn1Click(Sender: TObject); begin addch('1'); end;
procedure TForm1.btn2Click(Sender: TObject); begin addch('2'); end;
procedure TForm1.btn3Click(Sender: TObject); begin addch('3'); end;
procedure TForm1.btn4Click(Sender: TObject); begin addch('4'); end;
procedure TForm1.btn5Click(Sender: TObject); begin addch('5'); end;
procedure TForm1.btn6Click(Sender: TObject); begin addch('6'); end;
procedure TForm1.btn7Click(Sender: TObject); begin addch('7'); end;
procedure TForm1.btn8Click(Sender: TObject); begin addch('8'); end;
procedure TForm1.btn9Click(Sender: TObject); begin addch('9'); end;

//операции
procedure TForm1.btnAddClick(Sender: TObject); begin dop('+'); end;
procedure TForm1.btnSubClick(Sender: TObject); begin dop('-'); end;
procedure TForm1.btnMulClick(Sender: TObject); begin dop('*'); end;
procedure TForm1.btnDivClick(Sender: TObject); begin dop('/'); end;

//ce
procedure TForm1.btnCeClick(Sender: TObject);
begin
  if err then
    err := False;
  Edit1.Text := '0';
  fl := True;
end;

//равно
procedure TForm1.btnEqualClick(Sender: TObject);
begin
  if err then
  begin
    btnClearClick(nil);
    Exit;
  end;
  if op <> #0 then
    doop
  else
  begin
    if getn(a) then
    begin
      fl := True;
      Upd;
    end
    else
    begin
      err := True;
      Upd;
    end;
  end;
end;

//1/x
procedure TForm1.btnInvClick(Sender: TObject);
var
  x: double;
begin
  if err then
  begin
    btnClearClick(nil);
    Exit;
  end;
  if getn(x) then
  begin
    if x = 0 then
    begin
      err := True;
      Edit1.Text := 'ошибка';
    end
    else
    begin
      x := 1 / x;
      a := x;
      Edit1.Text := FloatToStr(x);
      fl := True;
      op := #0;
      err := False;
    end;
  end
  else
  begin
    err := True;
    Edit1.Text := 'ошибка';
  end;
end;

//корень
procedure TForm1.btnSqrtClick(Sender: TObject);
var
  x: double;
begin
  if err then
  begin
    btnClearClick(nil);
    Exit;
  end;
  if getn(x) then
  begin
    if x < 0 then
    begin
      err := True;
      Edit1.Text := 'ошибка';
    end
    else
    begin
      x := Sqrt(x);
      a := x;
      Edit1.Text := FloatToStr(x);
      fl := True;
      op := #0;
      err := False;
    end;
  end
  else
  begin
    err := True;
    Edit1.Text := 'ошибка';
  end;
end;

//квадрат
procedure TForm1.btnSquareClick(Sender: TObject);
var
  x: double;
begin
  if err then
  begin
    btnClearClick(nil);
    Exit;
  end;
  if getn(x) then
  begin
    x := x * x;
    a := x;
    Edit1.Text := FloatToStr(x);
    fl := True;
    op := #0;
    err := False;
  end
  else
  begin
    err := True;
    Edit1.Text := 'ошибка';
  end;
end;

//запятая
procedure TForm1.btnPointClick(Sender: TObject);
begin
  if err then
  begin
    btnClearClick(nil);
    Exit;
  end;
  if fl then
  begin
    Edit1.Text := '0';
    fl := False;
  end;
  if Pos(',', Edit1.Text) = 0 then
    Edit1.Text := Edit1.Text + ',';
end;

//backspace
procedure TForm1.btnBackspaceClick(Sender: TObject);
var
  s: string;
begin
  if err then
  begin
    btnClearClick(nil);
    Exit;
  end;
  if not fl then
  begin
    s := Edit1.Text;
    if Length(s) > 0 then
      Delete(s, Length(s), 1);
    if (s = '') or (s = ',') then
      s := '0';
    Edit1.Text := s;
  end;
end;

//создание формы
procedure TForm1.FormCreate(Sender: TObject);
begin
  Edit1.ReadOnly := True;
  Edit1.Text := '0';
  fl := True;
  op := #0;
  err := False;
  a := 0;
end;

end.

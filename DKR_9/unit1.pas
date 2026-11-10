unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Grids, ExtCtrls,
  Menus;

type
  TBook = record
    InvNumber: string[20];
    Author: string[30];
    Title: string[50];
    Year: integer;
    Pages: integer;
    InStock: boolean;
  end;

  { TMainForm }

  TMainForm = class(TForm)
    // главное меню
    MainMenu1: TMainMenu;
    MenuFile: TMenuItem;
    MenuItem1: TMenuItem;  // создать
    MenuItem10: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem12: TMenuItem;
    MenuItem15: TMenuItem;
    MenuItem16: TMenuItem;
    MenuItem13: TMenuItem;
    MenuItem14: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;  // редактировать
    MenuItem9: TMenuItem;
    MenuNew: TMenuItem;
    MenuOpen: TMenuItem;
    MenuSave: TMenuItem;
    MenuSaveAs: TMenuItem;
    MenuClose: TMenuItem;
    MenuExit: TMenuItem;
    MenuRecord: TMenuItem;
    MenuAdd: TMenuItem;
    MenuEdit: TMenuItem;
    MenuDelete: TMenuItem;
    MenuSort: TMenuItem;
    MenuSortAsc: TMenuItem;
    MenuSortDesc: TMenuItem;
    MenuSearch: TMenuItem;
    MenuClear: TMenuItem;

    // компоненты формы
    Panel1: TPanel;
    Label1: TLabel;     EditInv: TEdit;
    Label2: TLabel;     EditAuthor: TEdit;
    Label3: TLabel;     EditTitle: TEdit;
    Label4: TLabel;     EditYear: TEdit;
    Label5: TLabel;     EditPages: TEdit;
    CheckInStock: TCheckBox;

    // кнопки
    ButtonAdd: TButton;
    ButtonEdit: TButton;
    ButtonDelete: TButton;
    ButtonSortAsc: TButton;
    ButtonSortDesc: TButton;
    ButtonSearch: TButton;
    ButtonClear: TButton;

    StringGrid1: TStringGrid;

    // события формы и компонентов
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure StringGrid1SelectCell(Sender: TObject; aCol, aRow: Integer; var CanSelect: Boolean);

    // обработчики меню (menuitem1-menuitem16)
    procedure MenuItem2Click(Sender: TObject);  // создать
    procedure MenuItem3Click(Sender: TObject);  // открыть
    procedure MenuItem4Click(Sender: TObject);  // сохранить
    procedure MenuItem5Click(Sender: TObject);  // сохранить как
    procedure MenuItem6Click(Sender: TObject);  // закрыть
    procedure MenuItem7Click(Sender: TObject);  // выход
    procedure MenuItem9Click(Sender: TObject);  // добавить
    procedure MenuItem10Click(Sender: TObject);  // редактировать
    procedure MenuItem11Click(Sender: TObject);  // удалить


    // обработчики кнопок
    procedure ButtonAddClick(Sender: TObject);

  private
    FFileName: string;
    FModified: boolean;

    // вспомогательные методы
    procedure ClearFields;
    procedure LoadFieldsFromRow(ARow: integer);
    function Validate: boolean;
    function GetBook: TBook;
    procedure UpdateGrid;
    procedure SortGrid(Ascending: boolean);
    procedure CheckFileOpened;
    procedure UpdateMenuState;
    procedure LoadFromFile;
    procedure SaveToFile(const AFileName: string);
    procedure ShowMsg(const Msg: string);
  end;

var
  MainForm: TMainForm;

implementation

{$R *.lfm}

// вспомогательные методы

procedure TMainForm.ShowMsg(const Msg: string);
begin
  MessageDlg(Msg, mtInformation, [mbOK], 0);
end;

procedure TMainForm.ClearFields;
begin
  EditInv.Text := '';
  EditAuthor.Text := '';
  EditTitle.Text := '';
  EditYear.Text := '';
  EditPages.Text := '';
  CheckInStock.Checked := False;
end;

procedure TMainForm.LoadFieldsFromRow(ARow: integer);
begin
  if (ARow < 1) or (ARow >= StringGrid1.RowCount) then Exit;
  EditInv.Text := StringGrid1.Cells[0, ARow];
  EditAuthor.Text := StringGrid1.Cells[1, ARow];
  EditTitle.Text := StringGrid1.Cells[2, ARow];
  EditYear.Text := StringGrid1.Cells[3, ARow];
  EditPages.Text := StringGrid1.Cells[4, ARow];
  CheckInStock.Checked := (StringGrid1.Cells[5, ARow] = 'Да');
end;

function TMainForm.Validate: boolean;
var y, p: integer;
begin
  Result := False;
  if EditInv.Text = '' then begin ShowMsg('Введите инв. номер'); EditInv.SetFocus; Exit; end;
  if EditAuthor.Text = '' then begin ShowMsg('Введите автора'); EditAuthor.SetFocus; Exit; end;
  if EditTitle.Text = '' then begin ShowMsg('Введите название'); EditTitle.SetFocus; Exit; end;
  if not TryStrToInt(EditYear.Text, y) then begin ShowMsg('Год должен быть числом'); EditYear.SetFocus; Exit; end;
  if (y < 0) or (y > 2026) then begin ShowMsg('Некорректный год (0-2026)'); EditYear.SetFocus; Exit; end;
  if not TryStrToInt(EditPages.Text, p) then begin ShowMsg('Страниц должно быть числом'); EditPages.SetFocus; Exit; end;
  Result := True;
end;

function TMainForm.GetBook: TBook;
begin
  Result.InvNumber := EditInv.Text;
  Result.Author := EditAuthor.Text;
  Result.Title := EditTitle.Text;
  Result.Year := StrToInt(EditYear.Text);
  Result.Pages := StrToInt(EditPages.Text);
  Result.InStock := CheckInStock.Checked;
end;

procedure TMainForm.UpdateGrid;
begin
  LoadFromFile;
  ClearFields;
end;

procedure TMainForm.CheckFileOpened;
begin
  if FFileName = '' then
  begin
    ShowMsg('Файл не открыт. Создайте новый или откройте существующий.');
    Abort;
  end;
end;

procedure TMainForm.UpdateMenuState;
begin
  MenuItem3.Enabled := (FFileName <> '') and FModified;  // сохранить
  MenuItem5.Enabled := FFileName <> '';                   // закрыть
  MenuItem7.Enabled := FFileName <> '';                   // добавить
  MenuItem8.Enabled := (FFileName <> '') and (StringGrid1.RowCount > 2);  // редактировать
  MenuItem9.Enabled := (FFileName <> '') and (StringGrid1.RowCount > 2);  // удалить
  MenuItem10.Enabled := (FFileName <> '') and (StringGrid1.RowCount > 2); // сортировка возр.
  MenuItem11.Enabled := (FFileName <> '') and (StringGrid1.RowCount > 2); // сортировка убыв.
  MenuItem12.Enabled := (FFileName <> '') and (StringGrid1.RowCount > 2); // поиск
end;

// загрузка и сохранение

procedure TMainForm.LoadFromFile;
var
  f: file of TBook;
  book: TBook;
  row: integer;
begin
  if not FileExists(FFileName) then Exit;

  try
    AssignFile(f, FFileName);
    Reset(f);

    StringGrid1.RowCount := 2;
    row := 1;
    while not EOF(f) do
    begin
      Read(f, book);
      if row >= StringGrid1.RowCount then
        StringGrid1.RowCount := StringGrid1.RowCount + 1;
      StringGrid1.Cells[0, row] := book.InvNumber;
      StringGrid1.Cells[1, row] := book.Author;
      StringGrid1.Cells[2, row] := book.Title;
      StringGrid1.Cells[3, row] := IntToStr(book.Year);
      StringGrid1.Cells[4, row] := IntToStr(book.Pages);
      if book.InStock then
        StringGrid1.Cells[5, row] := 'Да'
      else
        StringGrid1.Cells[5, row] := 'Нет';
      Inc(row);
    end;
    CloseFile(f);
  except
    on E: Exception do ShowMsg('Ошибка загрузки: ' + E.Message);
  end;
end;

procedure TMainForm.SaveToFile(const AFileName: string);
var
  f: file of TBook;
  book: TBook;
  i: integer;
begin
  try
    AssignFile(f, AFileName);
    Rewrite(f);
    for i := 1 to StringGrid1.RowCount - 1 do
    begin
      if Trim(StringGrid1.Cells[0, i]) = '' then Continue;
      book.InvNumber := StringGrid1.Cells[0, i];
      book.Author := StringGrid1.Cells[1, i];
      book.Title := StringGrid1.Cells[2, i];
      book.Year := StrToIntDef(StringGrid1.Cells[3, i], 0);
      book.Pages := StrToIntDef(StringGrid1.Cells[4, i], 0);
      book.InStock := (StringGrid1.Cells[5, i] = 'Да');
      Write(f, book);
    end;
    CloseFile(f);
  except
    on E: Exception do ShowMsg('Ошибка сохранения: ' + E.Message);
  end;
end;

// сортировка

procedure TMainForm.SortGrid(Ascending: boolean);
var
  f: file of TBook;
  books: array of TBook;
  i, j, cnt: integer;
  temp: TBook;
  FieldIdx: integer;
  FieldName: string;
begin
  CheckFileOpened;

  if not InputQuery('Сортировка', 'Введите номер поля:' + sLineBreak +
    '1-Инв.номер, 2-Автор, 3-Название, 4-Год, 5-Страниц, 6-Наличие', FieldName) then Exit;

  FieldIdx := StrToIntDef(FieldName, 0);
  if (FieldIdx < 1) or (FieldIdx > 6) then
  begin
    ShowMsg('Неверный номер поля');
    Exit;
  end;

  try
    AssignFile(f, FFileName);
    Reset(f);
    cnt := FileSize(f);
    SetLength(books, cnt);
    for i := 0 to cnt-1 do Read(f, books[i]);
    CloseFile(f);

    for i := 0 to cnt-2 do
      for j := i+1 to cnt-1 do
      begin
        case FieldIdx of
          1: if (books[i].InvNumber > books[j].InvNumber) = Ascending then begin temp:=books[i]; books[i]:=books[j]; books[j]:=temp; end;
          2: if (books[i].Author > books[j].Author) = Ascending then begin temp:=books[i]; books[i]:=books[j]; books[j]:=temp; end;
          3: if (books[i].Title > books[j].Title) = Ascending then begin temp:=books[i]; books[i]:=books[j]; books[j]:=temp; end;
          4: if (books[i].Year > books[j].Year) = Ascending then begin temp:=books[i]; books[i]:=books[j]; books[j]:=temp; end;
          5: if (books[i].Pages > books[j].Pages) = Ascending then begin temp:=books[i]; books[i]:=books[j]; books[j]:=temp; end;
          6: if (books[i].InStock > books[j].InStock) = Ascending then begin temp:=books[i]; books[i]:=books[j]; books[j]:=temp; end;
        end;
      end;

    AssignFile(f, FFileName);
    Rewrite(f);
    for i := 0 to cnt-1 do Write(f, books[i]);
    CloseFile(f);
    UpdateGrid;
    if Ascending then ShowMsg('Отсортировано по возрастанию') else ShowMsg('Отсортировано по убыванию');
  except
    on E: Exception do ShowMsg('Ошибка сортировки: ' + E.Message);
  end;
end;

// обработчики меню

// создать новый файл
procedure TMainForm.MenuItem2Click(Sender: TObject);
var f: file of TBook;
begin
  if FModified and (MessageDlg('Сохранить изменения?', mtConfirmation, [mbYes, mbNo], 0) = mrYes) then
    SaveToFile(FFileName);

  FFileName := 'books.dat';
  if FileExists(FFileName) then
    DeleteFile(FFileName);

  AssignFile(f, FFileName);
  Rewrite(f);
  CloseFile(f);

  LoadFromFile;
  FModified := False;
  UpdateMenuState;
  ShowMsg('Создан новый файл');
end;

// открыть файл
procedure TMainForm.MenuItem3Click(Sender: TObject);
var dlg: TOpenDialog;
begin
  dlg := TOpenDialog.Create(Self);
  dlg.Filter := 'DAT files (*.dat)|*.dat|All files (*.*)|*.*';
  if dlg.Execute then
  begin
    FFileName := dlg.FileName;
    LoadFromFile;
    FModified := False;
    ClearFields;
    UpdateMenuState;
    ShowMsg('Файл открыт: ' + FFileName);
  end;
  dlg.Free;
end;

// сохранить
procedure TMainForm.MenuItem4Click(Sender: TObject);
begin
  CheckFileOpened;
  SaveToFile(FFileName);
  FModified := False;
  UpdateMenuState;
  ShowMsg('Сохранено');
end;

// сохранить как
procedure TMainForm.MenuItem5Click(Sender: TObject);
var dlg: TSaveDialog;
begin
  dlg := TSaveDialog.Create(Self);
  dlg.Filter := 'DAT files (*.dat)|*.dat';
  if dlg.Execute then
  begin
    FFileName := dlg.FileName;
    SaveToFile(FFileName);
    FModified := False;
    UpdateMenuState;
    ShowMsg('Сохранено как ' + FFileName);
  end;
  dlg.Free;
end;

// закрыть файл
procedure TMainForm.MenuItem6Click(Sender: TObject);
begin
  if FModified and (MessageDlg('Сохранить изменения?', mtConfirmation, [mbYes, mbNo], 0) = mrYes) then
    SaveToFile(FFileName);

  FFileName := '';
  StringGrid1.RowCount := 2;
  ClearFields;
  FModified := False;
  UpdateMenuState;
  ShowMsg('Файл закрыт');
end;

// выход из программы
procedure TMainForm.MenuItem7Click(Sender: TObject);
begin
  if FModified and (MessageDlg('Сохранить изменения?', mtConfirmation, [mbYes, mbNo], 0) = mrYes) then
    SaveToFile(FFileName);
  Close;
end;

// добавить запись
procedure TMainForm.MenuItem9Click(Sender: TObject);
var f: file of TBook;
begin
  CheckFileOpened;
  if not Validate then Exit;

  AssignFile(f, FFileName);
  Reset(f);
  Seek(f, FileSize(f));
  Write(f, GetBook);
  CloseFile(f);

  UpdateGrid;
  FModified := True;
  UpdateMenuState;
  ShowMsg('Запись добавлена');
end;

// редактировать запись
procedure TMainForm.MenuItem10Click(Sender: TObject);
var f: file of TBook; row: integer;
begin
  CheckFileOpened;
  row := StringGrid1.Row;
  if row < 1 then begin ShowMsg('Выберите запись'); Exit; end;
  if not Validate then Exit;

  AssignFile(f, FFileName);
  Reset(f);
  Seek(f, row - 1);
  Write(f, GetBook);
  CloseFile(f);

  UpdateGrid;
  FModified := True;
  UpdateMenuState;
  ShowMsg('Запись отредактирована');
end;

// удалить запись
procedure TMainForm.MenuItem11Click(Sender: TObject);
var f, ftmp: file of TBook; book: TBook; row, i: integer;
begin
  CheckFileOpened;
  row := StringGrid1.Row;
  if row < 1 then begin ShowMsg('Выберите запись'); Exit; end;
  if MessageDlg('Удалить запись?', mtConfirmation, [mbYes, mbNo], 0) <> mrYes then Exit;

  AssignFile(f, FFileName);
  Reset(f);
  AssignFile(ftmp, 'temp.dat');
  Rewrite(ftmp);

  i := 0;
  while not EOF(f) do
  begin
    Read(f, book);
    if i <> row-1 then Write(ftmp, book);
    Inc(i);
  end;

  CloseFile(f);
  CloseFile(ftmp);
  Erase(f);
  Rename(ftmp, FFileName);

  UpdateGrid;
  FModified := True;
  UpdateMenuState;
  ShowMsg('Запись удалена');
end;





// обработчики кнопок

procedure TMainForm.ButtonAddClick(Sender: TObject);
begin
  MenuItem7Click(Sender);
end;


// события формы

procedure TMainForm.StringGrid1SelectCell(Sender: TObject; aCol, aRow: Integer; var CanSelect: Boolean);
begin
  LoadFieldsFromRow(aRow);
end;

procedure TMainForm.FormCreate(Sender: TObject);
var f: file of TBook;
begin
  FFileName := 'books.dat';
  FModified := False;

  if not FileExists(FFileName) then
  begin
    AssignFile(f, FFileName);
    Rewrite(f);
    CloseFile(f);
  end;

  // настройка stringgrid
  StringGrid1.FixedCols := 0;
  StringGrid1.FixedRows := 1;
  StringGrid1.RowCount := 2;
  StringGrid1.Options := StringGrid1.Options + [goRowSelect];
  StringGrid1.Cells[0,0] := 'Инв. номер';
  StringGrid1.Cells[1,0] := 'Автор';
  StringGrid1.Cells[2,0] := 'Название';
  StringGrid1.Cells[3,0] := 'Год';
  StringGrid1.Cells[4,0] := 'Страниц';
  StringGrid1.Cells[5,0] := 'В наличии';

  LoadFromFile;
  ClearFields;
  UpdateMenuState;
end;

procedure TMainForm.FormResize(Sender: TObject);
begin
  // автоматическое растягивание колонок таблицы
  StringGrid1.AutoFillColumns := True;
end;

end.

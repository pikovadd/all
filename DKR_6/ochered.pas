const
  size = 5; // максимальный размер очереди

type
  // структура для описания очереди
  queue = record
    data: array[1..size] of integer;  // массив для хранения элементов
    head: integer;                    // индекс начала очереди (откуда берём)
    tail: integer;                    // индекс конца очереди (куда кладём)
    count: integer;                   // текущее количество элементов
  end;

var
  q: queue;        // переменная для работы с очередью 
  choice: integer; // номер выбранного пункта меню
  value: integer;  // значение для ввода/вывода 
  i: integer;      

// инициализация очереди
procedure init_queue(var q: queue);
begin
  q.head := 1;      // начало очереди - первый элемент массива
  q.tail := 1;      // конец очереди тоже в начале (очередь пуста)
  q.count := 0;     // количество элементов равно 0
end;

// проверка, пуста ли очередь 
function is_empty(q: queue): boolean;
begin
  is_empty := (q.count = 0); // пуста, если count = 0
end;

// проверка, полна ли очередь
function is_full(q: queue): boolean;
begin
  is_full := (q.count = size); // полна, если count = size
end;

// добавление элемента в конец очереди 
procedure enqueue(var q: queue; x: integer);
begin
  if is_full(q) then
    writeln('ошибка: очередь переполнена!')
  else
  begin
    q.data[q.tail] := x;      // кладём элемент в конец 
    q.tail := q.tail + 1;     // сдвигаем указатель конца 
    if q.tail > size then      
      q.tail := 1;            // если дошли до конца массива, переходим в начало
    q.count := q.count + 1;   // увеличиваем счётчик
    writeln('элемент ', x, ' добавлен в очередь.');
  end;
end;

// удаление элемента из начала очереди 
procedure dequeue(var q: queue; var x: integer);
begin
  if is_empty(q) then
    writeln('Ошибка: очередь пуста')
  else
  begin
    x := q.data[q.head];       // берём элемент из начала 
    q.head := q.head + 1;      // сдвигаем указатель начала 
    if q.head > size then      // если дошли до конца массива 
      q.head := 1;             // переходим в начало
    q.count := q.count - 1;    // уменьшаем счётчик 
    writeln('элемент ', x, ' удален из очереди.');
  end;
end;

// просмотр первого элемента без удаления 
procedure peek(q: queue; var x: integer);
begin
  if is_empty(q) then
    writeln('ошибка: очередь пуста')
  else
  begin
    x := q.data[q.head];       // смотрим первый элемент 
    writeln('первый элемент очереди: ', x);
  end;
end;

// визуализация содержимого очереди 
procedure show_queue(q: queue);
var
  i, pos: integer;
begin
  writeln;
  writeln('--- содержимое очереди ---');
  if is_empty(q) then
    writeln('очередь пуста')
  else
  begin
    write('элементы: ');
    // проходим по всем элементам очереди от head до tail-1
    for i := 1 to q.count do
    begin
      // вычисляем реальную позицию в массиве с учётом кольцевости 
      pos := q.head + i - 1;
      if pos > size then
        pos := pos - size;
      write(q.data[pos], ' ');
    end;
    writeln;
    
    // показываем позиции указателей 
    writeln('указывает на начальную позицию: ', q.head);
    writeln('указывает на конечную позицию: ', q.tail);
    writeln('количество элементов: ', q.count);
    
    // показываем весь массив для наглядности
    write('массив целиком: [');
    for i := 1 to size do
    begin
      write(q.data[i]);
      if i < size then write(', ');
    end;
    writeln(']');
  end;
  writeln;
end;

// основная программа
begin
  init_queue(q); // начинаем с пустой очереди
  
  repeat
    // выводим меню 
    writeln('МЕНЮ РАБОТЫ С ОЧЕРЕДЬЮ');
    writeln('1. добавить элемент');
    writeln('2. удалить элемент');
    writeln('3. посмотреть первый элемент');
    writeln('4. показать всю очередь');
    writeln('5. выход');
    write('выберите действие (1-5): ');
    readln(choice);
    
    // обрабатываем выбор пользователя 
    case choice of
      1: begin
           write('введите число для добавления: ');
           readln(value);
           enqueue(q, value);
         end;
      2: begin
           dequeue(q, value);
         end;
      3: begin
           peek(q, value);
         end;
      4: begin
           show_queue(q);
         end;
      5: begin
           writeln('программа завершена');
         end;
      else
        writeln('ошибка: выберите пункт от 1 до 5.');
    end;
    
  until choice = 5; // повторяем, пока не выбран выход
  
end.
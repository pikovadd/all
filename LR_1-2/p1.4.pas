program fgkjm;
var x1,x2,y1,y2,d: real;
begin
  write ('введите координату точки A ');
  read(x1);
  write ('введите координату точки A ');
  read(y1);
  write ('введите координату точки B ');
  read(x2);
  write ('введите координату точки B ');
  read(y2);
   d:= sqrt ( sqr ( x2 - x1 ) + sqr ( y2 - y1 ) );
  writeln ('расстояние между точками = ', round (d,3));
end.
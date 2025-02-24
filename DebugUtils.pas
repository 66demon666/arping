unit DebugUtils;

interface

uses System.SysUtils;
procedure PrintArray(arr: array of Byte);

implementation

procedure PrintArray(arr: array of Byte);
begin
  for var i := Low(arr) to High(arr) do
  begin
    write(IntToHex(arr[i], 2) + ' ');
    if (i mod 10 = 0) then
      writeln('');

  end;
end;

end.

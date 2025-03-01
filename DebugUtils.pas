unit DebugUtils;

interface

uses System.SysUtils, PcapTypes;
procedure PrintArray(arr: array of Byte); overload;
procedure PrintArray(arr: TPackedBytes); overload;

implementation

procedure PrintArray(arr: array of Byte); overload;
begin
  for var i := Low(arr) to High(arr) do
  begin
    write(IntToHex(arr[i], 2) + ' ');
    if (i mod 10 = 0) then
      writeln('');

  end;
end;

procedure PrintArray(arr: TPackedBytes); overload;
begin
  for var i := Low(arr) to High(arr) do
  begin
    write(IntToHex(arr[i], 2) + ' ');
    if (i mod 10 = 0) then
      writeln('');

  end;
end;

end.

unit Utils;

interface
uses
packet,
System.SysUtils;

function IPToString(ip:TPcapIP):string;

implementation
function IPToString(ip:TPcapIP):string;
begin
  Result:=Format('%d.%d.%d.%d', [ip[0], ip[1], ip[2],ip[3]]);
end;

end.

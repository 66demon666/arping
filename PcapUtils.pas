unit PcapUtils;

interface

uses
  packet,
  System.SysUtils;

function IPToString(ip: TPcapIP): string;
function MACToString(mac: TPcapMAC): string;
function IntToIP(ip: Integer): string;

implementation

function IPToString(ip: TPcapIP): string;
begin
  Result := Format('%d.%d.%d.%d', [ip[0], ip[1], ip[2], ip[3]]);
end;

function MACToString(mac: TPcapMAC): string;
begin
  Result := Format('%s:%s:%s:%s:%s:%s', [IntToHex(mac[0], 2),
    IntToHex(mac[1], 2), IntToHex(mac[2], 2), IntToHex(mac[3], 2),
    IntToHex(mac[4], 2), IntToHex(mac[5], 2)]);
end;

function StringToIP(ipstring: string):TPcapIP;
begin

end;

function IntToIP(ip: Integer): string;
begin
  Result := Format('%d.%d.%d.%d', [(ip shr 24) and $FF, (ip shr 16) and $FF,
    (ip shr 8) and $FF, ip and $FF]);
end;

end.

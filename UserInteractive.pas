unit UserInteractive;

interface

uses
  TPcapClass, SysUtils, PcapUtils, PcapTypes, WinSock;

type

  TUserInteractive = class
  private
    pcap: PPcap;
  public
    FSelectedInterface: PPcap_if;
    function GetInterface(msg: string = 'Choose interface:'): PPcap_if;
    constructor Create(pcap: PPcap);
  end;

implementation

constructor TUserInteractive.Create(pcap: PPcap);
begin
  self.pcap := pcap;
end;

function TUserInteractive.GetInterface(msg: string = 'Choose interface:')
  : PPcap_if;
var
  i: integer;
  selectedIndex: integer;
  ipTemp: string;
begin
  if pcap.interfaces.Count > 1 then
  begin
    i := 0;
    writeln(msg);
    for var interfaceItem in pcap.interfaces do
    begin
      if Assigned(interfaceItem.addresses) then
        ipTemp := IntToIp(ntohl(interfaceItem.addresses.addr.sin_addr.S_addr))
      else
        ipTemp := 'No address';
      writeln(Format('%d: %s (%s)', [i, interfaceItem^.description, ipTemp]));
      Inc(i);
    end;
    repeat
      readln(selectedIndex);
    until (selectedIndex >= 0) and (selectedIndex <= pcap.interfaces.Count);
    Result := pcap.interfaces[selectedIndex];
  end
  else
  begin
    Result := pcap.interfaces[0];
  end;

end;

end.

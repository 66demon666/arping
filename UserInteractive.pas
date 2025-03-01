unit UserInteractive;

interface

uses
  TPcapClass, SysUtils, PcapUtils, PcapTypes;

type

  TUserInteractive = class
  private
    pcap: PPcap;
  public
    FSelectedInterface: TPcap_if;
    function GetInterface(msg: string = 'Choose interface:'): TPcap_if;
    constructor Create(pcap: PPcap);
  end;

implementation

constructor TUserInteractive.Create(pcap: PPcap);
begin
  self.pcap := pcap;
end;

function TUserInteractive.GetInterface(msg: string = 'Choose interface:')
  : TPcap_if;
var
  i: integer;
  selectedIndex: integer;
begin
  if pcap^.FInterfaces.Count > 1 then
  begin
    i := 0;
    writeln(msg);
    for var interfaceItem in pcap^.FInterfaces do
    begin
      writeln(Format('%d: %s (%s)', [IntToStr(i), interfaceItem.description,
        IntToIp(interfaceItem.addresses.addr.sin_addr.S_addr)]));
      Inc(i);
    end;
    repeat
      readln(selectedIndex);
    until (selectedIndex >= 0) and (selectedIndex <= pcap^.FInterfaces.Count);
    Result := pcap^.FInterfaces[selectedIndex];
  end
  else
  begin
    Result := pcap^.FInterfaces[0];
  end;

end;

end.

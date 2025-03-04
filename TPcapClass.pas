unit TPcapClass;

interface

uses
  PcapTypes, System.Generics.Collections, System.Classes, SysUtils,
  PcapExceptions;

type
  TPcapInterfaces = array of TPcap_if;

  PPcap = ^TPcap;

  TPcap = class
  protected
    FErrbuf: TPcapErrbuf;
    FAllDevices: PPcap_if;
    FPcapHandle: PPcap_t;
    FSelectedInterface: PPcap_if;
    FInterfaces: TList<PPcap_if>;
    procedure FindAllDevices();
  public
    procedure OpenInterface(interfaceToOpen: PPcap_if; caplen: integer = 65536;
      capmode: integer = PCAP_OPENFLAG_PROMISCUOUS; timeout: integer = 1000);
    function SendPacket(packet:PPackedBytes):boolean;
    property errorBuffer:TPcapErrbuf read FErrbuf;
    property selectedInterface:PPcap_if read FSelectedInterface write FSelectedInterface;
    property interfaces:TList<PPcap_if> read FInterfaces;
    property handle:PPcap_t read FPcapHandle;
    constructor Create();

  end;

implementation

function TPcap.SendPacket(packet: PPackedBytes): Boolean;
var
packetBytes:TPackedBytes;
error:PAnsiChar;
begin
packetBytes:=packet^;
writeln('Packet size: ' + IntToStr(Length(packetBytes)));
Result:=(pcap_sendpacket(self.handle, PByte(packetBytes), Length(packetBytes)) = 0);
error:=pcap_geterr(handle);
Move(error^, self.FErrbuf[0], StrLen(error));
writeln('Errbuf: ' + self.errorBuffer);
end;

procedure TPcap.OpenInterface(interfaceToOpen: PPcap_if;
  caplen: integer = 65536; capmode: integer = PCAP_OPENFLAG_PROMISCUOUS;
  timeout: integer = 1000);
var
  adhandle: PPcap_t;
begin
  adhandle := pcap_open(interfaceToOpen^.name, caplen, capmode, timeout, nil,
    self.FErrbuf);
  if adhandle = nil then
    raise EOpenInterfaceException.Create(self.FErrbuf)
  else
    self.FPcapHandle := adhandle;
end;

constructor TPcap.Create;
begin
  self.FInterfaces:=TList<PPcap_if>.Create;
  FindAllDevices();
end;

procedure TPcap.FindAllDevices;
var
  interfaceList: TList<PPcap_if>;
begin
  if pcap_findalldevs_ex(PCAP_SRC_IF_STRING, nil, @self.FAllDevices, @self.errorBuffer) = -1 then
begin
  raise EFindAllDevicesException.Create(FErrbuf);
  writeln('FindAllDevices error');
end
else
begin
while Assigned(@self.FAllDevices.next) do
  begin
    self.FInterfaces.Add(FAllDevices);
    FAllDevices:=FAllDevices.next;
  end;
end;
end;

end.

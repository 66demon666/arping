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
    FAllDevices: TPcap_if;
    FPcapHandle: PPcap_t;
  public
    FSelectedInterface: TPcap_if;
    function FindAllDevices(): TList<TPcap_if>;
    procedure OpenInterface(interfaceToOpen: PPcap_if; caplen: integer = 65536;
      capmode: integer = PCAP_OPENFLAG_PROMISCUOUS; timeout: integer = 1000);

  public

    FInterfaces: TList<TPcap_if>;
    constructor Create(); virtual;

  end;

implementation

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
  FInterfaces := FindAllDevices();
  if FInterfaces = nil then
    raise EFindAllDevicesException.Create(FErrbuf);

end;

function TPcap.FindAllDevices: TList<TPcap_if>;
var
  interfaceList: TList<TPcap_if>;
begin
  if pcap_findalldevs_ex(PCAP_SRC_IF_STRING, nil, @FAllDevices, @FErrbuf) = -1
  then
    Result := nil
  else
  begin
    while Assigned(FAllDevices.next) do
    begin
      interfaceList := TList<TPcap_if>.Create;
      interfaceList.Add(FAllDevices);
      FAllDevices := FAllDevices.next^;
    end;
    Result := interfaceList;
  end;
end;

end.

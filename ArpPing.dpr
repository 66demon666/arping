program ArpPing;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils,
  WinSock2,
  pcap in 'pcap.pas',
  Windows,
  System.Classes,
  DebugUtils in 'DebugUtils.pas',
  packet in 'packet.pas';

const
  IF_ID = '\Device\NPF_{077C8EF5-CB84-4C34-9C2A-66006D41D835}';

var
  alldevs, d: TPcap_if;
  errbuf: TPcapErrbuf;
  i: Integer = 0;
  selected_interface: Integer;
  adhandle: PPcap_t;

procedure packet_handler(param: PByte; pkthdr: PPcap_pkthdr;
  packet_data: PByte);
var
  etherhdr: PEtherHeader;
  ethertype: word;

begin
  Writeln('Packet is capture');
  etherhdr := PEtherHeader(packet_data);
  ethertype := ntohs(etherhdr.ethertype);
  Writeln('EtherType: 0x' + IntToHex(ethertype, 4));
end;

begin
  try
    Writeln('Arping for Windows');
    Writeln('Fetching Interfaces list....');
    if (pcap_findalldevs_ex('', nil, @alldevs, @errbuf) = -1) then
    begin
      Writeln('Error fetching interfaces. Errbuf: ' + errbuf);
      readln;
      exit();
    end
    else
    begin
      d := alldevs;
      while Assigned(d.next) do
      begin
        Writeln(Format('%d. %s (%s)', [i, d.description, d.name]));
        d := d.next^;
        Inc(i);

      end;
      Writeln('Listing finished');
      Writeln('Trying open interface');
      adhandle := pcap_open(IF_ID, 655536, PCAP_OPENFLAG_PROMISCUOUS, 1000,
        nil, @errbuf);
      if (adhandle = nil) then
      begin
        Writeln('Adapter open promiscious mode error:' + errbuf);
        readln;
        exit;
      end
      else
      begin
        Writeln('Adapter opened on promiscious mode!');
        pcap_loop(adhandle, 0, packet_handler, nil);
        readln;
      end;
    end;

    readln;
  except
    on E: Exception do
    begin
      Writeln(E.ClassName, ': ', E.Message);
      readln;
    end;
  end;

end.

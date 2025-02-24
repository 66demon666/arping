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
  packet in 'packet.pas',
  Utils in 'Utils.pas';

const
  IF_ID = '\Device\NPF_{077C8EF5-CB84-4C34-9C2A-66006D41D835}';
  IF_ID_2='\Device\NPF_{9C22769D-724A-4B92-814A-605A36AAF2CC}';

var
  alldevs, d: TPcap_if;
  errbuf: TPcapErrbuf;
  i: Integer = 0;
  selected_interface: Integer;
  adhandle: PPcap_t;
  arp_ethernet: TetherHeader;
  packet_buffer: array of byte;
  fp: Tbpf_program;
  filter: AnsiString;
  arp_payload: TArpPacket;

procedure packet_handler(param: PByte; pkthdr: PPcap_pkthdr;
  packet_data: PByte);
var
  etherhdr: PEtherHeader;
  ethertype: word;
  arp_payload_income: PArpPacket;
  packet_array: array of byte;
  buf: pointer;
  test: smallint;
begin
  Writeln('Packet is capture');
  SetLength(packet_array, pkthdr.len);
  Move(packet_data^, packet_array[0], Length(packet_array));
  etherhdr := PEtherHeader(@packet_array[0]);
  Writeln('Ethertype: 0x' + IntToHex(ntohs(etherhdr.ethertype), 4));
  if ntohs(etherhdr.ethertype) = ETHERTYPE_ARP then
  begin
    Writeln('ARP');
    arp_payload_income := PArpPacket(@packet_array[SizeOf(TetherHeader)]);
    Writeln(IPToString(arp_payload_income.spa));
  end;

end;

begin
  try
    Writeln('Arping for Windows');
    Writeln('Fetching Interfaces list....');
    if (pcap_findalldevs_ex(PCAP_SRC_IF_STRING, nil, @alldevs, @errbuf) = -1) then
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
      adhandle := pcap_open(IF_ID_2, 655536, PCAP_OPENFLAG_PROMISCUOUS, 1000,
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
        with arp_ethernet do
        begin
          destination[0] := $FF;
          destination[1] := $FF;
          destination[2] := $FF;
          destination[3] := $FF;
          destination[4] := $FF;
          destination[5] := $FF;
          source[0] := $38;
          source[1] := $D5;
          source[2] := $47;
          source[3] := $19;
          source[4] := $DB;
          source[5] := $D6;
          ethertype := htons(ETHERTYPE_ARP);
        end;
        with arp_payload do
        begin
          htype := htons(1);
          ptype := htons(2048);
          hlen := 6;
          plen := 4;
          oper := htons(1);
          sha[0] := $38;
          sha[1] := $D5;
          sha[2] := $47;
          sha[3] := $19;
          sha[4] := $DB;
          sha[5] := $D6;
          spa[0] := $A;
          spa[1] := $1;
          spa[2] := $2;
          spa[3] := $D7;
          tha[0] := $FF;
          tha[1] := $FF;
          tha[2] := $FF;
          tha[3] := $FF;
          tha[4] := $FF;
          tha[5] := $FF;
          tpa[0] := $A;
          tpa[1] := $1;
          tpa[2] := $2;
          tpa[3] := $C8;
        end;
        SetLength(packet_buffer, SizeOf(arp_ethernet) + SizeOf(arp_payload));
        Move(arp_ethernet, packet_buffer[0], SizeOf(arp_ethernet));
        Move(arp_payload, packet_buffer[SizeOf(arp_ethernet)],
          SizeOf(arp_payload));

        filter := 'arp[6:2] = 2';
        Writeln('Filter compilation: ' + IntToStr(pcap_compile(adhandle, @fp,
          PAnsiChar(filter), 1, $FFFFFF00)));
        Writeln('Set filter: ' + IntToStr(pcap_setfilter(adhandle, @fp)));
        //pcap_loop(adhandle, 0, packet_handler, nil);
        //pcap_sendpacket(adhandle, @packet_buffer[0], Length(packet_buffer));
         while true do
         begin
         pcap_sendpacket(adhandle, @packet_buffer[0], Length(packet_buffer));
         sleep(1000);
       end;

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

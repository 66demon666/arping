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
    Writeln(IntToStr(arp_payload_income.plen));
  end;

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
        with arp_ethernet do
        begin
          destination[0] := $FF;
          destination[1] := $FF;
          destination[2] := $FF;
          destination[3] := $FF;
          destination[4] := $FF;
          destination[5] := $FF;
          source[0] := $50;
          source[1] := $E5;
          source[2] := $49;
          source[3] := $DE;
          source[4] := $68;
          source[5] := $89;
          ethertype := htons(ETHERTYPE_ARP);
        end;
        with arp_payload do
        begin
          htype := htons(1);
          ptype := htons(2048);
          hlen := 6;
          plen := 4;
          oper := htons(1);
          sha[0] := $50;
          sha[1] := $E5;
          sha[2] := $49;
          sha[3] := $DE;
          sha[4] := $68;
          sha[5] := $89;
          spa[0] := $C0;
          spa[1] := $A8;
          spa[2] := $1F;
          spa[3] := $A;
          tha[0] := $FF;
          tha[1] := $FF;
          tha[2] := $FF;
          tha[3] := $FF;
          tha[4] := $FF;
          tha[5] := $FF;
          tpa[0] := $C0;
          tpa[1] := $A8;
          tpa[2] := $1F;
          tpa[3] := $1;
        end;
        SetLength(packet_buffer, SizeOf(arp_ethernet) + SizeOf(arp_payload));
        Move(arp_ethernet, packet_buffer[0], SizeOf(arp_ethernet));
        Move(arp_payload, packet_buffer[SizeOf(arp_ethernet)],
          SizeOf(arp_payload));

        filter := 'arp[6:2] = 2';
        Writeln('Filter compilation: ' + IntToStr(pcap_compile(adhandle, @fp,
          PAnsiChar(filter), 1, $FFFFFF00)));
        Writeln('Set filter: ' + IntToStr(pcap_setfilter(adhandle, @fp)));
        pcap_loop(adhandle, 0, packet_handler, nil);
        pcap_sendpacket(adhandle, @packet_buffer[0], Length(packet_buffer));
        // while true do
        // begin
        // pcap_sendpacket(adhandle, @packet_buffer[0], Length(packet_buffer));
        // sleep(1000);
        // end;

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

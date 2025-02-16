program ArpPing;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils,
  WinSock2, // Используем только Winsock2
  pcap in 'pcap.pas',
  Windows,
  System.Classes;

const
  IF_ID = '\Device\NPF_{077C8EF5-CB84-4C34-9C2A-66006D41D835}';
  ETHERTYPE_IP = $0800;

type
  T20Bytes = array [1 .. 14] of Byte;

var
  alldevs, d: TPcap_if;
  errbuf: TPcapErrbuf;
  i: Integer = 0;
  selected_interface: Integer;
  adhandle: PPcap_t;
  ethertype_int: smallint;
  arp_packet: TArpPacket;
  ethernet_packet: TetherHeader;
  final_packet: array of Byte;

procedure DumpToScreen(const data: array of Byte);
var
  i: Integer;
begin
  for i := 0 to High(data) do
  begin
    Write(IntToHex(data[i], 2), ' '); // Вывод каждого байта в HEX-формате
    if (i + 1) mod 16 = 0 then // Переход на новую строку каждые 16 байт
      Writeln;
  end;
  Writeln; // Переход на новую строку в конце
end;

procedure DumpToFile(const data: array of Byte; const filename: string);
var
  i: Integer;
  f: TextFile;
begin
  AssignFile(f, filename);
  Rewrite(f); // Открываем файл для записи
  try
    for i := 0 to High(data) do
    begin
      Write(f, IntToHex(data[i], 2), ' '); // Запись каждого байта в HEX-формате
      if (i + 1) mod 16 = 0 then // Переход на новую строку каждые 16 байт
        Writeln(f);
    end;
    Writeln(f); // Переход на новую строку в конце
  finally
    CloseFile(f); // Закрываем файл
  end;
end;

procedure DumpEthToHex(filename: string; data: Pointer);
var
  bs: TBytesStream;
  fs: TFileStream;
  inner_data: TBytes;
  bytes_seek: Byte;
  bytestostring: AnsiString;
  etherheader: T20Bytes;
  a: Pointer;
  buffer: AnsiString;
begin
  buffer := '';
  fs := TFileStream.Create(filename, fmOpenReadWrite or fmExclusive);
  fs.Seek(0, soFromEnd);
  Move(data^, etherheader, 14);
  bytestostring := '';
  buffer := buffer + 'ETHERNET LAYER' + #10;
  buffer := buffer + 'Destination MAC:';
  for var i := 1 to 6 do
    buffer := buffer + IntToHex(etherheader[i], 2) + ' ';
  buffer := buffer + #10;
  buffer := buffer + 'Source MAC:';
  for var i := 7 to 12 do
    buffer := buffer + IntToHex(etherheader[i], 2) + ' ';
  buffer := buffer + #10;
  buffer := buffer + 'Ethertype:';
  for var i := 13 to 14 do

    buffer := buffer + IntToHex(etherheader[i], 2) + ' ';
  ethertype_int := ntohs(smallint(etherheader[13]));
  case ethertype_int of
    ETHERTYPE_IP:
      buffer := buffer + '(IP)';
  else
    buffer := buffer + '(NOT IP)';
  end;
  Writeln(buffer);
  fs.WriteBuffer(Pointer(buffer)^, Length(buffer));
  buffer := #10 +
    '-----------------------------------------------------------------' + #10;
  fs.WriteBuffer(Pointer(buffer)^, Length(buffer));
  fs.Free;
end;

procedure packet_handler(param: PByte; pkthdr: PPcap_pkthdr;
  packet_data: PByte);
var
  etherhdr: PEtherHeader;
  ethertype: word;
  bytes_seek: PByte;

begin
  Writeln('Packet is capture');
  DumpEthToHex('f:\dump.bin', packet_data);
  Writeln('Packet is dumping');
  etherhdr := PEtherHeader(packet_data);
  ethertype := ntohs(etherhdr.ethertype);
  // writeln('EtherType: 0x' + IntToHex(ethertype, 4));
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
      // Writeln('Select interface:');
      // readln(selected_interface);
      // pcap_freealldevs(@alldevs);
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
        // pcap_loop(adhandle, 0, packet_handler, nil);
        with ethernet_packet do
        begin
          destination[1] := $FF;
          destination[2] := $FF;
          destination[3] := $FF;
          destination[4] := $FF;
          destination[5] := $FF;
          destination[6] := $FF;
        end;
        with ethernet_packet do
        begin
          source[1] := $50;
          source[2] := $E5;
          source[3] := $49;
          source[4] := $DE;
          source[5] := $68;
          source[6] := $89;
        end;
        ethernet_packet.ethertype := htons(ETHERTYPE_ARP);
        arp_packet.htype := htons(1);
        arp_packet.ptype := htons($0800);
        arp_packet.hlen := 6;
        arp_packet.plen := 4;
        arp_packet.oper := htons(1);
        with arp_packet do
        begin
          sha[1] := $50;
          sha[2] := $E5;
          sha[3] := $49;
          sha[4] := $DE;
          sha[5] := $68;
          sha[6] := $89;
        end;
        with arp_packet do
        begin
          tha[1] := $FF;
          tha[2] := $FF;
          tha[3] := $FF;
          tha[4] := $FF;
          tha[5] := $FF;
          tha[6] := $FF;
        end;
        with arp_packet do
        begin
          spa[1] := $C0;
          spa[2] := $A8;
          spa[3] := $1F;
          spa[4] := $A;
        end;
        with arp_packet do
        begin
          tpa[1] := $C0;
          tpa[2] := $A8;
          tpa[3] := $1F;
          tpa[4] := $C0;
        end;
        SetLength(final_packet, SizeOf(ethernet_packet) + SizeOf(arp_packet));
        Move(ethernet_packet, final_packet[0], SizeOf(ethernet_packet));
        Move(arp_packet, final_packet[SizeOf(ethernet_packet)],
          SizeOf(arp_packet));
        DumpToFile(final_packet, 'f:\dump.bin');
        DumpToScreen(final_packet);
        Writeln('size:' + IntToStr(SizeOf(arp_packet)));
        while (True) do
        begin
          Writeln('Sending ' + IntToStr(Length(final_packet)) + 'bytes');
          Writeln('ARP sending:' + IntToStr(pcap_sendpacket(adhandle,
            @final_packet[0], Length(final_packet))));
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

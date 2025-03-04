program arping;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  DebugUtils in 'DebugUtils.pas',
  packet in 'packet.pas',
  PcapExceptions in 'PcapExceptions.pas',
  PcapTypes in 'PcapTypes.pas',
  PcapUtils in 'PcapUtils.pas',
  TPcapClass in 'TPcapClass.pas',
  UserInteractive in 'UserInteractive.pas',
  SysUtils;

const
  IF_ID = '\Device\NPF_{077C8EF5-CB84-4C34-9C2A-66006D41D835}';
  IF_ID_2 = '\Device\NPF_{9C22769D-724A-4B92-814A-605A36AAF2CC}';
  HOME_MAC: TPcapMAC = ($50, $E5, $49, $DE, $68, $89);
  WORK_MAC: TPcapMAC = ($38, $D5, $47, $19, $DB, $D6);
  BROADCAST_MAC: TPcapMAC = ($50, $E5, $49, $DE, $68, $89);

var
  pcap: TPcap;
  UserInteractive: TUserInteractive;
  ethernetHeader: TEthernetHeader;
  arpPayload: TArpPacket;
  networkPacket: TNetworkPacket;
  packetBuffer:TPackedBytes;
begin
  try
    try
      pcap := TPcap.Create;
    except
      on e: EFindAllDevicesException do
        writeln('Interfaces fetching error: ' + e.Message);
    end;
    UserInteractive := TUserInteractive.Create(@pcap);
    UserInteractive.FSelectedInterface := UserInteractive.GetInterface
      ('Select interface:');
    writeln('Selected interface: ' + UserInteractive.FSelectedInterface.
      description);
       try
      begin
        pcap.OpenInterface(UserInteractive.FSelectedInterface);
        writeln('Adapter open in promiscious mode');
      end;
    except
      on e: EOpenInterfaceException do
        writeln('Open adapter failed: ' + e.Message);
    end;
 ethernetHeader := TEthernetHeader.Create(pcap);
    FillChar(ethernetHeader.FDestination,
      SizeOf(ethernetHeader.FDestination), $FF);
    ethernetHeader.FSource := WORK_MAC;
    ethernetHeader.FEthertype := ETHERTYPE_ARP;
    arpPayload := TArpPacket.Create();
    arpPayload.oper := 1;
    arpPayload.sha := WORK_MAC;
    arpPayload.spa[0] := 10;
    arpPayload.spa[1] := 1;
    arpPayload.spa[2] := 2;
    arpPayload.spa[3] := 215;
    FillChar(arpPayload.tha, SizeOf(arpPayload.tha), $FF);
    arpPayload.tpa[0] := 10;
    arpPayload.tpa[1] := 1;
    arpPayload.tpa[2] := 2;
    arpPayload.tpa[3] := 143;
    //PrintArray(arpPayload.Build);
    networkPacket := TNetworkPacket.Create;
    networkPacket.addHeader(ethernetHeader);
    networkPacket.addHeader(arpPayload);
    packetBuffer:=networkPacket.BuildPacket;
    PrintArray(packetBuffer);
    while True do
    begin
    pcap.SendPacket(@packetBuffer);
    sleep(100);
    end;


    readln;
  except
    on e: Exception do
    begin
      writeln(e.ClassName, ': ', e.Message);
      readln;
    end;
  end;

end.

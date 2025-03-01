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
  BROADCAST_MAC: TPcapMAC = ($50, $E5, $49, $DE, $68, $89);

var
  pcap: TPcap;
  UserInteractive: TUserInteractive;
  ethernetHeader: TEthernetHeader;
  arpPayload: TArpPacket;
  networkPacket: TNetworkPacket;

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
        pcap.OpenInterface(@UserInteractive.FSelectedInterface);
        writeln('Adapter open in promiscious mode');
      end;
    except
      on e: EOpenInterfaceException do
        writeln('Open adapter failed: ' + e.Message);
    end;
    ethernetHeader := TEthernetHeader.Create(pcap);
    FillChar(ethernetHeader.FDestination,
      SizeOf(ethernetHeader.FDestination), $FF);
    ethernetHeader.FSource := HOME_MAC;
    ethernetHeader.FEthertype := ETHERTYPE_ARP;
    arpPayload := TArpPacket.Create();
    arpPayload.oper := 1;
    arpPayload.sha := HOME_MAC;
    arpPayload.spa[0] := $C0;
    arpPayload.spa[1] := $A8;
    arpPayload.spa[2] := $1F;
    arpPayload.spa[3] := $A;
    FillChar(arpPayload.tha, SizeOf(arpPayload.tha), $FF);
    arpPayload.tpa[0] := $C0;
    arpPayload.tpa[1] := $A8;
    arpPayload.tpa[2] := $1F;
    arpPayload.tpa[3] := $1;
    //PrintArray(arpPayload.Build);
    networkPacket := TNetworkPacket.Create;
    networkPacket.addHeader(ethernetHeader);
    networkPacket.addHeader(arpPayload);
    PrintArray(networkPacket.BuildPacket);

    readln;
  except
    on e: Exception do
    begin
      writeln(e.ClassName, ': ', e.Message);
      readln;
    end;
  end;

end.

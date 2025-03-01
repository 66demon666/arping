unit packet;

interface

uses TPcapClass, PcapTypes, WinSock, SYsUtils;

const
  ETHERTYPE_ARP = $0806;
  ETHERTYPE_IP = $0800;

type

  TPcapIP = array [0 .. 3] of Byte;
  TPcapMAC = array [0 .. 5] of Byte;

  PArpPacket = ^TArpPacket;

  TArpData = packed record
    htype: smallint; // hardware address type. Always 1 for Ethernet        0-1
    ptype: smallint; // protocol address type. 2048 for ipv4                2-3
    hlen: Byte; // hardware address length. 6 for MAC addresses             4
    plen: Byte; // protocol address length. 4 for ipv4                      5
    oper: smallint; // code of opeation. 1 for request, 2 for reply         6-7
    sha: TPcapMAC; // sender hardware (MAC) address           8-13
    spa: TPcapIP; // sender protocol (ip) address            14-17
    tha: TPcapMAC; // target hardware (MAC) address           18-23
    tpa: TPcapIP; // target protocol (ip) address            24-27
  end;

  PEtherHeader = ^TetherHeader;

  TetherHeader = packed record
    destination: TPcapMAC; // target MAC address
    source: TPcapMAC; // sender MAC address
    ethertype: word; // type of incapsulate protocol. 0x0800 for ipv4
  end;

  TNetworkHeader = class
  public
    data: TPackedBytes;
    constructor Create(pcap: TPcap); virtual; abstract;
    function Build(): TPackedBytes; virtual;  abstract;
    // function Parse(data: array of Byte): boolean; virtual; abstract;
  end;

  TNetworkPacket = class
  public
    FData: TPackedBytes;
    FHeaders: array of TNetworkHeader;
    function BuildPacket(): TPackedBytes;
    procedure addHeader(header: TNetworkHeader);
  end;

  TEthernetHeader = class(TNetworkHeader)
    data: TetherHeader;
    FDestination: TPcapMAC;
    FSource: TPcapMAC;
    FEthertype: word;
    constructor Create(pcap: TPcap);
    // function Parse(data: array of Byte): boolean;
    function Build(): TPackedBytes; override;
  end;

  TArpPacket = class(TNetworkHeader)
    data: TArpData;
    htype: smallint; // hardware address type. Always 1 for Ethernet        0-1
    ptype: smallint; // protocol address type. 2048 for ipv4                2-3
    hlen: Byte; // hardware address length. 6 for MAC addresses             4
    plen: Byte; // protocol address length. 4 for ipv4                      5
    oper: smallint; // code of opeation. 1 for request, 2 for reply         6-7
    sha: TPcapMAC; // sender hardware (MAC) address           8-13
    spa: TPcapIP; // sender protocol (ip) address            14-17
    tha: TPcapMAC; // target hardware (MAC) address           18-23
    tpa: TPcapIP; // target protocol (ip) address            24-27
    function Build(): TPackedBytes;  override;
    // function Parse(data: array of Byte): boolean;
    constructor Create();
  end;

implementation

constructor TArpPacket.Create;
begin

end;

constructor TEthernetHeader.Create(pcap: TPcap);
begin

end;

function TEthernetHeader.Build(): TPackedBytes;
begin
  data.destination := self.FDestination;
  data.source := self.FSource;
  data.ethertype := htons(self.FEthertype);
  SetLength(Result, SizeOf(data));
  Move(data, Result[0], SizeOf(data));
end;

function TArpPacket.Build: TPackedBytes;
begin
  data.htype := htons(1);
  data.ptype := htons(2048);
  data.hlen := 6;
  data.plen := 4;
  data.oper := htons(self.oper);
  data.sha := self.sha;
  data.spa := self.spa;
  data.tha := self.tha;
  data.tpa := self.tpa;
  SetLength(Result, SizeOf(self.data));
  Move(data, Result[0], SizeOf(data));
end;

function TNetworkPacket.BuildPacket: TPackedBytes;
var
  headerData: TPackedBytes;
  resultSeek: integer;
begin
  resultSeek := 0;
  for var i := Low(self.FHeaders) to High(self.FHeaders) do
  begin
    writeln('i=' + IntToStr(i));
    headerData := self.FHeaders[i].Build;
    SetLength(Result, Length(Result) + Length(headerData));
    Move(headerData[0], Result[resultSeek], Length(headerData));
    resultSeek := resultSeek + Length(headerData);
  end;
end;

procedure TNetworkPacket.addHeader(header: TNetworkHeader);
begin

  SetLength(self.FHeaders, Length(self.FHeaders) + 1);
  self.FHeaders[Length(self.FHeaders) - 1] := header;
  writeln('Length of Headers: ' + IntToStr(Length(self.FHeaders)));
end;


end.

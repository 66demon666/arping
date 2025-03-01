unit packet;

interface

uses TPcapClass;

const
  ETHERTYPE_ARP = $0806;
  ETHERTYPE_IP = $0800;

type

  TPcapIP = array [0 .. 3] of Byte;
  TPcapMAC = array [0 .. 5] of Byte;

  PArpPacket = ^TArpPacket;

  TArpPacket = packed record
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
    data: packed array of Byte;
    constructor Create(pcap: TPcap); virtual; abstract;
    function Build(): Boolean; virtual; abstract;
  end;

  TNetworkPacket = class
  public
    FData: packed array of Byte;
    FChunks: array of TNetworkHeader;
  end;

implementation

end.

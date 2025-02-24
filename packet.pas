unit packet;

interface

const
  ETHERTYPE_ARP = $0806;
  ETHERTYPE_IP = $0800;


type

  PArpPacket = ^TArpPacket;

  TArpPacket = packed record
    htype: smallint; // hardware address type. Always 1 for Ethernet        0-1
    ptype: smallint; // protocol address type. 2048 for ipv4                2-3
    hlen: byte; // hardware address length. 6 for MAC addresses             4
    plen: byte; // protocol address length. 4 for ipv4                      5
    oper: smallint; // code of opeation. 1 for request, 2 for reply         6-7
    sha: array [0 .. 5] of byte; // sender hardware (MAC) address           8-13
    spa: array [0 .. 3] of byte; // sender protocol (ip) address            14-17
    tha: array [0 .. 5] of byte; // target hardware (MAC) address           18-23
    tpa: array [0 .. 3] of byte; // target protocol (ip) address            24-27
  end;

  PEtherHeader = ^TetherHeader;

  TetherHeader = packed record
    destination: array [0 .. 5] of byte; // target MAC address
    source: array [0 .. 5] of byte; // sender MAC address
    ethertype: word; // type of incapsulate protocol. 0x0800 for ipv4
  end;

implementation

end.

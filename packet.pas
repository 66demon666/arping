unit packet;

interface

const
  ETHERTYPE_ARP = $0806;
  ETHERTYPE_IP = $0800;

type
  PArpPacket = ^TArpPacket;

  TArpPacket = packed record
    htype: smallint; // hardware address type. Always 1 for Ethernet
    ptype: smallint; // protocol address type. 2048 for ipv4
    hlen: byte; // hardware address length. 6 for MAC addresses
    plen: byte; // protocol address length. 4 for ipv4
    oper: smallint; // code of opeation. 1 for request, 2 for reply
    sha: array [1 .. 6] of byte; // sender hardware (MAC) address
    spa: array [1 .. 4] of byte; // sender protocol (ip) address
    tha: array [1 .. 6] of byte; // target hardware (MAC) address
    tpa: array [1 .. 4] of byte; // target protocol (ip) address
  end;

  PEtherHeader = ^TetherHeader;

  TetherHeader = packed record
    destination: array [1 .. 6] of byte; // target MAC address
    source: array [1 .. 6] of byte; // sender MAC address
    ethertype: word; // type of incapsulate protocol. 0x0800 for ipv4
  end;

implementation

end.

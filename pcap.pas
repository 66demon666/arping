unit pcap;

interface

uses Winsock2, WinSock, IpHlpApi;

const
  PCAP_SRC_IF_STRING = 'rpcap://';
  PCAP_ERRBUF_SIZE = 256;
  PCAP_OPENFLAG_PROMISCUOUS = 1;

type

  TTimeval = record
    tv_sec: Longint; // �������
    tv_usec: Longint; // ������������
  end;

  PTimeVal = ^timeval; // ��������� �� timeval

  TPcap_pkthdr = packed record
    ts: TTimeval;
    caplen: cardinal;
    len: cardinal;
  end;

  PPcap_pkthdr = ^TPcap_pkthdr;

  tpcap_handler = procedure(param: PByte; pkthdr: PPcap_pkthdr;
    packet_data: PByte);

  TPcapErrbuf = array [0 .. PCAP_ERRBUF_SIZE - 1] of AnsiChar;
  PPcap_rmtauth = ^TPcap_rmtauth;

  TPcap_rmtauth = packed record
    pcap_type: integer;
    username: PAnsiChar;
    password: PAnsiChar;
  end;

  PPcap_addr = ^TPcap_addr;

  TPcap_addr = packed record
    next: PPcap_addr;
    addr: Psockaddr;
    netmask: Psockaddr;
    broadaddr: Psockaddr;
    dstaddr: Psockaddr;
  end;

  PPPcap_if = ^PPcap_if;
  PPcap_if = ^TPcap_if;

  TPcap_if = packed record
    next: PPcap_if;
    name: PAnsiChar;
    description: PAnsiChar;
    addresses: PPcap_addr;
    flags: cardinal;
  end;

  PPcap_t = ^Tpcap_t;

  Tpcap_t = packed record
  end;

function pcap_findalldevs_ex(source: PAnsiChar; auth: PPcap_rmtauth;
  addresses: PPPcap_if; errbuf: PAnsiChar): integer; stdcall;
  external 'wpcap.dll';
procedure pcap_freealldevs(pcap_if_t: PPcap_if); stdcall; external 'wpcap.dll';
function pcap_open(source: PAnsiChar; snaplen: integer; flags: integer;
  read_timeout: integer; pcap_rmtauth: PPcap_rmtauth; errbuf: PAnsiChar)
  : PPcap_t; stdcall; external 'wpcap.dll';

function pcap_loop(pcap_t: PPcap_t; some_int: integer; handler: tpcap_handler;
  something: PByte): integer; stdcall; external 'wpcap.dll';

procedure pcap_close(pcap_t: PPcap_t); stdcall; external 'wpcap.dll';
function pcap_sendpacket(pcap_t: PPcap_t; buffer: PByte; size: integer)
  : integer; stdcall; external 'wpcap.dll';

implementation

end.

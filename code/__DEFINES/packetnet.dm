// We'll need to shove shit here eventually.
// ayy we did

//network_flags

/// Automatically generate a [/obj/machinery/var/net_id] on initialize.
#define NETWORK_FLAG_GEN_ID (1<<0)

/// Automatically connect to a data terminal at lateinit.
/// Not having this flag and attempting to interact with
/// data_terminals via [/obj/machinery/proc/link_to_jack()] is illegal and will explicitly crash.
#define NETWORK_FLAG_USE_DATATERMINAL (1<<1)

/// Add the machine to [/datum/powernet/var/list/data_nodes]
/// You should have a VERY good reason for this to be set on anything not of type [/obj/machinery/power]
#define NETWORK_FLAG_POWERNET_DATANODE (1<<2)

/// Standard set of network flags, for use by most network-connected equipment.
#define NETWORK_FLAGS_STANDARD_CONNECTION (NETWORK_FLAG_GEN_ID | NETWORK_FLAG_USE_DATATERMINAL)

// -----
// Net Classes
#define NETCLASS_P2P_PHONE "PNET_VCSTATION"
#define NETCLASS_APC "PNET_AREAPOWER"
#define NETCLASS_TERMINAL "PNET_STERM"
#define NETCLASS_GRPS_CARD "NET_GPRS"
#define NETCLASS_MESSAGE_SERVER "NET_MSGSRV"

// -----
// Signal Origins

// 'Raw' origins, either fresh from SSPackets or some other raw transport medium.
/// Originates directly from SSPackets 'SSPACKETS_POWERNET' phase.
#define ORIGIN_POWERLINE "powerline"
/// Originates directly from SSPackets ImmediateRadioPacketSend()
#define ORIGIN_RADIOLINE "radioline"
/// I hate telecomms I hate telecomms
#define ORIGIN_SUBSPACE "subspace_magic"
/// Originates directly from the bull's ass. Usually circuits.
#define ORIGIN_MAGIC "bullshit"

// 'Interface' origins, such as the various forms of terminal.
/// Originates from a device (goon style) terminal
#define ORIGIN_DEVICE_TERMINAL "device_terminal"
/// Originates from a data-enabled (APC/SMES style) terminal
#define ORIGIN_DATA_ENABLED_TERMINAL "data_enabled_terminal"

// -----
// Packet fields
// not honestly thrilled with having these be defines but kapu wants it that way
// I believe every coder is empowered with a right to footgun by our lord Dennis Ritchie


//Generic fields
/// Source (sender) address of a packet
#define PACKET_SOURCE_ADDRESS "s_addr"
/// Destination (receiver) address of a packet
#define PACKET_DESTINATION_ADDRESS "d_addr"
/// Command (type) of a packet
#define PACKET_CMD "command"
/// Network Class of a device, used as part of ping replies.
#define PACKET_NETCLASS "netclass"

// -----
// Special addresses

/// Ping all devices. Traverses bridges.
#define NET_ADDRESS_PING "ping" // This is kinda expensive, can we do better with routing?

/// Bridge Communication
// Functionally just an evil version of "Rapid" Spanning Tree Protocol
#define NET_ADDRESS_BRIDGE_CONTROL "bridge_control"

// -----
//'Command' values

// Standard Commands
#define NET_COMMAND_PING_REPLY "ping_reply"

// PDA Text Message
#define NETCMD_PDAMESSAGE "pda_message"

// -----
// Dataterminal connection/disconnect return values

/// Successfully connected.
#define NETJACK_CONNECT_SUCCESS 0

/// Connection rejected, Already connected to a machine
#define NETJACK_CONNECT_CONFLICT 1

/// Connection rejected, Not sharing a turf (???)
#define NETJACK_CONNECT_NOTSAMETURF 2

/// Data Terminal not found.
#define NETJACK_CONNECT_NOT_FOUND 3

// receive_signal return codes

/// Packet fully handled by parent
#define RECEIVE_SIGNAL_FINISHED TRUE
/// Packet needs additional handling
#define RECEIVE_SIGNAL_CONTINUE FALSE

// -----
// Inviolability flags

/// Packet contains volatile data where storing it may cause GC issues.
/// This means references to atoms, non-trivial datums like virtualspeakers, etc.
#define MAGIC_DATA_MUST_DISCARD (1<<0)

/// Packet contains data that players should never be able to see *DIRECTLY*.
/// Re-Interpretation is allowed, This is specifically for arbitrary packet capture applications where raw fields are accessible.
/// For example, voice signal packets, or stuff that wouldn't make sense to be parsable as raw text.
#define MAGIC_DATA_MUST_OBFUSCATE (1<<1)

/// All protection flags at once.
#define MAGIC_DATA_INVIOLABLE ALL

// -----
// Other

#define PACKET_STRING_FILE "packetnet.json"

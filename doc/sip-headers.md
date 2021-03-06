Besides standard SIP headers, the following headers are specific to the system:

P-Charge-Info (per draft-york-sipping-p-charge-info)
  The username part of the SIP URI is used as the "account".

X-CCNQ3-Location
  Proprietary header storing a location's identifier.
  (Received by an outbound-proxy.)

X-CCNQ3-Routing
  Proprietary header storing emergency routing data.

X-CCNQ3-Number-Domain
  Proprietary header storing local numbers' `number_domain`, set by an inbound client-sbc or a client-side proxy.
  This value is used for example by the voicemail system to locate the actual destination of a call.

X-CCNQ3-Attrs
  Proprietary header storing Least Cost Route data.
  Set by a routing proxy for the purpose of passing information about the
  selected route and prefix to a downstream element. Information is then
  inserted in CDRs as `variables.ccnq_attrs`.

X-CCNQ3-Emergency-Key
  Proprietary header storing an invalid emergency key.
  Sent by an emergency router in a 404 reply to indicate that an emergency key
  could not be located. Consists of the request username followed by `#` followed
  by the X-CCNQ3-Routing header's content.

X-CCNQ3-Reason
  Proprietary header storing a call disconnect cause.
  The only attributed cause is 'Call too long'.

X-CCNQ3-MediaProxy
  Proprietary header indicating that a call went through a MediaProxy server.
  Set to 'on' (but presence of the header is the indication), avoids going
  through multiple MediaProxy servers to avoid situations where this could
  create media issues.

X-CCNQ3-Extra
  Proprietary header providing extraneous information, typically to track
  end-user properties in CDRs as `variables.ccnq_extra`.
  In the `complete` opensips model, the content of this field can be configured
  by modifying the `lineside_extra_info` opensips configuration item.

Due to limitations in Sofia-SIP, we cannot comply with RFC5727 and RFC6648, which
would require the headers to not start with 'X-' nor 'P-'.

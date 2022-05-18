#if !defined(__ALI_RTS_MESSAGES_H__)
#define __ALI_RTS_MESSAGES_H__

#if defined(__cplusplus)
extern "C" {
#endif

/* event callback
 *
 * Set callback to rtssdk: call preconfig("MessageCallback", ...) and
 * preconfig("MessageCbParam", ...)
 * rtssdk will invoke your callback when an event happens (async mode). and
 * your callback need handle the event ASAP otherwise following event
 * messages will be blocked
 *
 * callback prototype
 * int (*event_callback)(void *opaque,
 *                    int type,
 *                    void *data,  // a string: "when=<time_in_ms>,where=<place>,who=<id>,desc=<extra text>"
 *                                 // if type == E_PROFILING_REPORT, desc=\"key1:val1,key2:val2,...\"
 *                                 // ATTENTION: temp data, do not cache it for later use
 *                    long long data_size // bytes of 'data'
 *                    );
 *
 * type:
 *       105           state report event (called periodically)
 *                     'data' points to a rtssdk_profiling_data object
 *       200~210       rtcp report event
 *       1100          opening an url
 *       1101          received first audio packet
 *       1102          received first video packet
 *       1103          output first video frame
 *       1104          output first audio frame
 *       20000~30000   error event
 *
 */

/* help support IDs
 * app need record these IDs. provide them to aliyun when ask for
 * issue support
 */
#define E_HELP_SUPPORT_ID_LOAD       100 // issue for loading
#define E_HELP_SUPPORT_ID_CONNECT    102 // issue for connect operation
#define E_HELP_SUPPORT_ID_PUBLISH    103 // issue for publish operation
#define E_HELP_SUPPORT_ID_SUBSCRIBE  104 // issue for subscribe operation

/* profiling data. sent every 4 seconds by default
 * data format: key1:value1,key2:value2,key3:value3...
 */
#define E_PROFILING_REPORT  105
// 107: reserved by E_PROFILING_REPORT_H5

/* got the aes keyinfo in stream, send to app to
 * fetch the plaintext key
 */
#define E_GOT_AESKEYINFO    106

#define E_OPEN              120 // event at opening
#define E_CLOSE             121 // event at closing
#define E_CONNECT           122 // event at connecting
#define E_DISCONNECT        123 // event at disconnecting
#define E_PUBLISH           124 // event at publishing
#define E_SUBSCRIBE         125 // event at subscribing
#define E_SUBSCRIBE_OK      126 // event at subscribing
#define E_PUBLISH_OK        127 // event at publishing


#define E_FIRST_PACKET      132 // first rtp packet, only sub
#define E_FIRST_VFRMAE      135 // first video frame, only sub
#define E_FIRST_AFRAME      136 // first audio frame, only sub

#define E_FIRST_PUB_VFRAME  137 //first pub video frame, only pub
#define E_FIRST_PUB_AFRAME  138 //first pub audio frame, only pub
// 137: reserved by E_FIRST_VFRAME_H5

/* some messages used internally. app
 * will not receive them
 */
// code 141 reserved for upstream period report to sls
#define E_REPORT_UPSTREAM_SLS   141 // slight difference from E_PROFILING_REPORT
// code 141 reserved for upstream period report to sls
#define E_REPORT_DOWNSTREAM_SLS 142 // slight difference from E_PROFILING_REPORT
// code 150 reserved for various error code to report to sls
#define E_ERROR_REPORT_SLS  150

#define E_VIDEO_FREEZE_FINISH    151        //Statistics of the last video freeze
#define E_AUDIO_FREEZE_FINISH    152        //Statistics of the last audio freeze
#define E_PUB_DELAY_REPORT       153        //Statistics of pub delay
#define E_SUB_DELAY_REPORT       154        //Statistics of sub delay
//code 200~210 reserved for rtcp report event use
#define EVENT_RTCP_BASE 200
#define E_PLI_REQUEST  (EVENT_RTCP_BASE + 1)
#define E_FIR_REQUEST  (EVENT_RTCP_BASE + 2)

//code 220~250 reserved for congestion control
#define EVENT_CONGESTIONCONTROL_BASE 220
#define E_STABLE_BITRATE (EVENT_CONGESTIONCONTROL_BASE + 1)

#define EVENT_ERROR_BASE 20000
// errors happening during opening stage
#define E_DNS_FAIL          (EVENT_ERROR_BASE + 1 )  // could not resolve host name
#define E_AUTH_FAIL         (EVENT_ERROR_BASE + 2 )  // bad auth code
#define E_CONN_OK           (EVENT_ERROR_BASE + 9 )  // connected to sfu
#define E_CONN_FAIL         (EVENT_ERROR_BASE + 10)  // fail to connect to sfu ,sub & pub
#define E_SUB_TIMEOUT       (EVENT_ERROR_BASE + 12)  // timeout for subscribe response
#define E_SUB_NO_STREAM     (EVENT_ERROR_BASE + 13)  // sub stream not exist
#define E_SUB_NO_AUDIO      (EVENT_ERROR_BASE + 14)  // sub audio track not found
#define E_SUB_NO_VIDEO      (EVENT_ERROR_BASE + 15)  // sub video track not found
#define E_SUB_UNKNOWN_ERROR (EVENT_ERROR_BASE + 20)  // sub other unknown error

#define E_PUB_TIMEOUT       (EVENT_ERROR_BASE + 30)  // timeout for pub response
#define E_PUB_NO_STREAM     (EVENT_ERROR_BASE + 31)  // pub stream not exist
#define E_PUB_UNKNOWN_ERROR (EVENT_ERROR_BASE + 32)  // pub other unknown error

// errors happening during running stage
#define E_CONGESTION_BEGIN  (EVENT_ERROR_BASE + 50)  // lost rate too high
#define E_CONGESTION_END    (EVENT_ERROR_BASE + 51)  // lost rate decrease to normal level
#define E_STREAM_BROKEN     (EVENT_ERROR_BASE + 52)  // no any audio and video packets
#define E_STREAM_RECOVERED  (EVENT_ERROR_BASE + 53)  // audio or video packets recovered
#define E_STREAM_EOF        (EVENT_ERROR_BASE + 54)  // EOF received from sfu. App need stop playback or pushstream

#define E_CONNECT_LOST      (EVENT_ERROR_BASE + 55)  // require reconnection. sub & pub
#define E_STREAM_RESTARTED  (EVENT_ERROR_BASE + 56)  // stream restart detected
#define E_DOWNGRADE_RTMP    (EVENT_ERROR_BASE + 57)  // need downgrade to rtmp  sub & pub
#define E_DECRYPT_STREAM    (EVENT_ERROR_BASE + 58)  // need check decrypt config
#define E_IPPORT_SWITCHED   (EVENT_ERROR_BASE + 59)  // wan ip port switched


//For internal use only
#define EVENT_INTERNAL_BASE 30000
#define E_CONNECT_TOKEN  (EVENT_INTERNAL_BASE + 1)

#if defined(__cplusplus)
}
#endif

#endif  // __ALI_RTS_MESSAGES_H__

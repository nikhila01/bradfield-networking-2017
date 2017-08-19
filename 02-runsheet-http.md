# Application layer: HTTP

This class is intended to go into detail on HTTP. Since most students will be using this protocol every day, we dedicate extra time to it and strive to understand it in more detail than others.


## Students should understand

* The details of how HTTP is specified to work
* The pros and cons of the HTTP specification
* Where HTTP/1.0 failed and how HTTP/1.1 addressed that
* The core ideas of HTTP/2 and why they were needed


## Students should be able to

* Parse and explain in detail basically any aspect of any HTTP/1.1 message
* Discuss at a high level the features of HTTP/2


## General timeline

* Review previous pcap assignment
* Overview of HTTP/1.0 and HTTP/1.1 - URLs, request and response formats, URLs etc
* Wireshark HTTP exercise
* Create their own capture with Wireshark
* Modify their parser code to work for this new capture
* Overview of HTTP/2
* Exercise: write an HTTP request/response parsing/generating library as you might for a web framework. Some of this code can be taken from the net.cap parsing exercise from lesson 1. As a stretch goal, include some support for an HTTP/2 feature such as compression/decompression of HTTP headers
  * __Haven't used this lately__
* Exercise: computing first byte time, total transit time, for http1.0, 1.1, 2 given some conditions

## Review PCAP Assignment (30 min) (or maybe 2 hours depending...)

* __Depending on the progress your students made you may want to use this class to live-code or work through the entire solution carefully__
* Walk through the provided solution step by step (layer by layer)
* Really emphasize the "enveloping" concept.

## HTTP Format (20 minutes):

HTTP is all over the place, lets look in a bit of detail at it's specification, some of the important headers and methods, and discuss it's overall importance

##### Request
```
METHOD URL VERSION\r\n
HEADER LINE\r\n
HEADER LINE\r\n
(AS MANY AS YOU NEED)\r\n
\r\n
DATA (OPTIONAL)
```

##### Response:
```
VERSION STATUS PHRASE\r\n
HEADER LINE\r\n
(AGAIN, MANY)\r\n
\r\n
DATA
```

* __Everyone Writes: Suppose you are a server and I sent you this data:__
```
GET /name HTTP/1.1\r\n
host: www.yourserver.com
accept: text/plain\r\n
```
* __Write two valid raw HTTP responses. One where your server experiences an internal error, and one where you return to me the data I asked for (your name)__
* You've probably had enough parsing for awhile... but a stretch exercise would be to parse and create raw HTTP data.

## HTTP headers (30 Minutes)

Headers control lots of things. You can define custom headers that aren't these headers, and your specific application can consume those if you wish.

### Request fields (15-20 minutes)

Note: these are defined in a variety of RFCs. It used to be that you'd use X-Blah: for custom headers, but that use was deprecated.

* "Accept: text/plain" content types that are _acceptable_
* "Authorization: Basic QWxohcabaouhtnahuotn==" credentials for HTTP auth
  * __Discuss: That string looks kind of like garbage, how is it encoded?__
* "Connection: keep-alive" persistent connection
  * __Discuss: This is considered a huge improvement in HTTP 1.1, why is it so powerful?__
  * __Discuss: What is TCP handshaking?__
  * __Discuss: HTTP/2 takes it further with fully multiplexed connections, how is this different from 1.1 persistent connections?__
* "Cookie: foo=bar; baz=quux;" a cookie _previously sent by server_
  * __Discuss: What is the role of cookies?__
* "Content-Length: 348" length of the request _body_ in octets
* "Content-Type: application/json" the mime type of the body of the request
  * __Discuss: From the servers point of view, why does this matter?__
* "Date: Tue, 15 Nov..." date that the message was originated
* "Host: en.wikipedia.org:8080" for when hosting multiple domains on a single server
  * __Discuss: Why isn't this the transport layers responsibility?__
* "If-Modified-Since: Sat, 29 Oct" allows a 304 to be returned if content is unchanged
* "If-None-Match: abababa" allows a 304 to be returned if content in unchanged
  * __Discuss: caching is a crucial performance feature, why support both of these tactics.__
  * __Discuss: What is a "message digest"?__
  * __Discuss: We'll see this again when we talk about checksums.__
* "Referer: http://en.wikipedia.org" [sic] the address of the previous web page
* "User-Agent: foo" basically a lie
  * __easy to spoof, but valuable to companies with lots of traffic because most traffic is real__

### Response fields (5-10 minutes)

* "Connection: close" control options for the current connection
* "Content-Encoding: gzip"
  * __Discuss: why do we have both content-encoding and content-type?__
  * __Discuss: for gzip specifically... why would we use this?__
* "Content-Language: en"
* "Content-Length: 1234"
* "Date: 1 Jan..."
* "ETag: ababab12121" an identifier for a specific version of a resource, often a message digest
  * __Discuss: What is this again?__
* "Expires: Thu 2 Jan blah" date at which response is considered stale
  * __Discuss: Why would a server set a header like this?__
  * __Discuss: What are the advantages/disadvantages of this vs the ETag?__
* "Set-Cookie: foo=bar; baz=quux"

## Advantages of persistent connections (10 minutes)

* Lower CPU and memory usage (because fewer connections are open simultaneously).
* Enables HTTP pipelining of requests and responses (only theoretical)
* Reduced network congestion (fewer TCP connections).
* Reduced latency in subsequent requests (no handshaking).
* Errors can be reported without the penalty of closing the TCP connection.
* HTTP/2 improves on this with fully multiplexed connections!

## HTTP/2 (5 minutes)

Main differences are that HTTP/2:

* is binary, instead of textual
* is fully multiplexed, instead of ordered and blocking
* can therefore use one connection for parallelism
* uses header compression to reduce overhead
* allows servers to “push” responses proactively into client caches

## Exercise: time to transfer (20 minutes)

Say we have a page with 3 images and 2 CSS files. Assume that all of the files (including the page itself) are two segments in size, and there's a packetization delay of 10ms. Assume also that latency from client to server is 80ms (say, the server is on the East coast and we are querying from the West). How long before we can start rendering the page? How long before it is fully rendered? Answer both in terms of HTTP/1.0 and HTTP/1.1. For the HTTP/1.1 case, what if we allowed 2 requests per connection, say, vs 5. (This may require giving some TCP background). What if we had 2 concurrent connections to the server?

__We Do Together... The TCP Handshake Portion of HTTP 1.0. In addition to the math DRAW a connection diagram.__

*These solutions assume that the request for data is sent by the client a negligible amount of time after the ACK, meaning the server starts sending bytes for the requested resource as soon as it recieves the ACK. In practice there would be a reasonable delay between the ACK and the data request, say 10-50ms. We're also making a lot of assumptions about no packet loss, or corruption in transit*

#### HTTP 1.0:

In HTTP 1.0, every asset gets it's own connection. For every asset this process occurs:

* Client -> Server (SYN): 80ms + 10ms: 90ms
* Server Agrees to connect (SYN-ACK): 80ms + 10ms: 180ms
* Client Agrees (ACK): 80ms + 10ms: 270ms
* Server sends data (assuming 2 segments per file, and that writing the data is trivially fast):  80ms + 10 ms: 360ms

__You do: Finish this one__

360ms till we can start rendering. (now the client would close, and initiate a new handshake, these can happen at the same time)

5 more round trips = 360*5 = 1800ms MORE before we can fully render. Total time till render:

1800 + 360 = 2160ms

#### HTTP 1.1:

##### One persistent connection, all 5 files on that connection

The initial request takes the same 360ms, but each subsequent asset only takes it's transmission time.

360ms + 5*(90ms + 90ms) = 1260ms till render. 90ms later the connection is closed.

90+90 here is send and acknowledge. Even though the connection is persistent, data is still sent serially so we need to receive and acknowledge the data before getting the next file.

##### Two concurrent persistent connections

Socket one opens (we don't yet know we'll need assets):

360ms till HTML arrives

CONCURRENTLY:
Connection one stays open, starts fetching css 1. a second connection opens as well and starts fetching css 2:

CONNECTION 1 Stream:  
360 + 90 + 90 = 540ms we have 1 css file (Receive and ack)  
540 + 90 + 90 = 720ms now get the first image:  
720 + 90 + 90 = 900ms Lets go ahead and get the third image  (or second, break ties)   

CONNECTION 2 Stream:  
A second connection is opened for css 2:  
360ms + 360ms (second handshake) + (90 + 90)[receieve and ack] = 900ms before css 2 has arrived
900ms + 90 + 90 = 1080ms image 2 arrives here  

This time, we're done at 1080ms

#### HTTP 2, Fully Multiplexed:

With our new "fully multiplexed" and "server push" capabilities, whats the total transmission time?

Again, initial request is the same to open a connection. 270ms till that pipe is open. Now, we start sending ALL the data. Assuming the write time for this data is still trivial, the server pushes all the packets required __right now__

Handshake finishes: 270ms
270 + 90ms = 360ms (all data has arrived)
360ms + 90ms = 450ms (connection is closed)

## Exercise Wireshark HTTP Lab (20-30 minutes)

> consider making this homework instead.

Give students the pdf!

## Stretch It Exercise (Bonus Homework)

Take the PCAP exercise, make a brand new capture dump using wireshark, and read YOUR dump. What is going to have to change?

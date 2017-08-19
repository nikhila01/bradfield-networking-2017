# Application layer: DNS, SMTP, FTP and others

This class is designed to be a survey of important application layer protocols other than HTTP. This is not particularly challenging content, but there is a lot of it, and students should have a baseline level of familiarity with it all.


## Students should understand

* The goals, design decisions and practical operation of DNS
* How SMTP works and its similarity to HTTP
* How FTP works at a high level, and differences between it and SSH file transfers


## Students should be able to

* Parse and explain in detail all aspects of a DNS request
* Reason about DNS concepts such as TTLs and propagation, and authorities
* Implement a very simple SMTP client
* Reason about file transfer protocols


## General timeline

* Explain DNS in detail
* Wireshark DNS exercise
* Discuss SMTP
* Exercise: write a very simple SMTP client that e.g. can send an email from the command line
* Discuss FTP


### DNS (40 minutes)

* __Discuss: What is DNS?__
  * __What makes it desirable?__
  * __Is it solving a COMPUTER problem? Or a HUMAN problem?__
  * *You're asking the students: Why bother with hostnames at all...? Ultimately about usability.*
* DNS is a combination of a distributed hierarchical database and an application-layer protocol that allows hosts to query them. DNS servers typically run BIND.
  * __Instructor draw: example of local->TLD->authoritative tree (maybe just com and edu)__
    * __Pair/Share: Why do you suppose a hierarchical model was chosen?__
    * __Discuss: What might be the advantages/disadvantages to a P2P model of DNS instead of this centralized hierarchy?__
* Other services provided include host aliasing, mail server aliasing, load distribution
* DNS steps:
  * Typically, an application calls a C library function like `getaddrinfo`.
  * The library will use a UDP socket on port 53 to make a query to a local DNS server
  * The local DNS server will check its cache, and otherwise query a root DNS server, which will return the address of the TLD DNS server
  * The TLD DNS server will return the address of the authoritative DNS server (although this may be intermediate)
  * It's also possible to do the query recursively
  * __Everyone Draws: A diagram of the non-recursive and recursive versions of this query__
    * __Compare the drawings__
  * __Discuss: UDP relies on the IP Network layer... How do we know the IP address of the DNS server??__
    * *Configured by your ISP, in your modem/router*
* There are more or less four classes of DNS servers: root DNS servers, TLD servers, authoritative DNS servers and local DNS servers (book says 3 in the hierarchy)
  * *Root are centralized, local are from your ISP is a simple way to think about it*
* There are 13 root DNS servers... they are the first point of contact for a local DNS server that doesn't have a record in its cache
* The TLD servers are responsible for com, edu, country domains etc.
* Caching can happen for hostname -> ip address records, as well as of TLD servers etc.
* Resource records have four fields: name, value, type, TTL
* If type is A, name is a hostname and value is the IP address
* If type is NS, the name is a domain and value is the hostname of an authoritative DNS server
* It type is CNAME, then value is a canonical hostname for the alias hostname Name.
* Query and reply messages have the same structure, explore this with wireshark
* To add a new record, pay a registrar to update the NS records of a TLD server for you
* __Everyone Writes: Revisit your diagrams of DNS Queries -- add which types of records are being sent between all the DNS servers__
  * __How does the TTL field get used in these diagrams?__

#### DNS Exercises (10-15 minutes)

* Use nslookup to find the _ip address_ of a foreign web server
* Use nslookup to find the _DNS servers_ for a foreign university
* Use nslookup _with one of the returned DNS servers_ to look up another server yet.
* What's the round trip time to our DNS server? You may need to figure out how to determine our local DNS server (scutil --dns), and how long it takes to get there (ping)

Sample:
```
nslookup
> set type=ns
> sina.com
Server:		127.0.0.53
Address:	127.0.0.53#53

Non-authoritative answer:
sina.com	nameserver = ns2.sina.com.cn.
sina.com	nameserver = ns4.sina.com.
sina.com	nameserver = ns2.sina.com.
sina.com	nameserver = ns1.sina.com.cn.
sina.com	nameserver = ns4.sina.com.cn.
sina.com	nameserver = ns3.sina.com.cn.
sina.com	nameserver = ns1.sina.com.
sina.com	nameserver = ns3.sina.com.

Authoritative answers can be found from:
> set type=A
> ns2.sina.com.cn
Server:		127.0.0.53
Address:	127.0.0.53#53

Non-authoritative answer:
Name:	ns2.sina.com.cn
Address: 61.172.201.254
# Exit or other tab
ping 61.172.201.254

PING 61.172.201.254 (61.172.201.254) 56(84) bytes of data.
64 bytes from 61.172.201.254: icmp_seq=1 ttl=47 time=180 ms
64 bytes from 61.172.201.254: icmp_seq=2 ttl=47 time=163 ms
64 bytes from 61.172.201.254: icmp_seq=3 ttl=47 time=162 ms
```

__Discuss: So what was interesting about all that?__

### Email Description (20 min)

* A message starts at the sender's mail client, travels to the sender's mail server, then the recipient's mail server, from which the recipient's mail client receives it. It's confusing to use these terms, though, because the servers act as clients when initiating requests.
* Failures are negotiated between the two servers. If B can't receive, A retries for a while.
* SMTP is for transferring between two _mail servers_. IMAP (and previously POP3) deals with communication between the client and server.
* __Everyone Draws: Draw a diagram which includes all the component programs needed for 2 humans to communicate via SMTP, assuming they are using two separate mail servers__
  * *Everyone should draw 2 POP/IMAP clients, and 2 SMTP mail servers*
* Steps for SMTP:
  1. Alice uses her user agent, provides Bob's e-mail address, composes a message, and instructs the user agent to send the message
  2. Alice's user agent send the message to her mail server _where it is placed in a message queue_.
  3. A's server (running as a client) open a TCP connection to port 25 to the server running B's mail server
  4. After SMTP handshaking, A's server sends A's message to B's server
  5. B's server places the message in a "mailbox"
  6. Bob uses his client to read the message at some point
* SMTP is old, and has warts, e.g. the body of a mail message is restricted to 7-bit ASCII.

##### Email Exercise (20-30 minutes)

* __Using the diagrams you built, simulate the following situations by labeling as many steps as you can:__
  * __Alice sends Bob an email, and it arrives as expected__
  * __Alice sends Bob an email, but Bob's mail-server is offline__
  * __Alice sends Bob an email, but Alice's mail-server is offline__
* __Lets take it a step further... we all probably use Gmail these days right?__
  * __Gmail is a web application running in the context of an HTTP server...__
  * __Draw a new diagram where Alice and Bob are both using the Gmail web-app to manage their email__
  * __Where does the SMTP server probably live?__
  * __Simulate Alice sending Bob an email in this new situation, and include the HTTP requests and responses in the diagram__

#### Sample SMTP conversation

```
S: 220 hamburger.edu
C: HELO crepes.fr
S: 250 Hello crepes.fr, pleased to meet you
C: MAIL FROM: <alice@crepes.fr>
S: 250 alice@crepes.fr ... Sender ok
C: RCPT TO: <bob@hamburger.edu>
S: 250 bob@hamburger.edu ... Recipient ok
C: DATA
S: 354 Enter mail, end with “.” on a line by itself C: Do you like ketchup?
C: How about pickles?
C: .
S: 250 Message accepted for delivery
C: QUIT
S: 221 hamburger.edu closing connection
```

#### SMTP Exercise (20-30 minutes)

Get a simple SMTP server running locally, e.g. `gem install mailcatcher`. Use telnet to send emails to it.

1. Send an email to your own mailcatcher.
2. Send an email to someone else's mailcatcher on the local network.
3. Make sure you send messages with to, from, and subject.
4. Capture traffic on Wireshark
  * Is any data encrypted?
  * What transport protocol is telnet using to communicate with mailcatcher?
  * Why isn't any of the traffic labeled "smtp"?

### FTP (10 minutes)

* FTP also runs on TCP, but sends its control messages out of band in a "control connection" as opposed to a "data connection"
* The control connection is used to "change" the directory and request a file, for which a data connection is established and torn down
* __Everyone Draws: The data as it would flow through sockets during an FTP session where:__
  * The user changes directories at least once
  * The user sends a file data at least once
  * The user downloads a file at least once

## To Fill Out The Rest Of Class:

There are a number of things you may want to explore at this point. We are finishing our discussion of application layer technologies today, and any of these exercises might be interesting to different students. I suggest letting students explore what they are most curious about, but have them doing one of the following:

### Exercise: Wireshark DNS

> See PDF.

### Exercise: Write a DNS client

* work backwards: capture a DNS request
* analyze the request
* analyze the response
* write a request constructor fn
* write a response parser/reader
* write the client that sends the UDP packet and waits for a response

### Exercise: Write a SMTP client program

* Write a program that communicates with MailCatcher. Specifically, if your program is provided with a the to, from, status, and body fields, make sure your program feeds them properly to MailCatcher by following the rules of SMTP.
* MailCatcher uses TCP

### Exercise: Write a LRU Caching Proxy Server

* This can be done in just a few lines of code depending on how many libraries you're willing to use.
* Send requests for data through your proxy and see how much a cache can make a difference
* Bonus: Configure the server to respect the HTTP protocol's use of headers like Etag, Expires, Last-Modified, as well as 304 Not-Modified
* Bonus: Configure your browser to use your proxy running on localhost
* Bonus: Setup a second computer to run your proxy on the local network and send requests through it
* Bonus: Setup a webserver that uses Etag and Expires headers for a few resources, test your proxy server to see if it invalidates data, and properly checks for stale data!

### Exercise: Continue extending the PCAP parser

* Extend your pcap parser to work for more arbitrary captures, interesting extensions could include:
  * Detect and handle IPv6 vs IPv4
  * Detect HTTP content type and save messages with the proper file extension
  * Parse multiple HTTP messages sent in a single capture

### Looking Ahead Exercise:

> TCP & UDP wireshark labs, see pdfs for both.

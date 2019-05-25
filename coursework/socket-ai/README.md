# ABCL Simple Client Server

A simple echo server using ABCL sockets and threads with no additional dependencies. 

## Running
To run, you need to have JRE 1.8 installed and a copy of
Armed Bear Common Lisp (ABCL).

At the REPL prompt, 

  * (start-client) starts up a client which will try to connect to a
    local IP address and port.

  * (start-client-ai) starts up a client which will try to connect to a
    local IP address and port.  Will proceed to run ai-related functions.

  * (start-server) starts up a server which will listen to connections on a local
    port.

Optional parameters:

  * (define-address "hostname") Change the default hostname from localhost to
    something else for the client to connect to.

  * (define-port port\_numer) Change the default port for the server or client
    to use.

  * (toggle-debug) Enable/Disable trivial log messages.

## ABCL

abcl.jar needs to be added to your classpath.  I've included run.sh as a
convenience.

ABCL can be downloaded here: https://common-lisp.net/project/armedbear/

At the time of this writing, ABCL 1.5.0 was used.



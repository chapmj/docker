; MC-SOCKET.LISP --- https://github.com/chapmj
(format *standard-output* "~%This is Marc Chapman's socket program~%")

;;;
;;; Globals
;;; 

;Default IP address, port, and debug mode
(setq *listener-port* 9999)
(setq *server-address* "127.0.0.1")
(setq *debug-enabled* Nil)

;;;
;;; Utility
;;;

; Enable/disable debug
(defun toggle-debug ()
  (if *debug-enabled* 
    (setq *debug-enabled* Nil) 
    (setq *debug-enabled* t)))

; Setter: client and server port
(defun define-port (port-number)
  (setq *listener-port* port-number))

; Setter: server address
(defun define-address (address-string)
  (setq *server-address* address-string))

; user startup scripts
(defun start-server () (server))

(defun start-client () (client))

(defun start-client-ai () (client-ai))

;;;
;;; Server
;;;

;Spawns a thread and runs specified handler.
(defun make-worker (socket)
  (when *debug-enabled*
    (format *standard-output* "~%Create thread~%"))
  ;create a thread. make-thread only accepts higher order functions
  (threads:make-thread 
      (lambda () 
        (handle-connection socket))))

;Server side handler for client messages
(defun handle-connection (socket)
  (when *debug-enabled*
    (format *standard-output* "~%Handler started~%"))
  (let 
    ((result (read-line (ext:get-socket-stream socket))))
    (princ result *standard-output*)
    (force-output *standard-output*)))


;Create a table to store event messages received.
;TODO: figure out how to make access syncrhonized
(defparameter *agent-event-table* (make-hash-table))

;Open a socket to listen and spawn threads when client connections are made.
(defun server ()
  (loop 
    :with server-socket := (ext:make-server-socket *listener-port*)
    :for socket := (ext:socket-accept server-socket)
    :do (make-worker socket)))

;If an agent event is received, do this.  Agent events are prefixed as
;AGENT-EVENT.
;((EVENT-TYPE AGENT-EVENT) (AGENT-ID 01) (EXPRESSION CRY) (EVENT-UUID asdf-asdf-asdf-asdf))

(defun handle-agent-event event)
;when an agent-event is received randomly assign it to another agent to receive
;new message:


;;;
;;; Client
;;;

;Basic client, prompts user for manual server requests.
(defun client ()
  (loop 
    :for message-to-send := (ask-for-text *standard-input*)
    :do (send-data message-to-send)))

; Prompt user for input and return that input
(defun ask-for-text (stream-source)
  (format *standard-output* "~%send: ")
  (terpri)
  (read-line stream-source))

; Open a socket and send data to the stream assigned to that socket.
(defun send-data (payload)
  (let 
    ((socket (ext:make-socket *server-address* *listener-port*)))
    (let 
      ((stream-data (ext:get-socket-stream socket)))
      (princ payload stream-data) 
      (force-output stream-data)
      (ext:socket-close socket))))

;;;
;;; Dumb AI
;;;

; Not much going on here.  Sets a counter and sends xml to server.
(defun client-ai ()
  (setq counter 0)
  (setq message "")
  (loop 
    (sleep 10)
    (setq counter (+ counter 1))
    (setq message (format nil "<?xml version=\"1.0\" encoding=\"UTF-8\"?><transaction><msg>stuff</msg><counter>~A</counter></transaction>" counter))
    (send-data message)))

;;;
;;; AI with queue
;;; AI are defined like actors.  Receive puts messages in an inbox (fifo queue).
;;; Messages in inbox are processed.
;;; Topics:  pattern-match, update-personality, emit-emotion, process-sym-event
;;; For simplicity, AI only communicate to a server, which relays messages to
;;; other AI
;;; TODO: Define state variables
;;; Idea: Process state variables to emit "emotions".  These are not literally
;;; the state.

; Random thouhts, a model for arousal or disarousal.  Excitement vs apathy


; A socket to listen for messages
(defun make-worker-handler (socket, handlerFunc) ;this name sucks
  (when *debug-enabled*
    (format *standard-output* "~%Create thread~%"))
  ;create a thread. make-thread only accepts higher order functions
  (threads:make-thread 
      (lambda () 
        (handlerFunc socket))))

; A queue to store messages

; MC-SOCKET.LISP --- https://github.com/chapmj
(format *standard-output* "~%This is Marc Chapman's socket program~%")

;;; Package package imports
(format *standard-output* "~%Importing external dependencies...~%")
(load "queue.lisp")
(load "~/quicklisp/setup.lisp")
(use-package 'ql)
(quickload :optima)
(use-package 'optima)
(use-package 'threads)
(use-package 'ext)

;;; Network configuration
;Set IP address, port, and debug mode
(setq *listener-port* 9999)
(defun define-port (port-number)
  (setq *listener-port* port-number))

(setq *server-address* "127.0.0.1")
(defun define-address (address-string)
  (setq *server-address* address-string))

;;; Debugging 
; Enable/disable debug
(setq *debug-enabled* Nil)
(defun toggle-debug ()
  (setq *debug-enabled*
    (if *debug-enabled* Nil t)))

(defun dprint (msg)
  (when *debug-enabled* 
    (format *standard-output* "~%~A~%" msg)))

;;; User startup scripts
(defun start-server () (server))

(defun start-client () (client))

(defun start-client-ai () (client-ai))

;;;
;;; Server
;;;

;Agent events is a queue for agent events
;This is a concurrent functional queue that relys on agent-events-lock for
;shared access.  Multiple clients connect to server singleton and threads get
;spawned to read data.  This data is placed in the ae queue storage.
(defparameter *agent-events* (make-amortized-queue))
(defvar *agent-events-lock* (threads:make-thread-lock))

;Receives data and does an optima match to determine what do with it
(defun receive (msg)
  (match msg
    ((list :make-connection-handle socket) (make-worker #'handle-connection socket))
    ((list :agent-event script) ((do-stuff)))))

(defun tell (msg)
  (receieve msg))

;MAKE-WORKER Spawns a thread and runs specified handler.
;HANDLER function for to use to execute the worker thread
;SOCKET is a network socket that is created when a client connects to the server
(defun make-worker (handler socket)
  (dprint "Create thread")
  ;create a thread. make-thread only accepts higher order functions
  (make-thread 
    (lambda () 
      (handler socket))))

;Server side handler for client messages
(defun handle-connection (socket)
  (dprint "Handler started")
  (let 
    ((result 
      (read-line (get-socket-stream socket))))
    (match result 
      (princ result *standard-output*)
      (force-output *standard-output*)

    ;write event to queue
    (put-agent-event result)))

;Create a queue to store event messages received.
;TODO: figure out how to make access syncrhonized

(defun get-agent-event ()
  (with-thread-lock (*agent-events-lock*)
    (multiple-value-bind (ae returnval) 
      (amortized-dequeue *agent-events*) 
      (setq *agent-events* ae)
      returnval)))

(defun set-test()
  (multiple-value-bind (a b) (values 1 9) (setq *testint* b)))

(defun put-agent-event (val) 
  (with-thread-lock(*agent-events-lock*)
    (setf *agent-events* (amortized-enqueue *agent-events* val))))

(defun list-agent-events()
  (with-thread-lock(*agent-events-lock*)
    (amortized-queue-list *agent-events*)))

;;; MAIN-SERVER
;Open a socket to listen and spawn threads when client connections are made.
(defun server ()
  (loop 
    :with server-socket := (make-server-socket *listener-port*)
    :for socket := (socket-accept server-socket)
    :do ((tell '(:make-connection-handle socket))))

;If an agent event is received, do this.  Agent events are prefixed as
;AGENT-EVENT.
;  (:AGENT-EVENT 
;  (:AGENT-ID 01 
;  :EXPRESSION CRY 
;  :EVENT-UUID asdf-asdf-asdf-asdf))

;(defun handle-agent-event event)
;when an agent-event is received randomly assign it to another agent to receive
;new message:

;;;
;;; Test-Client-Interactive
;;; A client that connects to a socket and reads user input.

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
    ((socket (make-socket *server-address* *listener-port*)))
    (let 
      ((stream-data (get-socket-stream socket)))
      (princ payload stream-data) 
      (force-output stream-data)
      (socket-close socket))))

;;;
;;; Socket tester
;;;

; A basic client interface to test connection to server.
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
(defun make-worker-handler (socket handlerFunc) ;this name sucks
  (dprint "Create thread")
  ;create a thread. make-thread only accepts higher order functions
  (make-thread 
      (lambda () 
        (handlerFunc socket))))

; A queue to store messages

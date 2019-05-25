#!/bin/sh
abcl=`pwd`/abcl/abcl.jar
export JAVA_HOME=`/usr/libexec/java_home -v 1.8`
java -jar $abcl --load "mc-socket.lisp" 

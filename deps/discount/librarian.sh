#! /bin/sh
#
#  Build static libraries, hiding (some) ickiness from the makefile

ACTION=$1; shift
LIBRARY=$1; shift
VERSION=$1; shift

case "$ACTION" in
make)   /usr/bin/ar crv $LIBRARY.a "$@"
	/usr/bin/ranlib $LIBRARY.a
	rm -f $LIBRARY
	/bin/ln -s $LIBRARY.a $LIBRARY
	;;
files)  echo "${LIBRARY}.a"
	;;
install)/usr/bin/install -m 644 ${LIBRARY}.a $1
	;;
esac

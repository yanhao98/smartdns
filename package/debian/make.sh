#!/bin/sh
#
# Copyright (C) 2018-2025 Ruilin Peng (Nick) <pymumu@gmail.com>.
#
# smartdns is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# smartdns is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
CURR_DIR=$(cd $(dirname $0);pwd)
VER="`date +"1.%Y.%m.%d-%H%M"`"
SMARTDNS_DIR=$CURR_DIR/../../
SMARTDNS_CP=$SMARTDNS_DIR/package/copy-smartdns.sh
SMARTDNS_BIN=$SMARTDNS_DIR/src/smartdns
IS_BUILD_SMARTDNS_UI=0

showhelp()
{
	echo "Usage: make [OPTION]"
	echo "Options:"
	echo " -o               output directory."
	echo " --arch           archtecture."
	echo " --ver            version."
	echo " --with-ui        build with smartdns-ui plugin."
	echo " -h               show this message."
}

build()
{
	ROOT=/tmp/smartdns-deiban
	rm -fr $ROOT
	mkdir -p $ROOT
	cd $ROOT/

	cp $CURR_DIR/DEBIAN $ROOT/ -af
	CONTROL=$ROOT/DEBIAN/control
	mkdir $ROOT/usr/sbin -p
	mkdir $ROOT/etc/smartdns/ -p
	mkdir $ROOT/etc/default/ -p
	mkdir $ROOT/lib/systemd/system/ -p


	pkgver=$(echo ${VER}| sed 's/^1\.//g')
	sed -i "s/Version:.*/Version: ${pkgver}/" $ROOT/DEBIAN/control
	sed -i "s/Architecture:.*/Architecture: $ARCH/" $ROOT/DEBIAN/control
	chmod 0755 $ROOT/DEBIAN/prerm

	cp $SMARTDNS_DIR/etc/smartdns/smartdns.conf  $ROOT/etc/smartdns/
	cp $SMARTDNS_DIR/etc/default/smartdns  $ROOT/etc/default/
	cp $SMARTDNS_DIR/systemd/smartdns.service $ROOT/lib/systemd/system/ 

	if [ $IS_BUILD_SMARTDNS_UI -eq 1 ]; then
		mkdir $ROOT/usr/local/lib/smartdns -p
		mkdir $ROOT/usr/share/smartdns/wwwroot -p
		cp $SMARTDNS_DIR/plugin/smartdns-ui/target/smartdns_ui.so $ROOT/usr/local/lib/smartdns/smartdns_ui.so -a
		if [ $? -ne 0 ]; then
			echo "Failed to copy smartdns-ui plugin."
			return 1
		fi

		cp $WORKDIR/smartdns-webui/out/* $ROOT/usr/share/smartdns/wwwroot/ -a
		if [ $? -ne 0 ]; then
			echo "Failed to copy smartdns-ui plugin."
			return 1
		fi
	else
		echo "smartdns-ui plugin not found, skipping copy."
	fi

	$SMARTDNS_CP $ROOT
	if [ $? -ne 0 ]; then
		echo "copy smartdns file failed."
		return 1
	fi
	chmod +x $ROOT/usr/sbin/smartdns 2>/dev/null

	dpkg -b $ROOT $OUTPUTDIR/smartdns.$VER.$FILEARCH.deb

	rm -fr $ROOT/
}

main()
{
	OPTS=`getopt -o o:h --long arch:,ver:,with-ui,filearch: \
		-n  "" -- "$@"`

	if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1 ; fi

	# Note the quotes around `$TEMP': they are essential!
	eval set -- "$OPTS"

	while true; do
		case "$1" in
		--arch)
			ARCH="$2"
			shift 2;;
		--filearch)
			FILEARCH="$2"
			shift 2;;
		--with-ui)
			IS_BUILD_SMARTDNS_UI=1
			shift ;;
		--ver)
			VER="$2"
			shift 2;;
		-o )
			OUTPUTDIR="$2"
			shift 2;;
		-h | --help )
			showhelp
			return 0
			shift ;;
		-- ) shift; break ;;
		* ) break ;;
		esac
	done

	if [ -z "$ARCH" ]; then
		echo "please input arch."
		return 1;
	fi

	if [ -z "$FILEARCH" ]; then
		FILEARCH=$ARCH
	fi

	if [ -z "$OUTPUTDIR" ]; then
		OUTPUTDIR=$CURR_DIR;
	fi

	build
}

main $@
exit $?

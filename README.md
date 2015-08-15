check_graylog2_stream.sh
========================

check_graylog2_stream is a check script for nagios that verifies graylog2 streams.

The script checks for the last-alarm time of the specified stream and:

1. If the time is within the specified age (sec), a CRITICAL alarm is raised, otherwise OK.

2. By using the inversion option (-i), if the time is within the specified age (sec), an OK status is returned, otherwise a CRITICAL alarm is triggered.


Usage:

	./check_graylog2_stream.sh -g <graylog server url> -k <graylog api_key> -t <alarm age> -s <stream name> [-i]

Options:

	-i , --INVERT
   	 inverts exit code interpretation (default: OFF)

Examples:

	1. INVERT=OFF (default) --> will return CRITICAL if alarm is ON for more than 300 seconds :

	./check_graylog2_stream.sh -g http://graylog2.mycorp.com -k da1c06b0e21ffd5cb52bb6e4230fb3439f6b99e8 -t 300 -s My-Stream-Name

	2. INVERT=ON (-i) --> will return CRITICAL if alarm is OFF for more than 300 seconds:

	./check_graylog2_stream.sh -i -g http://graylog2.mycorp.com -k da1c06b0e21ffd5cb52bb6e4230fb3439f6b99e8 -t 300 -s My-Stream-Name

	3. If graylog behind https use -c opt:

	./check_graylog2_stream.sh -i -g https://graylog2.mycorp.com -k da1c06b0e21ffd5cb52bb6e4230fb3439f6b99e8 -t 300 -s My-Stream-Name -c

Requirements:
	The check_graylog2_stream script uses jshon command line that further requires jansson .

Installation:

	* Download and install jansson-2.4
		cd /usr/local/src
		wget http://www.digip.org/jansson/releases/jansson-2.4.tar.gz
		tar zxvf jansson-2.4.tar.gz
		cd jansson-2.4
		./configure
		make
		make install

	* Download and install jshon
		cd /usr/local/src/
		wget http://kmkeen.com/jshon/jshon.tar.gz
		tar zxvf jshon.tar.gz
		cd jshon-20120914
		make
		cp jshon /bin/

	* Update libs
		cd /usr/local/lib
		ln -s /usr/local/lib/libjansson.so.4 /usr/lib/libjansson.so.4
		ldconfig

	* For debian users
		Install libjansson-dev by aptitude/apt-get and download and install jshon. Thats all.

License
-------

See the [LICENSE](LICENSE.md) file for license rights and limitations.

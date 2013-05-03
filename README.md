--------- License Info ---------
Copyright 2013 Emind Systems Ltd - htttp://www.emind.co
This file is part of Emind Systems DevOps Tool set.
Emind Systems DevOps Tool set is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
Emind Systems DevOps Tool set is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
You should have received a copy of the GNU General Public License along with Emind Systems DevOps Tool set. If not, see http://www.gnu.org/licenses/.
--------------------------------

check_graylog_stream is a check script for nagios that check graylog2 streams.
The script checks for the last-alarm time of the specified stream, if the time is within the specified age (sec), a CRITICAL alarm is raised, otherwise OK.

Input paramets:
-g <graylog server url>
-k <graylog api_key>
-t <alarm age (sec)>
-s <stream name>

Usage:
	./check_graylog_stream.sh -g <graylog server url> -k <graylog api_key> -t <alarm age> -s <stream name>

Example:
	./check_graylog_stream.sh -g http://graylog2.mycorp.com -k da1c06b0e21ffd5cb52bb6e4230fb3439f6b99e8 -t 300 -s My-Stream-Name

Requirements:
	check_graylog2 script use jshon command line that require the jansson

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
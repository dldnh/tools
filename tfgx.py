#!/usr/bin/env python

# tfgx = Tail -F and Grep then eXit

# Copyright (c) 2020 Dave Diamond (at dldnh.com)

# This script is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

import sys
import time
import re
import os
import signal

def handle_sigint(s, f):
    print ''
    sys.exit(0)

signal.signal(signal.SIGINT, handle_sigint)

def handle_sigalrm(s, f):
    print '*** Timeout ***'
    sys.exit(1)

signal.signal(signal.SIGALRM, handle_sigalrm)

if len(sys.argv) < 2:
    print 'No args'
    exit(1)

delay = 5

while sys.argv[1][0] == '-':
    opt = sys.argv[1][1:]
    sys.argv = sys.argv[:1] + sys.argv[2:]
    if opt == 'd':
        delay = int(sys.argv[1])
        sys.argv = sys.argv[:1] + sys.argv[2:]
    if opt == 't':
        timeout = int(sys.argv[1])
        signal.alarm(timeout)
        sys.argv = sys.argv[:1] + sys.argv[2:]
    else:
        print 'Illegal option', opt
        exit(1)

if len(sys.argv) > 3:
    print 'Too many args'
    exit(1)

if len(sys.argv) == 2:
    grep = sys.argv[1]
    tail = '/dev/stdin'

elif len(sys.argv) == 3:
    grep = sys.argv[1]
    tail = sys.argv[2]

prog = re.compile('.*' + grep + '.*', re.IGNORECASE)

f = open(tail, 'r')

pos = 0

while True:
    if tail != '/dev/stdin':
        flen = os.stat(tail).st_size
        if flen < f.tell():
            print '*** file truncated ***'
            f.seek(flen)
    line = f.readline()
    if line == '':
        time.sleep(delay)
        continue
    trim = line.rstrip()
    print trim
    if prog.match(trim):
        break

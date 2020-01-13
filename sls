#!/bin/bash

# Copyright (c) 2011 Dave Diamond (at dldnh.com)

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

usage() {
  echo "usage: sls [ls-option]... user@host[:file]..."
  if [[ $# -gt 0 && "${1:0:1}" != "-" ]] ; then echo $* ; fi
  if [ "${1}" != "-nodie" ] ; then exit ; fi
}

help() {
  usage -nodie
  cat <<EOF

sls is a magical combination of ssh and ls. Simply give the sls
command some (or no) ls options and one or more remote locations and
you'll get a listing for each. The remote spec is the same
user@host:file specification you would use with the scp command, and
the file part is optional. 
EOF
  exit
}

if [ $# -eq 0 ] ; then
  usage "no files specified"
fi

if [[ "${1}" == "-help" || "${1}" == "--help" || "${1}" == "-?" ]] ; then
  help
fi

opts=
n=0

while [ $# -gt 0 ] ; do
  if [ "${1:0:1}" == "-" ] ; then
    if [ ${n} -gt 0 ] ; then
      usage "options before files"
    fi
    opts="${opts} ${1}"
    shift
  else
    file[${n}]="${1}"
    n=$((n+1))
    shift
  fi
done

if [ $n -eq 0 ] ; then
  usage "no files specified"
fi

for ((i=0; i<n; i++)) ; do
  cmd[$i]=`echo ${file[$i]} | sed -e '/^[^@:]*$/ d; /^[^:@]*@[^:]*$/ s/\(.*\)/ssh \1 '"'ls ${opts}'"'/; /^.*:.*$/ s/\(.*\):\(.*\)/ssh \1 '"'ls ${opts} \2'"'/'`
  if [ "${cmd[$i]}" == "" ] ; then
    usage "unrecognized user@host[:file] format"
  fi
done

for ((i=0; i<n; i++)) ; do
  echo "${cmd[$i]}"
  bash -c "${cmd[$i]}"
done

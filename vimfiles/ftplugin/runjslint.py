#!/usr/bin/env python
from subprocess import Popen

output = Popen(['node', 'jslint/runjslint.js'], stdin=open(sys.argv[1]), stdout=PIPE).communicate()[0]

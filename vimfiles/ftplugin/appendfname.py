#!/usr/bin/env python
import sys

fname = sys.argv[1]
for line in sys.stdin:
    print '%s:%s' % (fname, line),

#!/usr/bin/python
# -*- coding: utf-8 -*-

import sys, os, re
from psd_tools import PSDImage

if sys.argv[1] and os.path.isfile(sys.argv[1]):
    psd = PSDImage.load(sys.argv[1])
    for layer in psd.layers:
        if layer.visible:
            if re.search(ur"^[-a-z0-9_]+$", layer.name, re.MULTILINE) is not None and layer.name not in [u'white', u'black']:
                width = layer.bbox.width
                height = layer.bbox.height
                x = layer.bbox.x1
                y = layer.bbox.y1
                print "." + layer.name + " { \n    width: " + str(width) + "px;\n    height: " + str(height) + "px;\n    background-position: " + (str(-x) + 'px' if x else str(x)) + " " + (str(-y) + 'px' if y else str(y)) + ";\n}\n"
        # if layer.name in [u'white', u'black']:
        #     layer.opacity = 0
    # if sys.argv[2]:
    #     icon = psd.as_PIL()
    #     icon.save(sys.argv[2])

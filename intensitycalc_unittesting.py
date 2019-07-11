#!/usr/bin/env python3
# -*- coding: utf-8 -*-

#unit testing for peakdetect_RI.py

import unittest
from intensitycalc import read_csv_from_folder, xvalues_for_continuous_curve
import os
import pandas as pd

class TestReadCsvFromFolder(unittest.TestCase):
    #test correct delimiter -> is imaga_data.shape 1 or 2?
    def test_determine_delimiter_effect(self):
        self.assertEqual(read_csv_from_folder(0).shape[1], 2) #second position (1) should be ==2


        
        
if __name__ == '__main__':
    unittest.main()
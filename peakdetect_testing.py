#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Jan 14 15:08:56 2019

@author: riselAir
"""

#unit testing for peakdetect_RI.py

import unittest
from peakfunctions import second_largest, fit_gaussian_to_rawdata

class TestSecondLargest(unittest.TestCase):
    
    def test_identifying_second_highest_peak(self):
        self.assertEqual(second_largest(numbers = [1,1,1,3,5,3,3,6,3,3,2]), 5)
    def test_fitting_to_standardistribution(self):
        self.assertEqual()
        
if __name__ == '__main__':
    unittest.main()
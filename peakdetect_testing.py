#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Jan 14 15:08:56 2019

@author: riselAir
"""

#unit testing for peakdetect_RI.py

import unittest
import math
from scipy.stats import norm
from peakfunctions import second_largest, fit_gaussian_to_rawdata

class TestSecondLargest(unittest.TestCase):
    
    def test_identifying_second_highest_peak(self):
        self.assertEqual(second_largest(numbers = [1,1,1,3,5,3,3,6,3,3,2]), 5)
    def test_fitting_to_standardistribution(self):
        self.assertEqual()
        
class TestGaussFit(unittest.TestCase):
    
    def test_gaussfit_for_analytic_reference(self):
        major_mean = 7.
        minor_mean = 3.
        major_sd = 0.5
        minor_sd = 0.1
        scale_factor = .3
        def intensity(x): 
            norm.pdf(x, major_mean, major_sd)+scale_factor*norm.pdf(x, minor_mean, minor_sd)
        offset = intensity(minor_mean)
        def inverse_pdf_sqrt(y, sigma):
            math.sqrt(-2*sigma**2 * math.log(y*sigma*math.sqrt(2*math.pi))) #tau+/- = mu +/- sqrt(-2sigma**2 * log(y*sigma*sqrt(2*pi)))
        reference_area = norm.cdf(inverse_pdf_sqrt(offset, major_sd)/major_sd) - norm.cdf(-inverse_pdf_sqrt(offset, major_sd)/major_sd)
        
        
if __name__ == '__main__':
    unittest.main()
    
    
#refactor my gaussfit as function!
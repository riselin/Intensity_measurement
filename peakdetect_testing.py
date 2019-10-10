#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Jan 14 15:08:56 2019

@author: riselAir
"""

#unit testing for peakdetect_RI.py

import unittest
import math
import numpy as np
from scipy.stats import norm
from peakfunctions import second_largest, fit_gaussian_to_shifted_data, xvalues_for_continuous_curve

class TestSecondLargest(unittest.TestCase):
    
    def test_identifying_second_highest_number(self):
        self.assertEqual(second_largest(numbers = [1,1,1,3,5,3,3,6,3,3,2]), 5)
        
    def test_function_should_identify_if_none(self):
        abort_result_one = second_largest(numbers = [1])
        abort_result_empty = second_largest(numbers = [])
        self.assertEqual(abort_result_one, abort_result_empty, None)
        
class TestFunctionBolstering(unittest.TestCase):
    
    def test_stretching_x_values(self):
        x=np.array([1.,2.])
        known_range = np.array(range(1*1000,2*1000,1))/1000
        calculated_range = xvalues_for_continuous_curve(x)
        comparison = (calculated_range == known_range)
        self.assertEqual(sum(comparison), 1000)
        

class TestGaussFit(unittest.TestCase):
    """ This test takes two peaks, correctly cuts off at the lower one,
    and calculates the area of the remaining curve. It does NOT calculate the area of the FWHM.
    It tests my gaussfit.
    Also, check cdf loc scale for scipy. Can also do fits. Hmm"""
        
    def test_passes_if_all_values_larger_than_minor_mean(self):
        major_mean = 7.
        minor_mean = 3.
        major_sd = 0.5
        minor_sd = 0.1
        scale_factor = .03
        def intensity(x): 
            return norm.pdf(x, major_mean, major_sd) + scale_factor * norm.pdf(x, minor_mean, minor_sd)
        offset = intensity(minor_mean)
        
    def test_fwhm_fixpoints(self):
        pass
    
    def test_gaussfit_for_analytic_reference_of_area_caclulation(self):
        major_mean = 7.
        minor_mean = 3.
        major_sd = 0.5
        minor_sd = 0.1
        scale_factor = .03
        def intensity(x): 
            return norm.pdf(x, major_mean, major_sd) + scale_factor * norm.pdf(x, minor_mean, minor_sd)
        offset = intensity(minor_mean)
        def inverse_pdf_sqrt(y, sigma):
            return math.sqrt(-2 * sigma ** 2 * math.log(y * sigma * math.sqrt(2 * math.pi))) #tau+/- = mu +/- sqrt(-2sigma**2 * log(y*sigma*sqrt(2*pi)))
        reference_area = norm.cdf(inverse_pdf_sqrt(offset, major_sd)/major_sd) - norm.cdf(-inverse_pdf_sqrt(offset, major_sd)/major_sd)
        self.assertEqual(reference_area, 0.94857078334750633)
        
        
if __name__ == '__main__':
    unittest.main()
    
    
#refactor my gaussfit as function!
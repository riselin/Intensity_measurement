#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Jan 14 15:52:43 2019

@author: riselAir
"""
import numpy as np
from scipy.special import binom


def second_largest(numbers): #found online, link unavailable
    """ return the second highest number of a list"""
    count = 0
    m1 = m2 = float('-inf')
    for x in numbers:
        count += 1
        if x > m2:
            if x >= m1:
                m1, m2 = x, m1
            else:
                m2 = x
    return m2 if count >= 2 else None

    
def fit_gaussian_to_shifted_data(x_cut, y_cut):
    function_mean = sum(x_cut * y_cut) / sum(y_cut)
    sigma = np.sqrt(sum(y_cut * (x_cut - function_mean) ** 2) / sum(y_cut))
    p0 = [max(y_cut), function_mean, sigma] #rename p0
    return p0

def identify_single_peak(second_peak):
    if second_peak is None:
        return True
    
def xvalues_for_continuous_curve(x):
    x = x*1000 #remove floats
    x_continuous_curve = np.array(range(int(min(x)), int(max(x)), 1))
    x_continuous_curve = x_continuous_curve/1000
    x = x/1000 #return floats
    return x_continuous_curve

def fwhm_point_identifier(x_cont, y_cont, hm):
    y_peak_index = np.where(y_cont == max(y_cont))[0][0] #index of value of peak
    y_smaller_peak = y_cont[0:y_peak_index] # all y values left of peak
    y_larger_peak = y_cont[y_peak_index:] # all y values right of peak
    y_left = y_smaller_peak[np.where(y_smaller_peak == min(y_smaller_peak, key=lambda x:abs(x-hm)))[0][0]] #closest y_value to calculated intersection, left
    y_right = y_larger_peak[np.where(y_larger_peak == min(y_larger_peak, key=lambda x:abs(x-hm)))[0][0]]#closest y_value to calculated intersection, right
    x_smaller_peak= x_cont[np.where(y_cont == y_left)[0][0]] #x_value of left fwhm intersection
    x_larger_peak= x_cont[np.where(y_cont == y_right)[0][0]]#x_value of right fwhm intersection
    fy = y_cont[np.where(y_cont == y_left)[0][0]:np.where(y_cont == y_right)[0][0]]
    fx = x_cont[np.where(y_cont == y_left)[0][0]:np.where(y_cont == y_right)[0][0]]
    return fx, fy, x_smaller_peak, x_larger_peak

"""#fit to mu = 0 and sigma^2 = 0.2 or 1
# e.g. binomial with 32points
y_cut=[]
x_cut = []
for number in (range(0,9)):
    y_cut.append((binom(8,number)))
x_cut.extend(range(0,9)) """


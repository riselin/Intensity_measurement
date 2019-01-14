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

    
def fit_gaussian_to_rawdata(x_cut, y_cut):
    function_mean = sum(x_cut * y_cut) / sum(y_cut)
    sigma = np.sqrt(sum(y_cut * (x_cut - function_mean) ** 2) / sum(y_cut))
    p0 = [max(y_cut), function_mean, sigma]
    return p0

def identify_single_peak(second_peak):
    if second_peak is None:
        return True

#fit to mu = 0 and sigma^2 = 0.2 or 1
# e.g. binomial with 32points
y_cut=[]
x_cut = []
for number in (range(0,9)):
    y_cut.append((binom(8,number)))
x_cut.extend(range(0,9))


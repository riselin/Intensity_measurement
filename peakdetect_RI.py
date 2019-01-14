#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Oct 11 18:13:11 2018

@author: riselAir


"""

from scipy.optimize import curve_fit
import pylab
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from peakdetect_bergmann import peakdetect as peakbg
from scipy.integrate import simps
import os
import csv

data_output = []






for i in range(0, len(os.listdir('./csv/'))):
    filename = os.listdir('./csv/')[i]
    filepath = ('./csv/' + filename)
    data = pd.read_csv(filepath, delimiter = ";")
    x = data.X
    y = data.Y
    
    def second_largest(numbers):
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
    
    #*************#
    # DETECT PEAK #
    #*************#
    _max, _min = peakbg(y, x, lookahead = 1, delta = 0) #lookahead 1,2,3,4 ok. Difference?
    
    #****************#
    # CUT BACKGROUND #
    #****************#
    secondary_y = second_largest([p[1] for p in _max])
    if secondary_y is None:
        print(filename, " has only one peak, abort") #append filename somewhere
        continue
    y_cut_ini = y - secondary_y #subtract background from all y
    x_cut = []
    y_cut = []
    for i in range(len(y_cut_ini)):
        if y_cut_ini[i] >0:
            y_cut = np.append(y_cut, y_cut_ini[i])
            x_cut = np.append(x_cut, x[i])
    
    
    #**************#
    # FIT GAUSSIAN #
    #**************#
    # The Gaussian is fit onto the cut curve, not the whole. This makes fitting easier
    # and more likely due to a single peak.
    # weighted arithmetic mean
    mean_f = sum(x_cut * y_cut) / sum(y_cut)
    sigma = np.sqrt(sum(y_cut * (x_cut - mean_f)**2) / sum(y_cut))
    
    c = min(y_cut)
    def Gauss(x_cut, a, x0, s):
        return a * np.exp(-(x_cut - x0)**2 / (2 * s**2))+c # a should be 1/sqrt(2*pi*sigma**2)?
    
    p0 = [max(y_cut), mean_f, sigma]
    
    try:
        popt,pcov = curve_fit(Gauss, x_cut, y_cut, p0) #is this a, x0, sigma? yes!
    except (RuntimeError, TypeError):
        print("Runtime or Type Error, most likely due to a bad measurement in ", filename)
        continue
    
    #**************************#
    # Make continuous function #
    #**************************#
    x_f = np.array(range(int(min(x_cut)), int(max(x_cut)), 1))
    y_f = Gauss(x_f, *popt) #apply function to these x-values
    
    
    #******#
    # FWHM #
    #******#
    #calculate exact half max, and later find closest point to this value
    hm = max(y_f)/2 #because I moved the scale down, so now 0 really is the actual baseline
    
    
    #find points closest to full width half max on function
    y_peak_index = np.where(y_f == max(y_f))[0][0] #index of value of peak
    y_f_left = y_f[0:y_peak_index] # all y values left of peak
    y_f_right = y_f[y_peak_index:] # all y values right of peak
    y_left = y_f_left[np.where(y_f_left == min(y_f_left, key=lambda x:abs(x-hm)))[0][0]] #closest y_value to calculated intersection, left
    y_right = y_f_right[np.where(y_f_right == min(y_f_right, key=lambda x:abs(x-hm)))[0][0]]#closest y_value to calculated intersection, right
    
    x_f_left= x_f[np.where(y_f == y_left)[0][0]] #x_value of left fwhm intersection
    x_f_right= x_f[np.where(y_f == y_right)[0][0]]#x_value of right fwhm intersection
    y_fwhm = y_f[np.where(y_f == y_left)[0][0]:np.where(y_f == y_right)[0][0]]
    x_fwhm = x_f[np.where(y_f == y_left)[0][0]:np.where(y_f == y_right)[0][0]]
    
    #****************#
    # INTEGRATE AREA #
    #****************#
    total_area = simps(y_fwhm, x_fwhm)
    square_area = (x_f_right-x_f_left)*hm
    actual_area = total_area - square_area
    
    #***********#
    # SAVE AREA #
    #***********#
    data_output.append([filename, actual_area])

    #******#
    # PLOT #
    #******#
    plt.plot(x,y)
    plt.plot(x_f, y_f) #plot to illustrate where y_f is
    plt.plot(x_cut, y_cut, 'b+:', label='data')
    plt.plot(x_cut, Gauss(x_cut, *popt), 'r-', label='fit')
    plt.axhline(y = hm) #plot half max line
    plt.axvline(x = x_f_left)
    plt.axvline(x = x_f_right)
    plt.title(filename)
    plt.xlabel('x coordinate')
    plt.ylabel('intensity (A.U.)')
    imagename = './png/' + filename + '.png'
    pylab.savefig(imagename, bbox_inches='tight')
    #plt.show()
    plt.pause(0.25)
    plt.close()

with open('./csv/data_output.csv', "w", newline='') as csv_file:
        writer = csv.writer(csv_file, delimiter=',')
        for line in data_output:
            writer.writerow(line)

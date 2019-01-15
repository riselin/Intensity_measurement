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

def second_largest(numbers): #found online, link unavailable
    """return the second highest number of a list"""
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

def identify_single_peak(second_peak):
    if second_peak is None:
        return True
    
def Gauss(x, a, x0, s):
        return a * np.exp(-(x - x0) ** 2 / (2 * s ** 2)) + c # scipy.stats.norm

    
def fit_gaussian_to_rawdata(x_cut, y_cut):
    function_mean = sum(x_cut * y_cut) / sum(y_cut)
    sigma = np.sqrt(sum(y_cut * (x_cut - function_mean) ** 2) / sum(y_cut))
    p0 = [max(y_cut), function_mean, sigma]
    return p0


for file in range(0, len(os.listdir('./csv/'))): #0 not necessary because standard anyway?
    filename = os.listdir('./csv/')[file]
    filepath = ('./csv/' + filename)
    image_data = pd.read_csv(filepath, delimiter = ";")
    raw_positon_values = image_data.X
    raw_intensity_greyvalues = image_data.Y
    
    
    #*************#
    # DETECT PEAK #
    #*************#
    _max, _min = peakbg(raw_intensity_greyvalues, raw_positon_values, lookahead = 1, delta = 0) #lookahead 1,2,3,4 ok. Difference?
    #unittest this
    
    #****************#
    # CUT BACKGROUND #
    #****************#
    second_peak = second_largest([p[1] for p in _max])
    if identify_single_peak:
        print(filename, "has only one peak, skip to next iteration")
        continue
    difference_raw_intensity_second_peak = raw_intensity_greyvalues - second_peak #subtract background from all raw_intensity_greyvalues
    postions_intensity_above_cut = []
    intensities_intensity_above_cut = []
    for position in range(len(difference_raw_intensity_second_peak)):
        if difference_raw_intensity_second_peak[position] > 0:
            intensities_intensity_above_cut = np.append(intensities_intensity_above_cut, difference_raw_intensity_second_peak[position])
            postions_intensity_above_cut = np.append(postions_intensity_above_cut, raw_positon_values[position])

#function, make more readable
            
            
            
    #**************#
    # FIT GAUSSIAN #
    #**************#
    # The Gaussian is fit onto the cut curve, not the whole. This makes fitting easier
    # and more likely due to a single peak.
    # weighted arithmetic mean
    p0 = fit_gaussian_to_rawdata(postions_intensity_above_cut, intensities_intensity_above_cut)
    c = min(intensities_intensity_above_cut)
    try:
        popt,pcov = curve_fit(Gauss, postions_intensity_above_cut, intensities_intensity_above_cut, p0) #is this a, x0, sigma? yes!
    except (RuntimeError, TypeError):
        print("Runtime or Type Error, likely due to a bad measurement in ", filename)
        continue
    
    #************************************#
    # Get values for continuous function #
    #************************************#
    x_continuous_function = np.array(range(int(min(postions_intensity_above_cut)), int(max(postions_intensity_above_cut)), 1))
    y_continuous_function = Gauss(x_continuous_function, *popt)
    
    
    #******#
    # FWHM #
    #******#
    hm = max(y_continuous_function)/2 #because I moved the scale down, so now 0 really is the actual baseline
    
    #find points closest to full width half max on function
    y_peak_index = np.where(y_continuous_function == max(y_continuous_function))[0][0] #index of value of peak
    y_f_left_of_peak = y_continuous_function[0:y_peak_index] # all y values left of peak
    y_f_right_of_peak = y_continuous_function[y_peak_index:] # all y values right of peak
    y_left = y_f_left_of_peak[np.where(y_f_left_of_peak == min(y_f_left_of_peak, key=lambda x:abs(x-hm)))[0][0]] #closest y_value to calculated intersection, left
    y_right = y_f_right_of_peak[np.where(y_f_right_of_peak == min(y_f_right_of_peak, key=lambda x:abs(x-hm)))[0][0]]#closest y_value to calculated intersection, right
    
    x_f_left_of_peak= x_continuous_function[np.where(y_continuous_function == y_left)[0][0]] #x_value of left fwhm intersection
    x_f_right_of_peak= x_continuous_function[np.where(y_continuous_function == y_right)[0][0]]#x_value of right fwhm intersection
    y_fwhm = y_continuous_function[np.where(y_continuous_function == y_left)[0][0]:np.where(y_continuous_function == y_right)[0][0]]
    x_fwhm = x_continuous_function[np.where(y_continuous_function == y_left)[0][0]:np.where(y_continuous_function == y_right)[0][0]]
    
    #****************#
    # INTEGRATE AREA #
    #****************#
    total_area = simps(y_fwhm, x_fwhm)
    square_area = (x_f_right_of_peak - x_f_left_of_peak)*hm
    peak_area_above_fwhm = total_area - square_area
    
    #***********#
    # SAVE AREA #
    #***********#
    data_output.append([filename, peak_area_above_fwhm])

    #******#
    # PLOT #
    #******#
    plt.plot(raw_positon_values, raw_intensity_greyvalues)
    plt.plot(x_continuous_function, y_continuous_function) #plot to illustrate where y_continuous_function is
    plt.plot(postions_intensity_above_cut, intensities_intensity_above_cut, 'b+:', label='data')
    plt.plot(postions_intensity_above_cut, Gauss(postions_intensity_above_cut, *popt), 'r-', label='fit')
    plt.axhline(y = hm) #plot half max line
    plt.axvline(x = x_f_left_of_peak)
    plt.axvline(x = x_f_right_of_peak)
    plt.title(filename)
    plt.xlabel('x coordinate')
    plt.ylabel('intensity (A.U.)')
    imagename = './png/' + filename + '.png'
    pylab.savefig(imagename, bbox_inches='tight')
    #plt.show()
    plt.pause(0.25) #allows user to check plots in realtime
    plt.close()

with open('./csv/data_output.csv', "w", newline='') as csv_file:
        writer = csv.writer(csv_file, delimiter=',')
        for line in data_output:
            writer.writerow(line)
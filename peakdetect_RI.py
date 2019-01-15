#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Oct 11 18:13:11 2018

@author: riselAir


#add license of some sort

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

#split program into three parts: open file, compute, close&save file, plot if necessary (plot with method)

POSITIONINCREMENT = 0.128

def second_largest(numbers): #found online, link unavailable
    """Return the second highest number of a list, or None if just one exists."""
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

def identified_single_peak(second_peak):
    if second_peak is None:
        return True
    
def cut_background(raw_intensity, second, increment):
    """ Take intensity values and second peak, shift values down by second peak"""
    difference_raw_intensity_second_peak = (raw_intensity - second).values
    positions, = np.where(difference_raw_intensity_second_peak > 0)
    positions_intensity_above_cut = positions*increment #get indices of desired values -> equivalent to positions if multiplied by 0.128?
    intensities_intensity_above_cut = difference_raw_intensity_second_peak[difference_raw_intensity_second_peak > 0]
    return positions_intensity_above_cut, intensities_intensity_above_cut
    
def fit_gaussian_to_shifted_data(x_cut, y_cut):
    function_mean = sum(x_cut * y_cut) / sum(y_cut)
    sigma = np.sqrt(sum(y_cut * (x_cut - function_mean) ** 2) / sum(y_cut))
    p0 = [max(y_cut), function_mean, sigma] #rename p0
    return p0

def Gauss(x, a, x0, s, c):
        return a * np.exp(-(x - x0) ** 2 / (2 * s ** 2)) + c # scipy.stats.norm

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

def fit_gaussian():
    pass

def calculate_area(x, opt): #calls two other functions
    x_continuous_function = xvalues_for_continuous_curve(x)
    y_continuous_function = Gauss(x_continuous_function, opt)
    hm = max(y_continuous_function)/2 #needed globally, output!
    x_curve, y_curve, x_left, x_right = fwhm_point_identifier(x_continuous_function, y_continuous_function, hm)
    total_area = simps(y_curve, x_curve)
    square_area = (x_right - x_left)*hm
    peak_area_above_fwhm = total_area - square_area
    return hm, peak_area_above_fwhm, x_left, x_right, x_continuous_function, y_continuous_function

for file in range(0, len(os.listdir('./csv/'))):
    filename = os.listdir('./csv/')[file]
    filepath = ('./csv/' + filename)
    image_data = pd.read_csv(filepath, delimiter = ";", encoding="utf-8-sig")
    raw_positon_values = image_data.X #pandas series object
    raw_intensity_greyvalues = image_data.Y #pandas series object

########## START COMPUTE 
    
    #*************#
    # DETECT PEAK #
    #*************#
    _max, _min = peakbg(raw_intensity_greyvalues, raw_positon_values, lookahead = 2, delta = 0)
    
    #****************#
    # CUT BACKGROUND #
    #****************#
    second_peak = second_largest([p[1] for p in _max])
    if identified_single_peak(second_peak):
        print(filename, "has only one peak, skip to next iteration")
        continue
    positions_intensity_above_cut, intensities_intensity_above_cut = cut_background(raw_intensity_greyvalues, second_peak, POSITIONINCREMENT)

    #**************#
    # FIT GAUSSIAN #
    #**************#
    # The Gaussian is fit onto the cut curve, not the whole. This makes fitting easier
    # and more likely due to a single peak.
    # weighted arithmetic mean
    gaussfit_values = fit_gaussian_to_shifted_data(positions_intensity_above_cut, intensities_intensity_above_cut) #rename
    c = min(intensities_intensity_above_cut)
    
    try:
        popt,pcov = curve_fit(Gauss, positions_intensity_above_cut, intensities_intensity_above_cut, gaussfit_values) #is this a, x0, sigma? yes!
    except (RuntimeError, TypeError):
        print("Runtime or Type Error, likely due to a bad measurement in ", filename)
        continue
    
    #too much output for a single function?
    hm, area, x_left, x_right, x_continuous_function, y_continuous_function = calculate_area(positions_intensity_above_cut, *popt)

########## END COMPUTE

    #******#
    # PLOT #
    #******#
    plt.plot(raw_positon_values, raw_intensity_greyvalues)
    plt.plot(x_continuous_function, y_continuous_function) #plot to illustrate where y_continuous_function is
    plt.plot(positions_intensity_above_cut, intensities_intensity_above_cut, 'b+:', label='data')
    plt.plot(positions_intensity_above_cut, Gauss(positions_intensity_above_cut, *popt), 'r-', label='fit')
    plt.axhline(y = hm) #plot half max line
    plt.axvline(x = x_left)
    plt.axvline(x = x_right)
    plt.title(filename)
    plt.xlabel('x coordinate')
    plt.ylabel('intensity (A.U.)')
    imagename = './png/' + filename + '.png'
    pylab.savefig(imagename, bbox_inches='tight')
    #plt.show()
    plt.pause(0.25) #allows user to check plots in realtime
    plt.close()
    
    #***********#
    # SAVE AREA #
    #***********#
    data_output.append([filename, area])

with open('./csv/data_output.csv', "w", newline='') as csv_file:
        writer = csv.writer(csv_file, delimiter=',')
        for line in data_output:
            writer.writerow(line)
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
@author: riselAir
#add license of some sort
problem march 2019: due to the abs(x-hm) on line 75 and the effect on post comma values, all end up being the same
No, the real problem is that Gauss() results in identical values. Why?
July 2019: add chisq test?
"""

import os
import csv
from scipy.optimize import curve_fit
import pylab
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from peakdetect_bergmann import peakdetect as peakbg
from scipy.integrate import simps

data_output = []

#split program into three parts: open file, compute, close&save file, plot if necessary (plot with method)

POSITIONINCREMENT = 0.128

def second_largest(numbers): #found online, https://stackoverflow.com/questions/16225677/get-the-second-largest-number-in-a-list-in-linear-time
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
    
def cut_background(raw_intensity, second):
    """cut_background: take intensity values and second peak, shift values down by second peak"""
    difference_raw_intensity_second_peak = (raw_intensity - second).values
    positions, = np.where(difference_raw_intensity_second_peak > 0)
    positions_intensity_above_cut = positions*POSITIONINCREMENT #get indices of desired values -> equivalent to positions if multiplied by 0.128?
    intensities_intensity_above_cut = difference_raw_intensity_second_peak[difference_raw_intensity_second_peak > 0]
    return positions_intensity_above_cut, intensities_intensity_above_cut
    
def fit_gaussian_to_shifted_data(x_cut, y_cut): #counts as one argument because ordered components of single value
    """determine parameters for gaussian fit. This should not be necessary, but somehow clearly helps."""
    function_mean = sum(x_cut * y_cut) / sum(y_cut)
    sigma = np.sqrt(sum(y_cut * (x_cut - function_mean) ** 2) / sum(y_cut))
    #global c
    c = min(y_cut)
    p0 = [max(y_cut), function_mean, sigma, c] #rename p0
    return p0

def Gauss(x, a, x0, s, c): #counts as one argument because ordered components of single value
    return a * np.exp(-(x - x0) ** 2 / (2 * s ** 2)) # + c # scipy.stats.norm #alternative for c? np.random.normal(0,0.2, len(x))

def xvalues_for_continuous_curve(x): #replace with linspace...
    """xvalues_for_continuous_curve: enlarge xvalues by 1000 and fill to a resolution of 1 (e.g. add around 634 for 6 points)"""
    """Use linspace instead?! yes..."""
    x = x*1000 #remove floats
    x_continuous_curve = np.array(range(int(min(x)), int(max(x)), 1))
    x_continuous_curve = x_continuous_curve/1000
    x = x/1000 #return floats
    return x_continuous_curve
    
def fwhm_point_identifier(x_cont, y_cont, hm):
    # 3 input arguments and 4 returns are bad design! Change x_cont and y_cont to one object, same for fx/fy and x_smaller/x_larger. Also, name change for hm...
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

def compute_area(y_greyscale): #requires: peakbg, second_largest, cut_background, fit_gaussian_to_shifted_data, curve_fit
    _max, _min = peakbg(y_greyscale, raw_positon_values, lookahead = 2, delta = 0) #find second peak -> this is where the script is lacking!
    second_peak = second_largest([p[1] for p in _max])
    if identified_single_peak(second_peak):
        print(filename, "has only one peak, skip to next iteration") #needs an "else: do this thing with derivatives"
    positions_intensity_above_cut, intensities_intensity_above_cut = cut_background(y_greyscale, second_peak) #after cutoff position is defined, cut off
    gaussfit_values = fit_gaussian_to_shifted_data(positions_intensity_above_cut, intensities_intensity_above_cut) #this simplifies the data enough to fit a gaussian on top
    popt,pcov = curve_fit(Gauss, positions_intensity_above_cut, intensities_intensity_above_cut, gaussfit_values) #is this a, x0, sigma? yes!
    return positions_intensity_above_cut, intensities_intensity_above_cut, popt    
    
def calculate_area(x_with_y_above_cut, *opt): #calls two other functions
    x_continuous_function =  xvalues_for_continuous_curve(x_with_y_above_cut)
    y_continuous_function = Gauss(x_continuous_function, *opt)
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
    #get X and Y values
    raw_positon_values = image_data.X #pandas series object
    raw_intensity_greyvalues = image_data.Y #pandas series object

    try:
        positions_intensity_above_cut, intensities_intensity_above_cut, popt = compute_area(raw_intensity_greyvalues, raw_positon_values)
    except(RuntimeError, TypeError):
        print("Runtime or Type Error, most likely due to a bad measurement in ", filename)
        continue
    hm, area, x_left, x_right, x_continuous_function, y_continuous_function = calculate_area(positions_intensity_above_cut, *popt)

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
    plt.xlabel('x coordinate')
    plt.ylabel('intensity (A.U.)')
    plt.title(filename)
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
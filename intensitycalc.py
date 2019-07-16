#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
author: R.Iselin
#add license
This script reads .csv files from a folder, one by one, and stores the X and Y values as pandas series object.
With each file and its set of values, it fits a gaussian onto the data. 
The data is artificially made more granular by adding 1000 more data points between min(x) and max(x), using the best fit.
The second highes peak or at least at an inflection point of the curve where the slope nears (but did not equal) 0 is determined.
All values are lowered to the second highest peak (if available)
Next, the full width half max (FWHM) is calculated.
"""

import os
import csv
import pylab
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from lmfit.models import GaussianModel, ExponentialModel
from peakdetect_bergmann import peakdetect as peakbg
from scipy.optimize import curve_fit, OptimizeWarning
from scipy.integrate import simps
from lmfit.models import PseudoVoigtModel #better chisquare than voigt
import warnings


import matplotlib
import scipy as scipy
from scipy import optimize
from matplotlib.ticker import AutoMinorLocator
from matplotlib import gridspec
import matplotlib.ticker as ticker
#matplotlib inline


data_output = []
POSITIONINCREMENT = 0.128

def read_csv_from_folder(iterator):
    filename = os.listdir('./csv/')[iterator]
    filepath = ('./csv/' + filename)
    image_data = pd.read_csv(filepath, delimiter = ";", encoding = "utf-8-sig")
    return image_data
    
def identified_single_peak(second_peak):
    if second_peak is None:
        return True

def xvalues_for_continuous_curve(x, n=100):
    x_continuous_curve = np.linspace(int(min(x)), int(max(x)), n)
    return x_continuous_curve

def yvalues_for_continuous_curve(y, x, x_interp):
    """Takes the interpolated y first. Then the x values that are of the same length. And finally the interpolated x with the new length."""
    y_continuous_curve = scipy.interpolate.interp1d(x, y, kind = 'cubic', fill_value="extrapolate")(x_interp)
    return y_continuous_curve

def initial_gaussian_parameters(x, y): #counts as one argument because ordered components of single value
    """determine parameters for gaussian fit."""
    amp1 = max(y)
    sigma1 = 500
    cen1 = len(x)/2

    amp2 = max(y)/5
    sigma2 = 100
    cen2 = len(x)/2 + len(x)/5

    amp3 = max(y_continuous)/5 
    sigma3 = 100
    cen3 = len(x)/2 - len(x)/5
    
    p0 = [amp1,cen1,sigma1, amp2,cen2,sigma2, amp3,cen3,sigma3]
    return p0

def _1gaussian(x, amp1,cen1,sigma1):
    """By Emily Grace Ripka: http://www.emilygraceripka.com/blog/16"""
    return amp1*(1/(sigma1*(np.sqrt(2*np.pi))))*(np.exp(-((x-cen1)**2)/((2*sigma1)**2)))

def _2gaussian(x, amp1,cen1,sigma1, amp2,cen2,sigma2):
    """By Emily Grace Ripka: http://www.emilygraceripka.com/blog/16"""
    return amp1*(1/(sigma1*(np.sqrt(2*np.pi))))*(np.exp(-((x-cen1)**2)/((2*sigma1)**2))) +\
           amp2*(1/(sigma2*(np.sqrt(2*np.pi))))*(np.exp(-((x-cen2)**2)/((2*sigma2)**2)))

def _3gaussian(x, amp1,cen1,sigma1, amp2,cen2,sigma2, amp3,cen3,sigma3): #just an idea - maybe worth it?
    return amp1*(1/(sigma1*(np.sqrt(2*np.pi))))*(np.exp(-((x-cen1)**2)/((2*sigma1)**2))) +\
           amp2*(1/(sigma2*(np.sqrt(2*np.pi))))*(np.exp(-((x-cen2)**2)/((2*sigma2)**2))) +\
           amp3*(1/(sigma3*(np.sqrt(2*np.pi))))*(np.exp(-((x-cen3)**2)/((2*sigma3)**2)))

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

def cut_background(y, x, threshold):
    """cut_background: take intensity values and second peak, shift values down by second peak"""
    difference_raw_intensity_second_peak = (y - threshold)
    xi, = np.where(difference_raw_intensity_second_peak > 0)
    x = x[min(xi):max(xi)+1]
    y = difference_raw_intensity_second_peak[difference_raw_intensity_second_peak > 0]
    return x, y

def fwhm_point_identifier(x_cont, y_cont, hm):
    y_peak_index = np.where(y_cont == max(y_cont))[0][0] #index of value of peak
    y_smaller = y_cont[0:y_peak_index] # all y values left of peak
    y_larger = y_cont[y_peak_index:] # all y values right of peak
    y_left = y_smaller[np.where(y_smaller == min(y_smaller, key=lambda x:abs(x-hm)))[0][0]] #closest y_value to calculated intersection, left
    y_right = y_larger[np.where(y_larger == min(y_larger, key=lambda x:abs(x-hm)))[0][0]]#closest y_value to calculated intersection, right
    x_fwhm =[x_cont[np.where(y_cont == y_left)[0][0]], x_cont[np.where(y_cont == y_right)[0][0]]]
    curve_data = [y_cont[np.where(y_cont == y_left)[0][0]:np.where(y_cont == y_right)[0][0]], x_cont[np.where(y_cont == y_left)[0][0]:np.where(y_cont == y_right)[0][0]]]
    return curve_data, x_fwhm


class State(object):
    def __init__(self):
        print('processing current state: ', str(self)
    def on_event(self, event):
        pass

class CurveFitGauss(State):
    def on_event(self, event):
        if event == 'gauss':
            return GaussSelected()
        
        return self
        
class CurveFitPeak(State):
    def on_event(self, event):
        if event == 'secondPeak':
            return PeakSelected()
        return self

for file in range(3, len(os.listdir('./csv/'))):
    print("Opening file: ", os.listdir('./csv/')[file])
    #loop, read data
    image_data = read_csv_from_folder(file)
    #determine x and y values
    try:
        x_array = image_data.x
        y_array = image_data.y
    except(AttributeError):
        x_array = image_data.X
        y_array = image_data.Y    
    

    #interpolate both sets of values first time
    
    x_continuous = xvalues_for_continuous_curve(x_array)
    y_continuous = yvalues_for_continuous_curve(y_array,x_array,x_continuous)
    
    y_continuous = y_continuous - min(y_continuous) 
    print(len(x_continuous),len(y_continuous))
    #Data is now ready for analysis
    
    #initial guess for gauss parameters 
    p0 = initial_gaussian_parameters(x_continuous, y_continuous)

    #distinguish between two cases: can I fit with 2 or should I try with 3?
    try:
        _max, _min = peakbg(y_continuous, x_continuous, lookahead = 2, delta = 0) #find second peak -> this is where the script is lacking!
        second_peak = second_largest([p[1] for p in _max])
        if identified_single_peak(second_peak):
            print(filename, "has only one peak, try gaussian") #needs an "else: do this thing with derivatives"
            popt_2gauss, pcov_2gauss = curve_fit(_2gaussian, x_continuous, y_continuous, p0=p0[0:6])
            perr_2gauss = np.sqrt(np.diag(pcov_2gauss))
            pars_1 = popt_2gauss[0:3]
            pars_2 = popt_2gauss[3:6]
            gauss_peak_1 = _1gaussian(x_continuous, *pars_1)
            gauss_peak_2 = _1gaussian(x_continuous, *pars_2)
            background = second_largest([max(gauss_peak_1), max(gauss_peak_2)])
            #shift curve down by background
            x_continuous2, y_continuous2 = cut_background(y_continuous, x_continuous, background)
        else:
            print("Used second peak")  
        x_continuous2, y_continuous2 = cut_background(y_continuous, x_continuous, second_peak)                
    except(RuntimeError, TypeError):
            print("Runtime or Type Error, most likely due to a bad measurement in ", os.listdir('./csv/')[file])
            continue

    #calculate area
    x_inter = xvalues_for_continuous_curve(x_continuous2, n=100)
    print(len(y_continuous2),len(x_continuous2),len(x_inter))
    y_inter = yvalues_for_continuous_curve(y_continuous2,x_continuous2,x_inter)
    hm = max(y_inter)/2
    curve, fwhm = fwhm_point_identifier(x_inter, y_inter, hm)
    total_area = simps(curve[0], curve[1])
    square_area = (fwhm[1] - fwhm[0])*hm
    peak_area_above_fwhm = total_area - square_area

    #plot
    plt.plot(x_continuous, y_continuous, "b+")
    plt.plot(x_inter, y_inter, "k-")
    plt.plot(x_continuous, gauss_peak_1, "g")
    plt.fill_between(x_continuous, gauss_peak_1.min(), gauss_peak_1, facecolor="green", alpha=0.5)
    plt.plot(x_continuous, gauss_peak_2, "y")
    plt.fill_between(x_continuous, gauss_peak_2.min(), gauss_peak_2, facecolor="yellow", alpha=0.5)
    plt.axhline(y = hm) #plot half max line
    plt.axvline(x = fwhm[0])
    plt.axvline(x = fwhm[1])
    plt.xlabel('x coordinate')
    plt.ylabel('intensity (A.U.)')
    plt.title(os.listdir('./csv/')[file])
    imagename = './png/' + os.listdir('./csv/')[file] + '.png'
    pylab.savefig(imagename, bbox_inches='tight')
    #plt.show()
    plt.pause(2.5) #allows user to check plots in realtime
    plt.close()
    data_output.append([os.listdir('./csv/')[file], peak_area_above_fwhm])


with open('./csv/data_output.csv', "w", newline='') as csv_file:
    writer = csv.writer(csv_file, delimiter=',')
    for line in data_output:
        writer.writerow(line)
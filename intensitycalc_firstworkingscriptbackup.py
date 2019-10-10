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
from scipy.optimize import curve_fit
from scipy.integrate import simps
from lmfit.models import PseudoVoigtModel #better chisquare than voigt

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
    
def xvalues_for_continuous_curve(x, n=100):
    x_continuous_curve = np.linspace(int(min(x)), int(max(x)), n)
    return x_continuous_curve

def yvalues_for_continuous_curve(y, x, x_interp):
    """Takes the interpolated y first. Then the x values that are of the same length. And finally the interpolated x with the new length."""
    y_continuous_curve = scipy.interpolate.interp1d(x, y, kind = 'cubic', fill_value="extrapolate")(x_interp)
    return y_continuous_curve

def initial_1gaussian_parameters(x, y): #counts as one argument because ordered components of single value
    """determine parameters for gaussian fit. This should not be necessary, but somehow clearly helps."""
    function_mean = sum(x * y) / sum(y)
    sigma = np.sqrt(sum(y * (x - function_mean) ** 2) / sum(y))
    c = min(y)
    p0 = [max(y), function_mean, sigma] #rename p0
    return p0
    
def initial_1voigt_parameters(x, y): #counts as one argument because ordered components of single value
    """determine parameters for gaussian fit. This should not be necessary, but somehow clearly helps."""
    function_mean = sum(x * y) / sum(y)
    sigma = np.sqrt(sum(y * (x - function_mean) ** 2) / sum(y))
    c = min(y)
    p0 = [max(y), function_mean, sigma] #rename p0
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

def _1Voigt(x, ampG1, cenG1, sigmaG1, ampL1, cenL1, widL1):
    return (ampG1*(1/(sigmaG1*(np.sqrt(2*np.pi))))*(np.exp(-((x-cenG1)**2)/((2*sigmaG1)**2)))) +\
           ((ampL1*widL1**2/((x-cenL1)**2+widL1**2)) )
           
def _2Voigt(x, ampG1, cenG1, sigmaG1, ampL1, cenL1, widL1, ampG2, cenG2, sigmaG2, ampL2, cenL2, widL2):
    return (ampG1*(1/(sigmaG1*(np.sqrt(2*np.pi))))*(np.exp(-((x-cenG1)**2)/((2*sigmaG1)**2)))) +\
           ((ampL1*widL1**2/((x-cenL1)**2+widL1**2)) ) +\
           (ampG2*(1/(sigmaG2*(np.sqrt(2*np.pi))))*(np.exp(-((x-cenG2)**2)/((2*sigmaG2)**2)))) +\
           ((ampL2*widL2**2/((x-cenL2)**2+widL2**2)) )


def cut_background(y, x, threshold):
    """cut_background: take intensity values and second peak, shift values down by second peak"""
    difference_raw_intensity_second_peak = (y - threshold)
    xi, = np.where(difference_raw_intensity_second_peak > 0)
    x = x[min(xi):max(xi)+1]
    # x = x*POSITIONINCREMENT #get indices of desired values -> equivalent to positions if multiplied by 0.128?
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

#loop, read data
image_data = read_csv_from_folder(7)

#determine x and y values
x_array = image_data.X
y_array = image_data.Y

#interpolate both sets of values
x_continuous = xvalues_for_continuous_curve(x_array)
y_continuous = yvalues_for_continuous_curve(y_array,x_array,x_continuous)
y_continuous = y_continuous - min(y_continuous)

#initial guess. Can I automate this? Improve it? Max and secondlargest as amp? But not finding a second largest is exactly the problem. 
amp1 = max(y_continuous)
sigma1 = 500
cen1 = len(x_continuous)/2

amp2 = max(y_continuous)/5
sigma2 = 100
cen2 = len(x_continuous)/2 + len(x_continuous)/5

amp3 = max(y_continuous)/5 
sigma3 = 100
cen3 = len(x_continuous)/2 - len(x_continuous)/5

#curve fit
# popt_2gauss, pcov_2gauss = curve_fit(_2gaussian, x_continuous, y_continuous, p0=[amp1, cen1, sigma1, amp2, cen2, sigma2])
# perr_2gauss = np.sqrt(np.diag(pcov_2gauss))
# pars_1 = popt_3gauss[0:3]
# pars_2 = popt_3gauss[3:6]
# gauss_peak_1 = _1gaussian(x_continuous, *pars_1)
# gauss_peak_2 = _1gaussian(x_continuous, *pars_2)

popt_3gauss, pcov_3gauss = curve_fit(_3gaussian, x_continuous, y_continuous, p0=[amp1, cen1, sigma1, amp2, cen2, sigma2, amp3,cen3,sigma3])
perr_3gauss = np.sqrt(np.diag(pcov_3gauss))
pars_1 = popt_3gauss[0:3]
pars_2 = popt_3gauss[3:6]
pars_3 = popt_3gauss[6:9]
gauss_peak_1 = _1gaussian(x_continuous, *pars_1)
gauss_peak_2 = _1gaussian(x_continuous, *pars_2)
gauss_peak_3 = _1gaussian(x_continuous, *pars_3)

#identify smaller of the two peaks
background = min(max(gauss_peak_1), max(gauss_peak_2), max(gauss_peak_3))


#shift curve down by background
x_continuous2, y_continuous2 = cut_background(y_continuous, x_continuous, background)



x = x_continuous2
y = y_continuous2
mod = PseudoVoigtModel()
pars = mod.guess(y, x=x)
print(pars)
out = mod.fit(y, pars, x=x)
print(out.fit_report(min_correl=0.25))
new_par = []
for par in out.params.values():
    new_par.append(par.value)

print(new_par)
# out = mod.fit(y, pars, x=x)
# new_params = out.params
# print(pars) 
# print(new_params)
#plt.plot(x, out.best_fit, 'r-')
# out.plot()
plt.plot(x_continuous, y_continuous, "b+")
# plt.plot(x_continuous, _1gaussian(x_continuous, *popt), 'k--')
plt.plot(x_continuous, gauss_peak_1, "g")
plt.fill_between(x_continuous, gauss_peak_1.min(), gauss_peak_1, facecolor="green", alpha=0.5)
plt.plot(x_continuous, gauss_peak_2, "y")
plt.fill_between(x_continuous, gauss_peak_2.min(), gauss_peak_2, facecolor="yellow", alpha=0.5)
plt.plot(x_continuous, gauss_peak_3, "y")
plt.fill_between(x_continuous, gauss_peak_3.min(), gauss_peak_3, facecolor="red", alpha=0.5)

plt.show()

x_inter = xvalues_for_continuous_curve(x_continuous2, n=100)
y_inter = yvalues_for_continuous_curve(y_continuous2,x_continuous2,x_inter)

hm = max(y_inter)/2
curve, fwhm = fwhm_point_identifier(x_inter, y_inter, hm)
total_area = simps(curve[0], curve[1])
square_area = (fwhm[1] - fwhm[0])*hm
peak_area_above_fwhm = total_area - square_area
print(peak_area_above_fwhm)

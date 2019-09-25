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
    
def gauss(x,a,mu,sigma):
    return a*np.exp(-(x-mu)**2/(2*sigma**2))
  
def xvalues_for_continuous_curve(x):
    x_continuous_curve = np.linspace(int(min(x)), int(max(x)), 100)
    return x_continuous_curve

def yvalues_for_continuous_curve(y):
    y_continuous_curve = scipy.interpolate.interp1d(x_array, y_array_2gauss, kind = 'cubic')(x_continuous_curve)
    return y_continuous_curve

def _1gaussian(x, amp1,cen1,sigma1):
    return amp1*(1/(sigma1*(np.sqrt(2*np.pi))))*(np.exp(-((x-cen1)**2)/((2*sigma1)**2)))


def _2gaussian(x, amp1,cen1,sigma1, amp2,cen2,sigma2):
    return amp1*(1/(sigma1*(np.sqrt(2*np.pi))))*(np.exp(-((x-cen1)**2)/((2*sigma1)**2))) +\
           amp2*(1/(sigma2*(np.sqrt(2*np.pi))))*(np.exp(-((x-cen2)**2)/((2*sigma2)**2)))



image_data = read_csv_from_folder(8)
x_array = image_data.X
y_array_2gauss = image_data.Y

x_continuous_curve = xvalues_for_continuous_curve(x_array)
y_continuous_curve = yvalues_for_continuous_curve(y_array_2gauss)



amp1 = 25000
sigma1 = 300
cen1 = 1500

amp2 = 6000
sigma2 = 200
cen2 = 2500

popt_2gauss, pcov_2gauss = curve_fit(_2gaussian, x_continuous_curve, y_continuous_curve, p0=[amp1, cen1, sigma1, amp2, cen2, sigma2])
perr_2gauss = np.sqrt(np.diag(pcov_2gauss))
pars_1 = popt_2gauss[0:3]
pars_2 = popt_2gauss[3:6]
gauss_peak_1 = _1gaussian(x_continuous_curve, *pars_1)
gauss_peak_2 = _1gaussian(x_continuous_curve, *pars_2)

fig = plt.figure(figsize=(4,3))
gs = gridspec.GridSpec(1,1)
ax1 = fig.add_subplot(gs[0])

print(max(gauss_peak_2))

ax1.plot(x_continuous_curve, y_continuous_curve, "ro")
ax1.plot(x_continuous_curve, _2gaussian(x_continuous_curve, *popt_2gauss), 'k--')

ax1.plot(x_continuous_curve, gauss_peak_1, "g")
ax1.fill_between(x_continuous_curve, gauss_peak_1.min(), gauss_peak_1, facecolor="green", alpha=0.5)
  
ax1.plot(x_continuous_curve, gauss_peak_2, "y")
ax1.fill_between(x_continuous_curve, gauss_peak_2.min(), gauss_peak_2, facecolor="yellow", alpha=0.5)  


ax1.set_xlabel("x_array",family="serif",  fontsize=12)
ax1.set_ylabel("y_array",family="serif",  fontsize=12)


fig.tight_layout()
fig.savefig("raw2Gaussian.png", format="png",dpi=1000)


"""print(y_continuous_curve)
plt.plot(x_continuous_curve, y_continuous_curve)
plt.plot(x_array, y_array_2gauss, 'b+:', label='data')
plt.show()"""
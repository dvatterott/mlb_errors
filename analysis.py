#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import pandas as pd
from scipy.stats import chisquare

YEAR = sys.argv[1]

DF = pd.read_csv('./processed_data/{}/errors_bip.out'.format(YEAR), header=None, names=['player', 'errors', 'bip', 'prop_error'])

# use chi2 test to look at if all frequencies are "equal"
AVG_ERROR_RATE = DF['errors'].sum()*1. / DF['bip'].sum()
print(chisquare(DF['errors'], f_exp=(DF['bip'] * AVG_ERROR_RATE).apply(round)))


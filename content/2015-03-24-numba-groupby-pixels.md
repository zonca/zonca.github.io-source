Title: Accelerate groupby operation on pixels with Numba
Date: 2015-03-24 9:00
Author: Andrea Zonca
Tags: python, numba, astrophysics
Slug: numba-groupby-pixels

[Download the original IPython notebook](/notebooks/numba_groupby_pixels.ipynb)

## Astrophysics background

It is very common in Astrophysics to work with sky pixels. The sky is tassellated in patches with specific properties and a sky map is then a collection of intensity values for each pixel. The most common pixelization used in Cosmology is [HEALPix](http://healpix.jpl.nasa.gov).

Measurements from telescopes are then represented as an array of pixels that encode the pointing of the instrument at each timestamp and the measurement output.

## Sample timeline

    import pandas as pd
    import numba
    import numpy as np

For simplicity let's assume we have a sky with 50K pixels:


    NPIX = 50000

And we have 50 million measurement from our instrument:


    NTIME = int(50 * 1e6)

The pointing of our instrument is an array of pixels, random in our sample case:


    pixels = np.random.randint(0, NPIX-1, NTIME)

Our data are also random:


    timeline = np.random.randn(NTIME)

## Create a map of the sky with pandas

One of the most common operations is to sum all of our measurements in a sky map, so the value of each pixel in our sky map will be the sum of each individual measurement.
The easiest way is to use the `groupby` operation in `pandas`:


    timeline_pandas = pd.Series(timeline, index=pixels)

    timeline_pandas.head()
    46889    0.407097
    3638     1.300001
    6345     0.174931
    15742   -0.255958
    34308    1.147338
    dtype: float64

    %time m = timeline_pandas.groupby(level=0).sum()

    CPU times: user 4.09 s, sys: 471 ms, total: 4.56 s
    Wall time: 4.55 s


## Create a map of the sky with numba

We would like to improve the performance of this operation using `numba`, which allows to produce automatically C-speed compiled code from pure python functions.

First we need to develop a pure python version of the code, test it, and then have `numba` optimize it:

    def groupby_python(index, value, output):
        for i in range(index.shape[0]):
            output[index[i]] += value[i]

    m_python = np.zeros_like(m)


    %time groupby_python(pixels, timeline, m_python)

    CPU times: user 37.5 s, sys: 0 ns, total: 37.5 s
    Wall time: 37.6 s

    np.testing.assert_allclose(m_python, m)

Pure Python is slower than the `pandas` version implemented in `cython`.

### Optimize the function with numba.jit

`numba.jit` gets an input function and creates an compiled version with does not depend on slow Python calls, this is enforced by `nopython=True`, `numba` would throw an error if it would not be possible to run in `nopython` mode.


    groupby_numba = numba.jit(groupby_python, nopython=True)

    m_numba = np.zeros_like(m)

    %time groupby_numba(pixels, timeline, m_numba)
    CPU times: user 274 ms, sys: 5 ms, total: 279 ms
    Wall time: 278 ms

    np.testing.assert_allclose(m_numba, m)

Performance improvement is about 100x compared to Python and 20x compared to Pandas, pretty good!

## Use numba.jit as a decorator

The exact same result is obtained if we use `numba.jit` as a decorator:

    @numba.jit(nopython=True)
    def groupby_numba(index, value, output):
        for i in range(index.shape[0]):
            output[index[i]] += value[i]

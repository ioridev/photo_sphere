/************************************************************************/
/*                                                                      */
/*            Copyright 2011-2012 by Ullrich Koethe                     */
/*                                                                      */
/*    This file is part of the VIGRA computer vision library.           */
/*    The VIGRA Website is                                              */
/*        http://hci.iwr.uni-heidelberg.de/vigra/                       */
/*    Please direct questions, bug reports, and contributions to        */
/*        ullrich.koethe@iwr.uni-heidelberg.de    or                    */
/*        vigra@informatik.uni-hamburg.de                               */
/*                                                                      */
/*    Permission is hereby granted, free of charge, to any person       */
/*    obtaining a copy of this software and associated documentation    */
/*    files (the "Software"), to deal in the Software without           */
/*    restriction, including without limitation the rights to use,      */
/*    copy, modify, merge, publish, distribute, sublicense, and/or      */
/*    sell copies of the Software, and to permit persons to whom the    */
/*    Software is furnished to do so, subject to the following          */
/*    conditions:                                                       */
/*                                                                      */
/*    The above copyright notice and this permission notice shall be    */
/*    included in all copies or substantial portions of the             */
/*    Software.                                                         */
/*                                                                      */
/*    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND    */
/*    EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES   */
/*    OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND          */
/*    NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT       */
/*    HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,      */
/*    WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING      */
/*    FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR     */
/*    OTHER DEALINGS IN THE SOFTWARE.                                   */
/*                                                                      */
/************************************************************************/

#define PY_ARRAY_UNIQUE_SYMBOL vigranumpyanalysis_PyArray_API
#define NO_IMPORT_ARRAY

#include "pythonaccumulator.hxx"

namespace python = boost::python;

namespace vigra
{

void defineSinglebandRegionAccumulators()
{
    using namespace python;
    using namespace vigra::acc;

    docstring_options doc_options(true, true, false);
    typedef Select<Count, Mean, Variance, Skewness, Kurtosis, 
                   Minimum, Maximum, StandardQuantiles<GlobalRangeHistogram<0> >,
                   RegionCenter, RegionRadii, RegionAxes,
                   Weighted<RegionCenter>, Weighted<RegionRadii>, Weighted<RegionAxes>,
                   Select<Coord<Minimum>, Coord<Maximum>, Coord<ArgMinWeight>, Coord<ArgMaxWeight>, 
                          Principal<Coord<Skewness> >, Principal<Coord<Kurtosis> >, 
                          Principal<Weighted<Coord<Skewness> > >, Principal<Weighted<Coord<Kurtosis> > > >,
                   DataArg<1>, WeightArg<1>, LabelArg<2>
                   > ScalarRegionAccumulators;
    definePythonAccumulatorArraySingleband<2, float, ScalarRegionAccumulators>();
    definePythonAccumulatorArraySingleband<3, float, ScalarRegionAccumulators>();
}

} // namespace vigra

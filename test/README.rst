==========================
Ophidia Workflow Catalogue
==========================

Test workflows
==============

This folder contains a number of workflows that can be used to test Ophidia service. Refer to PyOphidia_documentation_ for validation procedure.

Cold Spells
-----------
File: coldspells.py
Description: this workflow performs the computation of Cold Spells indexes.
Arguments:
1. the folder containing bash scripts (optional, by default the base folder will be the root folder)
2. the folder containing data to be processed and output (optional, by default the base folder will be the root folder)
Test example:

.. code-block:: python

	from pyophidia import Experiment
	Experiment.validate("coldspells.json")

Anomaly of Diurnal Temperature Range
------------------------------------
File: dtr.py
Description: this workflow computes the anomaly of DTR (Diurnal Temperature Range) index with respect to past values; it works on two input files (tasmin/tasmax variable).
Arguments:
1. ncores (mandatory)
2. the model name, e.g. 'CMCC-CM' (mandatory)
3. spatial filter (lat|lon ranges)
4. the first time filter (historical)
5. the second time filter (scenario)
6. the grid of output map using the format r<lon>x<lat> (e.g. r360x180), i.e. a global regular lon/lat grid (optional, by default the lon/lat grid of input file is adopted)
7. I/O server type (optional).
Test example:

.. code-block:: python

	from pyophidia import Experiment
	args = []
	args.append("1")
	args.append("CMCC-CM")
	args.append("30:45|0:40")
	args.append("0:50")
	args.append("r360x180")
	Experiment.validate("dtr.json", *args)

Lenght of snow season
---------------------
File: lss.py
Description: this workflow evaluates the lenght of snow season.
Arguments:
1. pid of input data cube, e.g. http://127.0.0.1/ophidia/1/1 (mandatory)
2. output path (mandatory)
3. output file name (optional)
4. path to bash script (optional, by default the base folder will be the root folder)
Test example:

.. code-block:: python

	from pyophidia import Experiment
	args = []
	args.append("http://127.0.0.1/ophidia/1/1")
	args.append("/data")
	Experiment.validate("lss.json", *args)

Precipitation trend analysis
----------------------------
File: pta.py
Description: this workflow analyse precipitation trends related to different scenarios.
Arguments:
1. ncores (mandatory)
2. list of models (e.g. 'CMCC-CM|CMCC-CMS')
3. scenario (e.g. rcp45 or rcp85)
4. frequency (e.g. day or mon)
5. percentile (e.g. 0.9)
6. past time subset (e.g. 1976_2006)
7. future time subset (e.g. 2071_2101)
8. geographic subset (e.g. 30:45|0:40)
9. the grid of output map using the format r<lon>x<lat> (e.g. r360x180), i.e. a global regular lon/lat grid
10. import type (optional), set to '1' in case only subsetting data have to be imported (default)
11. I/O server type (optional)
Test example:

.. code-block:: python

	from pyophidia import Experiment
	args = []
	args.append("http://127.0.0.1/ophidia/1/1")
	args.append("1")
	args.append("CMCC-CM|CMCC-CMS")
	args.append("rcp85")
	args.append("day")
	args.append("0.9")
	args.append("1976_2006")
	args.append("2071_2101")
	args.append("30:45|0:40")
	args.append("r360x180")
	Experiment.validate("lss.json", *args)

Sea surface temperature
-----------------------
File: sst.py
Description: this workflow evaluates monthly averages of sea surface temperature (SST).
Arguments:
1. ncores (mandatory)
2. output path (mandatory)
3. path to bash script (optional, by default the base folder will be the root folder)
Test example:

.. code-block:: python

	from pyophidia import Experiment
	args = []
	args.append("http://127.0.0.1/ophidia/1/1")
	args.append("/data")
	Experiment.validate("sst.json", *args)

Snow water equivalent
---------------------
File: swe.py
Description: this workflow evaluates monthly averages of snow water equivalent (SWE).
Arguments:
1. pid of input data cube, e.g. http://127.0.0.1/ophidia/1/1 (mandatory)
2. output path (mandatory)
3. output file name (optional)
4. path to bash script (optional, by default the base folder will be the root folder)
Test example:

.. code-block:: python

	from pyophidia import Experiment
	args = []
	args.append("http://127.0.0.1/ophidia/1/1")
	args.append("/data")
	Experiment.validate("swe.json", *args)

Uncorrect workflows
-------------------
The folder includes some workflows with errors named uncorrect1.py and uncorrect2.py useful for tests.

Further information about workflow submission can be found at Ophidia_documentation_.

.. _PyOphidia_documentation: https://pyophidia.readthedocs.io/en/stable/
.. _Ophidia_documentation: https://ophidia.cmcc.it/documentation/users/workflow/workflow_basic.html#workflow-submission


# Schnitzler Tagebuch


* build with [DSE-Static-Cookiecutter](https://github.com/acdh-oeaw/dse-static-cookiecutter)


## install/develop

* To run build/run (and develop) locally you need to 
  * install the needed libraries, on Linux you should be fine running `$ ./script.sh` as well as set up a python environment and run `pip install acdh-tei-pyutils`
  * fetch (and preprocess) the actual data; which should work by running `$ ./fetch_data.sh`
  * execute the ant-scripts to build the html/js, and rdf files

Anyways, for the most up-to-date instructions on how to get up and running have a look at  `./.github/workflows/build.yml`
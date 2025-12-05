# Schnitzler Tagebuch


* build with [DSE-Static-Cookiecutter](https://github.com/acdh-oeaw/dse-static-cookiecutter)


## install/develop

* To run build/run (and develop) locally you need to
  * install the needed libraries, on Linux you should be fine running `$ ./script.sh` as well as set up a python environment and run `pip install acdh-tei-pyutils`
  * fetch (and preprocess) the actual data; which should work by running `$ ./fetch_data.sh`
  * execute the ant-scripts to build the html/js, and rdf files

Anyways, for the most up-to-date instructions on how to get up and running have a look at  `./.github/workflows/build.yml`

## Third-Party Libraries

This project uses the following third-party libraries (located in `html/vendor/`, not tracked in git):

- **[Tabulator](https://tabulator.info/)** (MIT License) - Interactive table library for person, place, and work indexes
- **[Bootstrap 5](https://getbootstrap.com/)** (MIT License) - CSS framework
- **[Leaflet](https://leafletjs.com/)** (BSD-2-Clause License) - Interactive maps
- **[Leaflet.markercluster](https://github.com/Leaflet/Leaflet.markercluster)** (MIT License) - Marker clustering for maps
- **[jQuery](https://jquery.com/)** (MIT License) - JavaScript library
- **[Typesense InstantSearch Adapter](https://github.com/typesense/typesense-instantsearch-adapter)** (Apache-2.0 License) - Search functionality
- **[OpenSeadragon](https://openseadragon.github.io/)** (BSD-3-Clause License) - Image viewer
- **[i18next](https://www.i18next.com/)** (MIT License) - Internationalization

## License

This project is licensed under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/legalcode).
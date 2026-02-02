<a href="https://ai4life.eurobioimaging.eu/open-calls/">
    <img src="https://github.com/ai4life-opencalls/.github/blob/main/AI4Life_banner_giraffe_nodes_OC.png?raw=true" width="70%">
  </a>
</p>



# Project #17: Imprints of Wind Disturbances on Wood Anatomy

This repository contains code for the automatic segmentation of tree lumen and membrane in confocal microscopy. Developed as part of the [AI4Life project](https://ai4life.eurobioimaging.eu), it uses data provided by Jakub Kašpar from VUKOZ, Brno, CZ.
All images used in this tutorial are licensed under **CC-BY**. If any of the instructions are not working, please [open an issue](https://github.com/ai4life-opencalls/oc_3_project_17/issues) or contact us at [ai4life@fht.org](ai4life@fht.org)!

## Introduction
The project focuses on ...



## Installation

Install the [conda](https://conda.io) package, dependency and environment manager.

You can download this repository from the green `Code` button → download ZIP, or clone through the command line with

    cd <path to any folder of choice>
    git clone https://github.com/ai4life/oc_3_project_17.git

Then create the `oc_3_project_17` conda environment:

    cd <path to your 'oc_3_project_17' directory>
    conda env create -f environment.yml

This will install all necessary project dependencies.

## Usage

Copy all project data to the [data](data) directory (or use symbolic links).

Then run [Jupyter Lab](https://jupyter.org) from within the `oc_3_project_17` conda environment:

    cd <path to your 'oc_3_project_17' directory>
    conda activate oc_3_project_17
    jupyter-lab

Inside the `notebooks` folder you will find Jupyter notebooks for:

## Acknowledgements
AI4Life has received funding from the European Union’s Horizon Europe research and innovation programme under grant agreement number 101057970. Views and opinions expressed are however those of the author(s) only and do not necessarily reflect those of the European Union or the European Research Council Executive Agency. Neither the European Union nor the granting authority can be held responsible for them.

## License

[MIT](LICENSE)

Developed by [Kristina Lidayova](mailto:kristina.lidayova@scilifelab.se)

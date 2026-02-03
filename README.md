<a href="https://ai4life.eurobioimaging.eu/open-calls/">
    <img src="https://github.com/ai4life-opencalls/.github/blob/main/AI4Life_banner_giraffe_nodes_OC.png?raw=true" width="70%">
  </a>
</p>



# Project #17: Imprints of Wind Disturbances on Wood Anatomy

This repository contains code for the automatic segmentation of tree lumen and membrane in confocal microscopy. Developed as part of the [AI4Life project](https://ai4life.eurobioimaging.eu), it uses data provided by Jakub Kašpar from VUKOZ, Brno, CZ.
All images used in this tutorial are licensed under **CC-BY**. If any of the instructions are not working, please [open an issue](https://github.com/ai4life-opencalls/oc_3_project_17/issues) or contact us at [ai4life@fht.org](ai4life@fht.org)!

## Introduction
This project investigates differences in wood quality among trees from the Boubín Forest nature reserve, the largest indigenous forest in Central Europe. The forest has been significantly affected by windstorm disturbances in 1868 and 2017.
Wood samples from trees aged 300–400 years provide an opportunity to investigate potential changes in wood anatomy associated with these events.

<img width="1640" height="778" alt="Figure1" src="https://github.com/user-attachments/assets/ecbe4bb6-015c-46f1-96a4-a2a66bb3636c" />

_Figure 1: Wood sample illustrating earlywood cells (orange region) and latewood cells (red region) and annual tree rings (green lines). Samples were cut into 10 cm sticks, stained with Safranin, dehydrated, and imaged with a Zeiss confocal microscope._

In general, the software [ROXAS](https://www.quantitative-plant.org/software/roxas) is commonly used for wood cell analysis. However, in this study a new sample preparation method based on Safranin staining was applied, which significantly reduced preparation time. Safranin reacts with cellulose and alters the coloration of anatomical structures in the images, making them incompatible with the ROXAS software. Therefore, a new analysis solution had to be developed.

To investigate changes in wood anatomy, annual tree rings are first detected to assign wood cells to the correct year. Within each tree ring, individual wood cells are then identified. For each cell, the lumen and cell wall are distinguished, and the average wall thickness and lumen area are measured.

## Installation
For the analysis, two types of programs were developed: a FIJI macro and a Python Jupyter Notebook.

### 1. FIJI macro

Install FIJI:

1. Go to the official FIJI website: [https://imagej.net/software/fiji/downloads](https://imagej.net/software/fiji/downloads).
2. Download the installer or ZIP file for your operating system (Windows, macOS, or Linux).
3. Unzip the downloaded archive to a folder on your computer.
 
⚠️ Avoid installing FIJI in C:\Program Files to prevent permission issues.

Run the FIJI macro:

1. Download the FIJI macro file.
2. Move the macro file into the FIJI plugins directory, e.g.: Fiji.app/plugins/
3. Start FIJI.
4. Run the macro via:
Plugins → FIJI preprocessing

### 2. Python (Jupyter Notebook)

Install the [conda](https://conda.io) package, dependency and environment manager.

You can download this repository from the green `Code` button → download ZIP, or clone through the command line with

    cd <path to any folder of choice>
    git clone https://github.com/ai4life-opencalls/oc_3_project_17.git

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

Inside the `notebooks` folder you will find FIJI macro and Jupyter notebooks for:

### Step 1 : [Preprocessing the image in FIJI](notebooks/)

  This notebook preprocesses the image
The pipeline consists of:

1. **.**:
2. **.**: 
3. **.**:  

## Acknowledgements
AI4Life has received funding from the European Union’s Horizon Europe research and innovation programme under grant agreement number 101057970. Views and opinions expressed are however those of the author(s) only and do not necessarily reflect those of the European Union or the European Research Council Executive Agency. Neither the European Union nor the granting authority can be held responsible for them.

## License

[MIT](LICENSE)

Developed by [Kristina Lidayova](mailto:kristina.lidayova@scilifelab.se)

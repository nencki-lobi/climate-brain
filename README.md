# CLIMATE BRAIN

This repository contains supplementary materials associated with the development of the **CLIMATE BRAIN** dataset. The dataset itself is publicly available on [OpenNeuro](https://openneuro.org), under the accession number [ds005460](https://openneuro.org/datasets/ds005460).

Please cite the corresponding resource when using these materials:

> Zaremba, D., Kossowski, B., Wypych, M., Jednoróg, K., Michałowski, J. M., Klöckner, C. A., Wierzba, M., & Marchewka, A. (2024) CLIMATE BRAIN - Questionnaires, tasks and the neuroimaging dataset. OpenNeuro. [Dataset] doi: [TBA]()

## How to use

To reproduce the results described in the article, follow the instructions below.

Create a working directory for the analysis. By default it is assumed that `$HOME` is a root directory for the analysis. You can adjust this, as long as your setup follows the assumed directory structure (see below). Please be advised that you need at least 500 GB space available to complete the full analysis.

```
cd $HOME
```

Download the dataset, following the instructions provided [here](https://openneuro.org/datasets/ds005460/download), e.g.:

```
openneuro download --snapshot 1.0.0 ds005460 ds005460/
```

Download the code (this git repository), e.g.:

```
git clone https://github.com/nencki-lobi/climate-brain.git
```

Make sure that your directory structure is as follows, that is the `ds005460` and `climate-brain` directories are placed in the same parent directory:

```
.
├── climate-brain
└── ds005460
```

If your local setup is different, you can create symlinks to mimic the required setup. For instance, if you downloaded the OpenNeuro dataset to an external storage location `$STORAGE`, you can create a symlink to make it accessible from your working directory:

```
cd $HOME
ln -s $STORAGE/ds005460 ds005460
```

Use the following scripts:
- `climate-brain.R` to reproduce the behavioural results. This step requires [R](https://www.r-project.org).
- `climate-brain.m` to reproduce the neuroimaging results. This step requires [MATLAB](https://www.mathworks.com/products/matlab.html), [SPM12](https://www.fil.ion.ucl.ac.uk/spm/software/spm12), and [BIDS-Matlab](https://github.com/bids-standard/bids-matlab).
- `climate-brain.ipynb` to visualise the neuroimaging results. This step requires [Python](https://www.python.org), [Jupyter Notebook](https://jupyter.org), and [Nilearn](https://nilearn.github.io).


## Funding

<img align="left" src="https://www.norwaygrants.si/wp-content/uploads/2021/12/Norway_grants@4x-913x1024.png" width=10% height=10%> 
<br>The research leading to these results has received funding from the Norwegian Financial Mechanism 2014-2021, no. 2019/34/H/HS6/00677.

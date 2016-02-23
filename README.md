# WRF output for hydrology analysis
Creates statistical data with the results of the WRF simulations, over WRF simulated area and desired number off stations with coordinates location.

This tool is used to have a critical analysis over the WRF with hydrology outputs results, so user can study the hydrology in that particular area.

Work in progress!!!

**To implement:**

* Compare data obtained from Stations and WRF simulation

## Results:
**(example of 20 feb 2010 storm in Madeira modelated in WRF, images and graphs from 2 location with respective coordinates, FNCH (Funchal) & SEAG (Serra de Água))**


* Max hourly precipitation rate "RAINNC"
![alt text](obs/variav_rainnc_2010-02-18.png)
![alt text](obs/variav_rainnc_2010-02-19.png)
![alt text](obs/variav_rainnc_2010-02-20.png)
![alt text](obs/coor_rain_2010-02-18.png)

* Liquid soil moisture "SH2O"
![alt text](obs/variav_sh2o_2010-02-20.png)
![alt text](obs/coor_sh2o_2010-02-18.png)

* Surface runoff "SFROFF"
![alt text](obs/variav_sfroff_2010-02-20.png)
![alt text](obs/coor_sfroff_2010-02-18.png)

* Subsurface runoff "UDROFF"
![alt text](obs/variav_udroff_2010-02-20.png)
![alt text](obs/coor_udroff_2010-02-18.png)

## Usage:

* Run:
```r
make run
```

* kill application:
```r
make kill
```

Contacts:

<ricardo88faria@gmail.com>

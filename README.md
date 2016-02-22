# ReSun & WRF output analysis
Creates .kmz (Google Earth) and .png with geographical data with the results of the ReSun & WRF simulations. Outputs graphs with median daily radiation for the simulated area.

This tool is used to have a critical analysis over the WRF & ReSun results, to study the potencial Solar Energy of that particular area.

Work in progress!!!

## Results:

**High quality image (png) example**

* Global horizontal radiation
![alt text](obs/Rad_2009-05-01.png)
![alt text](obs/Rad_2009-05-02.png)

**Google Earth (kmz) & topographic data example**

* Global horizontal radiation
![alt text](obs/kmz.png)

<dl>
  <dt>Topography</dt>
  <dd>[link](https://plot.ly/~ricardo88faria/10.embed)</dd>
</dl>

**Animations (GIF) example**

* Global horizontal radiation
![alt text](obs/Rad_2009-05-25.gif)

**Graphics analysis**

* Daily median of studied period
![alt text](obs/Rad_daily_2009-04-30.png)


* Time Series of studied period
![alt text](obs/Rad_hour_TS_2009-04-30.png)

<dl>
  <dt>Dynamic time Series</dt>
  <dd>[link](https://plot.ly/~ricardo88faria/12.embed)</dd>
</dl>

<iframe width="550" height="500" frameborder="0" scrolling="no" src="https://plot.ly/~ricardo88faria/12/radiacao-solar-diaria-na-ilha-da-madeira/"></iframe>


* Hourly median of studied period
![alt text](obs/Rad_month_2009-04-30.png)

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

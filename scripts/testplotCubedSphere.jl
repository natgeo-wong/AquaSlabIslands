using DrWatson
@quickactivate "AquaSlabIslands"

using NCDatasets

using PyCall, LaTeXStrings
pplt = pyimport("proplot")

include(srcdir("cubedsphere2lonlat.jl"))

ds  = NCDataset(datadir("domain.ocn.ne5np4_gx3v7.140810.nc"))
# ds  = NCDataset(datadir("domain.ocn.ne30_gx1v7.171003.nc"))
lon = ds["xc"][:,1]
lat = ds["yc"][:,1]
afr = ds["frac"][:,1]
close(ds)

cs2ll = CubedSphere2LonLat(lon,lat,resolution_lon=0.2,resolution_lat=0.2)
ndata = zeros(cs2ll.nlon,cs2ll.nlat)
cubedsphere2lonlat!(ndata,afr,cs2ll)

pplt.close(); f,a = pplt.subplots(axwidth=4,proj="moll")

c = a[1].pcolormesh(cs2ll.lon,cs2ll.lat,ndata',extend="both")
a[1].format(coast=true)

f.colorbar(c)
f.savefig("test.png",transparent=false,dpi=300)
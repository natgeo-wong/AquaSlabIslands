using DrWatson
@quickactivate "AquaSlabIslands"

using NCDatasets

using PyCall, LaTeXStrings
pplt = pyimport("proplot")

include(srcdir("slaboceangen.jl"))

ds = slabocean_generation(
    datadir("control.nc"),
    srcfile=datadir("domain.ocn.ne5np4_gx3v7.140810.nc"),
)

ds = NCDataset(datadir("control.nc"))
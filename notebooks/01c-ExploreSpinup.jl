### A Pluto.jl notebook ###
# v0.18.4

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ eaf67b04-b81b-11ec-3e04-2b408f63075b
begin
	using Pkg; Pkg.activate()
	using DrWatson
	md"Using DrWatson to ensure reproducibility between different machines ..."
end

# ╔═╡ aeb8d729-ee16-4fc1-8a57-788891085720
begin
	@quickactivate "AquaSlabIslands"
	using NCDatasets
	using Statistics
	using PlutoUI
	using Printf

	using ImageShow, PNGFiles
	using PyCall, LaTeXStrings
	pplt = pyimport("proplot")

	include(srcdir("cubedsphere2lonlat.jl"))

md"Loading modules for the AquaSlabIslands project..."
end

# ╔═╡ 93cf1f1e-9457-44ca-a8a2-8fed95d356e0
begin
	fol  = datadir("LINSOL_ROT_SLAB","atm","hist")
	fnc1 = joinpath(fol,"LINSOL_ROT_SLAB.cam.h1.0002-01-01-00000.nc")
end

# ╔═╡ d82b3667-4c4f-4c17-a15e-6ede94aac48d
begin
	ds1  = NCDataset(fnc1)
	lon  = nomissing(ds1["lon"][:])
	lat  = nomissing(ds1["lat"][:])
	tcw  = nomissing(ds1["TMQ"][:])
	tsfc = nomissing(ds1["TS"][:]) .- 273.15
	olr  = nomissing(ds1["FLUT"][:])
	u250 = nomissing(ds1["U250"][:])
	close(ds1)
end

# ╔═╡ c26f41bd-38da-4dc0-9fb4-0e990c40f464
begin
	cs2ll = CubedSphere2LonLat(lon,lat)
	ntcw  = zeros(cs2ll.nlon,cs2ll.nlat)
	ntsfc = zeros(cs2ll.nlon,cs2ll.nlat)
	nolr  = zeros(cs2ll.nlon,cs2ll.nlat)
	nu250 = zeros(cs2ll.nlon,cs2ll.nlat)
	md"Loading CubedSphere2LonLat Structure"
end

# ╔═╡ a3ddf7a7-5bfe-4d80-bf50-9749021d7b97
md"Create Animation? $(@bind createanim PlutoUI.Slider(0:1))"

# ╔═╡ dbc2072e-b7a6-484b-82e3-9aafaf2f9700
begin
	if isone(createanim)
		for it = 1 : 365
	
			pplt.close(); f,a = pplt.subplots(nrows=2,ncols=2,proj="ortho")
	
			cubedsphere2lonlat!(ntcw,tcw[:,it],cs2ll)
			c1 = a[1].pcolormesh(
				cs2ll.lon,cs2ll.lat,ntcw',levels=5:5:50,
				cmap="blues",extend="both"
			)
			a[1].colorbar(c1,length=0.75,loc="l",label="Precipitable Water / mm")
	
			cubedsphere2lonlat!(ntsfc,tsfc[:,it],cs2ll)
			c2 = a[2].pcolormesh(
				cs2ll.lon,cs2ll.lat,ntsfc',levels=-25:5:25,
				cmap="viridis",extend="both"
			)
			a[2].colorbar(c2,length=0.75,label=L"Surface Temperature / $\degree$C")
	
			cubedsphere2lonlat!(nolr,olr[:,it],cs2ll)
			c3 = a[3].pcolormesh(
				cs2ll.lon,cs2ll.lat,nolr',levels=100:10:250,
				cmap="greys",extend="both"
			)
			a[3].colorbar(c3,length=0.75,loc="l",label=L"OLR / W m$^{-2}$")
	
			cubedsphere2lonlat!(nu250,u250[:,it],cs2ll)
			c4 = a[4].pcolormesh(
				cs2ll.lon,cs2ll.lat,nu250',levels=-50:10:50,
				cmap="RdBu_r",extend="both"
			)
			a[4].colorbar(c4,length=0.75,label=L"Zonal Wind / m s$^{-1}$")
			a[4].format(suptitle="Day $(@sprintf("%03d",it+365))")
	
			mkpath(plotsdir("testaquaplanet"))
			f.savefig(
				plotsdir("testaquaplanet","$(@sprintf("%03d",it+365)).png"),
				transparent=false,dpi=150
			)
			load(plotsdir("testaquaplanet","$(@sprintf("%03d",it+365)).png"))
			
		end
	end
	
end

# ╔═╡ Cell order:
# ╟─eaf67b04-b81b-11ec-3e04-2b408f63075b
# ╟─aeb8d729-ee16-4fc1-8a57-788891085720
# ╟─93cf1f1e-9457-44ca-a8a2-8fed95d356e0
# ╟─d82b3667-4c4f-4c17-a15e-6ede94aac48d
# ╟─c26f41bd-38da-4dc0-9fb4-0e990c40f464
# ╟─a3ddf7a7-5bfe-4d80-bf50-9749021d7b97
# ╟─dbc2072e-b7a6-484b-82e3-9aafaf2f9700

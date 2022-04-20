### A Pluto.jl notebook ###
# v0.19.0

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

# ╔═╡ cd703f8e-df7b-4b88-944c-fa21699925c1
begin
	using Pkg; Pkg.activate()
	using DrWatson
	md"Using DrWatson to ensure reproducibility between different machines ..."
end

# ╔═╡ 3a01cb09-2fd2-4ab3-aa76-b4bc89618efd
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

# ╔═╡ 3b7b2c8a-bf67-11ec-1840-937c86d1d42d
md"
# 02c. Filtering out the Diurnal Cycle

In this notebook, we explore the diurnal cycle by doing a rolling average of the 24-hour meteorological fields.  This notebook is meant more as a test for later notebooks which may use the functions here with more seriousness.
"

# ╔═╡ 2c6e703d-ed23-4717-bb71-a6e00dc0d795
md"
### A. Preloading example data ...
"

# ╔═╡ a706fdd7-ada7-4257-afeb-cf77e1473ba6
expname = "DINSOL_NOROT_A"

# ╔═╡ 1bd39cf0-c1fc-437a-b971-1bbfd1b209b5
nx = 7

# ╔═╡ 5de52554-ac79-4333-9984-60827ab1d06f
ny = 3

# ╔═╡ 017746b2-3eb7-443a-a064-9df0b6536791
landconfig = "$(nx)x$(ny)"

# ╔═╡ 8cc8c1c5-6e81-43d4-ae79-8eabcbde342b
runname = "$(uppercase(expname))$(landconfig)"

# ╔═╡ 2438a528-fdbf-43ac-a2a7-34a606d4a241
begin
	fol = datadir("$(runname)","atm","hist")
	fnc = joinpath(fol,"$(runname).cam.h2.0002-01-01-00000.nc")
	ds   = NCDataset(fnc)
	lon  = nomissing(ds["lon"][:]); npnt = length(lon)
	lat  = nomissing(ds["lat"][:])
	tcw  = nomissing(ds["TMQ"][:]); nt = size(tcw,2)
	olr  = nomissing(ds["FLUT"][:])
	close(ds)
end

# ╔═╡ a23725da-d8b9-441f-ba6c-a9d442f8dadc
begin
	ntcw = zeros(npnt,nt-23)
	nolr = zeros(npnt,nt-23)
	md"Preallocating arrays ..."
end

# ╔═╡ 32529324-8643-4095-9aac-8d768e5af233
begin
	for it = 1 : (nt-23), ipnt = 1 : npnt
		ntcw[ipnt,it] = mean(@view tcw[ipnt,it:(it+23)])
		nolr[ipnt,it] = mean(@view olr[ipnt,it:(it+23)])
	end
	md"Performing daily mean ..."
end

# ╔═╡ faa63af0-16b0-4e4e-bc2c-8a9f8574f92f
begin
	cs2ll = CubedSphere2LonLat(lon,lat)
	traw  = zeros(cs2ll.nlon,cs2ll.nlat)
	tdymn = zeros(cs2ll.nlon,cs2ll.nlat)
	md"Loading CubedSphere2LonLat Structure"
end

# ╔═╡ f5f78827-3a45-4153-988f-8fab6977bd6b
begin
	pplt.close(); f1,a1 = pplt.subplots(nrows=2,aspect=3,axwidth=4)
	
	a1[1].plot((1:nt)/24,olr[1,:])
	a1[1].plot((12:(nt-12))/24,nolr[1,:])

	for ipnt = 1 : 10
		a1[2].plot((12:(nt-12))/24,olr[ipnt,12:(nt-12)] .- nolr[ipnt,:],lw=1)
	end

	a1[2].format(xlim=(20,40),xlocator=0:100)
	
	f1.savefig("test.png",transparent=false,dpi=150)
	load("test.png")
end

# ╔═╡ b526f2e9-730c-4663-861c-b81ffc98a54a
md"Create Animation? $(@bind createanim PlutoUI.Slider(0:1))"

# ╔═╡ 8ea9fc7e-b820-4f5d-a318-ee6aadae4557
begin
	if isone(createanim)
		for it = 1920 : 2160
	
			# it = 2000
			pplt.close(); f2,a2 = pplt.subplots(ncols=2,proj="ortho")
		
			# cubedsphere2lonlat!(traw,tcw[:,it+11],cs2ll)
			cubedsphere2lonlat!(traw,olr[:,it+11],cs2ll)
			# cubedsphere2lonlat!(tdymn,ntcw[:,it],cs2ll)
			cubedsphere2lonlat!(tdymn,nolr[:,it],cs2ll)
			
			c2_1 = a2[1].pcolormesh(
				cs2ll.lon,cs2ll.lat,tdymn',
				levels=150:10:300,cmap="greys",extend="both"
			)
			c2_2 = a2[2].pcolormesh(
				cs2ll.lon,cs2ll.lat,traw'.-tdymn',
				levels=vcat(-5:-1,1:5)*10,cmap="drywet",extend="both")
	
			a2[1].colorbar(c2_1,loc="l",length=0.8)
			a2[2].colorbar(c2_2,loc="r",length=0.8)
	
			idr = plotsdir("testdiurnal"); mkpath(idr)
			iid = @sprintf("%03d",it)
			f2.savefig(joinpath(idr,"test$iid.png"),transparent=false,dpi=150)
			load(joinpath(idr,"test$iid.png"))
		
		end
		md"Making animation ..."
	else
		md"Not creating animation, skipping to next cell ..."
	end
end

# ╔═╡ Cell order:
# ╟─3b7b2c8a-bf67-11ec-1840-937c86d1d42d
# ╟─cd703f8e-df7b-4b88-944c-fa21699925c1
# ╟─3a01cb09-2fd2-4ab3-aa76-b4bc89618efd
# ╟─2c6e703d-ed23-4717-bb71-a6e00dc0d795
# ╠═a706fdd7-ada7-4257-afeb-cf77e1473ba6
# ╠═1bd39cf0-c1fc-437a-b971-1bbfd1b209b5
# ╠═5de52554-ac79-4333-9984-60827ab1d06f
# ╠═017746b2-3eb7-443a-a064-9df0b6536791
# ╠═8cc8c1c5-6e81-43d4-ae79-8eabcbde342b
# ╟─2438a528-fdbf-43ac-a2a7-34a606d4a241
# ╟─a23725da-d8b9-441f-ba6c-a9d442f8dadc
# ╟─32529324-8643-4095-9aac-8d768e5af233
# ╟─faa63af0-16b0-4e4e-bc2c-8a9f8574f92f
# ╟─f5f78827-3a45-4153-988f-8fab6977bd6b
# ╟─b526f2e9-730c-4663-861c-b81ffc98a54a
# ╟─8ea9fc7e-b820-4f5d-a318-ee6aadae4557

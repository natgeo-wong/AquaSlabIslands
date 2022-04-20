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

# ╔═╡ 47e99bd5-f018-4ae7-97af-515328e9d79c
md"
# 02a. Landmass Configuration Spinup
"

# ╔═╡ 4c2a4c84-7d0d-45c2-9747-ac0df6580d52
expname = "DINSOL_NOROT_A"

# ╔═╡ d693c898-4c5c-4602-9ba9-23d12cee2c26
nx = 1

# ╔═╡ 98aa076c-303c-49df-8225-db72068bd76d
ny = 1

# ╔═╡ 8ee83f4f-84ef-4677-931e-aac435b083f1
landconfig = "$(nx)x$(ny)"

# ╔═╡ 5348a75b-da3a-4951-b707-8049adf14703
runname = "$(uppercase(expname))$(landconfig)"

# ╔═╡ 93cf1f1e-9457-44ca-a8a2-8fed95d356e0
begin
	fol  = datadir("$(runname)","atm","hist")
	fnc1 = joinpath(fol,"$(runname).cam.h1.0002-01-01-00000.nc")
end

# ╔═╡ d82b3667-4c4f-4c17-a15e-6ede94aac48d
begin
	ds1  = NCDataset(fnc1)
	lon  = nomissing(ds1["lon"][:])
	lat  = nomissing(ds1["lat"][:])
	tcw  = nomissing(ds1["TMQ"][:])
	tsfc = nomissing(ds1["TS"][:])
	olr  = nomissing(ds1["FLUT"][:])
	u250 = nomissing(ds1["U250"][:])
	prcp = nomissing(ds1["PRECT"][:]) * 86400 * 1000
	close(ds1)
end

# ╔═╡ c26f41bd-38da-4dc0-9fb4-0e990c40f464
begin
	cs2ll = CubedSphere2LonLat(lon,lat)
	ntcw  = zeros(cs2ll.nlon,cs2ll.nlat)
	ntsfc = zeros(cs2ll.nlon,cs2ll.nlat)
	nolr  = zeros(cs2ll.nlon,cs2ll.nlat)
	nu250 = zeros(cs2ll.nlon,cs2ll.nlat)
	nprcp = zeros(cs2ll.nlon,cs2ll.nlat)
	md"Loading CubedSphere2LonLat Structure"
end

# ╔═╡ a3ddf7a7-5bfe-4d80-bf50-9749021d7b97
md"Create Animation? $(@bind createanim PlutoUI.Slider(0:1))"

# ╔═╡ dbc2072e-b7a6-484b-82e3-9aafaf2f9700
begin
	if isone(createanim)
		for it = 100
	
			# it = 95
			pplt.close();
			f,a = pplt.subplots(nrows=2,ncols=2,proj="ortho",axwidth=1.5)
	
			cubedsphere2lonlat!(ntcw,tcw[:,it],cs2ll)
			c1 = a[1].pcolormesh(
				cs2ll.lon,cs2ll.lat,ntcw',levels=20:2:40,
				cmap="blues",extend="both"
			)
			a[1].colorbar(c1,length=0.75,loc="l",label="PWV / mm")
	
			cubedsphere2lonlat!(ntsfc,tsfc[:,it],cs2ll)
			c2 = a[2].pcolormesh(
				cs2ll.lon,cs2ll.lat,ntsfc',levels=295:305,
				cmap="viridis",extend="both"
			)
			a[2].colorbar(c2,length=0.75,label=L"$T_s$ / $\degree$C")
	
			cubedsphere2lonlat!(nolr,olr[:,it],cs2ll)
			c3 = a[3].pcolormesh(
				cs2ll.lon,cs2ll.lat,nolr',levels=150:10:300,
				cmap="greys",extend="both"
			)
			a[3].colorbar(c3,length=0.75,loc="l",label=L"OLR / W m$^{-2}$")
	
			cubedsphere2lonlat!(nprcp,prcp[:,it],cs2ll)
			c4 = a[4].pcolormesh(
				cs2ll.lon,cs2ll.lat,nprcp',levels=5:5:50,
				cmap="Blues",extend="both"
			)
			a[4].colorbar(c4,length=0.75,label=L"Rain Rate / mm day$^{-1}$")
			a[4].format(suptitle="Hour $(@sprintf("%04d",it))")

			pfol = plotsdir("$(runname)")
			mkpath(pfol)
			f.savefig(
				plotsdir("$(runname)","$(@sprintf("%04d",it)).png"),
				transparent=false,dpi=150
			)
			# load(plotsdir("$(runname)","$(@sprintf("%04d",it)).png"))
			
		end
		md"Created animation for $(uppercase(expname)) spinup"
	else
		md"Not creating animation, skipping to next cell ..."
	end
	
end

# ╔═╡ 3683a6ef-5025-4a62-be7b-770ed8948f78
load(plotsdir("$(runname)","$(@sprintf("%04d",100)).png"))

# ╔═╡ Cell order:
# ╟─47e99bd5-f018-4ae7-97af-515328e9d79c
# ╟─eaf67b04-b81b-11ec-3e04-2b408f63075b
# ╟─aeb8d729-ee16-4fc1-8a57-788891085720
# ╠═4c2a4c84-7d0d-45c2-9747-ac0df6580d52
# ╠═d693c898-4c5c-4602-9ba9-23d12cee2c26
# ╠═98aa076c-303c-49df-8225-db72068bd76d
# ╟─8ee83f4f-84ef-4677-931e-aac435b083f1
# ╟─5348a75b-da3a-4951-b707-8049adf14703
# ╟─93cf1f1e-9457-44ca-a8a2-8fed95d356e0
# ╟─d82b3667-4c4f-4c17-a15e-6ede94aac48d
# ╟─c26f41bd-38da-4dc0-9fb4-0e990c40f464
# ╠═a3ddf7a7-5bfe-4d80-bf50-9749021d7b97
# ╠═dbc2072e-b7a6-484b-82e3-9aafaf2f9700
# ╟─3683a6ef-5025-4a62-be7b-770ed8948f78

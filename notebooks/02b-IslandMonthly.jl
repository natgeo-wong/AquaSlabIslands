### A Pluto.jl notebook ###
# v0.19.0

using Markdown
using InteractiveUtils

# ╔═╡ c9beb18e-a3b7-4563-a158-af3a0e89e019
begin
	using Pkg; Pkg.activate()
	using DrWatson
	md"Using DrWatson to ensure reproducibility between different machines ..."
end

# ╔═╡ 3b18a7ef-b0c7-4cee-9d19-4eb734687d64
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

# ╔═╡ a9ccb5a2-bd0d-11ec-13c3-5f5af9b5536a
md"
# 02b. Overview of Island Data

For each of the configurations we ran the model for 1000 days and collected the results.
"

# ╔═╡ a0b40e50-b481-4cb1-95d1-5461fb2306d0
md"
### A. Loading and plotting monthly data ...
"

# ╔═╡ 63a176bb-ac16-4dcf-8619-a1ea51130d26
expname = "DINSOL_NOROT_C"

# ╔═╡ 248c5f6d-c18a-4ada-8dba-1447067600c6
nx = 7

# ╔═╡ 5e386baf-515e-42eb-89d1-3b7319a66e84
ny = 3

# ╔═╡ ce6ba673-dc3f-429d-b81b-e8b85f32b466
landconfig = "$(nx)x$(ny)"

# ╔═╡ 7bf2e2a4-4ab6-42b0-b044-c997e05b0cff
runname = "$(uppercase(expname))$(landconfig)"

# ╔═╡ 37b063a3-1581-45a9-b0fc-be6895e643b2
begin
	fol  = datadir("$(runname)","atm","hist")
	fnc  = joinpath(fol,"$(runname).cam.h0.0005-09-28-00000.nc")
	ds   = NCDataset(fnc)
	lon  = nomissing(ds["lon"][:])
	lat  = nomissing(ds["lat"][:])
	lvl  = nomissing(ds["lev"][:]); nlvl = length(lvl)
	tcw  = dropdims(mean(nomissing(ds["TMQ"][:]),dims=2),dims=2)
	tsfc = dropdims(mean(nomissing(ds["TS"][:]),dims=2),dims=2)
	olr  = dropdims(mean(nomissing(ds["FLUT"][:]),dims=2),dims=2)
	prcp = dropdims(mean(nomissing(ds["PRECC"][:]),dims=2),dims=2) * 86400 * 1000
	wair = nomissing(ds["OMEGA"][:])
	uair = nomissing(ds["U"][:])
	cld  = nomissing(ds["CLOUD"][:])
	rhum = nomissing(ds["RELHUM"][:])
	close(ds)
	md"Loading monthly data ..."
end

# ╔═╡ cb40f054-d624-4c19-b37d-1743d51b0f27
begin
	cs2ll = CubedSphere2LonLat(lon,lat)
	ntcw  = zeros(cs2ll.nlon,cs2ll.nlat)
	ntsfc = zeros(cs2ll.nlon,cs2ll.nlat)
	nolr  = zeros(cs2ll.nlon,cs2ll.nlat)
	nprcp = zeros(cs2ll.nlon,cs2ll.nlat)
	nwair = zeros(cs2ll.nlon,cs2ll.nlat,nlvl)
	nuair = zeros(cs2ll.nlon,cs2ll.nlat,nlvl)
	ncld  = zeros(cs2ll.nlon,cs2ll.nlat,nlvl)
	nrhum = zeros(cs2ll.nlon,cs2ll.nlat,nlvl)
	md"Loading CubedSphere2LonLat Structure"
end

# ╔═╡ a32fbc7a-02aa-4b0d-a691-b86765be1841
begin
	pplt.close(); fig,axs = pplt.subplots(
		nrows=2,ncols=2,
		# axwidth=2.5,proj="moll",aspect=2,
		axwidth=2,proj="ortho",
		proj_kw=Dict("lon_0"=>00,"lat_0"=>0)
	)
	
	cubedsphere2lonlat!(ntcw,tcw,cs2ll)
	c1μ = axs[1].pcolormesh(
		cs2ll.lon,cs2ll.lat,ntcw',levels=28:38,
		cmap="blues",extend="both"
	)
	axs[1].colorbar(c1μ,length=0.75,loc="l",label="PWV / mm")
	
	cubedsphere2lonlat!(ntsfc,tsfc.-300,cs2ll)
	c2μ = axs[2].pcolormesh(
		cs2ll.lon,cs2ll.lat,ntsfc',levels=-2:0.2:2,
		cmap="RdBu_r",extend="both"
	)
	axs[2].colorbar(c2μ,length=0.75,label=L"$T_s$ / $\degree$C",
		locator=-2:1:2,minorlocator=0.2)
	
	cubedsphere2lonlat!(nolr,olr,cs2ll)
	c3μ = axs[3].pcolormesh(
		cs2ll.lon,cs2ll.lat,nolr',levels=200:10:300,
		cmap="greys",extend="both"
	)
	axs[3].colorbar(c3μ,length=0.75,loc="l",label=L"OLR / W m$^{-2}$")
	
	cubedsphere2lonlat!(nprcp,prcp,cs2ll)
	c4μ = axs[4].pcolormesh(
		cs2ll.lon,cs2ll.lat,nprcp',levels=1:10,
		cmap="Blues",extend="both"
	)
	axs[4].colorbar(c4μ,length=0.75,label=L"Rain Rate / mm day$^{-1}$")
	axs[4].format(suptitle="$runname | Mean")
	
	fig.savefig(plotsdir("02b-$(runname)_mean.png"),transparent=false,dpi=300)
	load(plotsdir("02b-$(runname)_mean.png"))
end

# ╔═╡ e1429fc9-410a-4c81-b170-367aabe4ecca
md"
### B. Zonal Asymmetries in the Climatology
"

# ╔═╡ c32eeaff-f2d2-493c-9a52-28e2e980e077
begin
	pplt.close(); f2,a2 = pplt.subplots(nrows=3,aspect=3,axwidth=5)

	clvl = [-10,-5,-2,-1,-0.5,0.5,1,2,5,10] / 100

	for ilvl = 1 : nlvl
		iwair = @view nwair[:,:,ilvl]
		iuair = @view nuair[:,:,ilvl]
		icld  = @view ncld[:,:,ilvl]
		irhum = @view nrhum[:,:,ilvl]
		cubedsphere2lonlat!(iwair,wair[:,ilvl],cs2ll)
		cubedsphere2lonlat!(iuair,uair[:,ilvl],cs2ll)
		cubedsphere2lonlat!(icld,cld[:,ilvl],cs2ll)
		cubedsphere2lonlat!(irhum,rhum[:,ilvl],cs2ll)
	end
	wair_zon = dropdims(mean(nwair[:,abs.(cs2ll.lat) .<15,:],dims=2),dims=2)
	uair_zon = dropdims(mean(nuair[:,abs.(cs2ll.lat) .<15,:],dims=2),dims=2)
	cld_zon  = dropdims(mean(ncld[:,abs.(cs2ll.lat) .<15,:],dims=2),dims=2)
	rhum_zon = dropdims(mean(nrhum[:,abs.(cs2ll.lat) .<15,:],dims=2),dims=2)
	
	cw = a2[1].contourf(cs2ll.lon,lvl,wair_zon',levels=clvl,cmap="RdBu",extend="both")
	a2[1].format(xlim=(0,180),ylim=(1000,25),yscale="log")
	a2[1].colorbar(cw,label=L"Pa s$^{-1}$")

	a2[1].quiver(
		cs2ll.lon[1:6:end],lvl,
		uair_zon[1:6:end,1:end]'/50,
		-wair_zon[1:6:end,1:end]',
	)
	
	ccld = a2[2].contourf(
		cs2ll.lon,lvl,cld_zon'*100,levels=10:10:90,
		cmap="Blues",extend="both"
	)
	a2[2].format(xlim=(0,180),ylim=(1000,25),yscale="log")
	a2[2].colorbar(ccld,label="Cloud Cover / %")
	
	ccld = a2[3].contourf(
		cs2ll.lon,lvl,rhum_zon',
		levels=10:10:90,
		cmap="Blues",extend="both"
	)
	a2[3].format(xlim=(-180,180),ylim=(1000,25),yscale="log")
	a2[3].colorbar(ccld,label="Relative Humidity / %")

	a2[1].format(suptitle="$runname | Vertical Profiles")
	
	f2.savefig(plotsdir("02b-$(runname)_zonalasym.png"),transparent=false,dpi=300)
	load(plotsdir("02b-$(runname)_zonalasym.png"))
end

# ╔═╡ Cell order:
# ╟─a9ccb5a2-bd0d-11ec-13c3-5f5af9b5536a
# ╟─c9beb18e-a3b7-4563-a158-af3a0e89e019
# ╟─3b18a7ef-b0c7-4cee-9d19-4eb734687d64
# ╟─a0b40e50-b481-4cb1-95d1-5461fb2306d0
# ╠═63a176bb-ac16-4dcf-8619-a1ea51130d26
# ╠═248c5f6d-c18a-4ada-8dba-1447067600c6
# ╠═5e386baf-515e-42eb-89d1-3b7319a66e84
# ╟─ce6ba673-dc3f-429d-b81b-e8b85f32b466
# ╠═7bf2e2a4-4ab6-42b0-b044-c997e05b0cff
# ╟─37b063a3-1581-45a9-b0fc-be6895e643b2
# ╟─cb40f054-d624-4c19-b37d-1743d51b0f27
# ╟─a32fbc7a-02aa-4b0d-a691-b86765be1841
# ╟─e1429fc9-410a-4c81-b170-367aabe4ecca
# ╟─c32eeaff-f2d2-493c-9a52-28e2e980e077

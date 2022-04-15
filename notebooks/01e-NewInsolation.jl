### A Pluto.jl notebook ###
# v0.18.4

using Markdown
using InteractiveUtils

# ╔═╡ 75baa984-b351-454f-8f90-cc944d0915b8
begin
	using Pkg; Pkg.activate()
	using DrWatson
	md"Using DrWatson to ensure reproducibility between different machines ..."
end

# ╔═╡ 3c1f3504-7793-4b88-bfda-914b28e3bae9
begin
	@quickactivate "AquaSlabIslands"
	using NCDatasets
	using Statistics

	using ImageShow, PNGFiles
	using PyCall, LaTeXStrings
	pplt = pyimport("proplot")

	include(srcdir("cubedsphere2lonlat.jl"))

md"Loading modules for the AquaSlabIslands project..."
end

# ╔═╡ 71e1d56a-b87f-11ec-37b5-fdc9c05de232
md"
# 01e. Testing a new Insolation Code

For this project, we made changes to the `radiation.F90` code, specifically that we can specify an insolation diurnal cycle of uniform amplitude and phases across the globe (i.e. a global RCE simulation except with a diurnal cycle).  This notebook allows us to visualize the `SOLIN` variable and see if the code works as intended.
"

# ╔═╡ 908d0f9d-e114-4a33-b006-2f84dbc7a441
begin
	ds  = NCDataset(datadir(
		"DINSOL_ROT_FIXED","atm","hist",
		"DINSOL_ROT_FIXED.cam.h0.0001-01-05-00000.nc"
	))
	lon = nomissing(ds["lon"][:,1])
	lat = nomissing(ds["lat"][:,1])
	sol = nomissing(ds["SOLIN"][:,1])
	close(ds)
end

# ╔═╡ d8917219-918d-44fb-939a-da2156657faa
begin
	cs2ll = CubedSphere2LonLat(lon,lat)
	nsol  = zeros(cs2ll.nlon,cs2ll.nlat)
	cubedsphere2lonlat!(nsol,sol,cs2ll)
	md"Loading CubedSphere2LonLat Structure"
end

# ╔═╡ 16d85a8f-b05d-4706-83b0-560e086ed902
begin
	pplt.close(); fig,axs = pplt.subplots(proj="ortho",proj_kw=Dict("lon_0"=>180))
	
	c = axs[1].pcolormesh(cs2ll.lon,cs2ll.lat,nsol',extend="both",levels=50:50:550)

	fig.colorbar(c,loc="r")
	fig.savefig("test.png",transparent=false,dpi=150)
	load("test.png")
end

# ╔═╡ 4fa23be8-1814-463b-9435-27407a80d365
maximum(sol)

# ╔═╡ Cell order:
# ╟─71e1d56a-b87f-11ec-37b5-fdc9c05de232
# ╟─75baa984-b351-454f-8f90-cc944d0915b8
# ╟─3c1f3504-7793-4b88-bfda-914b28e3bae9
# ╠═908d0f9d-e114-4a33-b006-2f84dbc7a441
# ╠═d8917219-918d-44fb-939a-da2156657faa
# ╠═16d85a8f-b05d-4706-83b0-560e086ed902
# ╠═4fa23be8-1814-463b-9435-27407a80d365

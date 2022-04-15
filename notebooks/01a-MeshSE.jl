### A Pluto.jl notebook ###
# v0.18.4

using Markdown
using InteractiveUtils

# ╔═╡ ee88d71e-5c0e-4b91-9178-c8d2156ab3e4
begin
	using Pkg; Pkg.activate()
	using DrWatson
	md"Using DrWatson to ensure reproducibility between different machines ..."
end

# ╔═╡ 00d52eb4-cdca-4889-87b3-f30bbfb488e6
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

# ╔═╡ a1109930-b626-11ec-3519-f9621a278916
md"
# 01a. The Spectral Element Mesh

In the `AquaplanetIslands` project, we attempt to use the new Spectral-Element mesh of CAMv6, knowing that for RCE-esque simulations the cubed-spherical mesh is more appropriate than the normal Finite-Volume mesh (though FV3 i.e. cubed-sphere FV remains to be seen) because the grid sizes are roughly equal in the SE-mesh.

However, Aquaplanet Slab-Ocean Model (SOM) is not fully supported in this mode.  Thus, our first order of business is to explore the Spectral Element Mesh makeup in the hopes that eventually we can create the SE-mesh equivalent of the SOM forcing files.
"

# ╔═╡ fd0bbfe4-5f38-4893-adb1-b10cf058236c
md"
### A. Visualizing the Spectral-Element Domain

The nice thing about CAM (and CESM in general) is that when you request for a particular grid mesh, they will download it into a shared repository.  I symlinked the `inputdata` directory to the project folder so that it is easily accessible, though anybody who wishes to replicate this must symlink to their own `inputdata` directory folder.
"

# ╔═╡ cb066087-18e6-4015-8a5e-fa67374d3e14
begin
	# Ocean grid by default is located at $DIN_LOC_ROOT/share/domains/domain.ocn.ne5np4_gx3v7.140810.nc
	fnc = projectdir("inputdata","share","domains","domain.ocn.ne5np4_gx3v7.140810.nc")
	ds  = NCDataset(fnc)
	xv  = ds["xv"][1:4,:,1]
	yv  = ds["yv"][1:4,:,1]
	xc  = ds["xc"][:,1]; ncell = length(xc)
	yc  = ds["yc"][:,1]
	msk = ds["mask"][:,1]
	are = ds["area"][:,1]
	afr = ds["frac"][:,1]
	close(ds)
	md"Loading Spectral-Element Grid at 6º horizontal resolution"
end

# ╔═╡ 7262434c-6dc1-4892-a093-2fdd96b56584
begin
	pplt.close()
	fig_1 = pplt.figure()
	gsp_1 = pplt.GridSpec(ncols=3,nrows=2)
	ax1_1 = fig_1.subplot(gsp_1[1],proj="ortho",proj_kw=Dict("lon_0"=>0))
	ax2_1 = fig_1.subplot(gsp_1[2],proj="ortho",proj_kw=Dict("lon_0"=>0,"lat_0"=>90))
	ax3_1 = fig_1.subplot(gsp_1[3],proj="ortho",proj_kw=Dict("lon_0"=>0,"lat_0"=>-90))
	ax4_1 = fig_1.subplot(gsp_1[4],proj="ortho",proj_kw=Dict("lon_0"=>90))
	ax5_1 = fig_1.subplot(gsp_1[5],proj="ortho",proj_kw=Dict("lon_0"=>180))
	ax6_1 = fig_1.subplot(gsp_1[6],proj="ortho",proj_kw=Dict("lon_0"=>270))

	for icell = 1 : ncell

		x = xv[:,icell]
		y = yv[:,icell]
		x360 = x .> 225
		x000 = x .< 135
		if !iszero(sum(x360)) && !iszero(sum(x000))
			x[x.<135] .+= 360
		end
		
		ax1_1.plot(x,y,c="grey",lw=0.5)
		ax2_1.plot(x,y,c="grey",lw=0.5)
		ax3_1.plot(x,y,c="grey",lw=0.5)
		ax4_1.plot(x,y,c="grey",lw=0.5)
		ax5_1.plot(x,y,c="grey",lw=0.5)
		ax6_1.plot(x,y,c="grey",lw=0.5)
		
	end

	ax1_1.format(coast=true,grid=false)
	ax2_1.format(coast=true,grid=false)
	ax3_1.format(coast=true,grid=false)
	ax4_1.format(coast=true,grid=false)
	ax5_1.format(coast=true,grid=false)
	ax6_1.format(coast=true,grid=false)
	
	fig_1.savefig(plotsdir("01a-SEgridexample_grid.png"),transparent=false,dpi=300)
	load(plotsdir("01a-SEgridexample_grid.png"))
end

# ╔═╡ 633ab765-0095-4649-9a89-c36d7c76ea0f
md"Now plotting with the datapoints (the fraction of the cell that is active) as scatter points ..."

# ╔═╡ 75d23c99-f2e5-4641-90d9-622b90a744c4
begin
	pplt.close()
	fig_2 = pplt.figure()
	gsp_2 = pplt.GridSpec(ncols=3,nrows=2)
	ax1_2 = fig_2.subplot(gsp_2[1],proj="ortho",proj_kw=Dict("lon_0"=>0))
	ax2_2 = fig_2.subplot(gsp_2[2],proj="ortho",proj_kw=Dict("lon_0"=>0,"lat_0"=>90))
	ax3_2 = fig_2.subplot(gsp_2[3],proj="ortho",proj_kw=Dict("lon_0"=>0,"lat_0"=>-90))
	ax4_2 = fig_2.subplot(gsp_2[4],proj="ortho",proj_kw=Dict("lon_0"=>90))
	ax5_2 = fig_2.subplot(gsp_2[5],proj="ortho",proj_kw=Dict("lon_0"=>180))
	ax6_2 = fig_2.subplot(gsp_2[6],proj="ortho",proj_kw=Dict("lon_0"=>270))

	cmap_dict = Dict("left"=>0.1,"right"=>0.9)
	
	ax1_2.scatter(xc,yc,c=afr,s=10,cmap="delta_r",cmap_kw=cmap_dict)
	ax2_2.scatter(xc,yc,c=afr,s=10,cmap="delta_r",cmap_kw=cmap_dict)
	ax3_2.scatter(xc,yc,c=afr,s=10,cmap="delta_r",cmap_kw=cmap_dict)
	ax4_2.scatter(xc,yc,c=afr,s=10,cmap="delta_r",cmap_kw=cmap_dict)
	ax5_2.scatter(xc,yc,c=afr,s=10,cmap="delta_r",cmap_kw=cmap_dict)
	ax6_2.scatter(xc,yc,c=afr,s=10,cmap="delta_r",cmap_kw=cmap_dict)

	for icell = 1 : ncell

		x = xv[:,icell]
		y = yv[:,icell]
		x360 = x .> 225
		x000 = x .< 135
		if !iszero(sum(x360)) && !iszero(sum(x000))
			x[x.<135] .+= 360
		end
		
		ax1_2.plot(x,y,c="grey",lw=0.5)
		ax2_2.plot(x,y,c="grey",lw=0.5)
		ax3_2.plot(x,y,c="grey",lw=0.5)
		ax4_2.plot(x,y,c="grey",lw=0.5)
		ax5_2.plot(x,y,c="grey",lw=0.5)
		ax6_2.plot(x,y,c="grey",lw=0.5)
		
	end

	ax1_2.format(coast=true,grid=false)
	ax2_2.format(coast=true,grid=false)
	ax3_2.format(coast=true,grid=false)
	ax4_2.format(coast=true,grid=false)
	ax5_2.format(coast=true,grid=false)
	ax6_2.format(coast=true,grid=false)
	
	fig_2.savefig(plotsdir("01a-SEgridexample_data.png"),transparent=false,dpi=300)
	load(plotsdir("01a-SEgridexample_data.png"))
end

# ╔═╡ 06f2cd9c-21f1-446e-ba83-1da36882a7f9
md"
### B. Notes on the Spectral-Element Domain Structure

Loading the data from the SE-domain file, we see that there are `(xv,yv)` points defining the boundaries of the grid cell, and `(xc,yc)` points defining their center.  We also see that similar to the FV-domain file there are the values `mask` and `area`, though there is also the `frac` which denotes the fraction of the grid cell that is active.

More specifically `frac` is the proportion of the cell that contains the ocean, while `mask` denotes whether a cell HAS ocean in it.

So, for our experiments in this project, we set both `mask` and `frac` to be 1 for all points, since what we are varying in this case is the _**slab depth**_ as a proxy to land (i.e. the only difference between land and ocean is the heat-capacity of the mixed layer).
"

# ╔═╡ 50d62d36-d5e3-45dd-8325-fac24d13265b
md"
### C. Plotting a Cubed-Sphere Grid

From the above plots, it can be seen that the cubed-sphere grid (obviously) is not a regular lon-lat grid, and in fact cannot be transformed into one.  Therefore, in order to proper plot contours and meshes for our data, we interpolate the data from the cubed-sphere spectral element grid onto a regular longitude-latitude grid.
"

# ╔═╡ 2089f8ae-e391-44a4-9497-95ea3334197a
begin
	cs2ll = CubedSphere2LonLat(xc,yc,resolution_lon=1,resolution_lat=1)
	ndata = zeros(cs2ll.nlon,cs2ll.nlat)
	cubedsphere2lonlat!(ndata,afr,cs2ll)
	md"Transforming cubed-sphere data to longitude-latitude coordinates ..."
end

# ╔═╡ 3fc07c38-d9db-4b85-ae49-ff0edf8d35e2
begin
	pplt.close()
	fig_3 = pplt.figure()
	gsp_3 = pplt.GridSpec(ncols=3,nrows=2)
	ax1_3 = fig_3.subplot(gsp_3[1],proj="ortho",proj_kw=Dict("lon_0"=>0))
	ax2_3 = fig_3.subplot(gsp_3[2],proj="ortho",proj_kw=Dict("lon_0"=>0,"lat_0"=>90))
	ax3_3 = fig_3.subplot(gsp_3[3],proj="ortho",proj_kw=Dict("lon_0"=>0,"lat_0"=>-90))
	ax4_3 = fig_3.subplot(gsp_3[4],proj="ortho",proj_kw=Dict("lon_0"=>90))
	ax5_3 = fig_3.subplot(gsp_3[5],proj="ortho",proj_kw=Dict("lon_0"=>180))
	ax6_3 = fig_3.subplot(gsp_3[6],proj="ortho",proj_kw=Dict("lon_0"=>270))
	
	c = ax1_3.pcolormesh(
		cs2ll.lon,cs2ll.lat,ndata',levels=0.1:0.1:0.9,
		cmap="delta_r",cmap_kw=cmap_dict,extend="both"
	)
	ax2_3.pcolormesh(
		cs2ll.lon,cs2ll.lat,ndata',levels=0.1:0.1:0.9,
		cmap="delta_r",cmap_kw=cmap_dict,extend="both"
	)
	ax3_3.pcolormesh(
		cs2ll.lon,cs2ll.lat,ndata',levels=0.1:0.1:0.9,
		cmap="delta_r",cmap_kw=cmap_dict,extend="both"
	)
	ax4_3.pcolormesh(
		cs2ll.lon,cs2ll.lat,ndata',levels=0.1:0.1:0.9,
		cmap="delta_r",cmap_kw=cmap_dict,extend="both"
	)
	ax5_3.pcolormesh(
		cs2ll.lon,cs2ll.lat,ndata',levels=0.1:0.1:0.9,
		cmap="delta_r",cmap_kw=cmap_dict,extend="both"
	)
	ax6_3.pcolormesh(
		cs2ll.lon,cs2ll.lat,ndata',levels=0.1:0.1:0.9,
		cmap="delta_r",cmap_kw=cmap_dict,extend="both"
	)

	for icell = 1 : ncell

		x = xv[:,icell]
		y = yv[:,icell]
		x360 = x .> 225
		x000 = x .< 135
		if !iszero(sum(x360)) && !iszero(sum(x000))
			x[x.<135] .+= 360
		end
		
		ax1_3.plot(x,y,c="grey",lw=0.5)
		ax2_3.plot(x,y,c="grey",lw=0.5)
		ax3_3.plot(x,y,c="grey",lw=0.5)
		ax4_3.plot(x,y,c="grey",lw=0.5)
		ax5_3.plot(x,y,c="grey",lw=0.5)
		ax6_3.plot(x,y,c="grey",lw=0.5)
		
	end

	ax1_3.format(coast=true)
	ax2_3.format(coast=true)
	ax3_3.format(coast=true)
	ax4_3.format(coast=true)
	ax5_3.format(coast=true)
	ax6_3.format(coast=true)

	fig_3.colorbar(c,length=0.5)
	fig_3.savefig(plotsdir("01a-SEgridexample_lonlat.png"),transparent=false,dpi=300)
	load(plotsdir("01a-SEgridexample_lonlat.png"))
end

# ╔═╡ eec04d76-78bf-4246-900a-e77788e6aed9
md"We do see that the nearest-neighbour interpolation method doesn't always match up with the grid-vertices.  But it generally is close enough that it is representative.  And the importance of these errors should decrease as the resolution increases.  In this example, the grid-size is roughly 6º, but we will likely be running simulations at ~1º instead"

# ╔═╡ Cell order:
# ╟─a1109930-b626-11ec-3519-f9621a278916
# ╟─ee88d71e-5c0e-4b91-9178-c8d2156ab3e4
# ╟─00d52eb4-cdca-4889-87b3-f30bbfb488e6
# ╟─fd0bbfe4-5f38-4893-adb1-b10cf058236c
# ╟─cb066087-18e6-4015-8a5e-fa67374d3e14
# ╠═7262434c-6dc1-4892-a093-2fdd96b56584
# ╟─633ab765-0095-4649-9a89-c36d7c76ea0f
# ╟─75d23c99-f2e5-4641-90d9-622b90a744c4
# ╟─06f2cd9c-21f1-446e-ba83-1da36882a7f9
# ╟─50d62d36-d5e3-45dd-8325-fac24d13265b
# ╟─2089f8ae-e391-44a4-9497-95ea3334197a
# ╟─3fc07c38-d9db-4b85-ae49-ff0edf8d35e2
# ╟─eec04d76-78bf-4246-900a-e77788e6aed9

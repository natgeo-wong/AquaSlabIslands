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

# ╔═╡ adad459e-b842-11ec-15b3-a700e0b631d4
begin
	using Pkg; Pkg.activate()
	using DrWatson
	md"Using DrWatson to ensure reproducibility between different machines ..."
end

# ╔═╡ 970fea27-4f24-44c3-b4b9-a8c4680c828d
begin
	@quickactivate "AquaSlabIslands"
	using GeoRegions
	using NCDatasets
	using PlutoUI

	using ImageShow, PNGFiles
	using PyCall, LaTeXStrings
	pplt = pyimport("proplot")

	include(srcdir("cubedsphere2lonlat.jl"))
	include(srcdir("slaboceangen.jl"))
	include(srcdir("landmasses.jl"))

md"Loading modules for the AquaSlabIslands project..."
end

# ╔═╡ 23d70adf-c263-40ea-8d92-6b44d0296286
md"
# 01d. Creating Shallow Slab-Depth Islands

In this notebook, we create regions of shallow slab-depth based on GeoRegion text files.
"

# ╔═╡ 84a363a6-a100-4ec2-8e9c-a171fa77ab5f
md"Is SST in RCE? $(@bind issstRCE PlutoUI.Slider(0:1,default=1))"

# ╔═╡ 0545daf7-27bd-4937-ba7d-342723234f5e
if isone(issstRCE)
	  sstconfig = "rce300K"
else; sstconfig = "control"
end

# ╔═╡ 246b836d-32b8-41fe-a093-ab92a31b2525
nx = 7

# ╔═╡ 0ceef88f-5038-479c-b59c-1c96afa48811
ny = 3

# ╔═╡ a9a79642-7372-4514-8a34-6f70fc98a3b0
md"Is Archipelago? $(@bind isarchipelago PlutoUI.Slider(0:1))"

# ╔═╡ c205b538-c8a1-4e96-9681-41917901ad20
if isone(isarchipelago)
	landtype = "archipelago"
else
	landtype = "continent"
end

# ╔═╡ 24465e12-fc78-454e-a214-d16be0199412
landconfig = "$(landtype)_$(nx)x$(ny)"

# ╔═╡ 5615e529-ee84-4de4-8b0c-635f7cae240e
config = "$(sstconfig)-$(landconfig)"

# ╔═╡ 8a4a4054-be83-48d0-9298-665b92e45920
md"
### A. Loading Island Bounds from GeoRegion Textfile
"

# ╔═╡ f0aea29d-a88a-47fb-959a-fa0590c66502
if isone(isarchipelago)
	geovec = archipelago(nx=nx,ny=ny)
else
	geovec = [continent(continent_lon=(2*nx-1)*4,continent_lat=(2*ny-1)*4)]
end

# ╔═╡ 89704ace-ea38-429b-b8ef-ca6b1fcd2a0f
begin
	pplt.close(); f1,a1 = pplt.subplots(proj="ortho",proj_kw=Dict("lon_0"=>120))

	for geo in geovec
		blon,blat = coordGeoRegion(geo)
		a1[1].plot(blon.+120,blat,c="r")
	end
	a1[1].format(coast=true)
	
	f1.savefig(plotsdir("01d-createislands_bounds.png"),transparent=false,dpi=150)
	load(plotsdir("01d-createislands_bounds.png"))
end

# ╔═╡ b76af22e-fccb-419e-9c44-71e1d609ece5
md"
### B. Making and Modifying a new Slab-Ocean File for the Configuration
"

# ╔═╡ 5d25c431-ec66-47a0-bc94-c5a3d2ed9e5c
begin
	mkpath(projectdir("userdata","slabocean_input"))
	dnc = projectdir("inputdata","share","domains","domain.ocn.ne30_gx1v7.171003.nc")
	nnc = projectdir("userdata","OCN_SOM","nwong_aquaslabislands-$(config).nc")
	nds = slabocean_generation(nnc,srcfile=dnc,control=false)
	md"Make new slab-ocean file for the \"$(config)\" configuration ..."
end

# ╔═╡ c3e014f0-6ae2-4892-b493-decf3b3e06f5
begin
	lon = nomissing(nds["xc"][:,1])
	lat = nomissing(nds["yc"][:,1])
	# slb = nomissing(nds["hblt"][:,1,1])
	pnt = Point2.(lon,lat)
	npt = length(pnt)
	lnd = zeros(npt)

	for geo in geovec, ipt = 1 : npt
		if isinGeoRegion(pnt[ipt],geo,throw=false)
			lnd[ipt] += 1
		end
	end

	lnd = Float32.(.!iszero.(lnd))

	if isone(issstRCE)
		nds["hblt"].var[:] .= 1.e9
		nds["T"].var[:] .= 26.85
	else
		for ipnt = 1 : npt
			ilat = lat[ipnt]
			if abs.(ilat) < 60
				  nds["T"].var[ipnt,:,:] .= 27 * (2 - sind(ilat*1.5)^2 - sind(ilat*1.5)^4) / 2
			else; nds["T"].var[ipnt,:,:] .= 0
			end
		end
	end

	for ilnd = 1 : npt
		if !iszero(lnd[ilnd])
			nds["hblt"].var[ilnd,:,:] .= 0.2
		end
	end
	
	close(nds)

	md"Modifying slab depth for the points with islands ..."
end

# ╔═╡ 73b0ecf8-e544-4f20-8d6f-52adc3740dfc
begin
	cs2ll = CubedSphere2LonLat(lon,lat)
	mask = zeros(cs2ll.nlon,cs2ll.nlat)
	cubedsphere2lonlat!(mask,lnd,cs2ll)
	md"Loading CubedSphere2LonLat Structure"
end

# ╔═╡ 1f2f5927-5594-4af1-a1d7-30764613e3dc
begin
	pplt.close(); f2,a2 = pplt.subplots(proj="ortho",proj_kw=Dict("lon_0"=>120))
	
	for geo in geovec
		blon,blat = coordGeoRegion(geo)
		a2[1].plot(blon.+120,blat,c="r")
	end
	
	c = a2[1].pcolormesh(
		cs2ll.lon.+120,cs2ll.lat,mask',
		cmap="delta",extend="both",cmap_kw=Dict("right"=>0.8,"left"=>0.45)
	)
	a2[1].format(coast=true)
	
	f2.savefig(plotsdir("01d-createislands_mask.png"),transparent=false,dpi=150)
	load(plotsdir("01d-createislands_mask.png"))
end

# ╔═╡ 3b118c8b-6e79-419b-99c4-5d0812dc5169
md"
### C. Double Checking the Slab-Ocean file
"

# ╔═╡ ef33cfbf-8ffd-44d6-9046-7a239cc9a9d3
begin
	ds = NCDataset(nnc)
	slb  = nomissing(ds["hblt"][:,1,1])
	tsfc = nomissing(ds["T"][:,1,1])
	nslb = zeros(cs2ll.nlon,cs2ll.nlat)
	ntsf = zeros(cs2ll.nlon,cs2ll.nlat)
	cubedsphere2lonlat!(nslb,slb,cs2ll)
	cubedsphere2lonlat!(ntsf,tsfc,cs2ll)
	close(ds)
end

# ╔═╡ 7bbecfcf-19f6-4886-a580-98f2760e23e0
begin
	pplt.close(); f3,a3 = pplt.subplots(proj="ortho",proj_kw=Dict("lon_0"=>120))
	
	for geo in geovec
		blon,blat = coordGeoRegion(geo)
		a3[1].plot(blon.+120,blat,c="r")
	end
	
	c3 = a3[1].pcolormesh(
		cs2ll.lon.+120,cs2ll.lat,nslb',
		cmap="Blues",extend="both",cmap_kw=Dict("right"=>0.9)
	)
	a3[1].format(coast=true)

	f3.colorbar(c3)
	f3.savefig(plotsdir("01d-createislands_check.png"),transparent=false,dpi=150)
	load(plotsdir("01d-createislands_check.png"))
end

# ╔═╡ 4f02e5a0-20cb-48b6-b727-78fa82dbcbf8
md"
### D. Compiling all the Figures together ...
"

# ╔═╡ da18d524-3e37-4110-b8a9-49f332bd9f91
begin
	pplt.close()
	fig,axs = pplt.subplots(axwidth=2,ncols=2,nrows=2,proj="ortho",proj_kw=Dict("lon_0"=>120))

	axs[2].pcolormesh(
		cs2ll.lon.+120,cs2ll.lat,mask',
		cmap="delta",extend="both",cmap_kw=Dict("right"=>0.8,"left"=>0.45)
	)
	
	clr_slb = axs[3].pcolormesh(
		cs2ll.lon.+120,cs2ll.lat,nslb',
		cmap="Blues",extend="both",cmap_kw=Dict("right"=>0.9)
	)
	
	clr_t = axs[4].pcolormesh(
		cs2ll.lon.+120,cs2ll.lat,ntsf',levels=0:2.5:25,
		cmap="viridis",extend="both"
	)

	for ax in axs
		for geo in geovec
			blon,blat = coordGeoRegion(geo)
			ax.plot(blon.+120,blat,c="r")
		end
		ax.format(coast=true)
	end

	axs[1].format(ltitle="(a) Island Boundary Outlines")
	axs[2].format(ltitle="(b) Land/Sea Mask on SE-grid")
	axs[3].format(ltitle="(c) Mapping to Mixed-Layer Depth")
	axs[3].colorbar(clr_slb,label="Mixed Layer Depth / m",loc="l",length = 0.8)
	axs[4].format(ltitle="(d) Initial Surface Temperature")
	axs[4].colorbar(clr_t,label=L"$T_s$ / K",loc="r",length = 0.8)
	
	fig.savefig(plotsdir("01d-createislands-$(config).png"),transparent=false,dpi=300)
	load(plotsdir("01d-createislands-$(config).png"))
end

# ╔═╡ Cell order:
# ╟─23d70adf-c263-40ea-8d92-6b44d0296286
# ╟─adad459e-b842-11ec-15b3-a700e0b631d4
# ╟─970fea27-4f24-44c3-b4b9-a8c4680c828d
# ╟─84a363a6-a100-4ec2-8e9c-a171fa77ab5f
# ╟─0545daf7-27bd-4937-ba7d-342723234f5e
# ╠═246b836d-32b8-41fe-a093-ab92a31b2525
# ╠═0ceef88f-5038-479c-b59c-1c96afa48811
# ╟─a9a79642-7372-4514-8a34-6f70fc98a3b0
# ╟─c205b538-c8a1-4e96-9681-41917901ad20
# ╟─24465e12-fc78-454e-a214-d16be0199412
# ╟─5615e529-ee84-4de4-8b0c-635f7cae240e
# ╟─8a4a4054-be83-48d0-9298-665b92e45920
# ╟─f0aea29d-a88a-47fb-959a-fa0590c66502
# ╟─89704ace-ea38-429b-b8ef-ca6b1fcd2a0f
# ╟─b76af22e-fccb-419e-9c44-71e1d609ece5
# ╟─5d25c431-ec66-47a0-bc94-c5a3d2ed9e5c
# ╟─c3e014f0-6ae2-4892-b493-decf3b3e06f5
# ╟─73b0ecf8-e544-4f20-8d6f-52adc3740dfc
# ╟─1f2f5927-5594-4af1-a1d7-30764613e3dc
# ╟─3b118c8b-6e79-419b-99c4-5d0812dc5169
# ╟─ef33cfbf-8ffd-44d6-9046-7a239cc9a9d3
# ╟─7bbecfcf-19f6-4886-a580-98f2760e23e0
# ╟─4f02e5a0-20cb-48b6-b727-78fa82dbcbf8
# ╟─da18d524-3e37-4110-b8a9-49f332bd9f91

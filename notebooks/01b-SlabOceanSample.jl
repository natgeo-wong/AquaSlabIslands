### A Pluto.jl notebook ###
# v0.19.0

using Markdown
using InteractiveUtils

# ╔═╡ 7edc4e26-c513-40dc-b80f-2fa0b4a65a37
begin
	using Pkg; Pkg.activate()
	using DrWatson
	md"Using DrWatson to ensure reproducibility between different machines ..."
end

# ╔═╡ e83d28c3-e4c0-436b-a6fa-e3c5edc84247
begin
	@quickactivate "AquaSlabIslands"
	using NCDatasets

	include(srcdir("slaboceangen.jl"))

md"Loading modules for the AquaSlabIslands project..."
end

# ╔═╡ 208c7612-b7bb-11ec-009a-5d7bdb56bf80
md"
# 01b. Sample Slab-Ocean input files for Spectral-Element Aquaplanets

Slab-Ocean Aquaplanets will not run without a sample slab-ocean input files, and so in this notebook we will attempt to create a sample slab-ocean input file so that the Aquaplanets can run.  We will need to load sample slab-ocean input files from the `inputfiles` folder, and also the spectral-element domain NetCDF file.
"

# ╔═╡ 318ab32c-4d5b-4352-a703-e3b751eae3dd
md"
### A. Loading ne30 Domain NetCDF File
"

# ╔═╡ d6156e87-8075-4dd9-b5a1-8a0ff9e54a68
begin
	# Ocean grid by default is located at $DIN_LOC_ROOT/share/domains/domain.ocn.ne30_gx1v7.171003.nc
	dnc = projectdir("inputdata","share","domains","domain.ocn.ne30_gx1v7.171003.nc")
	dds = NCDataset(dnc)
end

# ╔═╡ 1bd772b1-0597-47bd-b688-36298b675251
close(dds)

# ╔═╡ 4a200172-4a3a-4be7-96d9-3351e65be229
md"
### B. Loading the Finite-Volume Slab-Ocean file
"

# ╔═╡ d4cc4acc-ab01-46fd-9987-e29ffa7e4e34
begin
	# Ocean grid by default is located at $DIN_LOC_ROOT/share/domains/domain.ocn.ne30_gx1v7.171003.nc
	onc = projectdir(
		"inputdata","ocn","docn7","SOM",
		"default.som.forcing.aquaplanet.Qflux0_h30_sstQOBS.2degFV_c20170421.nc"
	)
	ods = NCDataset(onc)
end

# ╔═╡ 15d03aca-ed57-426a-a7fa-5fc3dd60584a
close(ods)

# ╔═╡ 41fce9ef-3e40-4436-a78e-2dfefc2d85c2
md"
### C. Creating a Sample Slab-Ocean file

From what we've seen, we create the slab-ocean file by first copying the ocean domain file over to our destination, and then we append variables based on the above slab-ocean file into this new file.
"

# ╔═╡ 609ed6e0-2c02-48ac-a378-bb4518ec24f7
begin
	mkpath(projectdir("userdata","OCN_SOM"))
	nnc = projectdir("userdata","OCN_SOM","nwong_aquaslabislands-control.nc")
	slabocean_generation(nnc,srcfile=dnc)
	md"Make new slab-ocean file ..."
end

# ╔═╡ Cell order:
# ╟─208c7612-b7bb-11ec-009a-5d7bdb56bf80
# ╟─7edc4e26-c513-40dc-b80f-2fa0b4a65a37
# ╟─e83d28c3-e4c0-436b-a6fa-e3c5edc84247
# ╟─318ab32c-4d5b-4352-a703-e3b751eae3dd
# ╟─d6156e87-8075-4dd9-b5a1-8a0ff9e54a68
# ╟─1bd772b1-0597-47bd-b688-36298b675251
# ╟─4a200172-4a3a-4be7-96d9-3351e65be229
# ╟─d4cc4acc-ab01-46fd-9987-e29ffa7e4e34
# ╟─15d03aca-ed57-426a-a7fa-5fc3dd60584a
# ╟─41fce9ef-3e40-4436-a78e-2dfefc2d85c2
# ╠═609ed6e0-2c02-48ac-a378-bb4518ec24f7

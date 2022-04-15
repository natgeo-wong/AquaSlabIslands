### A Pluto.jl notebook ###
# v0.18.4

using Markdown
using InteractiveUtils

# ╔═╡ ec9541fc-b7ad-11ec-0f3c-cb4c26e0824a
md"
# AquaSlabIslands: Idealized Islands in a Slab-Ocean Aquaplanet

This project investigates the impact of adding idealized islands to a slab-ocean Aquaplanet.  These \"islands\" are no different from the surrounding ocean, save that the slab-depth is much reduced, so as to allow a quicker response to fluctuations in the diurnal insolation, and to increase the amplitude of the local diurnal cycle.

This project can be split into the following parts:
1. Setting up the experiments in CAM6
   * Exploring the spectral-element cubed-sphere grid
   * Setting up a sample slab-ocean file
   * The different experimental configurations, and outlining the island size/locations
"

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.7.1"
manifest_format = "2.0"

[deps]
"""

# ╔═╡ Cell order:
# ╟─ec9541fc-b7ad-11ec-0f3c-cb4c26e0824a
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002

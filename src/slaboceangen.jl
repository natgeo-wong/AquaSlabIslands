using NCDatasets

function slabocean_copy(
    fnc :: AbstractString;
    srcfile :: AbstractString
)

    cp(srcfile,fnc,force=true)
    return NCDataset(fnc,"a")

end

function slabocean_generation(
    fnc :: AbstractString;
    srcfile :: AbstractString,
    control :: Bool = true,
    FT = Float32
)

    cp(srcfile,fnc,force=true)

    ds = NCDataset(fnc,"a")

    defDim(ds,"time",12)

    dstime = defVar(ds,"time",Float32,("time",),attrib=Dict(
        "calendar"  => "noleap",
        "long_name" => "observation time",
        "units"     => "days since 0001-01-01 00:00:00"
    ))

    dsqdp = defVar(ds,"qdp",FT,("ni","nj","time"),attrib=Dict(
        "long_name"   => "ocean heat flux convergence",
        "units"       => "W/m^2",
        "description" => "Qflux = 0 at every point"
    ))

    dshblt = defVar(ds,"hblt",FT,("ni","nj","time"),attrib=Dict(
        "long_name"   => "ocean boundary layer depth (slab ocean thickness)",
        "units"       => "m",
    ))

    dsS = defVar(ds,"S",FT,("ni","nj","time"),attrib=Dict(
        "long_name"   => "salinity",
        "units"       => "ppt",
    ))

    dsT = defVar(ds,"T",FT,("ni","nj","time"),attrib=Dict(
        "long_name"   => "temperature",
        "units"       => "degC",
    ))

    dsU = defVar(ds,"U",FT,("ni","nj","time"),attrib=Dict(
        "long_name"   => "u ocean current",
        "units"       => "m/s",
    ))

    dsV = defVar(ds,"V",FT,("ni","nj","time"),attrib=Dict(
        "long_name"   => "v ocean current",
        "units"       => "m/s",
    ))

    dsdhdx = defVar(ds,"dhdx",FT,("ni","nj","time"),attrib=Dict(
        "long_name"   => "ocean surface slope: zonal",
        "units"       => "m/m",
    ))

    dsdhdy = defVar(ds,"dhdy",FT,("ni","nj","time"),attrib=Dict(
        "long_name"   => "ocean surface slope: meridional",
        "units"       => "m/m",
    ))

    dstime.var[:] = Float32.([14.0,46.0,74.0,105.0,135.0,166.0,196.0,227.0,258.0,288.0,319.0,349.0])
    dsqdp.var[:] .= 0
    dshblt.var[:] .= 30
    dsS.var[:] .= 0
    dsT.var[:] .= 0
    dsU.var[:] .= 0
    dsV.var[:] .= 0
    dsdhdx.var[:] .= 0
    dsdhdy.var[:] .= 0

    if control
        lat = nomissing(ds["yc"][:,1])
        npt = length(lat)
        for ipnt = 1 : npt
			ilat = lat[ipnt]
			if abs.(ilat) < 60
				  ds["T"].var[ipnt,:,:] .= 27 * (2 - sind(ilat*1.5)^2 - sind(ilat*1.5)^4) / 2
			else; ds["T"].var[ipnt,:,:] .= 0
			end
		end
        close(ds)
    else; return ds
    end

end
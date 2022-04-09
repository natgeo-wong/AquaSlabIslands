using NCDatasets

function slabocean_generation(
    fnc :: AbstractString;
    srcfile :: AbstractString,
    control :: Bool = true
)

    cp(srcfile,fnc,force=true)

    ds = NCDataset(fnc,"a")

    defDim(ds,"time",12)

    dstime = defVar(ds,"time",Float32,("time",),attrib=Dict(
        "calendar"  => "noleap",
        "long_name" => "observation time",
        "units"     => "days since 0001-01-01 00:00:00"
    ))

    dsqdp = defVar(ds,"qdp",Float64,("ni","nj","time"),attrib=Dict(
        "long_name"   => "ocean heat flux convergence",
        "units"       => "W/m^2",
        "description" => "Qflux = 0 at every point"
    ))

    dshblt = defVar(ds,"hblt",Float64,("ni","nj","time"),attrib=Dict(
        "long_name"   => "ocean boundary layer depth (slab ocean thickness)",
        "units"       => "m",
    ))

    dsS = defVar(ds,"S",Float64,("ni","nj","time"),attrib=Dict(
        "long_name"   => "salinity",
        "units"       => "ppt",
    ))

    dsT = defVar(ds,"T",Float64,("ni","nj","time"),attrib=Dict(
        "long_name"   => "temperature",
        "units"       => "degC",
    ))

    dsU = defVar(ds,"U",Float64,("ni","nj","time"),attrib=Dict(
        "long_name"   => "u ocean current",
        "units"       => "m/s",
    ))

    dsV = defVar(ds,"V",Float64,("ni","nj","time"),attrib=Dict(
        "long_name"   => "v ocean current",
        "units"       => "m/s",
    ))

    dsdhdx = defVar(ds,"dhdx",Float64,("ni","nj","time"),attrib=Dict(
        "long_name"   => "ocean surface slope: zonal",
        "units"       => "m/m",
    ))

    dsdhdy = defVar(ds,"dhdy",Float64,("ni","nj","time"),attrib=Dict(
        "long_name"   => "ocean surface slope: meridional",
        "units"       => "m/m",
    ))

    dstime.var[:] = [14.0,46.0,74.0,105.0,135.0,166.0,196.0,227.0,258.0,288.0,319.0,349.0]
    dsqdp.var[:] .= 0
    dshblt.var[:] .= 0
    dsS.var[:] .= 0
    dsT.var[:] .= 0
    dsU.var[:] .= 0
    dsV.var[:] .= 0
    dsdhdx.var[:] .= 0
    dsdhdy.var[:] .= 0

    if control
          close(ds)
    else; return ds
    end

end
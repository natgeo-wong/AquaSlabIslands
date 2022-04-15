using GeoRegions

function archipelago(;
    nx :: Int,
    ny :: Int,
    islands_lon :: Real = 4.,
    islands_lat :: Real = 4.
)

    geovec = Array{GeoRegion}(undef,nx*ny)
    lonshift = (2*nx+1) * islands_lon / 2
    latshift = (2*ny+1) * islands_lat / 2

    for iy = 1 : ny, ix = 1 : nx

        ni = ix + (iy-1) * nx
        geovec[ni] = RectRegion("", "GLB", "", [
            2*iy * islands_lat - latshift, (2*iy-1) * islands_lat - latshift,
            2*ix * islands_lon - lonshift, (2*ix-1) * islands_lon - lonshift
        ], savegeo = false)

    end

    return geovec

end

function continent(;
    continent_lon :: Real,
    continent_lat :: Real
)

    return RectRegion("", "GLB", "", [
        continent_lat/2, -continent_lat/2,
        continent_lon/2, -continent_lon/2
    ], savegeo = false)

end
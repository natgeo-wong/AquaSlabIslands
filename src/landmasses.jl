using GeoRegions

function archipelago(;
    nx :: Int,
    ny :: Int,
    islands_lon :: Real = 4.,
    islands_lat :: Real = 4.,
    lonshift    :: Real = 0.,
    latshift    :: Real = 0.
)

    geovec = Array{GeoRegion}(undef,nx*ny)
    lonshift = (2*nx+1) * islands_lon / 2 - lonshift
    latshift = (2*ny+1) * islands_lat / 2 - latshift

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
    continent_lat :: Real,
    lonshift      :: Real = 0.,
    latshift      :: Real = 0.,
)

    return RectRegion("", "GLB", "", [
        continent_lat/2 + latshift, -continent_lat/2 + latshift,
        continent_lon/2 + lonshift, -continent_lon/2 + lonshift
    ], savegeo = false)

end
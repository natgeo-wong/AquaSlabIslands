using NearestNeighbors

struct CubedSphere2LonLat{FT<:Real}

    idxs :: Array{Int}
    lon  :: Vector{FT}
    lat  :: Vector{FT}
    nlon :: Int
    nlat :: Int

end

function CubedSphere2LonLat(
    mesh_lon :: Vector{<:Real},
    mesh_lat :: Vector{<:Real};
    resolution_lon :: Real = 1.0,
    resolution_lat :: Real = 1.0,
    FT = Float64
)

    lon = collect( 0  : resolution_lon : 360); nlon = length(lon)
    lat = collect(-90 : resolution_lat : 90);  nlat = length(lat)
    ncell  = length(mesh_lon)
    points = zeros(3,ncell)
    idxs   = zeros(nlon,nlat)
    
    for icell = 1 : ncell
        points[1,icell] = cosd(mesh_lon[icell]) * cosd(mesh_lat[icell])
        points[2,icell] = sind(mesh_lon[icell]) * cosd(mesh_lat[icell])
        points[3,icell] = sind(mesh_lat[icell])
    end

    kdtree = KDTree(points)

    for ilat = 1 : nlat, ilon = 1 : nlon
        x = cosd(lon[ilon]) * cosd(lat[ilat])
        y = sind(lon[ilon]) * cosd(lat[ilat])
        z = sind(lat[ilat])
        idxs[ilon,ilat],_ = nn(kdtree,[x,y,z])
    end

    return CubedSphere2LonLat{FT}(idxs,lon,lat,nlon,nlat)

end

function cubedsphere2lonlat!(
    oarray :: AbstractArray{<:Real,2},
    iarray :: AbstractVector{<:Real},
    cs2ll  :: CubedSphere2LonLat{FT}
) where FT <: Real

    nlon = cs2ll.nlon
    nlat = cs2ll.nlat
    idxs = cs2ll.idxs

    for ilat = 1 : nlat, ilon = 1 : nlon
        oarray[ilon,ilat] = iarray[idxs[ilon,ilat]]
    end

    return

end
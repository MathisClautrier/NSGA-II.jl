using Test
include("../src/NSGA-II.jl")
using .NSGA-II

include("./cornercases.jl")

@testset "crowdingDistanceAssignement" begin
    oneDimension,expectedRank1D=subPop1D()
    multipleDimension,expectedRank3D=subPop3D()
    oldPop1D=copy(oneDimension)
    oldPop3D=copy(multipleDimension)
    crowdingDistanceAssignement(oneDimension)
    crowdingDistanceAssignement(multipleDimension)
    @test length(oldPop1D)==length(oneDimension)
    @test length(oldPop3D)==length(multipleDimension)
    max1D=maxPop(oneDimension)
    min1D=minPop(oneDimension)
    @test min1D[1].distance==Inf
    @test max1D[1].distance==Inf
    max3D=maxPop(multipleDimension)
    min3D=minPop(multipleDimension)
    for x in max3D:
        @test x.distance==Inf
    end
    for x in min3D:
        @test x.distance==Inf
    end
    equalOneDimension=subPopEqual1D()
    crowdingDistanceAssignement(equalOneDimension)
    for x in equalOneDimension
        @test x.distance=0
    end
    equalMultipleDimension=subPopEqual3D()
    crowdingDistanceAssignement(equalMultipleDimension)
    for y in equalMultipleDimension
        @test y.distance=0
    end
end

using Test
include("../src/NSGA-II.jl")
using .NSGA-II

include("./cornercases.jl")

@testset "crowdingDistanceAssignement" begin
    oneDimension=subPop1D()
    multipleDimension=subPop3D()
    oldPop1D=copy(oneDimension)
    oldPop3D=copy(multipleDimension)
    crowdingDistanceAssignement(oneDimension)
    crowdingDistanceAssignement(multipleDimension)
    @test length(oldPop1D)==length(oneDimension)
    @test length(oldPop3D)==length(multipleDimension)
    for x in oldPop1D
        @test x in oneDimension
    end
    for x in oldPop3D
        @test x in multipleDimension
    end
    max3D=maxPop(multipleDimension)
    min3D=minPop(multipleDimension)
    for x in max3D:
        @test x.distance==Inf
    end
    for x in min3D:
        @test x.distance==Inf
    end
    for x in oneDimension
        @test x.distance=0
    end
    equalMultipleDimension=subPopEqual3D()
    crowdingDistanceAssignement(equalMultipleDimension)
    for y in equalMultipleDimension
        @test y.distance=0
    end
end

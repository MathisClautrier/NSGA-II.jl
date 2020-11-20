using Test
using NSGAII

include("./cornercases.jl")


@testset "Domination" begin
    A=[2,1,1]
    B=[1,2,2]
    @test dominates(A,B)==false
    @test dominates(B,A)==false
    C=[1,0,0]
    @test dominates(A,C)==true
    @test dominates(C,A)==false
end

@testset "fastNonDominatedSort" begin
    oneDimension,expectedRank1D=pop1D()
    multipleDimension,expectedRank3D=pop3D()
    oldPop1D=copy(oneDimension)
    oldPop3D=copy(multipleDimension)
    fastNonDominatedSort!(oneDimension)
    fastNonDominatedSort!(multipleDimension)
    @test length(oneDimension)==length(oldPop1D)
    @test length(multipleDimension)==length(oldPop3D)
    for x in oldPop1D
        @test x in oneDimension
    end
    for x in oldPop3D
        @test x in multipleDimension
    end
    n=length(oneDimension)
    m=length(multipleDimension)
    for i in 1:n
        @test expectedRank1D[i]==oneDimension[i].rank
    end
    for i in 1:m
        @test expectedRank3D[i]==multipleDimension[i].rank
    end
end

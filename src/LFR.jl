module LFR
using BinDeps


depsjl = joinpath(dirname(@__FILE__), "..", "deps", "deps.jl")
isfile(depsjl) ? include(depsjl) : error("LFR not properly ",
"installed. Please run\nPkg.build(\"LFR\")")

export get_edgelist

function get_edgelist(;excess=false,defect=false,N=1000,k=20,maxk=50,t1=2.0,t2=1.0,mu=0.1,on=0,om=0,minc=50,maxc=100,fixed_range=true,ca=-214741)
	p = ccall((:benchmark, libbnet), Ptr{Cint}, (Bool, Bool, Cint, Float64, Cint, Float64, Float64, Float64, Cint, Cint, Cint, Cint, Bool, Float64), excess, defect, N, k, maxk, t1, t2, mu, on, om, minc,maxc,fixed_range,ca)
	n = pointer_to_array(p,1)[1]
	edgelist = Int[]
	alldata = pointer_to_array(p,n)
	sepidx = 0
	for i=2:n
		if alldata[i] > 0
			push!(edgelist, alldata[i])
		else
			sepidx = i
			break
		end
	end
	membership = Array(Vector{Int}, N)
	for j=1:N
		membership[j] = Vector{Int}()
	end
	j = 1
	for k=sepidx+1:n
		if alldata[k] > 0
			push!(membership[j], alldata[k])
		else
			j += 1
		end
	end
	edgelist, membership
end

																												end # module


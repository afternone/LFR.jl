__precompile__(true)

module LFR

if isfile(joinpath(dirname(@__FILE__),"..","deps","deps.jl"))
    include("../deps/deps.jl")
else
    error("LFR not properly installed. Please run Pkg.build(\"LFR\")")
end

export get_edgelist, write_graph, write_community, benchmark

function get_edgelist(;excess=false,defect=false,N=1000,k=20,maxk=50,t1=2.0,t2=1.0,mu=0.1,on=0,om=0,minc=50,maxc=100,fixed_range=true,ca=-214741)
	p = ccall((:benchmark, libbnet), Ptr{Cint}, (Bool,Bool,Cint,Float64,Cint,Float64,Float64,Float64,Cint,Cint,Cint,Cint,Bool,Float64), excess,defect,N,k,maxk,t1,t2,mu,on,om,minc,maxc,fixed_range,ca)
	n = pointer_to_array(p,1)[1]
	edgelist = Int[]
	alldata = pointer_to_array(p,n,true)
	sepidx = 0
	for i=2:n
		if alldata[i] > 0
			push!(edgelist, alldata[i])
		else
			sepidx = i
			break
		end
	end
	membership = [Vector{Int}() for j=1:N]
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

function write_graph(graphfile, edgelist; start_index=0)
    edgelist = edgelist - 1 + start_index
    open(graphfile,"w") do f
        for i=1:2:length(edgelist)-1
            println(f, edgelist[i], ' ', edgelist[i+1])
        end
    end
end

function write_community(commfile, membership; start_index=0)
    open(commfile,"w") do f
        for i in membership
            println(f, i[end]-1+start_index)
        end
    end
end

function benchmark(gfile="network.dat", cfile="community.dat"; excess=false, defect=false, N=1000, k=20, maxk=50, t1=2.0, t2=1.0, mu=0.1, on=0, om=0, minc=50, maxc=100, fixed_range=true, ca=-214741, start_index=0)
    x, y = get_edgelist(;excess=excess, defect=defect, N=N, k=k, maxk=maxk, t1=t1, t2=t2, mu=mu, on=on, om=om, minc=minc, maxc=maxc, fixed_range=fixed_range, ca=ca)
    write_graph(gfile, x; start_index=start_index)
    write_community(cfile, y, start_index=start_index)
end

end # module

using DataFrames
using CSV
using PlotlyJS

file_path = "C:\\Users\\gabrielprovenzano\\Downloads\\participation_list_52830533.csv"
participation_df = DataFrame(CSV.File(file_path, header = 1))

# data filter
function filterdata(stringdata)
    day = parse(Float64, stringdata[1:2])
    if day >= 7.0 && day <= 13.0
        return true
    else
        return false
    end
end

# filter between day 7 and day 13
filter!(:date_creation => filterdata, participation_df)

# brands list
brands_list = Vector{Any}()

mis = 0

for brand in participation_df.brandLabel
    if ismissing(brand)
        mis += 1
    else
        if brand ∉ brands_list
            if brand == "Vick Primeira Prote\xe7\xe3o"
                brand = "Vick Primeira Proteção"
            end
            push!(brands_list, brand)
        end
    end
end

brands_dict = Dict(i => 0 for i in brands_list)

for brand in participation_df.brandLabel
    if ismissing(brand) == false
        if brand == "Vick Primeira Prote\xe7\xe3o"
            brand = "Vick Primeira Proteção"
        end
        brands_dict[brand] += 1
    end
end

# total number of brands
brand_number = size(participation_df.brandLabel)[1]

# defines data frame with only registers and states
register_uf = DataFrame(register_id = participation_df.register_id, state = participation_df.state)

# defines data frame with only participations and states
participation_uf = DataFrame(participation_id = participation_df.participation_id, state = participation_df.state)

# remove repeated rows
unique!(register_uf)

# remove repeated rows
unique!(participation_uf)

sort!(participation_uf, :participation_id)

#number of unique participations
total_participation_unique = size(participation_uf.participation_id)[1]

# brand per receipt mean
brand_participation_mean = brand_number / total_participation_unique

# all states list
ufs_list = Vector{Any}()

# get all states
for uf in register_uf.state
    if uf ∉ ufs_list
        push!(ufs_list, uf)
    end
end

# dictionary with the registers for each state
ufs_dict_reg = Dict(uf => 0 for uf in ufs_list)

for uf in register_uf.state
    ufs_dict_reg[uf] += 1
end

# all regions list
regions_list = ["Nordeste", "Norte", "Sudeste", "Sul", "Centro-Oeste"]

# dictionary with the registers for each state
regions_dict_reg = Dict(uf => 0 for uf in regions_list)

# ufs per region
ufs_no = ["AM", "RR", "AP", "PA", "TO", "RO", "AC"]
ufs_ne = ["MA", "PI", "CE", "RN", "PE", "PB", "SE", "AL", "BA"]
ufs_co = ["MT", "MS", "GO", "DF"]
ufs_se = ["RJ", "SP", "ES", "MG"]
ufs_su = ["PR", "RS", "SC"]

# dict to identificate all ufs in each region
reg_uf_indent = Dict(ufs_no => "Norte",
    ufs_ne => "Nordeste",
    ufs_co => "Centro-Oeste",
    ufs_se => "Sudeste",
    ufs_su => "Sul")

regions = []

for uf in register_uf.state
    for ufs in keys(reg_uf_indent)
        if uf ∈ ufs
            push!(regions, reg_uf_indent[ufs])
        end
    end
end

register_uf[!, :region] = regions

# dictionary with the registers for each region
regions_dict_reg = Dict(uf => 0 for uf in regions_list)

for uf in register_uf.region
    regions_dict_reg[uf] += 1
end

state_df = DataFrame(state = [i for i in keys(ufs_dict_reg)], cadastros = [i for i in values(ufs_dict_reg)])
state_region = []
for uf in state_df.state
    for ufs in keys(reg_uf_indent)
        if uf ∈ ufs
            push!(state_region, reg_uf_indent[ufs])
        end
    end
end

state_df[!, :region] = state_region

brand_df = DataFrame(brand = [i for i in keys(brands_dict)], participations = [i for i in values(brands_dict)])
sort!(brand_df, :participations)

plot_state = plot(bar(state_df, x = :cadastros, y = :state, orientation = "h", text = [i for i in values(ufs_dict_reg)], textposition = "outside"), Layout(title = "Cadastros por Estado", xaxis_title_text = "Cadastros"))

plot_region = plot(bar(x = keys(regions_dict_reg), y = [i for i in values(regions_dict_reg)], text = [i for i in values(regions_dict_reg)], textposition = "outside"), Layout(title = "Cadastros por Região", yaxis_title_text = "Cadastros"))

plot_brands = plot(bar(brand_df, x = :participations, y = :brand, orientation = "h", text = :participations, textposition = "outside"), Layout(title = "Participações por Marca", xaxis_title_text = "Participações"))


savefig(plot_state, "C:\\Users\\gabrielprovenzano\\Downloads\\cadastros-por-estado.svg")
savefig(plot_region, "C:\\Users\\gabrielprovenzano\\Downloads\\cadastros-por-região.svg")
savefig(plot_brands, "C:\\Users\\gabrielprovenzano\\Downloads\\participacoes-por-marca.svg")


# sort by register
#sort!(paticipation_df, :register_id)
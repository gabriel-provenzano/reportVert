using DataFrames
using CSV
using PlotlyJS
using Dates

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

#function filterdata(date::Dates.Date)
#    if date >= Date(2022, 3, 7) && date <= Date(2022, 03, 13)
#        return true
#    else
#        return false
#    end
#end

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
total_register_unique = size(register_uf.register_id)[1]

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

regions = []

for uf in participation_uf.state
    for ufs in keys(reg_uf_indent)
        if uf ∈ ufs
            push!(regions, reg_uf_indent[ufs])
        end
    end
end

participation_uf[!, :region] = regions
participation_uf[!, :brands] = [[] for i in 1:size(participation_uf)[1]]

line_df = 0
for receipt in participation_df.participation_id
    line_df += 1
    line_uf = 0
    for receipt_uf in participation_uf.participation_id
        line_uf += 1
        if receipt == receipt_uf
            if ismissing(participation_df.brandLabel[line_df]) == false
                push!(participation_uf.brands[line_uf], participation_df.brandLabel[line_df])
                break
            end
        end
    end
end


# dictionary with the registers for each region
regions_dict_reg = Dict(uf => 0 for uf in regions_list)

for uf in register_uf.region
    regions_dict_reg[uf] += 1
end

state_df_reg = DataFrame(state = [i for i in keys(ufs_dict_reg)], cadastros = [i for i in values(ufs_dict_reg)])
state_region_reg = []
for uf in state_df_reg.state
    for ufs in keys(reg_uf_indent)
        if uf ∈ ufs
            push!(state_region_reg, reg_uf_indent[ufs])
        end
    end
end

state_df_reg[!, :region] = state_region_reg


brands_duos = []
brands_duos_region = []

line = 0
for brands_array in participation_uf.brands
    line += 1
    sort!(brands_array)
    for i in 1:size(brands_array)[1]
        for j in i+1:size(brands_array)[1]
            push!(brands_duos, [brands_array[i], brands_array[j]])
            push!(brands_duos_region, participation_uf.region[line])
        end
    end
end

brands_duos_per_region = DataFrame(brandsDuo = brands_duos, region = brands_duos_region)

brands_duos_se = filter(:region => x -> x == "Sudeste", brands_duos_per_region)
brands_duos_su = filter(:region => x -> x == "Sul", brands_duos_per_region)
brands_duos_ne = filter(:region => x -> x == "Nordeste", brands_duos_per_region)
brands_duos_no = filter(:region => x -> x == "Norte", brands_duos_per_region)
brands_duos_co = filter(:region => x -> x == "Centro-Oeste", brands_duos_per_region)

brands_duos_se_unique = unique(brands_duos_se)
brands_duos_su_unique = unique(brands_duos_su)
brands_duos_ne_unique = unique(brands_duos_ne)
brands_duos_no_unique = unique(brands_duos_no)
brands_duos_co_unique = unique(brands_duos_co)




brands_duos_count_se = Dict(brandDuo => 0 for brandDuo in brands_duos_se.brandsDuo)
brands_duos_count_su = Dict(brandDuo => 0 for brandDuo in brands_duos_su.brandsDuo)
brands_duos_count_ne = Dict(brandDuo => 0 for brandDuo in brands_duos_ne.brandsDuo)
brands_duos_count_no = Dict(brandDuo => 0 for brandDuo in brands_duos_no.brandsDuo)
brands_duos_count_co = Dict(brandDuo => 0 for brandDuo in brands_duos_co.brandsDuo)


for brand_duo in brands_duos_se.brandsDuo
    brands_duos_count_se[brand_duo] += 1
end
for brand_duo in brands_duos_su.brandsDuo
    brands_duos_count_su[brand_duo] += 1
end
for brand_duo in brands_duos_ne.brandsDuo
    brands_duos_count_ne[brand_duo] += 1
end
for brand_duo in brands_duos_no.brandsDuo
    brands_duos_count_no[brand_duo] += 1
end
for brand_duo in brands_duos_co.brandsDuo
    brands_duos_count_co[brand_duo] += 1
end

brands_duos_se_df = DataFrame(Brands = [i for i in keys(brands_duos_count_se)], Aparição = [i for i in values(brands_duos_count_se)])
brands_duos_su_df = DataFrame(Brands = [i for i in keys(brands_duos_count_su)], Aparição = [i for i in values(brands_duos_count_su)])
brands_duos_ne_df = DataFrame(Brands = [i for i in keys(brands_duos_count_ne)], Aparição = [i for i in values(brands_duos_count_ne)])
brands_duos_no_df = DataFrame(Brands = [i for i in keys(brands_duos_count_no)], Aparição = [i for i in values(brands_duos_count_no)])
brands_duos_co_df = DataFrame(Brands = [i for i in keys(brands_duos_count_co)], Aparição = [i for i in values(brands_duos_count_co)])

sort!(brands_duos_se_df, :Aparição)
sort!(brands_duos_su_df, :Aparição)
sort!(brands_duos_ne_df, :Aparição)
sort!(brands_duos_no_df, :Aparição)
sort!(brands_duos_co_df, :Aparição)

brands_str = []
for brand_duo in brands_duos_se_df.Brands
    push!(brands_str, brand_duo[1] * "+" * brand_duo[2])
end
brands_duos_se_df[!, :brands_str] = brands_str
brands_str = []
for brand_duo in brands_duos_su_df.Brands
    push!(brands_str, brand_duo[1] * "+" * brand_duo[2])
end
brands_duos_su_df[!, :brands_str] = brands_str
brands_str = []
for brand_duo in brands_duos_ne_df.Brands
    push!(brands_str, brand_duo[1] * "+" * brand_duo[2])
end
brands_duos_ne_df[!, :brands_str] = brands_str
brands_str = []
for brand_duo in brands_duos_no_df.Brands
    push!(brands_str, brand_duo[1] * "+" * brand_duo[2])
end
brands_duos_no_df[!, :brands_str] = brands_str
brands_str = []
for brand_duo in brands_duos_co_df.Brands
    push!(brands_str, brand_duo[1] * "+" * brand_duo[2])
end
brands_duos_co_df[!, :brands_str] = brands_str

#brands_duos_se_df = brands_duos_se_df[end-10:end, :]
#brands_duos_su_df = brands_duos_su_df[end-10:end, :]
#brands_duos_ne_df = brands_duos_ne_df[end-10:end, :]
#brands_duos_no_df = brands_duos_no_df[end-10:end, :]
#brands_duos_co_df = brands_duos_co_df[end-10:end, :]

plot_brandDuo_se = plot(bar(brands_duos_se_df, x = :Aparição, y = :brands_str, orientation = "h", text = :Aparição, textposition = "outside"), Layout(title = "Grupos de Marcas (Sudeste)", xaxis_title_text = "Aparições"))
plot_brandDuo_su = plot(bar(brands_duos_su_df, x = :Aparição, y = :brands_str, orientation = "h", text = :Aparição, textposition = "outside"), Layout(title = "Grupos de Marcas (Sul)", xaxis_title_text = "Aparições"))
plot_brandDuo_ne = plot(bar(brands_duos_ne_df, x = :Aparição, y = :brands_str, orientation = "h", text = :Aparição, textposition = "outside"), Layout(title = "Grupos de Marcas (Nordeste)", xaxis_title_text = "Aparições"))
plot_brandDuo_no = plot(bar(brands_duos_no_df, x = :Aparição, y = :brands_str, orientation = "h", text = :Aparição, textposition = "outside"), Layout(title = "Grupos de Marcas (Norte)", xaxis_title_text = "Aparições"))
plot_brandDuo_co = plot(bar(brands_duos_co_df, x = :Aparição, y = :brands_str, orientation = "h", text = :Aparição, textposition = "outside"), Layout(title = "Grupos de Marcas (Centro-Oeste)", xaxis_title_text = "Aparições"))




brand_df = DataFrame(brand = [i for i in keys(brands_dict)], participations = [i for i in values(brands_dict)])
sort!(brand_df, :participations)

plot_state = plot(bar(state_df_reg, x = :cadastros, y = :state, orientation = "h", text = [i for i in values(ufs_dict_reg)], textposition = "outside"), Layout(title = "Cadastros por Estado", xaxis_title_text = "Cadastros"))

plot_region = plot(bar(x = keys(regions_dict_reg), y = [i for i in values(regions_dict_reg)], text = [i for i in values(regions_dict_reg)], textposition = "outside"), Layout(title = "Cadastros por Região", yaxis_title_text = "Cadastros"))

plot_brands = plot(bar(brand_df, x = :participations, y = :brand, orientation = "h", text = :participations, textposition = "outside"), Layout(title = "Participações por Marca", xaxis_title_text = "Participações", xaxis_range = [0, 3000]))


savefig(plot_state, "C:\\Users\\gabrielprovenzano\\Downloads\\cadastros-por-estado.svg")
savefig(plot_region, "C:\\Users\\gabrielprovenzano\\Downloads\\cadastros-por-região.svg")
savefig(plot_brands, "C:\\Users\\gabrielprovenzano\\Downloads\\participacoes-por-marca.svg")

# https://www.youtube.com/watch?v=IdhnP00Y1Ks&feature=emb_logo
using VegaLite, DataFrames, Query, VegaDatasets, Clustering, Plots

# load the data
cars = dataset("cars");

# select pairs
cars |> @select(:Acceleration, :Name) |> collect

# create function for plotting some data
function foo(data,origin)
    df = data |> @filter(_.Origin==origin) |> DataFrame

    return df |> @vlplot(:point, :Acceleration, :Miles_per_Gallon)
end

#p = foo(cars, "USA")

# let's try k-means clustering with cars data
# kept all attempts of cleaning data for records
df = DataFrame(cars)
df = filter(:Acceleration => x -> !(ismissing(x) || isnothing(x) || isnan(x)), df)
df = dropmissing(df, :Acceleration)
df = dropmissing(df, :Cylinders)
df = dropmissing(df, :Horsepower)
df = dropmissing(df, :Displacement)
df = dropmissing(df, :Weight_in_lbs)
df = dropmissing(df, :Miles_per_Gallon)

df = select!(df, Not(:Name)); # remove columns
df = select!(df, Not(:Year));
df = select!(df, Not(:Origin));

# convert all columns to float
df.Acceleration = convert(Array{Float64,1},df.Acceleration)
df.Cylinders = convert(Array{Float64,1},df.Cylinders)
df.Horsepower = convert(Array{Float64,1},df.Horsepower)
df.Displacement = convert(Array{Float64,1},df.Displacement)
df.Weight_in_lbs = convert(Array{Float64,1},df.Weight_in_lbs)
df.Miles_per_Gallon = convert(Array{Float64,1},df.Miles_per_Gallon)

# create array for kmeans input (issue: "float64,2" needed copy)
features = collect(Matrix(df))
features = copy(features')

# kmeans function
result = kmeans(features,3); # run K-means for 3 clusters

# plot weight vs mpg
p3 = scatter(df.Weight_in_lbs, df.Miles_per_Gallon, marker_z=result.assignments,
        color=:lightrainbow, legend=false, dpi=500)
plot(p3,
    xlabel = "Weight (lbs)",
    #xlims = (0,10),
    #xticks = 0:0.5:10,
    #xscale = :log,
    #xflip = true,
    ylabel = "Miles per gallon",
    size = (450,450)
)
savefig(p3,"cars.png")
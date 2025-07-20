using CSV
using DataFrames
using Statistics
using Plots
using Dates
using DelimitedFiles

# ========== UTILITIES ========== #

# Haversine distance in km
function haversine_dist(lat1, lon1, lat2, lon2)
    R = 6371.0
    φ1, φ2 = deg2rad(lat1), deg2rad(lat2)
    Δφ, Δλ = deg2rad(lat2 - lat1), deg2rad(lon2 - lon1)

    a = sin(Δφ / 2)^2 + cos(φ1) * cos(φ2) * sin(Δλ / 2)^2
    c = 2 * atan2(sqrt(a), sqrt(1 - a))

    return R * c
end

# ========== DATA LOADING ========== #

function load_flight_data(filepath::String)::DataFrame
    df = CSV.read(filepath, DataFrame)
    df.timestamp = DateTime.(df.timestamp)  # Ensure timestamps are DateTime
    return df
end

# ========== FLIGHT ANALYSIS ========== #

function compute_stats(df::DataFrame)
    total_flight_time = maximum(df.timestamp) - minimum(df.timestamp)
    total_distance = sum(diff.(haversine_dist.(df.latitude[1:end-1], df.longitude[1:end-1],
                                                df.latitude[2:end], df.longitude[2:end])))
    avg_altitude = mean(df.altitude)
    max_altitude = maximum(df.altitude)
    min_battery = minimum(df.battery)

    return (
        total_flight_time = total_flight_time,
        total_distance_km = total_distance,
        avg_altitude = avg_altitude,
        max_altitude = max_altitude,
        min_battery = min_battery
    )
end

# ========== SMOOTHING + ANOMALY DETECTION ========== #

function smooth_velocity(df::DataFrame; window::Int = 5)
    df.velocity_smooth = [mean(df.velocity[max(i - window, 1):min(i + window, end)]) for i in 1:nrow(df)]
    return df
end

function detect_velocity_anomalies(df::DataFrame; threshold::Float64 = 10.0)
    anomalies = findall(abs.(df.velocity .- df.velocity_smooth) .> threshold)
    return anomalies
end

# ========== VISUALIZATIONS ========== #

function plot_geopath(df::DataFrame)
    plot(df.longitude, df.latitude, label="Flight Path", xlabel="Longitude", ylabel="Latitude",
         title="Geospatial Flight Path", legend=false, seriestype=:path)
    savefig("geopath.png")
end

function plot_altitude(df::DataFrame)
    plot(df.timestamp, df.altitude, label="Altitude (m)", xlabel="Time", ylabel="Altitude (m)",
         title="Altitude Over Time", legend=:bottomright)
    savefig("altitude_plot.png")
end

function plot_battery(df::DataFrame)
    plot(df.timestamp, df.battery, label="Battery (%)", xlabel="Time", ylabel="Battery (%)",
         title="Battery Drain Over Time", legend=:bottomright)
    savefig("battery_plot.png")
end

function plot_velocity(df::DataFrame, anomalies::Vector{Int})
    plot(df.timestamp, df.velocity, label="Raw Velocity", lw=1.5)
    plot!(df.timestamp, df.velocity_smooth, label="Smoothed", lw=2)
    scatter!(df.timestamp[anomalies], df.velocity[anomalies], label="Anomalies", color=:red)
    xlabel!("Time")
    ylabel!("Velocity (m/s)")
    title!("Velocity with Anomaly Detection")
    savefig("velocity_plot.png")
end

# ========== REPORT EXPORT ========== #

function export_summary(stats, anomalies::Vector{Int})
    open("uav_flight_report.txt", "w") do io
        write(io, "🛸 UAV Flight Summary Report\n")
        write(io, "===========================\n")
        for (k, v) in stats
            write(io, "$k: $v\n")
        end
        write(io, "\nDetected Velocity Anomalies: $(length(anomalies))\n")
        if !isempty(anomalies)
            write(io, "Anomaly Timestamps:\n")
            for i in anomalies
                write(io, " - $i\n")
            end
        end
    end
end

# ========== MAIN ========== #

function main()
    filepath = "uav_flight_data.csv"  # Replace with your actual CSV file
    df = load_flight_data(filepath)

    stats = compute_stats(df)
    df = smooth_velocity(df)
    anomalies = detect_velocity_anomalies(df)

    plot_geopath(df)
    plot_altitude(df)
    plot_battery(df)
    plot_velocity(df, anomalies)

    export_summary(stats, anomalies)

    println("✅ Analysis complete. Plots and report saved.")
end

main()
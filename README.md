# UAV Flight Data Analysis in Julia

This project provides a set of tools for analyzing UAV (drone) flight data using the Julia programming language. It includes functionality for:

- ✅ Loading flight data from CSV
- ✅ Geospatial path mapping (latitude/longitude)
- ✅ Altitude, battery, and velocity time series plots
- ✅ Velocity smoothing and anomaly detection
- ✅ Summary report generation (distance, time, battery, anomalies)

## Requirements

Install the following Julia packages:

```julia
using Pkg
Pkg.add(["CSV", "DataFrames", "Statistics", "Plots", "DelimitedFiles", "Dates"])
```

## File Structure

```
uav-flight-analysis/
├── analyze_uav_data.jl         # Main script
├── data/
│   └── uav_flight_data.csv     # Sample flight data
├── plots/
│   ├── geopath.png
│   ├── altitude_plot.png
│   ├── battery_plot.png
│   └── velocity_plot.png
├── reports/
│   └── uav_flight_report.txt   # Summary output
├── README.md
└── Project.toml
```

## Usage

Place your flight log CSV file in `data/`. Ensure the format is:

```
timestamp,latitude,longitude,altitude,velocity,battery
```

Run the script:

```bash
julia analyze_uav_data.jl
```

The script will:
   - Generate plots in the `plots/` directory
   - Write a report to `reports/uav_flight_report.txt`

## License

This project is licensed under the MIT License.
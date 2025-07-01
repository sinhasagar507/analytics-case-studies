# Dino Fun World Assignments

This repository contains solutions for the **Dino Fun World** assignments, which involve analyzing amusement park data to answer operational and visual questions using Python, SQL, and data visualization libraries. The solutions are organized as Jupyter Notebook files and are tailored to meet the specific requirements of each task.

## Table of Contents

1. [Assignment 1: Park Operations Analysis](#assignment-1-park-operations-analysis)
2. [Assignment 2: Graphing Park Data](#assignment-2-graphing-park-data)
3. [Assignment 3: Visitor Path Analysis](#assignment-3-visitor-path-analysis)
4. [Assignment 4: Time Series Analysis for Attendance](#assignment-4-time-series-analysis-for-attendance)
5. [Assignment 5: Geographic Data Visualization](#assignment-5-geographic-data-visualization)
6. [Assignment 6: Visitor Trajectory Clustering](#assignment-6-visitor-trajectory-clustering)
7. [Assignment 7: Time Series Analysis for Attendance](#assignment-7-time-series-analysis-for-attendance)

---

## Assignment 1: Park Operations Analysis

Analyze amusement park operations to answer these questions:
- Identify the most popular attraction.
- Determine the ride with the longest average visit time.
- Find the fast food offering with the fewest visitors.
- Compute the Skyline for park rides based on visit counts and durations.

### Key Outputs
- **Most Popular Attraction:** *Atmosfear*
- **Longest Visit Time:** *TerrorSaur*
- **Fewest Visitors:** *Theresaur Food Stop*
- **Skyline Rides:** ['Wrightiraptor Mountain', 'Atmosfear', 'Dykesadactyl Thrill']

---

## Assignment 2: Graphing Park Data

Create visualizations for the park's operations:
1. **Pie Chart** of visits to thrill rides.
2. **Bar Chart** of total visits to food stalls.
3. **Line Chart** of attendance at the newest ride, Atmosfear.
4. **Box-and-Whisker Plot** of total visits to kiddie rides.

---

## Assignment 3: Visitor Path Analysis

Understand visitor behavior by:
1. Constructing a distance matrix for selected visitor paths.
2. Plotting attendance dynamics at rides using a Parallel Coordinate Plot.
3. Visualizing ride statistics with a Scatterplot Matrix.

---

## Assignment 4: Time Series Analysis for Attendance

### Overview

This assignment focuses on analyzing time-series data to help the administrators of Dino Fun World understand attendance trends at the popular ride *'Atmosfear'*. The analysis includes creating a **control chart**, a **moving average chart**, and an **Exponentially Weighted Moving Average (EWMA)** chart to provide actionable insights into ride attendance.

### Provided Database

The provided database, `dinofunworld.db`, contains the following tables:
- **`checkins`**:
  - Description: Check-in data for all visitors for the day, including inferred and actual check-ins.
  - Fields: `visitorID`, `timestamp`, `attraction`, `duration`, `type`
- **`attractions`**:
  - Description: Attractions categorized by `Region`, `Category`, and `Type`.
  - Fields: `AttractionID`, `Name`, `Region`, `Category`, `type`
- **`sequences`**:
  - Description: Check-in sequences recorded every five minutes, listing the visitor's most recent attraction.
  - Fields: `visitorID`, `sequence`

### Key Questions Addressed

1. **Control Chart**: Create a control chart for attendance at *'Atmosfear'* over time, showing:
   - Attendance
   - Mean
   - One and two standard deviation bands

2. **Moving Average Chart**: Create a moving average chart for *'Atmosfear'* attendance with a window size of **50 samples**.

3. **Exponentially Weighted Moving Average (EWMA) Chart**: Create an EWMA chart for *'Atmosfear'* attendance, using a **50-sample window**.

---

## Assignment 5: Geographic Data Visualization

Leverage PySAL and GeoPandas to analyze geographic data:
- **Choropleth Map:** Visualize per capita income across the US in 2009.
- **Proportional Symbol Map:** Highlight per capita income using dot sizes.
- **Moran's I Computation:** Calculate Moran's I for income data using Rook's Contiguity.

---

## Assignment 6: Visitor Trajectory Clustering

Build upon previous analyses to:
- Generate a **dendrogram** using trajectories of specified visitors.
- Use hierarchical clustering with average distance metrics.

---

## Assignment 7: Time Series Analysis for Attendance

### Overview

Analyze time-series data to help the administrators of Dino Fun World understand attendance trends at the popular ride *'Atmosfear'*. This assignment includes creating a **control chart**, a **moving average chart**, and an **Exponentially Weighted Moving Average (EWMA)** chart to provide actionable insights into ride attendance.

### Key Questions Addressed

1. **Control Chart**: Visualize the total attendance at *'Atmosfear'*. The chart includes:
   - Attendance over time
   - Mean attendance
   - Standard deviation bands at one and two standard deviations

2. **Moving Average Chart**: Provide a smoother trend of *'Atmosfear'* attendance using a 50-sample moving average window.

3. **EWMA Chart**: Highlight recent trends in attendance using an exponentially weighted 50-sample moving average.

### Technologies Used

- **Python**: Core analysis and visualization.
- **SQL**: Data extraction from the SQLite database.
- **Libraries**: Pandas, NumPy, Matplotlib, Seaborn.

---

## Technologies Used

- **Python**: Data analysis and visualization.
- **Libraries**: Pandas, Matplotlib, NumPy, SQLite3, GeoPandas, PySAL.
- **SQL**: Data querying.
- **Tools**: Jupyter Notebook.

---

## Getting Started

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/dino-fun-world.git
   ```
2. Create a virtual environment using `venv` and install the dependencies from `requirements.txt`
3. Run the notebooks

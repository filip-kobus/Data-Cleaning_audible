# Audible Data Cleaning Project

This project involves cleaning and preparing raw Audible data for further analysis. The main steps include loading the raw dataset, applying transformations, and exporting the cleaned version for use. 

## Project Structure

The repository contains the following files:

1. **audible_uncleaned.csv**  
   This file contains the raw, unprocessed Audible data. The data may have missing values, inconsistent formats, or other issues that need to be cleaned.

![uncleanedAudible](https://github.com/user-attachments/assets/973631a5-303f-4a21-a6c1-0a0a81387d93)


2. **audible_cleaned.csv**  
   This file contains the cleaned version of the Audible dataset. After applying the cleaning steps outlined in the `audible_cleaning_steps.sql` script, the data is ready for analysis or further processing.

![audibleCleaned](https://github.com/user-attachments/assets/da3ddd8e-65bd-41a8-a738-f696be3c1266)

3. **audible_cleaning_steps.sql**  
   This SQL script documents the various data cleaning steps applied to the `audible_uncleaned.csv` file. The script includes transformations such as:
   - Handling missing or null values
   - Standardizing data formats
   - Removing duplicates
   - Other custom transformations specific to this dataset

## How to Use

1. **Load the Raw Data**  
   Begin by loading the `audible_uncleaned.csv` file into your SQL or data processing tool.

2. **Apply Cleaning Steps**  
   Run the SQL queries provided in `audible_cleaning_steps.sql`. This script will clean and transform the raw data according to the defined steps.

3. **Export the Cleaned Data**  
   After the cleaning process is complete, export the cleaned data to generate a file similar to `audible_cleaned.csv`.

## Requirements

- SQL or a similar tool that can process `.sql` files and perform data transformations.
- A data analysis tool (e.g., Python, Excel) to load and work with the cleaned `.csv` files.

## Kaggle Dataset

The cleaned dataset and the SQL steps used in this project are also available on Kaggle. You can view and download the dataset here:  
[Kaggle Dataset - Audible Dataset Cleaning SQL](https://www.kaggle.com/datasets/fkobus/audible-dataset-cleaning-sql)

## Future Work

- Additional transformations or data enhancements could be applied, depending on the final use case of the cleaned data.
- Integration with a data visualization or reporting tool for further insights.

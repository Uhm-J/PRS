#!/usr/bin/env Rscript

#.libPaths("./lib")
#options(repos = c(CRAM = "https://cloud.r-project.org/"))

# Function to check and install missing packages
check_and_install <- function(package) {
  if (!require(package, character.only = TRUE)) {
    #install.packages(package, dependencies = TRUE)
    library(package, character.only = TRUE)
  }
}

# Packages needed
packages <- c("dplyr", "stringr", "ggplot2", "tidyverse")
lapply(packages, check_and_install)
args <- commandArgs(trailingOnly = TRUE)

# First argument is file name, the rest are group names
file_name <- args[1]
group_names <- args[-1]
group_names_str <- paste(group_names, collapse = ", ")


# Make sure you have correct number of arguments
if (length(args) < 1) {
  stop("At least one group must be provided as an argument", call. = FALSE)
}

# Convert args to lowercase for comparison
args <- tolower(args)

df <- read.table(file_name, header = T)
df <- df %>% dplyr::select(FID, Pt_5e.08, Pt_0.0001, Pt_0.001, Pt_0.01, Pt_0.05, Pt_0.1, Pt_0.2, Pt_0.5, Pt_1)

# Define a function to assign groups
assign_group <- function(fid) {
  group_start <- tolower(fid)
  match_group <- args[sapply(args, function(x) startsWith(group_start, x))]
  
  if(length(match_group) > 0) {
    return(toupper(match_group))
  } else {
    return(NA)
  }
}

# Assign groups based on FID
df$Group <- sapply(df$FID, assign_group)

# Convert 'Group' from character to factor
df$Group <- as.factor(df$Group)

# Vector of sample IDs to exclude
#print(df)

# Convert data to long format
df_long <- df %>% 
  pivot_longer(cols = starts_with("Pt"), 
               names_to = "Pt", 
               values_to = "Value")

# Calculate z-scores for 'Value' per threshold
df_long <- df_long %>%
  group_by(Pt) %>%
  mutate(ZScore = scale(Value))


# Calculate group medians
group_medians <- df_long %>%
  group_by(Pt, Group) %>%
  summarise(Median = median(ZScore))

# Create density plots
df_long$Pt <- factor(df_long$Pt, levels = c("Pt_5e.08","Pt_0.0001", "Pt_0.001", "Pt_0.01", "Pt_0.05", "Pt_0.1", "Pt_0.2", "Pt_0.5", "Pt_1"))

# Get directory and base name of the file
file_directory <- dirname(file_name)
file_base_name <- tools::file_path_sans_ext(basename(file_name))

# Construct the output file path
output_file <- file.path(file_directory, paste0(file_base_name, "_plot.pdf"))


pdf(output_file)
ggplot(df_long, aes(x=ZScore, fill=Group)) + 
  geom_vline(data = group_medians, aes(xintercept = Median, color = Group), linetype = "dashed") +
  geom_density(alpha=0.5) + 
  facet_wrap(~Pt, ncol = 3, nrow = 3) +
  theme_bw() + 
  labs(title=paste0("BMI: Density Plot of Z-Scores for ", group_names_str), 
       x="Z-Score", 
       y="Density")

dev.off()
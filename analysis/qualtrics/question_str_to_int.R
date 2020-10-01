generic_int <- function(val, valid_values){
  if (is.na(val)){
    return(NA)
  }
  
  match_position <- match(val, valid_values)
  if (is.na(match_position)) {
    stop(
      glue::glue("Value \"{val}\" not found in vector of valid values ({paste(valid_values, collapse=', ')}).")
    )
  } else {
    return(match_position)
  }
}

q3.1_int <- function(val){
  valid <- c(
    "I have none",
    "I took some programming related class in the past but have not used it since",
    "I have written a few lines now and again",
    "I have written programs for my own use that are a couple of pages long",
    "I have written and maintained larger pieces of software"
  )
  return(
    generic_int(val, valid)
  )
}

q3.3_int <- function(val) {
  valid <- c(
    "I do not know what those are",
    "I have heard of them but have never used them before",
    "I have installed it, but have only done simple examples with them",
    "I have written a small program with them before",
    "I use it to automate certain repetitive tasks",
    "I have small side projects that I program in it",
    "I program in them for work"
  )
  return(
    generic_int(val, valid)
  )
}

q3.4_int <- function(val){
  valid <- c(
    "Never",
    "Less than once per year",
    "Several times per year",
    "Monthly",
    "Weekly",
    "Daily"
  )
  return(
    generic_int(val, valid)
  )
}

q3.5_int <- function(val){
  valid <- c(
    "I wouldn't know where to start",
    "I could struggle through, but not confident I could do it",
    "I could struggle through by trial and error with a lot of web searches",
    "I could do it quickly with little or no use of external help"
  )
  #browser()
  return(
    generic_int(val, valid)
  )
}

q3.6_int <- q3.4_int

q3.7_int <- q3.4_int

q4.1_int <- function(val){
  valid <- c(
    "I have never used it, or I have tried it but can't really do anything with it.",
    "I have used it as an electronic todo list and planner putting schedules and task deadlines in a single place",
    "I've used it to store datasets and able to calculate basic aggregate values, such as mean and sums",
    "I've used data aggregation, pivot tables, formulas, and plotting feature to understand how my data breaks down.",
    "I've coded up VBA macros and made VLOOKUP calls integrating multiple sheets for a simulation task"
  )
  return(
    generic_int(val, valid)
  )
}

q4.2_int <- q3.5_int

q4.3_int <- function(val){
  valid <- c(
    "I have never heard of the term",
    "I have heard of it but don't remember what it is.",
    "I have some idea of what it is, but am not too clear",
    "I know what it is and could explain what it pertains to"
  )
  return(
    generic_int(val, valid)
  )
}

q4.4_int <- q4.3_int

q5.1_int <- function(val){
  valid <- c(
    "Very unsatisfied",
    "Unsatisfied",
    "Neutral",
    "Satisfied",
    "Very satisfied",
    "Not sure",
    "Not applicable",
    "Never thought about this"
  )
  return(
    generic_int(val, valid)
  )
}

q5.2_int <- function(val){
  valid <- c(
    "I don't do data and/or analysis work",
    "My data and analysis are all in excel files, possibly with multiple sheets.",
    "I work on carefully time-stamped excel files for my version control and analysis",
    "I use some programming language to load in my data sets for analysis, but sometimes modify my original data files when cleaning the data",
    "I hold my original data sacred, and only work on it from another program and save out intermediate and final data projects as separate files",
    "I have a very specific project structure where data and analysis are kept in separate areas and have a version control system (e.g., Git, SVN)",
    "I have version controlled project templates along with build scripts (e.g., Makefile) to reproduce various aspects of the analysis"
  )
  return(
    generic_int(val, valid)
  )
}

q6.1_int <- q3.5_int

q6.2_int <- q3.5_int

q6.3_int <- q3.5_int

q6.4_int <- function(val){
  valid <- c(
    "I have never heard of the term",
    "I have heard of it but don't remember what it is", # differs from q4.3_int because there is no period in this version
    "I have some idea of what it is, but am not too clear",
    "I know what it is and could explain what it pertains to"
  )
  return(
    generic_int(val, valid)
  )
}

recode_responses_int <- function(qpart, response) {
  switch(
    qpart,
    "Q3.1" = q3.1_int(response),
    "Q3.3" = q3.3_int(response),
    "Q3.4" = q3.4_int(response),
    "Q3.5" = q3.5_int(response),
    "Q3.6" = q3.6_int(response),
    "Q3.7" = q3.7_int(response),
    "Q4.1" = q4.1_int(response),
    "Q4.2" = q4.2_int(response),
    "Q4.3" = q4.3_int(response),
    "Q4.4" = q4.4_int(response),
    "Q5.1" = q5.1_int(response),
    "Q5.2" = q5.2_int(response),
    "Q6.1" = q6.1_int(response),
    "Q6.2" = q6.2_int(response),
    "Q6.3" = q6.3_int(response),
    "Q6.4" = q6.4_int(response)
  )
}

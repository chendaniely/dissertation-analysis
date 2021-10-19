library(rlang)

recode_occupation <- function(dat, occupation_col) {
  researcher_group <- c("Academic", "faculty", "PhD", "PhD (Professor)", "Analyst", "Biomedical Technician", "iTHRIV Scholar", "medical librarian", "Postdoc", "Librarian")
  admin_group <- c("Research administrator", "Research Adminstrator", "healthcare administration, PhD, MPH")
    
  dat <- dat %>%
    dplyr::mutate(
      occupation_group = dplyr::case_when(
        {{ occupation_col }} %in% researcher_group ~ "researcher",
        {{ occupation_col }} %in% admin_group ~ "researcher",
        
        {{ occupation_col }} %in% c("RN/PA", "DO/MD", "DVM", "PharmD") ~ "clinician",
        
        {{ occupation_col }} %in% c("Student (DVM)") ~ "student",
        
        {{ occupation_col }} %in% c("Student (Graduate)",
                                    "Student (Masters e.g., MPH)",
                                    "Student (Undergraduate)") ~ "student",
        TRUE ~ NA_character_
      )
    )
  
  return(dat)
}

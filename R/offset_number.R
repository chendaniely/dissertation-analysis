offset_number <- function(num, offset_value, pad_0_left) {
  new_val <- as.integer(num) + offset_value
  padded <- stringr::str_pad(new_val, 3,"left", 0)
  return(padded)
}

stopifnot(offset_number("010", -10, 3) == "000")
stopifnot(offset_number("020", -10, 3) == "010")
stopifnot(offset_number("020", 10, 3) == "030")
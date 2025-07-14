#' @import stringi
NULL #  Process @import stringi without function immediately below

# Aux functions for metaphonebr (internal)

#' Phonetic preprocessing: removes accents, numbers and capitalizes
#'
#' Remove diacritics, capitalizes and remove
#' characters that are not letters or spaecs.
#'
#' @param fullname a character vector.
#' @return a preprocessed character vector.
#' @keywords internal


capitalize_remove_accents <- function(fullname) {
  # Remove diacritics (ex.: "Jo\u00e3o" -> "Joao")
  fullname <- stringi::stri_trans_general(fullname, "Latin-ASCII")
  # Capitalizes (ex.: "joao" -> "JOAO")
  fullname <- base::toupper(fullname)
  # Remove non space nor letter characters
  # Example: "JOAO123!" -> "JOAO"
  # Adjust to keep single spacing between words
  fullname <- stringi::stri_replace_all_regex(fullname, "[^A-Z ]+", "")
  fullname <- stringi::stri_replace_all_regex(fullname, "\\s+", " ") # Ensures single spacing
  fullname <- stringi::stri_trim_both(fullname) # trim spaces
  return(fullname)
}

#' Phonetic Simplification: removal of silent letters
#'
#' Removes silent 'H'  at the beggining of each word.
#'
#' @param fullname a character vector.
#' @return a character vector with silent initial 'H's removed.
#' @keywords internal

remove_silent_letters <- function(fullname) {
  # Remove silent 'H'  at the beggining of each word. .
  # Example: "Helena Silva" -> "ELENA SILVA"
  fullname <- stringi::stri_replace_all_regex(fullname, "\\bH", "")
  return(fullname)
}

#' Phonetic Simplification: similar digraphs
#'
#' Transforms common sounding digraphs to simplify their phonetic representation.
#'
#' @param fullname a character vector.
#' @return a character vector with simplified representation of digraphs.
#' @keywords internal

simplify_digraphs <- function(fullname) {
  # Transform "LH" in "1"
  fullname <- stringi::stri_replace_all_fixed(fullname, "LH", "1")
  # Transform "NH" in "3"
  fullname <- stringi::stri_replace_all_fixed(fullname, "NH", "3")
  # Transform "CH" in "X" ( /\u0283/ sound)
  fullname <- stringi::stri_replace_all_fixed(fullname, "CH", "X")
  # Transform "SH" in "X" (For foreign names with  /\u0283/ sound)
  fullname <- stringi::stri_replace_all_fixed(fullname, "SH", "X")
  # Transform "SCH" in "X" (som /\u0283/ or /sk/ , here opted simplifying X)
  fullname <- stringi::stri_replace_all_fixed(fullname, "SCH", "X") # Design decision, could vary to SK sound
  # Transform "PH" in "F"
  fullname <- stringi::stri_replace_all_fixed(fullname, "PH", "F")
  # Treat "SC" according to subsequent vowell
  # If "SC" followed by E or I, Transform in "S"
  fullname <- stringi::stri_replace_all_regex(fullname, "SC(?=[EI])", "S")
  # If "SC" (ou XC) followed by A, O or U, Transform in "SK".
  # For consistency with 'C' becoming 'K', 'SC' becomes 'SK' here.
  fullname <- stringi::stri_replace_all_regex(fullname, "SC(?=[AOU])", "SK")
  # Treat "QU" digraph: remove silent U before e E or I
  # \u00dc treated in previous function
  fullname <- stringi::stri_replace_all_regex(fullname, "QU(?=[EI])", "K") # QUE, QUI -> KE, KI

  # "QU" seguido de A, O -> K (simplified by design decision, generally U is pronounced in this case)
  fullname <- stringi::stri_replace_all_regex(fullname, "QU", "K") # QUanto -> KANTO (simplified)

  return(fullname)
}

#' Phonetic Simplification: Similar Consonants
#'
#' Represent similar consonants with single representation.
#'
#' @param fullname A character vector.
#' @return A character vector with simplified consonants.
#' @keywords internal

simplify_consonants <- function(fullname) {
  # Transform "\u00c7" in "S"
  fullname <- stringi::stri_replace_all_fixed(fullname, "\u00c7", "S")
  # Letter C: if followed by E or I, Transform in "S"
  fullname <- stringi::stri_replace_all_regex(fullname, "C(?=[EI])", "S")
  # Letter C: if not followeb by E or I (and not part of CH, SC, previously treated), Transform in "K"
  fullname <- stringi::stri_replace_all_regex(fullname, "C(?![EIH])", "K") # Avoids reprocessing CH
  fullname <- stringi::stri_replace_all_fixed(fullname, "C", "K") # remaining C become K

  # Letter G: if followed by E or I, Transform in "J" (GUE/GUI previosuly treated)
  fullname <- stringi::stri_replace_all_regex(fullname, "G(?=[EI])", "J")
  # Remaining G  (followed by A, O, U or consonant) remains G, not K.

  # Q always becomes "K" (QU previously treated, but there may be isolated Q along fullnames)
  fullname <- stringi::stri_replace_all_fixed(fullname, "Q", "K")
  # Transform "W" in "V" (or "U" depending on pronounciation, design decision as V is common in BR)
  fullname <- stringi::stri_replace_all_fixed(fullname, "W", "V")
  # Transform "Y" in "I"
  fullname <- stringi::stri_replace_all_fixed(fullname, "Y", "I")
  # Transform all occurrences of "Z" in "S"
  fullname <- stringi::stri_replace_all_fixed(fullname, "Z", "S")


  return(fullname)
}

#' Phonetic Simplification: Ending Nasal Sounds
#'
#' Unifies Ending Nasal Sounds.
#'
#' @param fullname A character vector.
#' @return A character vector with simplified nasal sounds.
#' @keywords internal

simplify_ending_nasals <- function(fullname) {
  # Convert N, M, or any nasalized sound (represented by vowel+M/N) in word ending.
  # Original Methaphone centers on consonants. Here, a simplification:
  # AO, AN, AM -> OM (or numerical code)
  # EN, in -> EM
  # IN, IM -> IM
  # ON, OM -> OM
  # UN, UM -> UM
  # Simplifiying for ending N becoming M (as in its original)
  fullname <- stringi::stri_replace_all_regex(fullname, "N\\b", "M")

  return(fullname)
}

#' Phonetic Removal: Repeated Vowels
#'
#' Compress adjacent identical vowel sequences.
#'
#' @param fullname A character vector.
#' @return A character vector with duplicated vowels removed.
#' @keywords internal

remove_duplicated_vowels <- function(fullname) {
  # Compress duplicated vowels sequences.
  # Exemplo: "REEBA" -> "REBA"
  fullname <- stringi::stri_replace_all_regex(fullname, "([AEIOU])\\1+", "$1")
  return(fullname)
}

#' Phonetic Removal: duplicated letters and spaces
#'
#' Remove duplicated letters and spaces.
#'
#' @param fullname A character vector.
#' @return A character vector with no repeated letters nor spaces.
#' @keywords internal

remove_dup_letters_spaces <- function(fullname) {
  # Remove adjacent duplicated letters.
  fullname <- stri_replace_all_regex(fullname, "(\\w)\\1+", "$1")
  # Trim extra spaces.
  fullname <- stringi::stri_replace_all_regex(fullname, "\\s+", " ")
  fullname <- stringi::stri_trim_both(fullname)
  return(fullname)
}


#' Generates Phonetic Code  (adapted Metaphone-BR) for Names in Portuguese
#'
#' Applies a series of phonetic transformations to a person names vector to
#' generate code that represents its approximate pronunciation in Brazilian
#' Portuguese.
#' The objective is to group similar sounding names, even though written
#' in different forms.
#'
#' @param fullnames A character vector for names to be processed.
#' @param verbose Logical, if `TRUE`, print progress messages at each step.
#'        Default  `FALSE`.
#'
#' @return A character vector with corresponding
#' phonetic representation for each entry.
#'
#' @details
#' The treatment process involves:
#' \enumerate{
#'   \item Preprocessing: Removal of accents, numbers and capitalize.
#'   \item Removal of silent letters (initial H).
#'   \item Simplification of common digraphs (LH, NH, CH, SC, QU, etc.).
#'   \item Simplification of similar sounding consonants (C/K/S, G/J, Z/S, etc.).
#'   \item Simplification of ending nasal sounds.
#'   \item Removal of duplicated vowels.
#'   \item Removal/trim of spaces and duplicated letters.
#' }
#' This is an adpation that does not follow strictly any published Metaphone
#' algorithm, but was inspired by them considering brazilian portuguese
#' context.
#'
#' @export
#' @examples
#' example_names <- c("Jo\u00e3o Silva", "Joao da Silva", "Maria", "Marya",
#'                    "Helena", "Elena", "Philippe", "Filipe", "Xavier", "Chavier")
#' phonetic_codes <- metaphonebr(example_names)
#' print(data.frame(Original = example_names, metaphonebr = phonetic_codes))
#'
#' # With progress messages
#' phonetic_codes_verbose <- metaphonebr("Exemplo único", verbose = TRUE)
metaphonebr <- function(fullnames, verbose = FALSE) {
  # Verifies if 'fullnames' is a character vector.
  if (!is.character(fullnames)) {
    stop("Error: 'fullnames' must be a character vector.")
  }
  if (!is.logical(verbose) || length(verbose) != 1) {
    stop("Error: 'verbose' must be a logical value (TRUE or FALSE).")
  }

  # Apply to each name in vector
  resultados <- sapply(fullnames, function(individual_name) {
    if (is.na(individual_name) || individual_name == "") {
      return(NA_character_) # Return NA if entry is empty or NA
    }

    x <- capitalize_remove_accents(individual_name)
    if (verbose) message("STEP 1 - capitalize_remove_accents: '", individual_name, "' -> '", x, "'")

    x <- remove_silent_letters(x)
    if (verbose) message("STEP 2 - remove_silent_letters:           '", individual_name, "' -> '", x, "'")

    x <- simplify_digraphs(x)
    if (verbose) message("STEP 3 - simplify_digraphs:       '", individual_name, "' -> '", x, "'")

    x <- simplify_consonants(x)
    if (verbose) message("STEP 4 - simplify_consonants:     '", individual_name, "' -> '", x, "'")

    x <- simplify_ending_nasals(x)
    if (verbose) message("STEP 5 - simplify_ending_nasals:    '", individual_name, "' -> '", x, "'")

    x <- remove_duplicated_vowels(x)
    if (verbose) message("STEP 6 - remove_duplicated_vowels:            '", individual_name, "' -> '", x, "'")

    x <- remove_dup_letters_spaces(x) # Treats duplicated letters and spaces
    if (verbose) message("STEP 7 - remove_dup_letters_spaces:  '", individual_name, "' -> '", x, "'")

    return(x)
  }, USE.NAMES = FALSE)

  return(resultados)
}

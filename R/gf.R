#' String interpolation to build regression formulas from vectors with variable names.
#'
#' Insert vectors with variable names into \{ \} placeholder in a formula and collapse vectors with +.
#'
#' An adaption of the \code{glue} function specialized to build
#' regression formulas from variable names stored in vectors.
#'
#' @param form A formula or string of a formula. E.g. \code{y~x+{controls}} where \code{controls} is a character vector with variables that will be inserted.
#' @param values A named list containing the vectors of variable names. If empty the enclosing environment will be searched.
#' @param enclos the enclosing environment in which the vectors with variable names will be taken if not provided by values. By default the calling enviornment.
#' @param as.formula if \code{TRUE} (default) return a formula object, otherwise a string.
#' @param form.env The environment assigned to the returned formula. By default the calling environment.
#' @param collapse how shall variables in a vector be collapsed. Default \code{" # "}.
#' @examples
#' # Assume we want to estimate a demand function
#' # using ivreg
#'
#' contr = c("x1","x2","x3") # exogenous control variables
#' instr = c(contr, "z1","z2") # instruments
#'
#' # Replace {contr} and {instr} in formula
#' gf(q ~ p + {contr} | {instr})
#'
#' # You could also provide the formula as string
#' gf("q ~ p + {contr} | {instr}")
#'
#' @export
gf = function(form, values=list(), enclos=parent.frame(), as.formula=TRUE, form.env = parent.frame(), collapse=" + " ) {

  if (is(form,"formula")) {
    # Use for formula with 3 parts formulation from here
    # https://github.com/tidyverse/glue/issues/108
    parts <- gsub("\\n\\s*","",as.character(form))
    if (length(parts)==3) {
      form = paste0(parts[c(2,1,3)], collapse="")
    } else {
      # If the formula does not have 3 parts: capture output
      form = paste0(trimws(capture.output(print(form))), collapse="")
    }
  }

  open = gregexpr("{",form, fixed=TRUE)[[1]]
  close = gregexpr("}",form, fixed=TRUE)[[1]]
  vars = substring(form,open+1, close-1)

  vals = lapply(vars, function(var) {
    if (var %in% names(values)) {
      val = values[[var]]
    } else {
      val = enclos[[var]]
    }
    paste0(val, collapse=collapse)
  })
  names(vals) = vars
  res = glue::glue_data(.x = vals, form)
  if (!as.formula) {
    return(res)
  }
  res.form = try(as.formula(res,form.env),silent = TRUE)
  if (is(res.form,"try-error")) {
    stop(paste0("You created a non-valid formula:\n",res))
  }
  return(res.form)
}

#' Creates a simple snippet code to generate a string
#' vector of all column names of a data frame
#'
#' The if the data frame has 3 columns named
#' "x", "y" and "name with space"
#' the function cats and on windows also copies to
#' your clipboard the
#' following code:
#'
#' \code{c("x","y","`name with space`")}
#'
#' This can be helpful to specify vectors of control
#' variables when using \code{\link{gf}}. If there are
#' many variables it is just easier to remove not-used variables
#' from the created code snippet than to write down
#' manually all used variables.
#'
#' @param x A data frame or other objects with \code{names}.
#' @examples
#' df = data.frame(x=1,y=5,z=4,`a b`=4)
#' varnames_snippet(df)
#'
#' @export
varnames_snippet = function(x) {
  if (!is.null(names(x))) x = names(x)

  invalid.regex = "[ \\-]"
  invalid = grepl(invalid.regex,x)
  bt = ifelse(invalid,"`","")

  code = paste0("c(",paste0('"',bt,x,bt,'"', collapse=", "),")")
  cat(paste0("\n",code))
  if (.Platform$OS.type == "windows") {
    writeClipboard(code)
    cat("\n\nCode above is also copied to clipboard.")
  }
  invisible(code)
}

example.gf = function() {
  library(glueformula)

  contr = c("x1","x2","x3")
  instr = c(contr,"z1","z2")
  gf(q ~ p + {contr} | {instr})

  library(ivreg)
  ivreg(gf(y ~ p + {contr} | {instr}))

}

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
#' instr = c(contr, "z1","z2) # instruments
#'
#' # Replace {contr} and {instr} in formula
#' gf(q ~ p + {contr} | {instr})
#'
#' # You could also provide the formula as string
#' gf("q ~ p + {contr} | {instr}")
#'
#' @export
gf = function(form, values=list(), enclos=parent.frame(), as.formula=TRUE, form.env = parent.frame(), collapse=" + " ) {

  if (is(form,"formula"))
    form = paste0(trimws(capture.output(print(form))), collapse="")

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
  res = glue::glue(form, .envir = vals)
  if (!as.formula) {
    return(res)
  }
  res.form = try(as.formula(res,form.env),silent = TRUE)
  if (is(res.form,"try-error")) {
    stop(paste0("You created a non-valid formula:\n",res))
  }
  return(res.form)
}

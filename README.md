### glueformula: string interpolation to build regression formulas

Only has the function gl that is a variant of glue useful
for building regression formulas given vectors of variable names.

```r
library(glueformula)

# Example: build a formula for ivreg
# with gf

contr = c("x1","x2","x3") # exogenous control variables
instr = c(contr,"z1","z2") # instruments

gf(q ~ p + {contr} | {instr})
```

### Installation

Run the following code to install the package from Github:
```
if (!require(glue)) install.packages("glue")
if (!require(remotes)) install.packages("remotes")
remotes::install_github("skranz/glueformula")

```

If installation fails because unimportant warnings are converted to errors run before the installation:
```r
Sys.setenv(R_REMOTES_NO_ERRORS_FROM_WARNINGS="true")
```
See [https://remotes.r-lib.org/#environment-variables](https://remotes.r-lib.org/#environment-variables)

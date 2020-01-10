### glueformula: string interpolation to build regression formulas

The main function is `gl`. It is a variant of [glue](https://github.com/tidyverse/glue) to simplify
building regression formulas given vectors of variable names.

```r
library(glueformula)

# Example: build a formula for ivreg
# with gf

contr = c("x1","x2","x3") # exogenous control variables
instr = c(contr,"z1","z2") # instruments

gf(q ~ p + {contr} | {instr})

```

Another helper function is `varnames_snippet`. It just uses the colnames of a data frame to create a code snippet with a vector of all variable names. Here is an example:
```
df = dplyr::tibble(x=1,y=5,z=4,`a b`=4)
varnames_snippet(df)
```
This prints (and on Windows copies to your clipboard) the following code snippet:
```r
c("x", "y", "z", "`a b`")
```
You can then manually select the used variables in your regression by deleting the unused variables. With many variables, this can be much quicker than writing down all used variables.

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

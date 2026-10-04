# Math functions

Statistical functions in T-SQL, mostly ports of [Apache Commons Math](https://commons.apache.org/proper/commons-math/): the error function, the normal distribution and its inverse, the log gamma and the regularized gamma functions. They are created in a `math` schema, which each script creates if it does not exist, in whatever database you run them in. They use `CREATE OR ALTER` (SQL Server 2016 SP1+).

The functions were checked against Python scipy on a grid of points, extremes included: `math.fnLogGamma`, `math.fnRegularizedGammaP`, `math.fnRegularizedGammaQ` and `math.fnErfc` agree to 1e-12 (1e-10 for `@a` up to 100000), `math.fnErfInv` to 1e-9 relative, and `math.fnCumulativeProbability` to its 10 decimals of rounding.

Install order, for the functions that depend on others:

1. `math.fnErfHorner` and `math.fnErf`, then `math.fnCumulativeProbability`
2. `math.fnErfInv`, then `math.fnInverseCumulativeProbability`
3. `math.fnLogGamma` and `math.ContinuedFraction`, then `math.fnRegularizedGammaP` and `math.fnRegularizedGammaQ` (they call each other: install both, in any order), then `math.fnErfc`

## 📝 [math.fnCumulativeProbability](./math.fnCumulativeProbability.sql)

Cumulative distribution function of the standard normal distribution (mean 0, standard deviation 1): the probability that a value is lower than `@x`, rounded to 10 decimals. Uses `math.fnErf`, and `math.fnErfHorner` when `|@x|` is between 6 and 6.5. Returns 0 for `@x` <= -6.5 and 1 for `@x` >= 6.5.

## 📝 [math.fnErf](./math.fnErf.sql)

Error function computed with its Taylor series, up to `@MaxIterations` terms (100 by default, pass `DEFAULT` to use it).

## 📝 [math.fnErfHorner](./math.fnErfHorner.sql)

Approximation of the error function with a polynomial evaluated by Horner's rule, in `decimal(18,10)`. Faster than `math.fnErf`, precise to about 7 decimals.

## 📝 [math.fnErfInv](./math.fnErfInv.sql)

Inverse error function, ported from Apache Commons Math. Returns NULL for -1 and 1, where the function is infinite, and outside [-1, 1].

## 📝 [math.fnInverseCumulativeProbability](./math.fnInverseCumulativeProbability.sql)

Inverse of the standard normal cumulative distribution (quantile function): the value below which a proportion `@p` of the distribution lies, rounded to 10 decimals. Returns NULL when `@p` is outside ]0, 1[. Uses `math.fnErfInv` on `2 * @p - 1`, which loses precision for very small `@p`: below about 1e-16 it rounds to -1 and the function returns NULL, and at 1e-10 the result is only good to about 1e-9.

## 📝 [math.fnLogGamma](./math.fnLogGamma.sql)

Natural logarithm of the gamma function with the Lanczos approximation, ported from Apache Commons Math. Returns NULL for `@x` <= 0.

## 📝 [math.fnRegularizedGammaP](./math.fnRegularizedGammaP.sql)

Regularized lower incomplete gamma function P(a, x), computed with a series, ported from Apache Commons Math. Parameters: `@a`, `@x`, the tolerance `@epsilon` (for example `1e-15`) and `@maxIterations` (for example `10000`). Returns NULL for `@a` <= 0, `@x` < 0, or when `@maxIterations` is reached. Calls `math.fnRegularizedGammaQ` when `@x` >= `@a` + 1.

## 📝 [math.fnRegularizedGammaQ](./math.fnRegularizedGammaQ.sql)

Regularized upper incomplete gamma function Q(a, x) = 1 - P(a, x), same parameters as `math.fnRegularizedGammaP`. Evaluates `math.ContinuedFraction` when `@x` >= `@a` + 1, and calls `math.fnRegularizedGammaP` otherwise.

## 📝 [math.fnErfc](./math.fnErfc.sql)

Complementary error function (1 - erf(x)), computed from `math.fnRegularizedGammaQ`.

## 📝 [math.ContinuedFraction](./math.ContinuedFraction.sql)

Continued fraction of the regularized upper incomplete gamma function, evaluated with the modified Lentz algorithm as in Apache Commons Math. Not generic: T-SQL cannot pass the coefficient functions as parameters, so the coefficients of the gamma Q fraction are written in the function. Used by `math.fnRegularizedGammaQ`; returns NULL when `@maxIterations` is reached.

## 📝 [tests](./tests.sql)

Sample calls of each function, with the expected value (computed with Python scipy) in a comment.

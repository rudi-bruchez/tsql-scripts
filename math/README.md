# Math functions

Statistical functions in T-SQL, mostly ports of [Apache Commons Math](https://commons.apache.org/proper/commons-math/): the error function, the normal distribution and its inverse, the log gamma and the regularized gamma functions. They are created in a `math` schema, which each script creates if it does not exist, in whatever database you run them in. They use `CREATE OR ALTER` (SQL Server 2016 SP1+).

Several files are marked IN PROGRESS in their header and do not compile yet: `math.ContinuedFraction`, `math.fnRegularizedGammaP`, `math.fnRegularizedGammaQ`, and `math.fnErfc` which depends on them.

Install order, for the functions that depend on others:

1. `math.fnErfHorner` and `math.fnErf`, then `math.fnCumulativeProbability`
2. `math.fnErfInv`, then `math.fnInverseCumulativeProbability`
3. `math.fnLogGamma`, then `math.fnRegularizedGammaP` and `math.fnRegularizedGammaQ` (they call each other), then `math.fnErfc`

## 📝 [math.fnCumulativeProbability](./math.fnCumulativeProbability.sql)

Cumulative distribution function of the standard normal distribution (mean 0, standard deviation 1): the probability that a value is lower than `@x`, rounded to 10 decimals. Uses `math.fnErf`, and `math.fnErfHorner` when `|@x|` is between 6 and 6.5. Beware: it returns 1 for any `@x` <= -6.5 and `@x` itself when `|@x|` > 40.

## 📝 [math.fnErf](./math.fnErf.sql)

Error function computed with its Taylor series, up to `@MaxIterations` terms (100 by default, pass `DEFAULT` to use it).

## 📝 [math.fnErfHorner](./math.fnErfHorner.sql)

Approximation of the error function with a polynomial evaluated by Horner's rule, in `decimal(18,10)`. Faster than `math.fnErf`, precise to about 7 decimals.

## 📝 [math.fnErfInv](./math.fnErfInv.sql)

Inverse error function, ported from Apache Commons Math. The branch for values very close to -1 or 1 is commented out, so the function returns NULL there, and fails on -1 and 1.

## 📝 [math.fnInverseCumulativeProbability](./math.fnInverseCumulativeProbability.sql)

Inverse of the standard normal cumulative distribution (quantile function): the value below which a proportion `@p` of the distribution lies, rounded to 10 decimals. Returns NULL when `@p` is outside [0, 1]. Uses `math.fnErfInv`.

## 📝 [math.fnLogGamma](./math.fnLogGamma.sql)

Natural logarithm of the gamma function with the Lanczos approximation, ported from Apache Commons Math. Returns NULL for `@x` <= 0. The Lanczos coefficients are added without being divided by `(@x + i)`, so the results are wrong (about 1.2 too high for `@x` = 5).

## 📝 [math.fnRegularizedGammaP](./math.fnRegularizedGammaP.sql)

Regularized lower incomplete gamma function P(a, x), computed with a series, ported from Apache Commons Math. In progress: does not compile yet.

## 📝 [math.fnRegularizedGammaQ](./math.fnRegularizedGammaQ.sql)

Regularized upper incomplete gamma function Q(a, x) = 1 - P(a, x). In progress: the continued fraction branch is still Java code.

## 📝 [math.fnErfc](./math.fnErfc.sql)

Complementary error function (1 - erf(x)), computed from `math.fnRegularizedGammaQ`. In progress, depends on that function.

## 📝 [math.ContinuedFraction](./math.ContinuedFraction.sql)

Start of a port of the continued fraction evaluation of Apache Commons Math, meant for `math.fnRegularizedGammaQ`. In progress: mostly Java code, does not compile.

## 📝 [tests](./tests.sql)

Two sample calls: `math.fnCumulativeProbability(9.33)` and `math.fnInverseCumulativeProbability(0.99)`, no expected values.

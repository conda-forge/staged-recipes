library(fuzzyRankTests)

fits <- list(
    fuzzy.sign.test(c(-2, -1, 0, 1, 2, 3)),
    fuzzy.ranksum.test(c(1, 2, 2, 4), c(2, 3, 5, 6))
)
for (fit in fits) {
    stopifnot(
        inherits(fit, "fuzzyranktest"),
        length(fit$knots) == length(fit$values),
        all(is.finite(fit$knots)), all(is.finite(fit$values)),
        all(fit$knots >= 0 & fit$knots <= 1),
        all(fit$values >= 0 & fit$values <= 1)
    )
}

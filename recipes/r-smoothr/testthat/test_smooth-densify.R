context("smooth_densify()")
skip_on_os("solaris")

test_that("smooth_densify() works on polygons", {
  m <- jagged_polygons$geometry[[2]][[1]]
  m_smooth <- smooth_densify(m, wrap = TRUE, n = 2)
  expect_is(m_smooth, "matrix")
  expect_equal(nrow(m_smooth), 2 * (nrow(m) - 1) + 1)
  expect_equal(m_smooth[1, ], m_smooth[nrow(m_smooth), ])
})

test_that("smooth_densify() works on lines", {
  l <- jagged_lines$geometry[[2]][]
  l_smooth <- smooth_densify(l, wrap = FALSE, n = 3)
  expect_is(l_smooth, "matrix")
  expect_equal(nrow(l_smooth), 3 * (nrow(l) - 1) + 1)
})

test_that("smooth_densify() works on 3d lines", {
  g <- sf::st_geometry(jagged_lines_3d)
  for (i in seq_along(g)) {
    l <- g[[i]][]
    l_smooth <- smooth_densify(l, wrap = FALSE, n = 3)
    expect_is(l_smooth, "matrix")
    expect_equal(nrow(l_smooth), 3 * (nrow(l) - 1) + 1)
  }
})

test_that("smooth_densify() max_distance works", {
  l <- jagged_lines$geometry[[2]][]
  md <- 0.1
  l_smooth <- smooth_densify(l, wrap = FALSE, max_distance = md)
  expect_is(l_smooth, "matrix")
  expect_true(all(smoothr:::point_distance(l_smooth) <= md))
})

test_that("smooth_densify() edge cases work", {
  m <- jagged_lines$geometry[[2]][]
  # if max distance is longer than segment distances, return original vertices
  expect_equivalent(m, smooth_densify(m, max_distance = 10000))
  # if n = 1 return original vertices
  expect_equivalent(m, smooth_densify(m, n = 1))
})

test_that("smooth_densify() raises error on invalid input", {
  expect_error(smooth_densify(jagged_lines))
  m <- jagged_lines$geometry[[2]][]
  expect_error(smooth_densify(m, n = -1))
  expect_error(smooth_densify(m, n = 0))
  expect_error(smooth_densify(m, n = 1.5))
  expect_error(smooth_densify(m, max_distance = -1.0))
  expect_error(smooth_densify(m, max_distance = 0))
})

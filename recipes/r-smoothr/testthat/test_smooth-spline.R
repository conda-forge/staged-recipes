context("smooth_spline()")
skip_on_os("solaris")

test_that("smooth_spline() works on polygons", {
  m <- jagged_polygons$geometry[[2]][[1]]
  m_smooth <- smooth_spline(m, wrap = TRUE)
  expect_is(m_smooth, "matrix")
  expect_gt(nrow(m_smooth), nrow(m))
  expect_equal(m_smooth[1, ], m_smooth[nrow(m_smooth), ])
})

test_that("smooth_spline() works on lines", {
  l <- jagged_lines$geometry[[2]][]
  l_smooth <- smooth_spline(l, wrap = FALSE)
  expect_is(l_smooth, "matrix")
  expect_gt(nrow(l_smooth), nrow(l))
})

test_that("smooth_spline() works on 3d lines", {
  g <- sf::st_geometry(jagged_lines_3d)
  for (i in seq_along(g)) {
    l <- g[[i]][]
    l_smooth <- smooth_spline(l, wrap = FALSE)
    expect_is(l_smooth, "matrix")
    expect_gt(nrow(l_smooth), nrow(l))
  }
})

test_that("smooth_spline() raises error on invalid input", {
  expect_error(smooth_spline(jagged_polygons))
  m <- jagged_polygons$geometry[[2]][[1]]
  expect_error(smooth_spline(m, n = -1))
  expect_error(smooth_spline(m, n = 1.5))
  expect_error(smooth_spline(m, n = nrow(m) - 1))
})

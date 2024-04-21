context("smooth_chaikin()")
skip_on_os("solaris")

test_that("smooth_chaikin() works", {
  m <- jagged_polygons$geometry[[2]][[1]]
  m_smooth <- smooth_chaikin(m, wrap = TRUE)
  expect_is(m_smooth, "matrix")
  expect_gt(nrow(m_smooth), nrow(m))
  expect_equal(m_smooth[1, ], m_smooth[nrow(m_smooth), ])
})

test_that("smooth_chaikin() works on lines", {
  l <- jagged_lines$geometry[[2]][]
  l_smooth <- smooth_chaikin(l, wrap = FALSE)
  expect_is(l_smooth, "matrix")
  expect_gt(nrow(l_smooth), nrow(l))
})

test_that("smooth_chaikin() works on 3d lines", {
  g <- sf::st_geometry(jagged_lines_3d)
  for (i in seq_along(g)) {
    l <- g[[i]][]
    l_smooth <- smooth_chaikin(l, wrap = FALSE)
    expect_is(l_smooth, "matrix")
    expect_gt(nrow(l_smooth), nrow(l))
  }
})

test_that("smooth_chaikin() raises error on invalid input", {
  expect_error(smooth_chaikin(jagged_polygons))
  m <- jagged_polygons$geometry[[2]][[1]]
  expect_error(smooth_chaikin(m, refinements = 100L))
  expect_error(smooth_chaikin(m, refinements = -1))
  expect_error(smooth_chaikin(m, refinements = 1.5))
})

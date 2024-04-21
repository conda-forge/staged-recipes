context("smooth()")
skip_on_os("solaris")

library(sf)

test_that("smooth() methods work", {
  # polygons
  # chakin
  s <- smooth(jagged_polygons, method = "chaikin")
  # change precision to fix some floating point issues on windows
  s <- st_set_precision(s, 1e6)
  expect_true(all(st_is_valid(s)))
  # ksmooth
  s <- smooth(jagged_polygons[1:6, ], method = "ksmooth")
  # change precision to fix some floating point issues on windows
  s <- st_set_precision(s, 1e6)
  expect_true(all(st_is_valid(s)))
  # spline
  s <- smooth(jagged_polygons[1:6, ], method = "spline")
  # change precision to fix some floating point issues on windows
  s <- st_set_precision(s, 1e6)
  expect_true(all(st_is_valid(s)))
  # densify
  s <- smooth(jagged_polygons, method = "densify")
  # change precision to fix some floating point issues on windows
  s <- st_set_precision(s, 1e6)
  expect_true(all(st_is_valid(s)))

  # lines
  sl <- smooth(jagged_lines, method = "chaikin")
  expect_true(all(st_is_valid(s)))
  sl <- smooth(jagged_lines, method = "ksmooth")
  expect_true(all(st_is_valid(s)))
  sl <- smooth(jagged_lines, method = "spline")
  expect_true(all(st_is_valid(s)))
  sl <- smooth(jagged_lines, method = "densify")
  expect_true(all(st_is_valid(s)))

  # test parameters
  # chaikin
  p <- jagged_polygons$geometry[[3]]
  s_r2 <- smooth(p, method = "chaikin", refinements = 1)
  s_r5 <- smooth(p, method = "chaikin", refinements = 5)
  expect_lt(nrow(s_r2[[1]]), nrow(s_r5[[1]]))
  # ksmooth
  s_n2 <- smooth(p, method = "ksmooth", n = 2)
  s_n3 <- smooth(p, method = "ksmooth", n = 3)
  expect_lt(nrow(s_n2[[1]]), nrow(s_n3[[1]]))
  expect_lte(abs(nrow(s_n2[[1]]) - (2 * (nrow(p[[1]]) - 1) + 1)), 1)
  expect_lte(abs(nrow(s_n3[[1]]) - (3 * (nrow(p[[1]]) - 1) + 1)), 1)
  s_md1 <- smooth(p, method = "ksmooth", max_distance = 0.1)
  s_md05 <- smooth(p, method = "ksmooth", max_distance = 0.05)
  expect_lt(nrow(s_md1[[1]]), nrow(s_md05[[1]]))
  # spline
  s_n100 <- smooth(p, method = "spline", n = 100)
  s_n1000 <- smooth(p, method = "spline", n = 1000)
  expect_lt(nrow(s_n100[[1]]), nrow(s_n1000[[1]]))
  expect_equal(nrow(s_n100[[1]]), 100)
  expect_equal(nrow(s_n1000[[1]]), 1000)
  s_vf2 <- smooth(p, method = "spline", vertex_factor = 2)
  s_vf4 <- smooth(p, method = "spline", vertex_factor = 4)
  expect_equal(nrow(s_vf2[[1]]), nrow(p[[1]]) * 2)
  expect_equal(nrow(s_vf4[[1]]), nrow(p[[1]]) * 4)
  # densify
  s_n2 <- smooth(p, method = "densify", n = 2)
  s_n3 <- smooth(p, method = "densify", n = 3)
  expect_lt(nrow(s_n2[[1]]), nrow(s_n3[[1]]))
  expect_equal(nrow(s_n2[[1]]), 2 * (nrow(p[[1]]) - 1) + 1)
  expect_equal(nrow(s_n3[[1]]), 3 * (nrow(p[[1]]) - 1) + 1)
  s_md1 <- smooth(p, method = "densify", max_distance = 0.1)
  s_md05 <- smooth(p, method = "densify", max_distance = 0.05)
  expect_lt(nrow(s_md1[[1]]), nrow(s_md05[[1]]))
  expect_true(all(smoothr:::point_distance(s_md1[[1]]) <= 0.1))
})

test_that("smooth() works for different input formats", {
  s_sf <- smooth(jagged_polygons)
  s_sfc <- smooth(st_geometry(jagged_polygons))
  s_sfg <- smooth(st_geometry(jagged_polygons)[[1]])
  s_spdf <- smooth(as(jagged_polygons, "Spatial"))
  s_sp <- smooth(as(as(jagged_polygons, "Spatial"), "SpatialPolygons"))
  expect_s3_class(s_sf, "sf")
  expect_s3_class(s_sfc, "sfc")
  expect_s3_class(s_sfg, "POLYGON")
  expect_s4_class(s_spdf, "SpatialPolygonsDataFrame")
  expect_s4_class(s_sp, "SpatialPolygons")
  expect_equal(nrow(s_sf), length(s_sfc))
  expect_equal(nrow(s_sf), length(s_spdf))
  expect_equivalent(st_set_geometry(s_sf, NULL), s_spdf@data)
})

test_that("smooth() works for SpatVector objects", {
  skip_if_not_installed("terra")
  jp_terra <- terra::vect(as(jagged_polygons, "Spatial"))
  s_terra <- expect_warning(smooth(jp_terra))
  expect_s4_class(s_terra, "SpatVector")
})

test_that("smooth() preserves holes", {
  p <- jagged_polygons$geometry[[5]]
  expect_true(st_is_valid(smooth(p, method = "chaikin")))
  expect_true(st_is_valid(smooth(p, method = "ksmooth")))
  expect_true(st_is_valid(smooth(p, method = "spline")))
  expect_true(st_is_valid(smooth(p, method = "densify")))
  expect_equal(length(p), length(smooth(p)))
})

test_that("smooth() preserves multipart features", {
  p <- jagged_polygons$geometry[[7]]
  expect_true(st_is_valid(smooth(p, method = "chaikin")))
  expect_true(st_is_valid(smooth(p, method = "ksmooth")))
  #expect_true(st_is_valid(smooth(p, method = "spline")))
  expect_true(st_is_valid(smooth(p, method = "densify")))
  expect_equal(length(p), length(smooth(p)))

  l <- jagged_lines$geometry[[8]]
  expect_true(st_is_valid(smooth(l, method = "chaikin")))
  expect_true(st_is_valid(smooth(l, method = "ksmooth")))
  expect_true(st_is_valid(smooth(l, method = "spline")))
  expect_true(st_is_valid(smooth(l, method = "densify")))
  expect_equal(length(l), length(smooth(l)))
})

test_that("smooth() fails for points", {
  point <- st_point(c(0, 0))
  expect_error(smooth(point))
  expect_error(smooth(st_sfc(point)))
  expect_error(smooth(as(st_sfc(point), "Spatial")))
})

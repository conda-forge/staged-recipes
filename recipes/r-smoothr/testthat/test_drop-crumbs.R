context("drop_crumbs()")
skip_on_os("solaris")

library(sf)
library(units)

test_that("drop_crumbs() works", {
  p <- jagged_polygons$geometry[7]
  area_thresh <- units::set_units(200, km^2)
  p_dropped <- drop_crumbs(p, threshold = area_thresh)
  expect_true(any(st_area(st_cast(p, "POLYGON")) < area_thresh))
  expect_true(all(st_area(st_cast(p_dropped, "POLYGON")) >= area_thresh))

  l <- jagged_lines$geometry[8]
  length_thresh <- units::set_units(40, km)
  l_dropped <- drop_crumbs(l, threshold = length_thresh)
  expect_true(any(st_length(st_cast(l, "LINESTRING")) < length_thresh))
  expect_true(all(st_length(st_cast(l_dropped, "LINESTRING")) >= length_thresh))
})

test_that("drop_crumbs() doesn't alter features with nothing dropped", {
  p <- jagged_polygons
  p_dropped <- drop_crumbs(p, threshold = units::set_units(0.1, m^2))
  expect_equivalent(p, p_dropped)

  l <- jagged_lines
  l_dropped <- drop_crumbs(l, threshold = units::set_units(0.1, m))
  expect_equivalent(l, l_dropped)
})

test_that("drop_crumbs() drop_empty works", {
  p <- jagged_polygons$geometry
  area_thresh <- units::set_units(200, km^2)
  p_dropped <- drop_crumbs(p, threshold = area_thresh, drop_empty = FALSE)
  expect_equal(length(p_dropped), length(p))
  expect_true(any(st_is_empty(p_dropped)))
  p_dropped <- drop_crumbs(p, threshold = area_thresh, drop_empty = TRUE)
  expect_lt(length(p_dropped), length(p))
  expect_true(all(!st_is_empty(p_dropped)))
})

test_that("drop_crumbs() handling of empty results", {
  s_sf <- drop_crumbs(jagged_polygons, threshold = 2e20)
  s_sfc <- drop_crumbs(st_geometry(jagged_polygons), threshold = 2e20)
  jp_sp <- as(jagged_polygons, "Spatial")
  sp::proj4string(jp_sp) <- st_crs(jagged_polygons)$proj4string
  s_spdf <- drop_crumbs(jp_sp, threshold = 2e20)

  expect_equal(nrow(s_sf), 0)
  expect_equal(length(s_sfc), 0)
  expect_null(s_spdf)
})

test_that("drop_crumbs() works for different input formats", {
  s_sf <- drop_crumbs(jagged_polygons, threshold = 2e8)
  s_sfc <- drop_crumbs(st_geometry(jagged_polygons), threshold = 2e8)

  jp_spdf <- as_Spatial(jagged_polygons)
  sp::proj4string(jp_spdf) <- st_crs(jagged_polygons)$proj4string
  s_spdf <- drop_crumbs(jp_spdf, threshold = 2e8)

  jp_sp <- as(jp_spdf, "SpatialPolygons")
  sp::proj4string(jp_sp) <- st_crs(jagged_polygons)$proj4string
  s_sp <- drop_crumbs(jp_sp, threshold = 2e8)

  expect_s3_class(s_sf, "sf")
  expect_s3_class(s_sfc, "sfc")
  expect_s4_class(s_spdf, "SpatialPolygonsDataFrame")
  expect_s4_class(s_sp, "SpatialPolygons")
  expect_equal(nrow(s_sf), length(s_sfc))
  expect_equal(nrow(s_sf), length(s_spdf))
  expect_equivalent(st_set_geometry(s_sf, NULL), s_spdf@data)
})

test_that("drop_crumbs() works for SpatVector objects", {
  skip_if_not_installed("terra")
  jp <- jagged_polygons[7, ]
  jp_terra <- terra::vect(jp)
  s_terra <- expect_warning(
    drop_crumbs(jp_terra, threshold = units::set_units(200, km^2))
  )
  expect_s4_class(s_terra, "SpatVector")

  a_diff <- terra::expanse(jp_terra) - terra::expanse(s_terra)
  expect_gt(a_diff, 0)
})

test_that("drop_crumbs() fails for points", {
  point <- st_point(c(0, 0)) %>%
    st_sfc()
  expect_error(drop_crumbs(point, threshold = 1))
  expect_error(drop_crumbs(as(st_sfc(point), "Spatial"), threshold = 1))
})

test_that("drop_crumbs() fails for mixed geometries", {
  mixed <- list(jagged_polygons$geometry[[1]], jagged_lines$geometry[[1]]) %>%
    st_sfc(crs = 4326)
  expect_error(drop_crumbs(mixed, threshold = 1))
})

test_that("drop_crumbs() fails for invalid thresholds", {
  expect_error(drop_crumbs(jagged_polygons, threshold = -1))
  expect_error(drop_crumbs(jagged_polygons, threshold = 0))
  expect_error(drop_crumbs(jagged_polygons,
                           threshold = set_units(1, km)))
})

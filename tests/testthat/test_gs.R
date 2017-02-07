library(gs)
context("GS tree reconstruction")

correct1 <- '\\(7,\\(\\(5,4\\)\\:\\['
correct2 <- "\\(\\(\\(7,\\(\\(5,4\\),\\(8,\\(\\(15,9\\),\\(13,10\\)\\)\\)\\)\\),\\(\\(\\(20,11\\),19\\),\\(17,\\(16,3\\)\\)\\)\\),\\(\\(\\(6,1\\),\\(18,2\\)\\),\\(14,12\\)\\)\\)\\;"

package.dir <- find.package('gs')
testfst     <- file.path(package.dir, 'tests/test.faa')

test_that("GS tree with EP values",{
  expect_output(gs(testfst, dup=10), correct1)
  expect_output(gs(testfst, dup= 0), correct2)
})
test_that("metphonebr works", {
  expect_equal(metaphonebr(c('MARYA','CHAVIER','HELENA','PHILIPE')),c('MARIA','XAVIER','ELENA','FILIPE'))
})

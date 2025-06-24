test_that("metphonebr works", {
  expect_equal(metaphonebr(c('MARYA','CHAVIER','HELENA','PHILIPE',
                             "CALHEIROS",
                             "FILHA MANHA CHICO SCHMIDT SCENA ESCOVA QUILO")),
               c('MARIA','XAVIER','ELENA','FILIPE',"KA1EIROS","FI1A MA3A XIKO SXMIDT SENA ESKOVA KILO"))
})

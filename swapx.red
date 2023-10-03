Red []

txt: read %txt
replace/all txt newline " "
replace/all txt ":" ""
txts: split txt " "
take/last txts
lg: length? txts
i: 1
txto: []
while [ i < (lg + 1) ]  [ append txto txts/(i + 1) append txto txts/(i) i: i + 2]
probe txto

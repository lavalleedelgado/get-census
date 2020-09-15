BEGIN {
    FS="\t"
    OFS="|"
    if (geo == "tract") FIPS_N=3
    else if (geo == "county") FIPS_N=2
    else if (geo == "state") FIPS_N=1
} {
    for (i=FIPS_N; i > 0; i--) {
        FIPS_CODE = FIPS_CODE $(NF - i)
        $(NF - i)=""
    }
    NF=(NF - FIPS_N - 1)
    print yr, FIPS_CODE, $0
    FIPS_CODE=""
}

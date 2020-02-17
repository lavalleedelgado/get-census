BEGIN {
    FS="\",\""
    OFS="|"
    if (geo == "tract") FIPS_N=3
    else if (geo == "county") FIPS_N=2
    else if (geo == "state") FIPS_N=1
} {
    for (i=FIPS_N; i > 0; i--) {
        FIPS_CODE = FIPS_CODE $(NF - i + 1)
        $(NF - i + 1)=""
    }
    NF=(NF - FIPS_N)
    print yr, FIPS_CODE, $0
    FIPS_CODE=""
}

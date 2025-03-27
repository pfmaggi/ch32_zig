SVD files extracted from `MounRiver_Studio_Community_Linux_x64_V190.zip`

`/MRS_Community/template/wizard/WCH/RISC-V/*/NoneOS/*.svd`

```shell
sha1sum */NoneOS/*.svd | grep -v "CH32[MV]00[24567]/" | grep "CH32V"
9278c175949a57ac3f00c3094326c9fab15cb222  CH32V003/NoneOS/CH32V003xx.svd
edac7df5cc762fd6d721a3ec66e62b1004478a51  CH32V103/NoneOS/CH32V103xx.svd
615325f6f9f7dcb36db65185ee0f993c03d2ab00  CH32V203/NoneOS/CH32V203xx.svd
8529fd0ba4e2ee6d5afd7f9cecae98ceadf42070  CH32V208/NoneOS/CH32V208xx.svd
b5cfa80b22ac5805e8b79d42500178f8dc150724  CH32V303/NoneOS/CH32V303xx.svd
6e9ed5eefb32dfe587dd566287bdd0f7d93e3cfc  CH32V305/NoneOS/CH32V305xx.svd
8986c66db282a8647fe7cc4b2a0989ff0dec0e5a  CH32V307/NoneOS/CH32V307xx.svd
96ef91d066e38e7abe5f8bd50ed8e109db48dd04  CH32V317/NoneOS/CH32V317xx.svd
```

## Update sequence

Copy:

```shell
cp $(ls */NoneOS/*.svd | grep -v "CH32[MV]00[24567]/" | grep "CH32V") <path>/ch32v003_zig/template/svd/
```

Check hash for deduplication:

```shell
find . -name "*.svd" | while read f; do
  # Skip first 8 lines (trim chip name).
  tail -n +9 "$f" | sha1sum | awk '{print $1, "'$f'"}'
done | sort -k2

2f694ea252a412c8abca92bbeaa5ab5de3eb14c0 ./CH32V003xx.svd
a05928c8845d94844de19a586a9492b0b6eae913 ./CH32V103xx.svd
f2c409ee18c93e663e029e50126766ab3f35c376 ./CH32V203xx.svd
f2c409ee18c93e663e029e50126766ab3f35c376 ./CH32V208xx.svd
48528b2f673f0120d29c9854ab22a81bc39e773f ./CH32V303xx.svd
48528b2f673f0120d29c9854ab22a81bc39e773f ./CH32V305xx.svd
48528b2f673f0120d29c9854ab22a81bc39e773f ./CH32V307xx.svd
48528b2f673f0120d29c9854ab22a81bc39e773f ./CH32V317xx.svd
```

Remove duplicates(see hashes from previous step):

```shell
rm ./CH32V208xx.svd
rm ./CH32V305xx.svd
rm ./CH32V307xx.svd
rm ./CH32V317xx.svd
```

Rename files:

```shell
mv CH32V003xx.svd CH32V003.svd
mv CH32V103xx.svd CH32V103.svd
mv CH32V203xx.svd CH32V20x.svd
mv CH32V303xx.svd CH32V30x.svd
```

Replace name in files:

```shell
sed -i 's/CH32V00xxx/CH32V003/g' CH32V003.svd
sed -i 's/CH32V103xx/CH32V103/g' CH32V103.svd
sed -i 's/CH32V203xx/CH32V20x/g' CH32V20x.svd
sed -i 's/CH32V30[37]xx/CH32V30x/g' CH32V30x.svd
```

Generate Zig files:

```shell
zig build
```

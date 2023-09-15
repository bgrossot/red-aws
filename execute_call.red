Red []

;#include %castr/common-tools.red

; renvoie une chaine de caractères avec un préfixe à "0" si l'entrée est inférieure à 10
tostr0: function [ val [integer!] ] [
    ret: to-string val
    if val < 10 [ ret: rejoin [ "0" ret] ]
    return ret
]
; pour une chaîne
; "#{
; ABCDEF
; }"
; renvoie
; "ABCDEF"
extractstr: function [ val [string!] ] [
    return second split val #"^(line)"
]

cr: #"^(line)"

; Configuration de l'authentification AWS
; lecture du fichier "credentials" dans le répertoire racine du répertoire courant
cred: read/lines %../credentials
foreach lines cred [
    if fnd: find lines "aws_access_key_id" [
        access_key: pick split fnd "=" 2
    ]
    if fnd: find lines "aws_secret_access_key" [
        secret_key: pick split fnd "=" 2
    ]
    if fnd: find lines "region" [
        region_key: pick split fnd "=" 2
    ]
]
;session_token = 'votre_session_token'  # Facultatif si vous utilisez des rôles IAM

; générisation de s3 :
; pour chaque action
; statique : identique pour tout appel
; variable : change selon l'appel
; action
;                                 nombre de variables
; method             [ statique ] [ fixe ]
; host               [ variable ] [ variable ]
; request_header     [ variable ] [ variable ]
; request_parameters [ variable ] [ variable ]
; querystring        [ variable ] [ variable ]

; exemple : cas de list_buckets
; method : GET
; host : s3.amazonaws.com [statique]
; request_header : aucun => donc uniquement les 3 headers de base : amz_date, request_body_hash, authorization
;                : certains headers sont facultatifs
; request_parameters : "/" [statique]
; querystring : aucun

; method host uri querystring [ optional_querystring ]
; [ required_request_values required_request_parameters ] [ optional_request_values optional_request_parameters ] mandatory_region
delete_bucket_analytics_configuration_param:  [ DELETE "_bucket.s3" "/" "?analytics&id=_Id" [] [] [ "ExpectedBucketOwner" "x-amz-expected-bucket-owner" ] "" ]

get_bucket_accelerate_configuration_param: [ GET "_bucket.s3" "/" "?accelerate" [] [] [ "ExpectedBucketOwner" "x-amz-expected-bucket-owner" "RequestPayer" "x-amz-request-payer" ] "" ]
get_bucket_acl_param: [ GET "_bucket.s3" "/" "?acl" [] [] [ "ExpectedBucketOwner" "x-amz-expected-bucket-owner" ] "" ]
get_bucket_analytics_configuration_param:  [ GET "_bucket.s3" "/" "?analytics&id=_Id" [] [] [ "ExpectedBucketOwner" "x-amz-expected-bucket-owner" ] "" ]
get_bucket_cors_param: [ GET "_bucket.s3" "/" "?cors" [] [] [ "ExpectedBucketOwner" "x-amz-expected-bucket-owner" ] "" ]
get_bucket_encryption_param: [ GET "_bucket.s3" "/" "?encryption" [] [] [ "ExpectedBucketOwner" "x-amz-expected-bucket-owner" ] "" ]
get_bucket_inventory_configuration_param:  [ GET "_bucket.s3" "/" "?inventory&id=_Id" [] [] [ "ExpectedBucketOwner" "x-amz-expected-bucket-owner" ] "" ]
get_bucket_intelligent_tiering_configuration_param:  [ GET "_bucket.s3" "/" "?intelligent-tiering&id=_Id" [] [] [ "ExpectedBucketOwner" "x-amz-expected-bucket-owner" ] "" ]
get_bucket_lifecycle_configuration_param: [ GET "_bucket.s3" "/" "?lifecycle" [] [] [ "ExpectedBucketOwner" "x-amz-expected-bucket-owner" ] "" ]
get_bucket_location_param: [ GET "_bucket.s3" "/" "?location" [] [] [ "ExpectedBucketOwner" "x-amz-expected-bucket-owner" ] "" ]
get_bucket_logging_param: [ GET "_bucket.s3" "/" "?logging" [] [] [ "ExpectedBucketOwner" "x-amz-expected-bucket-owner" ] "" ]
get_bucket_notification_configuration_param: [ GET "_bucket.s3" "/" "?notification" [] [] [ "ExpectedBucketOwner" "x-amz-expected-bucket-owner" ] "" ]
get_bucket_ownership_controls_param: [ GET "_bucket.s3" "/" "?ownershipControls" [] [] [ "ExpectedBucketOwner" "x-amz-expected-bucket-owner" ] "" ]
get_bucket_metrics_configuration_param:  [ GET "_bucket.s3" "/" "?metrics&id=_Id" [] [] [ "ExpectedBucketOwner" "x-amz-expected-bucket-owner" ] "" ]
get_bucket_policy_param: [ GET "_bucket.s3" "/" "?policy" [] [] [ "ExpectedBucketOwner" "x-amz-expected-bucket-owner" ] "" ]
get_bucket_policy_status_param: [ GET "_bucket.s3" "/" "?policyStatus" [] [] [ "ExpectedBucketOwner" "x-amz-expected-bucket-owner" ] "" ]
get_bucket_replication_param: [ GET "_bucket.s3" "/" "?replication" [] [] [ "ExpectedBucketOwner" "x-amz-expected-bucket-owner" ] "" ]
get_bucket_request_payment_param: [ GET "_bucket.s3" "/" "?requestPayment" [] [] [ "ExpectedBucketOwner" "x-amz-expected-bucket-owner" ] "" ]
get_bucket_tagging_param: [ GET "_bucket.s3" "/" "?tagging" [] [] [ "ExpectedBucketOwner" "x-amz-expected-bucket-owner" ] "" ]
get_bucket_versioning_param: [ GET "_bucket.s3" "/" "?versioning" [] [] [ "ExpectedBucketOwner" "x-amz-expected-bucket-owner" ] "" ]
get_bucket_website_param: [ GET "_bucket.s3" "/" "?website" [] [] [ "ExpectedBucketOwner" "x-amz-expected-bucket-owner" ] "" ]

list_bucket_analytics_configuration_param: [ GET "_bucket.s3" "/" "?analytics" [ "continuation-token" "_ContinuationToken" ]
                                             [] [ "ExpectedBucketOwner" "x-amz-expected-bucket-owner" ] "" ]
list_bucket_intelligent_tiering_configurations_param: [ GET "_bucket.s3" "/" "?intelligent-tiering" [ "continuation-token" "_ContinuationToken" ]
                                                         [] [] "" ]
list_bucket_inventory_configurations_param: [ GET "_bucket.s3" "/" "?inventory" [ "continuation-token" "_ContinuationToken" ]
                                              [] [ "ExpectedBucketOwner" "x-amz-expected-bucket-owner" ] "" ]
list_bucket_metrics_configurations_param: [ GET "_bucket.s3" "/" "?metrics" [ "continuation-token" "_ContinuationToken" ]
                                             [] [ "ExpectedBucketOwner" "x-amz-expected-bucket-owner" ] "" ]
list_buckets_param: [ GET "s3" "/" "" [] [] [] "us-east-1" ]

list_object_versions_param: [ GET "_bucket.s3" "/" "?versions" [ "delimiter" "_Delimiter" "encoding-type" "_EncodingType"
                                                                 "key-marker" "_KeyMarker" "max-keys" "_MaxKeys"
                                                                 "prefix" "_Prefix" "version-id-marker" "_VersionIdMarker" ]
                                                                 [] [ "ExpectedBucketOwner" "x-amz-expected-bucket-owner"
                                                                      "RequestPayer" "x-amz-request-payer"
                                                                      "OptionalObjectAttributes" "x-amz-optional-object-attributes" ] "" ]

list_objects_v2_param: [ GET "_bucket.s3" "/" "?list-type=2" [ "continuation-token" "_ContinuationToken" "delimiter" "_Delimiter"
                                                               "encoding-type" "_EncodingType" "fetch-owner" "_FetchOwner"
                                                               "max-keys" "_MaxKeys" "prefix" "_Prefix"
                                                               "start-after" "_StartAfter" ]
                                                               [] [ "RequestPayer" "x-amz-request-payer"
                                                                    "ExpectedBucketOwner" "x-amz-expected-bucket-owner"
                                                                    "OptionalObjectAttributes" "x-amz-optional-object-attributes" ] "" ]

put_bucket_analytics_configuration_param:  [ PUT "_bucket.s3" "/" "?analytics&id=_Id" [] [] [ "ExpectedBucketOwner" "x-amz-expected-bucket-owner" ] "" ]

; META
;les arguments optionnels doivent être mis en refinement
;Host: Bucket.s3.amazonaws.com
;response = client.get_bucket_policy(
;    Bucket='string',
;    ExpectedBucketOwner='string'
;)
; FIN META

;-------- première étape on gère par paramètres optionnels
execute_call: function [ param [block!] val [block!] ] [
    ; param contient les paramètres de l'appel
    ; var contient les valeurs obligatoires ou optionnelles de l'appel
    ; exemple : [ "_bucket" "monbucket" ]
    ; Configuration de l'appel à l'API
    method: param/1
    subhost: param/2
    region: region_key
    if param/8 <> "" [ region: param/8 ]
    if find subhost "_bucket" [
        bucket: to string! select val "_bucket"
        replace subhost "_bucket" bucket
        ]
    if find subhost "_region" [
        region: to string! select val "_region"
        replace subhost "_region" region
        ]
    host: rejoin [ subhost ".amazonaws.com" ]
    service: "s3"
    endpoint: rejoin [ "https://" host ]

    canonical_uri: param/3

    ; quuerystring
    canonical_querystring_brute: copy param/4

    query_parameters: select val "query"
    ;print ["canonical_querystring_brute" canonical_querystring_brute]
    ;print ["query_parameters" query_parameters]
    if query_parameters <> none
    [
        foreach [ key value ] query_parameters [
            replace canonical_querystring_brute key value ; uniquement les paramètres obligatoires
        ]
    ]
    ;print ["canonical_querystring_brute" canonical_querystring_brute]
    canonical_querystring_orig: canonical_querystring_brute

    ; optional querystring
    optional_querystring_brute: param/5
    if optional_querystring_brute <> [] [
        if query_parameters <> none
        [
            foreach [ key value ] query_parameters [
                print [ "key" key "value" value ]
                idx: index? find optional_querystring_brute key
                print [ "idx" idx]
                if idx <> none [
                    toadd: rejoin [ "&" optional_querystring_brute/(idx) "=" value ]
                ]
                append canonical_querystring_orig toadd ; uniquement les paramètres optionnels
            ]
        ]
    ]

    print ["canonical_querystring_orig" canonical_querystring_orig]

    ; https://docs.aws.amazon.com/AmazonS3/latest/API/sig-v4-header-based-auth.html
    ; on n'utilise pas canonical_querystring directement, il faut le transformer
    ; on prend la chaine et on sépare les paramètres
    ; on retire "?"
    ; la séparation se fait sur "&"
    ; on trie par ordfre alphabétique
    ; pour chaque élément
    ;   si pas de "=", on en rajoute un
    ; on concatène le résultat avec "&"

; AFAIRE canonical_querystring doit être encodé
;   prefix=somePrefix&marker=someMarker&max-keys=20
;   =>
;   UriEncode("marker")+"="+UriEncode("someMarker")+"&"+
;   UriEncode("max-keys")+"="+UriEncode("20") + "&" +
;   UriEncode("prefix")+"="+UriEncode("somePrefix")

; url-encode "lifecycle?" "="

; utiliser url-encode (de rebolek)
;-----------
    canonical_querystring: copy canonical_querystring_orig
    if canonical_querystring_orig <> "" [
        canonical_querystring: clear ""
        canonical_querystring_split: split next canonical_querystring_orig "&" ; next permet de supprimer "?"
        sort canonical_querystring_split
        foreach elem canonical_querystring_split [
            append canonical_querystring elem
            if not find elem "=" [
                append canonical_querystring "="
            ]
            append canonical_querystring "&"
        ]
        take/last canonical_querystring
    ]
    print ["canonical_querystring" canonical_querystring]

    ; Génération de la signature de la requête
    signed_headers_blk: copy [ "host;" "x-amz-date;" "x-amz-content-sha256;" ] ; minimum obligatoire
    canonical_headers_blk: clear []
    algorithm: "AWS4-HMAC-SHA256"
    datestamp: rejoin [ now/utc/year tostr0 now/utc/month tostr0 now/utc/day ]
    temps: now/utc/time
    amz_date: rejoin [ datestamp "T" tostr0 temps/hour tostr0 temps/minute tostr0 to-integer temps/second "Z" ]

    request_body: ""
    val_body: select val "body"
    if val_body <> none [
        request_body: reduce val_body
    ]
    print [ "body" request_body ]

    request_body_hash: extractstr lowercase mold checksum request_body 'SHA256
    repend canonical_headers_blk [ "host:" host cr "x-amz-content-sha256:" request_body_hash cr "x-amz-date:" amz_date cr ]

    headermap: make map! []
    put headermap 'x-amz-content-sha256 request_body_hash
    put headermap 'x-amz-date amz_date

    request_parameters: select val "param"

    ; paramètres obligatoires
    required_request_parameters: param/6
    print required_request_parameters
    print intersect required_request_parameters val
    if required_request_parameters <> [] [
        request_parameters_name: extract request_parameters 2
        if (intersect required_request_parameters request_parameters_name) == required_request_parameters [
            foreach rqn request_parameters_name [
                header: select required_request_parameters rqn
                headerval: select request_parameters rqn
                append signed_headers_blk rejoin [ header ";" ]
                repend canonical_headers_blk [ rejoin [ header ":" ] headerval cr ]

                put headermap to set-word! header headerval
            ]
        ]
        [
            print "Missing required parameter"
            quit/return 1
        ]
    ]
    ; paramètres optionnels
    optional_request_parameters: param/7
    if optional_request_parameters <> [] [
        request_parameters_name: extract request_parameters 2
        either (intersect optional_request_parameters request_parameters_name) == request_parameters_name [
            foreach rqn request_parameters_name [
                header: select optional_request_parameters rqn
                headerval: select request_parameters rqn
                append signed_headers_blk rejoin [ header ";" ]
                repend canonical_headers_blk [ rejoin [ header ":" ] headerval cr ]

                put headermap to set-word! header headerval
            ]
        ]
        [
            print "Error optional parameter"
            quit/return 2
        ]
    ]

    ; signed_headers et canonical_headers doivent être par ordre alphabétique
    print "--signed_headers--"
    sort signed_headers_blk

    signed_headers: rejoin signed_headers_blk
    take/last signed_headers ; remove last ";"

    print signed_headers

    print "--canonical_headers--"
    sort/skip canonical_headers_blk 3
    canonical_headers: rejoin canonical_headers_blk

    print canonical_headers
    canonical_request: rejoin [ method cr canonical_uri cr canonical_querystring cr canonical_headers cr signed_headers cr request_body_hash ]
    print "--canonical_request--"
    print canonical_request
    credential_scope: rejoin [ datestamp "/" region "/" service "/aws4_request"]
    string_to_sign: rejoin [ algorithm cr amz_date cr credential_scope cr extractstr lowercase mold checksum canonical_request 'SHA256 ]

    print "--string_to_sign--"
    print string_to_sign
    print "--fin string_to_sign--"

    signing_key_date: checksum/with datestamp 'SHA256 rejoin [ "AWS4" secret_key ]
    ;print signing_key_date
    signing_key_region: checksum/with region 'SHA256 signing_key_date
    ;print signing_key_region
    signing_key_service: checksum/with service 'SHA256 signing_key_region
    ;print signing_key_service
    signing_key_signing: checksum/with "aws4_request" 'SHA256 signing_key_service
    ;print signing_key_signing
    signature: extractstr lowercase mold checksum/with string_to_sign 'SHA256 signing_key_signing
    print [ "signature:" signature ]
    authorization: rejoin [ algorithm " Credential=" access_key "/" credential_scope ", SignedHeaders=" signed_headers ", Signature=" signature ]

    ; Envoi de la requête à l'API

    put headermap 'authorization authorization

    print [ "endpoint:" endpoint ]
    print [ "headermap:" headermap ]
    print [ "request_parameters:" request_parameters ]

    whatcalled: rejoin [endpoint canonical_uri canonical_querystring_orig ]   ;<========= OUI
    print [ "whatcalled:" whatcalled ]
    data: reduce [ method body-of headermap request_body]
    probe data
    reply: write/binary/info to-url whatcalled data
    print reply/1
    print reply/2
    print to string! reply/3
]

;val: [ "_bucket" "test-hosting-dual-apps" "param" [] ]
;execute_call get_bucket_logging_param val
;execute_call get_bucket_website_param val
;execute_call get_bucket_policy_param val
;execute_call get_bucket_cors_param val
;execute_call get_bucket_tagging_param val
;execute_call get_bucket_versioning_param val

;val: [ "_bucket" "test-hosting-dual-apps" "param" [ "ExpectedBucketOwner" "436735548418" "RequestPayer" "zzzzzz" ] ]
;execute_call get_bucket_accelerate_configuration_param val

;val: [ "_bucket" "nissan-paris-common-codepipeline-cicd" "_region" "eu-west-1" "param" [] ]
;execute_call list_buckets_param []

;val: [ "_bucket" "test-hosting-dual-apps" "_region" "eu-west-1" "query" [ "continuation-token" "54hgnlBJCTmhxRPJUXT6T0Ml_esx3XK4YAZlyzlmHd7mIOwTZHXUOAAAAAAAAAAB84rJnR0-5W8Y1uFKUJp9l5BDYLAk726aJ4RIMUQcKHnPByJh8XVZ3N0kVMeeDiABdOqN9eM9X4C3l_BrevgdXXr0BvaEJh9_qyhZ-3oJfQHstorMmAD-wsldVqeIkKTACXrkl7JGuVJMQ7lnFQa0v4phm6UECfGaoLS3XiKxpgmrBJXA2uRzi1AYR-FztESz3rNMTGDT9ZXxSvqstP0WsA" ] "param" [] ]
;execute_call list_bucket_metrics_configurations_param val
val: [ "_bucket" "test-hosting-dual-apps" "_region" "eu-west-1" "query" [ "prefix" "test" "encoding-type" "url" ] "param" [ "RequestPayer" "requester" ] ]
execute_call list_objects_v2_param val


Red []

#include %castr/client-tools.red

; renvoie une chaine de caractères avec un préfixe à "0" si l'entrée est inférieure à 10
tostr0: function [ val [integer!] ] [
    ret: to-string val
    if val < 10 [ ret: rejoin [ "0" ret] ]
    return ret
]
; pour une chaîne
; "#{
; ABCDEF
; }""
; renvoie
; "ABCDEF"
extractstr: function [ val [string!] ] [
    return second split val #"^(line)"
]

cr: #"^(line)"

; Configuration de l'authentification AWS
; lecture du fichier "credentials"  dans le répertoire racine du répertoire courant
cred: read/lines %../credentials
foreach lines cred [
    if fnd: find lines "aws_access_key_id" [
        access_key: pick split fnd "=" 2
    ]
    if fnd: find lines "aws_secret_access_key" [
        secret_key: pick split fnd "=" 2
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

; method host uri querystring [ required_request_values required_request_parameters ] [ optional_request_values optional_request_parameters ] request_body
list_buckets_param: [ "GET" "s3" "/" "" [] [] "" ]
get_bucket_policy_param: [ "GET" "_bucket.s3._region" "/" "?policy" [] [ "ExpectedBucketOwner" "x-amz-expected-bucket-owner" ] "" ]

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
    region: "us-east-1"
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
    canonical_querystring_orig: param/4
    canonical_querystring: param/4

    ; https://docs.aws.amazon.com/AmazonS3/latest/API/sig-v4-header-based-auth.html
    ; on n'utilise pas canonical_querystring directement, il faut le transformer
    ; 3 cas :
    ; "" (aucun)                              => "" (on ne change rien)
    ; subresource : "?subresource"            => "subresource=" (on retire "?" et ajoute un "=")
    ; parameters : "?param1=val1&param2=val2" => "param1=val1&param2=val2" (on retire "?")
    ; algo :
    ;   si "", on ne fait rien
    ;   sinon on retire "?"
    ;     si on ne trouve pas de "=", on rajoute "=" à la fin
    if canonical_querystring <> "" [
        canonical_querystring: next canonical_querystring
        if not find canonical_querystring "=" [
            append canonical_querystring "="
        ]
    ]

    signed_headers_blk: copy [ "host;" "x-amz-date;" "x-amz-content-sha256;" ] ; minimum obligatoire
    canonical_headers_blk: clear []
    headerblock: clear []
    ; Génération de la signature de la requête
    algorithm: "AWS4-HMAC-SHA256"
    datestamp: rejoin [ now/utc/year tostr0 now/utc/month tostr0 now/utc/day ]
    temps: now/utc/time
    amz_date: rejoin [ datestamp "T" tostr0 temps/hour tostr0 temps/minute tostr0 to-integer temps/second "Z" ]

    request_body: param/7
    request_body_hash: extractstr lowercase mold checksum request_body 'SHA256
;    append canonical_headers rejoin [ "host:" host cr "x-amz-content-sha256:" request_body_hash cr "x-amz-date:" amz_date cr]
    append canonical_headers_blk [ "x-amz-date:" amz_date cr "x-amz-content-sha256:" request_body_hash cr "host:" host cr]

    append headerblock "x-amz-content-sha256:"
    append headerblock request_body_hash
    append headerblock "x-amz-date:"
    append headerblock amz_date

    request_parameters: select val "param"

    ; paramètres obligatoires
    required_request_parameters: param/5
    print required_request_parameters
    print val
    print intersect required_request_parameters val
    if required_request_parameters <> [] [
        request_parameters_name: extract request_parameters 2
        if (intersect required_request_parameters request_parameters_name) == required_request_parameters [
            foreach rqn request_parameters_name [
                header: select required_request_parameters rqn
                headerval: select request_parameters rqn
                append signed_headers_blk rejoin [ header ";" ]
                append canonical_headers_blk rejoin [ header ":" ]
                append canonical_headers_blk headerval
                append canonical_headers_blk cr

                append/only headerblock rejoin [ header ":" ]
                append/only headerblock headerval
            ]
        ]
        [
            print "Missing required parameter"
            quit/return 1
        ]
    ]
    ; paramètres optionnels
    optional_request_parameters: param/6
    if optional_request_parameters <> [] [
        request_parameters_name: extract request_parameters 2
        either (intersect optional_request_parameters request_parameters_name) == request_parameters_name [
            foreach rqn request_parameters_name [
                header: select optional_request_parameters rqn
                headerval: select request_parameters rqn
                append signed_headers_blk rejoin [ header ";" ]
                append canonical_headers_blk rejoin [ header ":" ]
                append canonical_headers_blk headerval
                append canonical_headers_blk cr

                append/only headerblock rejoin [ header ":" ]
                append/only headerblock headerval
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
    signing_key_date: checksum/with datestamp 'SHA256 rejoin [ "AWS4" secret_key ]
    signing_key_region: checksum/with region 'SHA256 signing_key_date
    signing_key_service: checksum/with service 'SHA256 signing_key_region
    signing_key_signing: checksum/with "aws4_request" 'SHA256 signing_key_service
    signature: extractstr lowercase mold checksum/with string_to_sign 'SHA256 signing_key_signing

    authorization: rejoin [ algorithm " Credential=" access_key "/" credential_scope ", SignedHeaders=" signed_headers ", Signature=" signature ]
    ; Envoi de la requête à l'API
    ;headers: make map! []
    ;put headers "X-Amz-Date" amz_date
    ;put headers "X-Amz-Content-Sha256" request_body_hash
    ;put headers "Authorization" authorization

    append headerblock "authorization:"
    append headerblock authorization

    print [ "endpoint:" endpoint ]
    print [ "headerblock:" headerblock ]
    print [ "request_parameters:" request_parameters ]

    whatcalled: rejoin [endpoint canonical_uri canonical_querystring_orig ]   ;<========= OUI
    sortie: send-request/data/with to-url whatcalled to word! method request_parameters headerblock
    print sortie
    ; on récupère une map!
    ; code, headers, cookies, raw
]

val: [ "_bucket" "nissan-paris-common-codepipeline-cicd" "_region" "eu-west-1" "param" [ "ExpectedBucketOwner" "valeurTEST" ] ]
execute_call get_bucket_policy_param val
execute_call list_buckets_param []
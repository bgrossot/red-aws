Red []

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

; cette version de uriencode est spéciale car elle n'encode pas '='
uriencode: function [ val [string!] ] [
    ret: copy {}
    unreserved_chars: charset [#"A" - #"Z" #"a" - #"z" #"0" - #"9" "-_.~="]
    foreach ch val [
        either find unreserved_chars ch
            [append ret ch]
            [append ret rejoin [ "%" enbase/base form ch 16 ]]
    ]
    return ret
]

; Configuration de l'authentification AWS
; lecture du fichier "credentials" dans le répertoire racine du répertoire courant

; @get-env "HOME"
; récupère la variable d'environnement
;Oui, sur Windows, il existe des variables d'environnement similaires à `HOME` sur les systèmes Unix.
;Ces variables sont `%HOMEDRIVE%` et `%HOMEPATH%`. Ensemble, elles spécifient le chemin d'accès au répertoire de l'utilisateur⁴.
; Par exemple, si `%HOMEDRIVE%` vaut `C:` et `%HOMEPATH%` vaut `\\Users\\ {utilisateur}`, alors le répertoire de l'utilisateur serait
; `C:\\Users\\ {utilisateur}`⁴. Cependant, il n'y a pas de variable d'environnement `HOME` spécifique sur Windows⁴.

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

; PROBABLEMENT INUTILE, CE TYPE DE CAS N'EXISTE PAS
; [ required_request_values required_request_parameters ]

copy_object_param: [ PUT "_bucket.s3" "/_key" "" [] []
                    [ "ACL" "x-amz-acl" "CacheControl" "Cache-Control" "ChecksumAlgorithm" "x-amz-checksum-algorithm"
                      "ContentDisposition" "Content-Disposition" "ContentEncoding" "Content-Encoding" "ContentLanguage" "Content-Language"
                      "ContentType" "Content-Type" "CopySource" "x-amz-copy-source" "CopySourceIfMatch" "x-amz-copy-source-if-match"
                      "CopySourceIfModifiedSince" "x-amz-copy-source-if-modified-since" "CopySourceIfNoneMatch" "x-amz-copy-source-if-none-match"
                      "CopySourceIfUnmodifiedSince" "x-amz-copy-source-if-unmodified-since" "Expires" "Expires"
                      "GrantFullControl" "x-amz-grant-full-control" "GrantRead" "x-amz-grant-read" "GrantReadACP" "x-amz-grant-read-acp"
                      "GrantWriteACP" "x-amz-grant-write-acp" "MetadataDirective" "x-amz-metadata-directive" "TaggingDirective" "x-amz-tagging-directive"
                      "ServerSideEncryption" "x-amz-server-side-encryption" "StorageClass" "x-amz-storage-class" "WebsiteRedirectLocation" "x-amz-website-redirect-location"
                      "SSECustomerAlgorithm" "x-amz-server-side-encryption-customer-algorithm" "SSECustomerKey" "x-amz-server-side-encryption-customer-key"
                      "SSECustomerKeyMD5" "x-amz-server-side-encryption-customer-key-MD5" "SSEKMSKeyId" "x-amz-server-side-encryption-aws-kms-key-id"
                      "SSEKMSEncryptionContext" "x-amz-server-side-encryption-context" "BucketKeyEnabled" "x-amz-server-side-encryption-bucket-key-enabled"
                      "CopySourceSSECustomerAlgorithm" "x-amz-copy-source-server-side-encryption-customer-algorithm"
                      "CopySourceSSECustomerKey" "x-amz-copy-source-server-side-encryption-customer-key"
                      "CopySourceSSECustomerKeyMD5" "x-amz-copy-source-server-side-encryption-customer-key-MD5"
                      "RequestPayer" "x-amz-request-payer" "Tagging" "x-amz-tagging" "ObjectLockMode" "x-amz-object-lock-mode"
                      "ObjectLockRetainUntilDate" "x-amz-object-lock-retain-until-date" "ObjectLockLegalHoldStatus" "x-amz-object-lock-legal-hold"
                      "ExpectedBucketOwner" "x-amz-expected-bucket-owner" "ExpectedSourceBucketOwner" "x-amz-source-expected-bucket-owner" ] "" ]

create_bucket_param: [ PUT "_bucket.s3" "/" "" [] []
                       [ "ACL" "x-amz-acl" "GrantFullControl" "x-amz-grant-full-control" "GrantRead" "x-amz-grant-read"
                         "GrantReadACP" "x-amz-grant-read-acp" "GrantWrite" "x-amz-grant-write" "GrantWriteACP" "x-amz-grant-write-acp"
                         "ObjectLockEnabledForBucket" "x-amz-bucket-object-lock-enabled" "ObjectOwnership" "x-amz-object-ownership" ] "us-east-1" ]

delete_bucket_param: [ DELETE "_bucket.s3._region" "/" "" [] [] [ "ExpectedBucketOwner" "x-amz-expected-bucket-owner" ] "" ]
delete_bucket_analytics_configuration_param: [ DELETE "_bucket.s3" "/" "?analytics&id=_Id" [] [] [ "ExpectedBucketOwner" "x-amz-expected-bucket-owner" ] "" ]
delete_bucket_cors_param: [ DELETE "_bucket.s3" "/" "?cors" [] [] [ "ExpectedBucketOwner" "x-amz-expected-bucket-owner" ] "" ]
delete_bucket_encryption_param: [ DELETE "_bucket.s3" "/" "?encryption" [] [] [ "ExpectedBucketOwner" "x-amz-expected-bucket-owner" ] "" ]
delete_bucket_intelligent_tiering_configuration_param:  [ DELETE "_bucket.s3" "/" "?intelligent-tiering&id=_Id" [] [] [] "" ]
delete_bucket_inventory_configuration_param: [ DELETE "_bucket.s3" "/" "?inventory&id=_Id" [] [] [ "ExpectedBucketOwner" "x-amz-expected-bucket-owner" ] "" ]
delete_bucket_lifecycle_param: [ DELETE "_bucket.s3" "/" "?lifecycle" [] [] [ "ExpectedBucketOwner" "x-amz-expected-bucket-owner" ] "" ]
delete_bucket_metrics_configuration_param: [ DELETE "_bucket.s3" "/" "?metrics&id=_Id" [] [] [ "ExpectedBucketOwner" "x-amz-expected-bucket-owner" ] "" ]
delete_bucket_ownership_controls_param: [ DELETE "_bucket.s3" "/" "?ownershipControls" [] [] [ "ExpectedBucketOwner" "x-amz-expected-bucket-owner" ] "" ]
delete_bucket_policy_param: [ DELETE "_bucket.s3" "/" "?policy" [] [] [ "ExpectedBucketOwner" "x-amz-expected-bucket-owner" ] "" ]
delete_bucket_replication_param: [ DELETE "_bucket.s3" "/" "?replication" [] [] [ "ExpectedBucketOwner" "x-amz-expected-bucket-owner" ] "" ]
delete_bucket_tagging_param: [ DELETE "_bucket.s3" "/" "?tagging" [] [] [ "ExpectedBucketOwner" "x-amz-expected-bucket-owner" ] "" ]
delete_bucket_website_param: [ DELETE "_bucket.s3" "/" "?website" [] [] [ "ExpectedBucketOwner" "x-amz-expected-bucket-owner" ] "" ]
delete_object_param: [ DELETE "_bucket.s3" "/_key" "" [ "versionId" "_VersionId" ]
                       [] [ "MFA" "x-amz-mfa" "RequestPayer" "x-amz-request-payer"
                            "BypassGovernanceRetention" "x-amz-bypass-governance-retention" "ExpectedBucketOwner" "x-amz-expected-bucket-owner" ] "" ]
delete_object_tagging_param: [ DELETE "_bucket.s3" "/_key" "?tagging" [ "versionId" "_VersionId" ] [] [ "ExpectedBucketOwner" "x-amz-expected-bucket-owner" ] "" ]
delete_objects_param: [ POST "_bucket.s3" "/" "?delete" []
                        [] [ "MFA" "x-amz-mfa" "RequestPayer" "x-amz-request-payer" "BypassGovernanceRetention" "x-amz-bypass-governance-retention"
                             "ContentMD5" "Content-MD5" "ExpectedBucketOwner" "x-amz-expected-bucket-owner" ] "" ]
delete_public_access_block_param: [ DELETE "_bucket.s3" "/" "?publicAccessBlock" [] [] [ "ExpectedBucketOwner" "x-amz-expected-bucket-owner" ] "" ]

get_bucket_accelerate_configuration_param: [ GET "_bucket.s3" "/" "?accelerate" [] [] [ "ExpectedBucketOwner" "x-amz-expected-bucket-owner" "RequestPayer" "x-amz-request-payer" ] "" ]
get_bucket_acl_param: [ GET "_bucket.s3" "/" "?acl" [] [] [ "ExpectedBucketOwner" "x-amz-expected-bucket-owner" ] "" ]
get_bucket_analytics_configuration_param: [ GET "_bucket.s3" "/" "?analytics&id=_Id" [] [] [ "ExpectedBucketOwner" "x-amz-expected-bucket-owner" ] "" ]
get_bucket_cors_param: [ GET "_bucket.s3" "/" "?cors" [] [] [ "ExpectedBucketOwner" "x-amz-expected-bucket-owner" ] "" ]
get_bucket_encryption_param: [ GET "_bucket.s3" "/" "?encryption" [] [] [ "ExpectedBucketOwner" "x-amz-expected-bucket-owner" ] "" ]
get_bucket_inventory_configuration_param: [ GET "_bucket.s3" "/" "?inventory&id=_Id" [] [] [ "ExpectedBucketOwner" "x-amz-expected-bucket-owner" ] "" ]
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

get_object_param: [ GET "_bucket.s3" "/_key" "" [ "partNumber" "_PartNumber"
                                                  "response-cache-control" "_ResponseCacheControl" "response-content-disposition" "_ResponseContentDisposition"
                                                  "response-content-encoding" "_ResponseContentEncoding" "response-content-language" "_ResponseContentLanguage"
                                                  "response-content-type" "_ResponseContentType" "response-expires" "_ResponseExpires"
                                                  "versionId" "_VersionId" ]
                    [] [ "IfMatch" "If-Match" "IfModifiedSince" "If-Modified-Since" "IfNoneMatch" "If-None-Match" "IfUnmodifiedSince" "If-Unmodified-Since"
                         "Range" "Range" "SSECustomerAlgorithm" "x-amz-server-side-encryption-customer-algorithm" "SSECustomerKey" "x-amz-server-side-encryption-customer-key"
                         "SSECustomerKeyMD5" "x-amz-server-side-encryption-customer-key-MD5" "RequestPayer" "x-amz-request-payer"
                         "ExpectedBucketOwner" "x-amz-expected-bucket-owner" "ChecksumMode" "x-amz-checksum-mode" ] "" ]

get_object_acl_param: [ GET "_bucket.s3" "/_key" "?acl" [ "versionId" "_VersionId" ]
                        [] [ "RequestPayer" "x-amz-request-payer" "ExpectedBucketOwner" "x-amz-expected-bucket-owner" ] "" ]

get_object_attributes_param: [ GET "_bucket.s3" "/_key" "?attributes" [ "versionId" "_VersionId" ]
                               [] [ "MaxParts" "x-amz-max-parts" "PartNumberMarker" "x-amz-part-number-marker"
                                    "SSECustomerAlgorithm" "x-amz-server-side-encryption-customer-algorithm"
                                    "SSECustomerKey" "x-amz-server-side-encryption-customer-key"
                                    "SSECustomerKeyMD5" "x-amz-server-side-encryption-customer-key-MD5" "RequestPayer" "x-amz-request-payer"
                                    "ExpectedBucketOwner" "x-amz-expected-bucket-owner" "ObjectAttributes" "x-amz-object-attributes" ] "" ]

get_object_legal_hold_param: [ GET "_bucket.s3" "/_key" "?legal-hold" [ "versionId" "_VersionId" ]
                               [] [ "RequestPayer" "x-amz-request-payer" "ExpectedBucketOwner" "x-amz-expected-bucket-owner" ] "" ]

get_object_lock_configuration_param: [ GET "_bucket.s3" "/" "?object-lock" [] [] [ "ExpectedBucketOwner" "x-amz-expected-bucket-owner" ] "" ]

get_object_retention_param: [ GET "_bucket.s3" "/_key" "?retention" [ "versionId" "_VersionId" ]
                              [] [ "RequestPayer" "x-amz-request-payer" "ExpectedBucketOwner" "x-amz-expected-bucket-owner" ] "" ]

get_object_tagging_param: [ GET "_bucket.s3" "/_key" "?tagging" [ "versionId" "_VersionId" ]
                            [] [ "RequestPayer" "x-amz-request-payer" "ExpectedBucketOwner" "x-amz-expected-bucket-owner" ] "" ]

get_object_torrent_param: [ GET "_bucket.s3" "/_key" "?torrent" [] [] [ "RequestPayer" "x-amz-request-payer" "ExpectedBucketOwner" "x-amz-expected-bucket-owner" ] "" ]

get_public_access_block_param: [ GET "_bucket.s3" "/" "?publicAccessBlock" [] [] [ "ExpectedBucketOwner" "x-amz-expected-bucket-owner" ] "" ]

head_bucket_param: [ HEAD "_bucket.s3" "/" "" [] [] [ "ExpectedBucketOwner" "x-amz-expected-bucket-owner" ] "" ]
head_object_param: [ HEAD "_bucket.s3" "/_key" "" [ "partNumber" "_PartNumber" "versionId" "_VersionId" ]
                     [] [ "IfMatch" "If-Match" "IfModifiedSince" "If-Modified-Since" "IfNoneMatch" "If-None-Match" "IfUnmodifiedSince" "If-Unmodified-Since"
                          "Range" "Range" "SSECustomerAlgorithm" "x-amz-server-side-encryption-customer-algorithm" "SSECustomerKey" "x-amz-server-side-encryption-customer-key"
                          "SSECustomerKeyMD5" "x-amz-server-side-encryption-customer-key-MD5" "RequestPayer" "x-amz-request-payer"
                          "ExpectedBucketOwner" "x-amz-expected-bucket-owner" "ChecksumMode" "x-amz-checksum-mode" ] "" ]

list_bucket_analytics_configuration_param: [ GET "_bucket.s3" "/" "?analytics" [ "continuation-token" "_ContinuationToken" ]
                                             [] [ "ExpectedBucketOwner" "x-amz-expected-bucket-owner" ] "" ]
list_bucket_intelligent_tiering_configurations_param: [ GET "_bucket.s3" "/" "?intelligent-tiering" [ "continuation-token" "_ContinuationToken" ]
                                                        [] [] "" ]
list_bucket_inventory_configurations_param: [ GET "_bucket.s3" "/" "?inventory" [ "continuation-token" "_ContinuationToken" ]
                                              [] [ "ExpectedBucketOwner" "x-amz-expected-bucket-owner" ] "" ]
list_bucket_metrics_configurations_param: [ GET "_bucket.s3" "/" "?metrics" [ "continuation-token" "_ContinuationToken" ]
                                            [] [ "ExpectedBucketOwner" "x-amz-expected-bucket-owner" ] "" ]
list_buckets_param: [ GET "s3" "/" "" [] [] [] "us-east-1" ]

list_object_versions_param: [ GET "_bucket.s3" "/" "?versions" [ "delimiter" "_Delimiter" "encoding-type" "_EncodingType" "key-marker" "_KeyMarker"
                                                                 "max-keys" "_MaxKeys" "prefix" "_Prefix" "version-id-marker" "_VersionIdMarker" ]
                              [] [ "ExpectedBucketOwner" "x-amz-expected-bucket-owner" "RequestPayer" "x-amz-request-payer"
                                   "OptionalObjectAttributes" "x-amz-optional-object-attributes" ] "" ]

list_objects_v2_param: [ GET "_bucket.s3" "/" "?list-type=2" [ "continuation-token" "_ContinuationToken" "delimiter" "_Delimiter"
                                                               "encoding-type" "_EncodingType" "fetch-owner" "_FetchOwner"
                                                               "max-keys" "_MaxKeys" "prefix" "_Prefix" "start-after" "_StartAfter" ]
                         [] [ "RequestPayer" "x-amz-request-payer" "ExpectedBucketOwner" "x-amz-expected-bucket-owner"
                              "OptionalObjectAttributes" "x-amz-optional-object-attributes" ] "" ]

put_bucket_accelerate_configuration_param: [ PUT "_bucket.s3" "/" "?accelerate" [] [] [ "ExpectedBucketOwner" "x-amz-expected-bucket-owner" ] "" ]

put_bucket_acl_param: [ PUT "_bucket.s3" "/" "?acl" []
                        [] [ "ACL" "x-amz-acl" "ContentMD5" "Content-MD5"
                             "GrantFullControl" "x-amz-grant-full-control" "GrantRead" "x-amz-grant-read" "GrantReadACP" "x-amz-grant-read-acp"
                             "GrantWrite" "x-amz-grant-write" "GrantWriteACP" "x-amz-grant-write-acp" "ExpectedBucketOwner" "x-amz-expected-bucket-owner" ] "" ]

put_bucket_analytics_configuration_param: [ PUT "_bucket.s3" "/" "?analytics&id=_Id" [] [] [ "ExpectedBucketOwner" "x-amz-expected-bucket-owner" ] "" ]

put_bucket_cors_param: [ PUT "_bucket.s3" "/" "?cors" []
                         [] [ "ContentMD5" "Content-MD5" "ExpectedBucketOwner" "x-amz-expected-bucket-owner" ] "" ]

put_bucket_encryption_param: [ PUT "_bucket.s3" "/" "?encryption" []
                               [] [ "ContentMD5" "Content-MD5" "ExpectedBucketOwner" "x-amz-expected-bucket-owner" ] "" ]

put_bucket_intelligent_tiering_configuration_param: [ PUT "_bucket.s3" "/" "?intelligent-tiering&id=_Id" [] [] [] "" ]

put_bucket_inventory_configuration_param: [ PUT "_bucket.s3" "/" "?inventory&id=_Id" [] [] [ "ExpectedBucketOwner" "x-amz-expected-bucket-owner" ] "" ]
put_bucket_lifecycle_configuration_param: [ PUT "_bucket.s3" "/" "?lifecycle" [] [] [ "ContentMD5" "Content-MD5" "ExpectedBucketOwner" "x-amz-expected-bucket-owner" ] "" ]
put_bucket_logging_param: [ PUT "_bucket.s3" "/" "?logging" [] [] [ "ContentMD5" "Content-MD5" "ExpectedBucketOwner" "x-amz-expected-bucket-owner" ] "" ]
put_bucket_inventory_configuration_param: [ PUT "_bucket.s3" "/" "?inventory&id=_Id" [] [] [ "ExpectedBucketOwner" "x-amz-expected-bucket-owner" ] "" ]
put_bucket_metrics_configuration_param: [ PUT "_bucket.s3" "/" "?metrics&id=_Id" [] [] [ "ExpectedBucketOwner" "x-amz-expected-bucket-owner" ] "" ]
put_bucket_notification_configuration_param: [ PUT "_bucket.s3" "/" "?notification" [] [] [ "ContentMD5" "Content-MD5" "ExpectedBucketOwner" "x-amz-expected-bucket-owner"
                                                                                            "SkipDestinationValidation" "x-amz-skip-destination-validation" ] "" ]
put_bucket_ownership_controls_param: [ PUT "_bucket.s3" "/" "?ownershipControls" [] [] [ "ContentMD5" "Content-MD5" "ExpectedBucketOwner" "x-amz-expected-bucket-owner" ] "" ]
put_bucket_policy_param: [ PUT "_bucket.s3" "/" "?policy" [] [] [ "ContentMD5" "Content-MD5" "ConfirmRemoveSelfBucketAccess" "x-amz-confirm-remove-self-bucket-access"
                                                                  "ExpectedBucketOwner" "x-amz-expected-bucket-owner" ] "" ]
put_bucket_replication_param: [ PUT "_bucket.s3" "/" "?replication" [] [] [ "ContentMD5" "Content-MD5" "Token" "x-amz-bucket-object-lock-token"
                                                                            "ExpectedBucketOwner" "x-amz-expected-bucket-owner" ] "" ]
put_bucket_request_payment_param: [ PUT "_bucket.s3" "/" "?requestPayment" [] [] [ "ContentMD5" "Content-MD5" "ExpectedBucketOwner" "x-amz-expected-bucket-owner" ] "" ]
put_bucket_tagging_param: [ PUT "_bucket.s3" "/" "?tagging" [] [] [ "ContentMD5" "Content-MD5" "ExpectedBucketOwner" "x-amz-expected-bucket-owner" ] "" ]
put_bucket_versioning_param: [ PUT "_bucket.s3" "/" "?versioning" [] [] [ "ContentMD5" "Content-MD5" "MFA" "x-amz-mfa" "ExpectedBucketOwner" "x-amz-expected-bucket-owner" ] "" ]
put_bucket_website_param: [ PUT "_bucket.s3" "/" "?website" [] [] [ "ContentMD5" "Content-MD5" "ExpectedBucketOwner" "x-amz-expected-bucket-owner" ] "" ]

put_object_param: [ PUT "_bucket.s3" "/_key" "" [] []
                    [ "ACL" "x-amz-acl" "CacheControl" "Cache-Control"
                      "ContentDisposition" "Content-Disposition" "ContentEncoding" "Content-Encoding"
                      "ContentLanguage" "Content-Language" "ContentLength" "Content-Length"
                      "ContentMD5" "Content-MD5" "ContentType" "Content-Type"
                      "ChecksumCRC32" "x-amz-checksum-crc32" "ChecksumCRC32C" "x-amz-checksum-crc32c"
                      "ChecksumSHA1" "x-amz-checksum-sha1" "ChecksumSHA256" "x-amz-checksum-sha256"
                      "Expires" "Expires" "GrantFullControl" "x-amz-grant-full-control"
                      "GrantRead" "x-amz-grant-read" "GrantReadACP" "x-amz-grant-read-acp"
                      "GrantWriteACP" "x-amz-grant-write-acp" "ServerSideEncryption" "x-amz-server-side-encryption"
                      "StorageClass" "x-amz-storage-class" "WebsiteRedirectLocation" "x-amz-website-redirect-location"
                      "SSECustomerAlgorithm" "x-amz-server-side-encryption-customer-algorithm" "SSECustomerKey" "x-amz-server-side-encryption-customer-key"
                      "SSECustomerKeyMD5" "x-amz-server-side-encryption-customer-key-MD5" "SSEKMSKeyId" "x-amz-server-side-encryption-aws-kms-key-id"
                      "SSEKMSEncryptionContext" "x-amz-server-side-encryption-context" "BucketKeyEnabled" "x-amz-server-side-encryption-bucket-key-enabled"
                      "RequestPayer" "x-amz-request-payer" "Tagging" "x-amz-tagging"
                      "ObjectLockMode" "x-amz-object-lock-mode" "ObjectLockRetainUntilDate" "x-amz-object-lock-retain-until-date"
                      "ObjectLockLegalHoldStatus" "x-amz-object-lock-legal-hold" "ExpectedBucketOwner" "x-amz-expected-bucket-owner" ] "" ]

put_object_acl_param: [ PUT "_bucket.s3" "/_key" "?acl" [ "versionId" "_VersionId" ]
                        [] [ "ACL" "x-amz-acl" "ContentMD5" "Content-MD5" "GrantFullControl" "x-amz-grant-full-control" "GrantRead" "x-amz-grant-read"
                             "GrantReadACP" "x-amz-grant-read-acp" "GrantWrite" "x-amz-grant-write" "GrantWriteACP" "x-amz-grant-write-acp"
                             "RequestPayer" "x-amz-request-payer" "ExpectedBucketOwner" "x-amz-expected-bucket-owner" ] "" ]
put_object_legal_hold_param: [ PUT "_bucket.s3" "/_key" "?legal-hold" [ "versionId" "_VersionId" ]
                               [] [  "ContentMD5" "Content-MD5" "RequestPayer" "x-amz-request-payer" "ExpectedBucketOwner" "x-amz-expected-bucket-owner" ] "" ]
put_object_lock_configuration_param:[ PUT "_bucket.s3" "/" "?object-lock" []
                                      [] [ "ContentMD5" "Content-MD5" "Token" "x-amz-bucket-object-lock-token"
                                           "RequestPayer" "x-amz-request-payer" "ExpectedBucketOwner" "x-amz-expected-bucket-owner" ] "" ]
put_object_retention_param: [ PUT "_bucket.s3" "/_key" "?retention" [ "versionId" "_VersionId" ]
                              [] [  "ContentMD5" "Content-MD5" "BypassGovernanceRetention" "x-amz-bypass-governance-retention"
                                    "RequestPayer" "x-amz-request-payer" "ExpectedBucketOwner" "x-amz-expected-bucket-owner" ] "" ]
put_object_tagging_param: [ PUT "_bucket.s3" "/_key" "?tagging" [ "versionId" "_VersionId" ]
                            [] [  "ContentMD5" "Content-MD5" "RequestPayer" "x-amz-request-payer" "ExpectedBucketOwner" "x-amz-expected-bucket-owner" ] "" ]
put_public_access_block_param: [ PUT "_bucket.s3" "/" "?publicAccessBlock" [] [] [ "ContentMD5" "Content-MD5" "ExpectedBucketOwner" "x-amz-expected-bucket-owner" ] "" ]

restore_object_param: [ POST "_bucket.s3" "/_key" "?restore" [ "versionId" "_VersionId" ]
                        [] [ "RequestPayer" "x-amz-request-payer" "ExpectedBucketOwner" "x-amz-expected-bucket-owner" ] "" ]

select_object_content_param: [ POST "_bucket.s3" "/_key" "?restore&select-type=2" []
                               [] [ "SSECustomerAlgorithm" "x-amz-server-side-encryption-customer-algorithm" "SSECustomerKey" "x-amz-server-side-encryption-customer-key"
                                    "SSECustomerKeyMD5" "x-amz-server-side-encryption-customer-key-MD5" "ExpectedBucketOwner" "x-amz-expected-bucket-owner" ] "" ]

write_get_object_response_param: [ POST "s3" "/WriteGetObjectResponse" "" []
                                   [] [ "RequestRoute" "x-amz-request-route" "RequestToken" "x-amz-request-token" "StatusCode" "x-amz-fwd-status"
                                        "ErrorCode" "x-amz-fwd-error-code" "ErrorMessage" "x-amz-fwd-error-message" "AcceptRanges" "x-amz-fwd-header-accept-ranges"
                                        "CacheControl" "x-amz-fwd-header-Cache-Control" "ContentDisposition" "x-amz-fwd-header-Content-Disposition"
                                        "ContentEncoding" "x-amz-fwd-header-Content-Encoding" "ContentLanguage" "x-amz-fwd-header-Content-Language"
                                        "ContentLength" "Content-Length" "ContentRange" "x-amz-fwd-header-Content-Range" "ContentType" "x-amz-fwd-header-Content-Type"
                                        "ChecksumCRC32" "x-amz-fwd-header-x-amz-checksum-crc32" "ChecksumCRC32C" "x-amz-fwd-header-x-amz-checksum-crc32c"
                                        "ChecksumSHA1" "x-amz-fwd-header-x-amz-checksum-sha1" "ChecksumSHA256" "x-amz-fwd-header-x-amz-checksum-sha256"
                                        "DeleteMarker" "x-amz-fwd-header-x-amz-delete-marker" "ETag" "x-amz-fwd-header-ETag" "Expires" "x-amz-fwd-header-Expires"
                                        "Expiration" "x-amz-fwd-header-x-amz-expiration" "LastModified" "x-amz-fwd-header-Last-Modified"
                                        "MissingMeta" "x-amz-fwd-header-x-amz-missing-meta" "ObjectLockMode" "x-amz-fwd-header-x-amz-object-lock-mode"
                                        "ObjectLockLegalHoldStatus" "x-amz-fwd-header-x-amz-object-lock-legal-hold"
                                        "ObjectLockRetainUntilDate" "x-amz-fwd-header-x-amz-object-lock-retain-until-date" "PartsCount" "x-amz-fwd-header-x-amz-mp-parts-count"
                                        "ReplicationStatus" "x-amz-fwd-header-x-amz-replication-status" "RequestCharged" "x-amz-fwd-header-x-amz-request-charged"
                                        "Restore" "x-amz-fwd-header-x-amz-restore" "ServerSideEncryption" "x-amz-fwd-header-x-amz-server-side-encryption"
                                        "SSECustomerAlgorithm" "x-amz-fwd-header-x-amz-server-side-encryption-customer-algorithm"
                                        "SSEKMSKeyId" "x-amz-fwd-header-x-amz-server-side-encryption-aws-kms-key-id"
                                        "SSECustomerKeyMD5" "x-amz-fwd-header-x-amz-server-side-encryption-customer-key-MD5" "StorageClass" "x-amz-fwd-header-x-amz-storage-class"
                                        "TagCount" "x-amz-fwd-header-x-amz-tagging-count" "VersionId" "x-amz-fwd-header-x-amz-version-id"
                                        "BucketKeyEnabled" "x-amz-fwd-header-x-amz-server-side-encryption-bucket-key-enabled" ] "" ]

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
    if find canonical_uri "_" [
        uri_parameters: select val "uri"
        foreach [ key value ] uri_parameters [
            replace canonical_uri key value
        ]
    ]

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

;-----------
        ; fonctionne ; prévoir le cas si canonical_querystring_orig est vide
        ; il faut tester les deux cas
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
    print [ "body" request_body newline "fin_body" ]

    request_body_hash: extractstr lowercase mold checksum request_body 'SHA256
    repend canonical_headers_blk [ "host:" host newline "x-amz-content-sha256:" request_body_hash newline "x-amz-date:" amz_date newline ]

    headermap: make map! []
    put headermap 'x-amz-content-sha256 request_body_hash
    put headermap 'x-amz-date amz_date

    request_parameters: select val "param"

    ; paramètres obligatoires
    required_request_parameters: param/6
    if required_request_parameters <> [] [
        request_parameters_name: extract request_parameters 2
        if (intersect required_request_parameters request_parameters_name) == required_request_parameters [
            foreach rqn request_parameters_name [
                header: select required_request_parameters rqn
                headerval: select request_parameters rqn
                append signed_headers_blk rejoin [ lowercase header ";" ]
                repend canonical_headers_blk [ rejoin [ lowercase header ":" ] headerval newline ]

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
                append signed_headers_blk rejoin [ lowercase header ";" ]
                repend canonical_headers_blk [ rejoin [ lowercase header ":" ] headerval newline ]

                put headermap to set-word! header headerval
            ]
        ]
        [
            print "Error optional parameter"
            quit/return 2
        ]
    ]

    ; indispensable pour delte_objects
    if method == 'POST [ put headermap to set-word! "Content-Type" "application/xml" ]

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
    canonical_request: rejoin [ method newline canonical_uri newline canonical_querystring newline canonical_headers newline signed_headers newline request_body_hash ]
    print "--canonical_request--"
    print canonical_request
    credential_scope: rejoin [ datestamp "/" region "/" service "/aws4_request"]
    string_to_sign: rejoin [ algorithm newline amz_date newline credential_scope newline extractstr lowercase mold checksum canonical_request 'SHA256 ]

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

    whatcalled: rejoin [endpoint canonical_uri canonical_querystring_orig ]
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
;execute_call head_bucket_param val
;execute_call get_object_lock_configuration_param val
;execute_call delete_bucket_encryption_param val

;val: [ "_bucket" "test-hosting-dual-apps" "param" [ "IfMatch" "ZZZ"] "uri" [ "_key" "index.html" ] ]
;execute_call head_object_param val

;val: [ "_bucket" "test-hosting-dual-apps" "param" [ ] "uri" [ "_key" "index.html" ] ]
;execute_call get_object_param val

;val: [ "_bucket" "test-hosting-dual-apps" "param" [ "ExpectedBucketOwner" "436735548418" "RequestPayer" "zzzzzz" ] ]
;execute_call get_bucket_accelerate_configuration_param val

;val: [ "_bucket" "nissan-paris-common-codepipeline-cicd" "_region" "eu-west-1" "param" [] ]
;execute_call list_buckets_param []

;val: [ "_bucket" "test-hosting-dual-apps" "_region" "eu-west-1" "query" [ "continuation-token" "54hgnlBJCTmhxRPJUXT6T0Ml_esx3XK4YAZlyzlmHd7mIOwTZHXUOAAAAAAAAAAB84rJnR0-5W8Y1uFKUJp9l5BDYLAk726aJ4RIMUQcKHnPByJh8XVZ3N0kVMeeDiABdOqN9eM9X4C3l_BrevgdXXr0BvaEJh9_qyhZ-3oJfQHstorMmAD-wsldVqeIkKTACXrkl7JGuVJMQ7lnFQa0v4phm6UECfGaoLS3XiKxpgmrBJXA2uRzi1AYR-FztESz3rNMTGDT9ZXxSvqstP0WsA" ] "param" [] ]
;execute_call list_bucket_metrics_configurations_param val
;val: [ "_bucket" "test-hosting-dual-apps" "_region" "eu-west-1" "query" [ "prefix" "test" "encoding-type" "url" ] "param" [ "RequestPayer" "requester" ] ]
;execute_call list_objects_v2_param val

;body: {"<?xml version=^"1.0^" encoding=^"UTF-8^" standalone=^"yes^"?><AnalyticsConfiguration xmlns=^"http://s3.amazonaws.com/doc/2006-03-01/^"><Id>newconftest</Id><StorageClassAnalysis/></AnalyticsConfiguration>"}
;body: read %xml_aconf.txt

;body1: {<?xml version="1.0" encoding="UTF-8"?><AnalyticsConfiguration xmlns="http://s3.amazonaws.com/doc/2006-03-01/"><Id>newconftest1</Id><StorageClassAnalysis><DataExport><OutputSchemaVersion>V_1</OutputSchemaVersion><Destination><S3BucketDestination><Format>CSV</Format><BucketAccountId>123456789012</BucketAccountId><Bucket>arn:aws:s3:::destination-bucket</Bucket><Prefix>destination-prefix</Prefix></S3BucketDestination></Destination></DataExport></StorageClassAnalysis></AnalyticsConfiguration>}
;val: [ "_bucket" "test-hosting-dual-apps" "_region" "eu-west-1" "query" [ "_Id" "newconftest1" ] "param" [] "body" body1 ]
;execute_call put_bucket_analytics_configuration_param val

;val: [ "_bucket" "test-hosting-dual-apps" "_region" "eu-west-1" "query" [ "_Id" "ztest99" ] "param" [] ]
;execute_call get_bucket_intelligent_tiering_configuration_param val


;body:{
;<IntelligentTieringConfiguration xmlns="http://s3.amazonaws.com/doc/2006-03-01/"><Id>ztest77</Id><Filter><Prefix>index</Prefix></Filter><Status>Enabled</Status><Tiering><AccessTier>ARCHIVE_ACCESS</AccessTier><Days>177</Days></Tiering></IntelligentTieringConfiguration>
;}

;val: [ "_bucket" "test-hosting-dual-apps" "_region" "eu-west-1" "query" [ "_Id" "ztest77" ] "param" [] "body" body ]
;execute_call put_bucket_intelligent_tiering_configuration_param val

;body:{
;<InventoryConfiguration xmlns="http://s3.amazonaws.com/doc/2006-03-01/"><Id>ztestinv2</Id><IsEnabled>true</IsEnabled><Destination><S3BucketDestination><Format>CSV</Format><AccountId>436735548418</AccountId><Bucket>arn:aws:s3:::dave-neu-test1</Bucket><Prefix>toto</Prefix></S3BucketDestination></Destination><Schedule><Frequency>Daily</Frequency></Schedule><IncludedObjectVersions>Current</IncludedObjectVersions><OptionalFields/></InventoryConfiguration>
;}

;val: [ "_bucket" "test-hosting-dual-apps" "_region" "eu-west-1" "query" [ "_Id" "ztestinv2" ] "param" [] ]
;execute_call delete_bucket_intelligent_tiering_configuration_param val
;execute_call delete_bucket_inventory_configuration_param val


val: [ "" "" "query" [] "param" [] ]
execute_call write_get_object_response_param val

; body1:
; {
; <CORSConfiguration>
;  <CORSRule>
;    <AllowedOrigin>*</AllowedOrigin>
;    <AllowedMethod>GET</AllowedMethod>
;    <MaxAgeSeconds>3000</MaxAgeSeconds>
;    <AllowedHeader>Authorization</AllowedHeader>
;  </CORSRule>
; </CORSConfiguration>
; }

; body1:
; {
; <ServerSideEncryptionConfiguration xmlns="http://s3.amazonaws.com/doc/2006-03-01/">
;    <Rule>
;       <ApplyServerSideEncryptionByDefault>
;          <SSEAlgorithm>AES256</SSEAlgorithm>
;       </ApplyServerSideEncryptionByDefault>
;    </Rule>
; </ServerSideEncryptionConfiguration>
; }

; ck: enbase checksum body1 'MD5
; ; print ck
; val: [ "_bucket" "test-hosting-dual-apps" "_region" "eu-west-1" "param" [ "ContentMD5" "/m7seTgRCXAPY6BPTM+Vmg==" ] "body" body1 ]
; val/6/2: ck

; execute_call put_bucket_encryption_param val

; body:
; {
; <Tagging xmlns="http://s3.amazonaws.com/doc/2006-03-01/">
;    <TagSet>
;       <Tag>
;          <Key>string</Key>
;          <Value>string</Value>
;       </Tag>
;    </TagSet>
; </Tagging>
; }

; ck: enbase checksum body 'MD5
; val: [ "_bucket" "test-hosting-dual-apps" "_region" "eu-west-1" "param" [ "ContentMD5" "dddddddddddddd" ] "uri" [ "_key" "index.html" ]  "body" body ]
; val/6/2: ck
; execute_call put_object_tagging_param val

; body:
; {
;     Ceci est un test. Ceci est un test. Ceci est un test. Ceci est un test. Ceci est un test. Ceci est un test. Ceci est un test. Ceci est un test.
; }

; ck: enbase checksum body 'MD5
; val: [ "_bucket" "test-hosting-dual-apps" "_region" "eu-west-1" "param" [ "ContentMD5" "dddddddddddddd" ] "uri" [ "_key" "ztest3.file" ]  "body" body ]
; val/6/2: ck
; execute_call put_object_param val

; body:
; {
; <Delete xmlns="http://s3.amazonaws.com/doc/2006-03-01/">
;    <Object>
;       <Key>ztest3.file</Key>
;    </Object>
; </Delete>
; }

; ck: enbase checksum body 'MD5
; ; pour un POST, on rajoute le body uriencode + "="

; val: [ "_bucket" "test-hosting-dual-apps" "param" [ "ContentMD5" "dddddddddddddd" ] "body" body ]
; val/4/2: ck

; execute_call delete_objects_param val

;val: [ "_bucket" "test-hosting-dual-apps" "_region" "eu-west-1" "param" [ "CopySource" "/test-hosting-dual-apps/index.html" ] "uri" [ "_key" "ztest3.file" ] ]
;execute_call copy_object_param val

; body:
; {
; <CreateBucketConfiguration xmlns="http://s3.amazonaws.com/doc/2006-03-01/"> 
;     <LocationConstraint>eu-west-1</LocationConstraint> 
; </CreateBucketConfiguration >
; }

;val: [ "_bucket" "benzarma1917777" "_region" "us-east-1" "param" [] "uri" [] ]
;execute_call create_bucket_param val
;execute_call delete_bucket_param val

;;;;;;;;;;;;;;;;;;
; body: {<?xml version="1.0" encoding="UTF-8"?><AnalyticsConfiguration xmlns="http://s3.amazonaws.com/doc/2006-03-01/"><Id>newconftest§</Id><StorageClassAnalysis><DataExport><OutputSchemaVersion>V_1</OutputSchemaVersion><Destination><S3BucketDestination><Format>CSV</Format><BucketAccountId>123456789012</BucketAccountId><Bucket>arn:aws:s3:::destination-bucket</Bucket><Prefix>destination-prefix</Prefix></S3BucketDestination></Destination></DataExport></StorageClassAnalysis></AnalyticsConfiguration>}
; valminus: [ "_bucket" "test-hosting-dual-apps" "_region" "eu-west-1" "query" [ "_Id" "newconftest§" ] "param" [] "body" ]
; ii: 21
; loop 100 [
; print ii
; copybody: copy body
; copyval: copy/deep valminus
; replace copybody "newconftest§" rejoin [ "newconftest" ii ]
; replace/deep copyval "newconftest§" rejoin [ "newconftest" ii ]
; append copyval copybody
; print copyval
; print "------"
; ii: ii + 1
; execute_call put_bucket_analytics_configuration_param copyval
; ]
;;;;;;;;;;;;;;;;;;
; valminus: [ "_bucket" "test-hosting-dual-apps" "_region" "eu-west-1" "query" [ "_Id" "newconftest§" ] "param" [] ]
; ii: 117
; loop 3 [
; print ii
; copyval: copy/deep valminus
; replace/deep copyval "newconftest§" rejoin [ "newconftest" ii ]
; print copyval
; print "------"
; ii: ii + 1
; execute_call delete_bucket_analytics_configuration_param copyval
; ]

;execute_call get_bucket_inventory_configuration_param val
;execute_call get_bucket_intelligent_tiering_configuration_param val
;execute_call get_bucket_metrics_configuration_param val

;<?xml version="1.0" encoding="UTF-8" standalone="yes"?><AnalyticsConfiguration xmlns="http://s3.amazonaws.com/doc/2006-03-01/"><Id>conftest</Id><StorageClassAnalysis/></AnalyticsConfiguration>

;<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
;<AnalyticsConfiguration
;	xmlns="http://s3.amazonaws.com/doc/2006-03-01/">
;	<Id>conftest</Id>
;	<StorageClassAnalysis/>
;</AnalyticsConfiguration>

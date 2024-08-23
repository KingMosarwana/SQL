SELECT PHONE_NUMBER, COUNTRY nationality, PERSON_FIRST_NAME firstname, PERSON_LAST_NAME lastname, DATE_OF_BIRTH dateofbirth, GENDER sex, 
PERSON_IDEN_TYPE documenttype, PERSON_IDENTIFIER documentnumber, replace(PHYSICALADDRESS, '999','') PHYSICALADDRESS, 
REPLACE(POSTALADDRESS, '999','') POSTALADDRESS,
'' dateofissue , '' expirydate
FROM (
SELECT
    a.*,
    CASE
        WHEN length(a.person_identifier) = 9
             AND a.country = 'Botswana' THEN
            'OK'
        WHEN length(a.person_identifier) != 9
             AND a.country = 'Botswana' THEN
            'NOK'
        WHEN a.country != 'Botswana' THEN
            'UNKNOWN'
            WHEN a.country is null then 'NOK'
        ELSE
            'UNKNOWN'
    END AS id_length,
    CASE
        WHEN substr(a.person_identifier, 5, 1) = '1'
             AND a.country = 'Botswana'
             AND upper(a.gender) = 'MALE' THEN
            'OK'
        WHEN substr(a.person_identifier, 5, 1) = '2'
             AND a.country = 'Botswana'
             AND upper(a.gender) = 'FEMALE' THEN
            'OK'
        WHEN substr(a.person_identifier, 5, 1) = '1'
             AND a.country = 'Botswana'
             AND upper(a.gender) != 'MALE' THEN
            'NOK'
        WHEN substr(a.person_identifier, 5, 1) = '2'
             AND a.country = 'Botswana'
             AND upper(a.gender) != 'FEMALE' THEN
            'NOK'
        WHEN a.gender IS NULL THEN
            'NO_GENDER'
        ELSE
            'UNKNOWN'
    END AS gender_validation,
    CASE
        WHEN a.country IS NULL THEN
            'NOK'
        ELSE
            'OK'
    END AS country_validation,
    CASE
        WHEN a.person_first_name IS NULL THEN
            'NOK'
        ELSE
            'OK'
    END AS first_name_validation,
    CASE
        WHEN a.person_last_name IS NULL THEN
            'NOK'
        ELSE
            'OK'
    END AS last_name_validation,
    CASE
        WHEN a.date_of_birth IS NULL THEN
            'NOK'
        ELSE
            'OK'
    END AS dob_validation
FROM
    ( ---Clean up of special characters using regex replace on table a
        SELECT
            prep_registration.phone_number,
            regexp_replace(prep_registration.country, '[^a-zA-Z]')            country,
            regexp_replace(prep_registration.person_first_name, '[^a-zA-Z ]') person_first_name,
            regexp_replace(prep_registration.person_last_name, '[^a-zA-Z]')   person_last_name,
            cast(prep_registration.date_of_birth as date)                     date_of_birth,
            UPPER(regexp_replace(prep_registration.gender, '[^a-zA-Z ]')  )          gender,
            CASE WHEN regexp_replace(prep_registration.person_iden_type, '[^a-zA-Z ]') = 'ID card' THEN 'NATIONAL_ID' ELSE  
            regexp_replace(prep_registration.person_iden_type, '[^a-zA-Z ]') END person_iden_type,
            replace(regexp_replace(prep_registration.person_identifier, '[^a-zA-Z0-9 ]'),
                    ' ',
                    '')                                                       person_identifier,
            regexp_replace(prep_registration.address1, '[^a-zA-Z0-9 ]')       physicaladdress,
            regexp_replace(prep_registration.address2, '[^a-zA-Z0-9 ]')       postaladdress
        FROM
            prep_registration
        WHERE
            prep_registration.attribute_category = 'Prepaid' AND PREPAID_STATUS = 'A' 
    ) a 
WHERE COUNTRY IS NOT NULL AND PERSON_FIRST_NAME IS NOT NULL AND PERSON_LAST_NAME IS NOT NULL AND date_of_birth is not null and gender is not null and 
person_iden_type is not null AND PERSON_IDENTIFIER IS NOT NULL AND PHYSICALADDRESS IS NOT NULL AND POSTALADDRESS IS NOT NULL and COUNTRY = 'Botswana'
    ) i left JOIN BOCRAVALIDATED b on i.person_identifier = b.DOCUMENTNUMBER 
--AND UPPER(PERSON_FIRST_NAME) = UPPER(firstname) AND UPPER(PERSON_LAST_NAME) = UPPER(lastname) and UPPER(GENDER) = UPPER(sex) AND UPPER(COUNTRY) = UPPER(nationality) AND UPPER(person_iden_type) = UPPER(documenttype)
where id_length  IN ('OK', 'UNKNOWN') and gender_validation  in ('OK','UNKNOWN') and 
country_validation IN ('OK', 'UNKNOWN') AND first_name_validation IN ('OK', 'UNKNOWN') AND last_name_validation IN ('OK', 'UNKNOWN') AND dob_validation IN ('OK', 'UNKNOWN') AND 
VERIFICATIONSTATE IS NULL 

katlo moreeng

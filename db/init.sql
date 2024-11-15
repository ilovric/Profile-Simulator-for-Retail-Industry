CONNECT SYS/sys_user_password@FREEPDB1 AS SYSDBA;

GRANT EXECUTE ON DBMS_AQADM TO ihuser;
/
GRANT EXECUTE ON DBMS_AQ TO ihuser;
/
CONNECT  ihuser/ihuser@FREEPDB1;
/
ALTER SESSION SET CURRENT_SCHEMA = ihuser;
/
CREATE TABLE personal_details (
    personal_details_id NUMBER PRIMARY KEY,
    first_name       VARCHAR2(50) NOT NULL,
    last_name        VARCHAR2(50) NOT NULL,
    gender           VARCHAR2(10) CHECK (gender IN ('Male', 'Female', 'Other')),
    date_of_birth    DATE NOT NULL,
    home_address     VARCHAR2(200),
    home_city        VARCHAR2(100),
    postal_code      VARCHAR2(20),
    country          VARCHAR2(100),
    iso_country_code VARCHAR2(3), 
    mobile_phone     VARCHAR2(20),
    email            VARCHAR2(100) UNIQUE NOT NULL
)
/
CREATE TABLE retail_preferences (
    retail_preferences_id NUMBER PRIMARY KEY,
    customer_id        NUMBER NOT NULL,
    favourite_color    VARCHAR2(50),
    favourite_category VARCHAR2(100),
    favourite_sub_category VARCHAR2(100),
    shirt_size         VARCHAR2(10),
    pants_size         VARCHAR2(10),
    shoe_size          VARCHAR2(10),
    FOREIGN KEY (customer_id) REFERENCES personal_details (personal_details_id)
)
/
CREATE TABLE marketing_preferences (
    marketing_preferences_id NUMBER PRIMARY KEY,
    customer_id        NUMBER NOT NULL,
    consent            CHAR(1) CHECK (consent IN ('Y', 'N')), 
    preferred_communication_method VARCHAR2(20) CHECK (preferred_communication_method IN ('email', 'push', 'sms')),
    FOREIGN KEY (customer_id) REFERENCES personal_details (personal_details_id)
)
/
CREATE TABLE loyalty_data (
    loyalty_data_id     NUMBER PRIMARY KEY,
    customer_id         NUMBER NOT NULL,
    date_joined         DATE DEFAULT SYSDATE,
    points              NUMBER(10, 2) DEFAULT 0,
    FOREIGN KEY (customer_id) REFERENCES personal_details (personal_details_id)
)
/
CREATE TABLE system_data (
    system_data         NUMBER PRIMARY KEY,
    customer_id         NUMBER NOT NULL,
    profile_creation_date DATE DEFAULT SYSDATE,
    FOREIGN KEY (customer_id) REFERENCES personal_details (personal_details_id)
)
/
create sequence seq_task_id
 nomaxvalue
 nominvalue
/
-- Random First Name Function
CREATE OR REPLACE FUNCTION generate_random_first_name RETURN VARCHAR2 IS
    first_names  VARCHAR2(500) := 'Jane,Alice,Anna,Cath,Sara,John,Harry,David,Tom,Will,Charlie,Jimmy,Dan';
    first_name   VARCHAR2(50);
BEGIN
    -- Pick a random first name from the list
    first_name := TRIM(REGEXP_SUBSTR(first_names, '[^,]+', 1, DBMS_RANDOM.VALUE(1, 8)));
    RETURN first_name;
END;
/
-- Random Last Name Function
CREATE OR REPLACE FUNCTION generate_random_last_name RETURN VARCHAR2 IS
    last_names   VARCHAR2(500) := 'Doe,Smith,Harris,Walker,Allen,Clark,Bennett,Reed,Ellison,Lawrence';
    last_name    VARCHAR2(50);
BEGIN
    -- Pick a random last name from the list
    last_name := TRIM(REGEXP_SUBSTR(last_names, '[^,]+', 1, DBMS_RANDOM.VALUE(1, 8)));
    RETURN last_name;
END;
/
-- Random Gender Function
CREATE OR REPLACE FUNCTION generate_random_gender RETURN VARCHAR2 IS
BEGIN
    -- Randomly choose 'Male' or 'Female'
    IF DBMS_RANDOM.VALUE(0, 1) < 0.5 THEN
        RETURN 'Male';
    ELSE
        RETURN 'Female';
    END IF;
END;
/
-- Random Date of Birth Function
CREATE OR REPLACE FUNCTION generate_random_dob RETURN DATE IS
BEGIN
    -- Random date between 18 and 60 years old
    RETURN TRUNC(SYSDATE) - ROUND(DBMS_RANDOM.VALUE(6570, 21900));
END;
/
-- Random Email Function
CREATE OR REPLACE FUNCTION generate_random_email RETURN VARCHAR2 IS
    domains    VARCHAR2(100) := 'example.com,testmail.com,mail.com,gmail.com';
    email      VARCHAR2(100);
    name_part  VARCHAR2(50);
BEGIN
    -- Random part before the @ symbol
    name_part := LOWER(generate_random_first_name || '.' || generate_random_last_name || ROUND(DBMS_RANDOM.VALUE(1, 1000)));
    -- Pick a random domain
    email := name_part || '@' || TRIM(REGEXP_SUBSTR(domains, '[^,]+', 1, DBMS_RANDOM.VALUE(1, 3)));
    RETURN email;
END;
/
-- Random Mobile Phone Function
CREATE OR REPLACE FUNCTION generate_random_mobile_phone RETURN VARCHAR2 IS
BEGIN
    RETURN '09' || to_char(dbms_random.value * 100000000,'fm00000000');  -- OK
END;
/
-- Random Country Function (Simulated)
CREATE OR REPLACE FUNCTION generate_random_country RETURN VARCHAR2 IS
    countries  VARCHAR2(500) := 'USA,Canada,UK,Australia,India,Germany,France,Italy,Spain,Japan';
    country    VARCHAR2(100);
BEGIN
    -- Pick a random country from the list
    country := TRIM(REGEXP_SUBSTR(countries, '[^,]+', 1, DBMS_RANDOM.VALUE(1, 10)));
    RETURN country;
END;
/
-- Random Postal Code Function (Simulated)
CREATE OR REPLACE FUNCTION generate_random_postal_code RETURN VARCHAR2 IS
BEGIN
    -- Generate a random postal code (5 digits)
    RETURN TO_CHAR(TRUNC(DBMS_RANDOM.VALUE(10000, 99999)));
END;
/
-- Random Shirt Size Function
CREATE OR REPLACE FUNCTION generate_random_shirt_size RETURN VARCHAR2 IS
BEGIN
    -- Randomly pick from available shirt sizes
    IF DBMS_RANDOM.VALUE(0, 1) < 0.3 THEN
        RETURN 'S';
    ELSIF DBMS_RANDOM.VALUE(0, 1) < 0.6 THEN
        RETURN 'M';
    ELSE
        RETURN 'L';
    END IF;
END;
/
-- Random Pants Size Function
CREATE OR REPLACE FUNCTION generate_random_pants_size RETURN VARCHAR2 IS
BEGIN
    -- Randomly pick from available pants sizes
    IF DBMS_RANDOM.VALUE(0, 1) < 0.3 THEN
        RETURN '30';
    ELSIF DBMS_RANDOM.VALUE(0, 1) < 0.6 THEN
        RETURN '32';
    ELSE
        RETURN '34';
    END IF;
END;
/
-- Random Shoe Size Function
CREATE OR REPLACE FUNCTION generate_random_shoe_size RETURN VARCHAR2 IS
BEGIN
    -- Randomly pick a shoe size
    RETURN TO_CHAR(TRUNC(DBMS_RANDOM.VALUE(6, 12)));
END;
/
CREATE OR REPLACE PROCEDURE generate_profile IS
    v_customer_id      NUMBER;
    v_loyalty_number_id NUMBER;
    v_first_name       VARCHAR2(50);
    v_last_name        VARCHAR2(50);
    v_gender           VARCHAR2(10);
    v_date_of_birth    DATE;
    v_home_address     VARCHAR2(200);
    v_home_city        VARCHAR2(100);
    v_postal_code      VARCHAR2(20);
    v_country          VARCHAR2(100);
    v_iso_country_code VARCHAR2(3);
    v_mobile_phone     VARCHAR2(20);
    v_email            VARCHAR2(100);
    v_favourite_color  VARCHAR2(50);
    v_favourite_category VARCHAR2(100);
    v_favourite_sub_category VARCHAR2(100);
    v_shirt_size       VARCHAR2(10);
    v_pants_size       VARCHAR2(10);
    v_shoe_size        VARCHAR2(10);
    v_consent          CHAR(1);
    v_preferred_method VARCHAR2(20);
    v_points           NUMBER(10, 2);
    v_profile_creation_date DATE;
    v_delay_seconds    NUMBER;
BEGIN
    -- Generate random data for the profile
        v_first_name := generate_random_first_name;
        v_last_name  := generate_random_last_name;
        v_gender     := generate_random_gender;
        v_date_of_birth := generate_random_dob;
        v_home_address := 'Address ' || TRUNC(DBMS_RANDOM.VALUE(1, 1000));
        v_home_city    := 'City ' || TRUNC(DBMS_RANDOM.VALUE(1, 100));
        v_postal_code  := generate_random_postal_code;
        v_country      := generate_random_country;
        v_iso_country_code := 'US';  -- Example fixed country code
        v_mobile_phone := generate_random_mobile_phone;
        v_email        := generate_random_email;
        v_favourite_color := 'Blue';
        v_favourite_category := 'Electronics';
        v_favourite_sub_category := 'Mobile Phones';
        v_shirt_size   := generate_random_shirt_size;
        v_pants_size   := generate_random_pants_size;
        v_shoe_size    := generate_random_shoe_size;
        v_consent      := 'Y';
        v_preferred_method := 'email';
        v_points       := DBMS_RANDOM.VALUE(0, 1000);
        v_profile_creation_date := SYSDATE;
        
        -- Insert into Personal_Details
        INSERT INTO personal_details (
            personal_details_id, first_name, last_name, gender, date_of_birth, 
            home_address, home_city, postal_code, country, iso_country_code, 
            mobile_phone, email
        ) VALUES (
            seq_task_id.nextval, v_first_name, v_last_name, v_gender, v_date_of_birth, 
            v_home_address, v_home_city, v_postal_code, v_country, v_iso_country_code, 
            v_mobile_phone, v_email
        ) RETURNING personal_details_id INTO v_customer_id;

        -- Insert into Retail_Preferences
        INSERT INTO retail_preferences (
            retail_preferences_id, customer_id, favourite_color, favourite_category, favourite_sub_category, 
            shirt_size, pants_size, shoe_size
        ) VALUES (
            seq_task_id.nextval, v_customer_id, v_favourite_color, v_favourite_category, v_favourite_sub_category, 
            v_shirt_size, v_pants_size, v_shoe_size
        );

        -- Insert into Marketing_Preferences
        INSERT INTO marketing_preferences (
            marketing_preferences_id, customer_id, consent, preferred_communication_method
        ) VALUES (
            seq_task_id.nextval, v_customer_id, v_consent, v_preferred_method
        );

        -- Insert into Loyalty_Data
        INSERT INTO loyalty_data (
            loyalty_data_id, customer_id, date_joined, points
        ) VALUES (
            seq_task_id.nextval, v_customer_id, SYSDATE, v_points
        );

        -- Insert into System_Data
        INSERT INTO system_data (
            system_data, customer_id, profile_creation_date
        ) VALUES (
            seq_task_id.nextval, v_customer_id, v_profile_creation_date
        );
    COMMIT;
END generate_profile;
/
CREATE OR REPLACE TRIGGER trg_after_personal_details
AFTER INSERT ON personal_details
FOR EACH ROW
DECLARE
    v_json_result VARCHAR2(32767);

    enqueue_options    dbms_aq.enqueue_options_t;
    message_properties dbms_aq.message_properties_t;
    message_handle     raw(16);
    message            SYS.AQ$_JMS_TEXT_MESSAGE;
BEGIN
        -- Genereate JSON
        v_json_result := JSON_OBJECT(
                    'createDate' VALUE TO_CHAR(SYSDATE, 'YYYY-MM-DD"T"HH24:MI:SS'),  
                    'customerId' VALUE :NEW.personal_details_id,
                    'source' VALUE  'personal_details',
                    'identification' VALUE JSON_OBJECT(
                        'customerId' VALUE :NEW.personal_details_id,
                        'email' VALUE :NEW.email,
                        'phoneNumber' VALUE :NEW.mobile_phone
                    ),
                    'individualCharacteristics' VALUE JSON_OBJECT(
                        'core' VALUE JSON_OBJECT(
                            'age' VALUE FLOOR(MONTHS_BETWEEN(SYSDATE, :NEW.date_of_birth) / 12)
                        )
                    ),
                    'userAccount' VALUE JSON_OBJECT(
                        'ID' VALUE :NEW.personal_details_id
                    ),
                    'homeAddress' VALUE JSON_OBJECT(
                        'city' VALUE :NEW.home_city,
                        'country' VALUE :NEW.country,
                        'countryCode' VALUE :NEW.iso_country_code,
                        'street1' VALUE :NEW.home_address,
                        'postalCode' VALUE :NEW.postal_code
                    ),
                    'mobilePhone' VALUE JSON_OBJECT(
                        'number' VALUE :NEW.mobile_phone
                    ),
                    'person' VALUE JSON_OBJECT(
                        'birthDayAndMonth' VALUE TO_CHAR(:NEW.date_of_birth, 'MM-DD'),
                        'birthYear' VALUE TO_CHAR(:NEW.date_of_birth, 'YYYY'),
                        'name' VALUE JSON_OBJECT(
                            'lastName' VALUE :NEW.last_name,
                            'fullName' VALUE :NEW.first_name || ' ' || :NEW.last_name,
                            'firstName' VALUE :NEW.first_name
                        ),
                        'gender' VALUE :NEW.gender
                    ),
                    'personalEmail' VALUE JSON_OBJECT(
                        'address' VALUE :NEW.email
                    ),
                    'testProfile' VALUE 'true'
                ) ;


    
    -- print json for test
    DBMS_OUTPUT.PUT_LINE(v_json_result);

    -- create the message payload
    message := SYS.AQ$_JMS_TEXT_MESSAGE.construct;
    message.set_text(v_json_result);

    -- set the consumer name 
    message_properties.correlation := 'my_subscriber';

    -- enqueue the message
    dbms_aq.enqueue(
        queue_name           => 'my_teq',           
        enqueue_options      => enqueue_options,       
        message_properties   => message_properties,     
        payload              => message,               
        msgid                => message_handle);
END;
/
CREATE OR REPLACE TRIGGER trg_after_loyalty_data
AFTER INSERT ON loyalty_data
FOR EACH ROW
DECLARE
    v_json_result VARCHAR2(32767);

    enqueue_options    dbms_aq.enqueue_options_t;
    message_properties dbms_aq.message_properties_t;
    message_handle     raw(16);
    message            SYS.AQ$_JMS_TEXT_MESSAGE;
BEGIN
        -- -- Genereate JSON
        v_json_result := JSON_OBJECT(
                    'createDate' VALUE TO_CHAR(SYSDATE, 'YYYY-MM-DD"T"HH24:MI:SS'), 
                    'customerId' VALUE :NEW.customer_id, 
                    'source' VALUE  'loyalty_data',
                    'identification' VALUE JSON_OBJECT(
                        'customerId' VALUE :NEW.customer_id,
                        'loyaltyId' VALUE :NEW.loyalty_data_id
                    ),
                    'userAccount' VALUE JSON_OBJECT(
                        'ID' VALUE :NEW.customer_id
                    ),
                   'loyalty' VALUE JSON_OBJECT(
                        'loyaltyID' VALUE :NEW.loyalty_data_id,
                        'joinDate' VALUE TO_CHAR(:NEW.date_joined, 'YYYY-MM-DD"T"HH24:MI:SS'),
                        'points' VALUE :NEW.points
                    ),
                    'testProfile' VALUE 'true'
                ) ;

    -- print json for test
    DBMS_OUTPUT.PUT_LINE(v_json_result);

    -- create the message payload
    message := SYS.AQ$_JMS_TEXT_MESSAGE.construct;
    message.set_text(v_json_result);

    -- set the consumer name 
    message_properties.correlation := 'my_subscriber';

    -- enqueue the message
    dbms_aq.enqueue(
        queue_name           => 'my_teq',           
        enqueue_options      => enqueue_options,       
        message_properties   => message_properties,     
        payload              => message,               
        msgid                => message_handle);
END;
/
CREATE OR REPLACE TRIGGER trg_after_marketing_preferences
AFTER INSERT ON marketing_preferences
FOR EACH ROW
DECLARE
    v_json_result VARCHAR2(32767);

    enqueue_options    dbms_aq.enqueue_options_t;
    message_properties dbms_aq.message_properties_t;
    message_handle     raw(16);
    message            SYS.AQ$_JMS_TEXT_MESSAGE;
BEGIN
        -- -- Genereate JSON
        v_json_result := JSON_OBJECT(
                    'createDate' VALUE TO_CHAR(SYSDATE, 'YYYY-MM-DD"T"HH24:MI:SS'), 
                    'customerId' VALUE :NEW.customer_id, 
                    'source' VALUE  'marketing_preferences',
                    'userAccount' VALUE JSON_OBJECT(
                        'ID' VALUE :NEW.customer_id
                    ),
                    'consents' VALUE JSON_OBJECT(
                        'collect' VALUE JSON_OBJECT('val' VALUE :NEW.consent),
                        'marketing' VALUE JSON_OBJECT('preferred' VALUE :NEW.preferred_communication_method)
                    ),
                    'testProfile' VALUE 'true'
                ) ;

    -- print json for test
    DBMS_OUTPUT.PUT_LINE(v_json_result);

    -- create the message payload
    message := SYS.AQ$_JMS_TEXT_MESSAGE.construct;
    message.set_text(v_json_result);

    -- set the consumer name 
    message_properties.correlation := 'my_subscriber';

    -- enqueue the message
    dbms_aq.enqueue(
        queue_name           => 'my_teq',           
        enqueue_options      => enqueue_options,       
        message_properties   => message_properties,     
        payload              => message,               
        msgid                => message_handle);
END;
/
CREATE OR REPLACE TRIGGER trg_after_retail_preferences
AFTER INSERT ON retail_preferences
FOR EACH ROW
DECLARE
    v_json_result VARCHAR2(32767);

    enqueue_options    dbms_aq.enqueue_options_t;
    message_properties dbms_aq.message_properties_t;
    message_handle     raw(16);
    message            SYS.AQ$_JMS_TEXT_MESSAGE;
BEGIN
        -- -- Genereate JSON
        v_json_result := JSON_OBJECT(
                    'createDate' VALUE TO_CHAR(SYSDATE, 'YYYY-MM-DD"T"HH24:MI:SS'), 
                    'customerId' VALUE :NEW.customer_id, 
                    'source' VALUE  'retail_preferences',
                    'individualCharacteristics' VALUE JSON_OBJECT(
                        'core' VALUE JSON_OBJECT(
                            'favouriteCategory' VALUE :NEW.favourite_category,
                            'favouriteSubCategory' VALUE :NEW.favourite_sub_category
                        ),
                        'retail' VALUE JSON_OBJECT(
                            'favoriteColor' VALUE :NEW.favourite_color,
                            'pantsSize' VALUE :NEW.pants_size,
                            'shirtSize' VALUE :NEW.shirt_size,
                            'shoeSize' VALUE :NEW.shoe_size
                        )
                    ),
                    'userAccount' VALUE JSON_OBJECT(
                        'ID' VALUE :NEW.customer_id
                    ),
                    'testProfile' VALUE 'true'
                ) ;

    -- print json for test
    DBMS_OUTPUT.PUT_LINE(v_json_result);

    -- create the message payload
    message := SYS.AQ$_JMS_TEXT_MESSAGE.construct;
    message.set_text(v_json_result);

    -- set the consumer name 
    message_properties.correlation := 'my_subscriber';

    -- enqueue the message
    dbms_aq.enqueue(
        queue_name           => 'my_teq',           
        enqueue_options      => enqueue_options,       
        message_properties   => message_properties,     
        payload              => message,               
        msgid                => message_handle);
END;
/
CREATE OR REPLACE TRIGGER trg_after_system_data
AFTER INSERT ON system_data
FOR EACH ROW
DECLARE
    v_json_result VARCHAR2(32767);

    enqueue_options    dbms_aq.enqueue_options_t;
    message_properties dbms_aq.message_properties_t;
    message_handle     raw(16);
    message            SYS.AQ$_JMS_TEXT_MESSAGE;
BEGIN
    -- Genereate JSON
    v_json_result := JSON_OBJECT(
                'createDate' VALUE TO_CHAR(SYSDATE, 'YYYY-MM-DD"T"HH24:MI:SS'), 
                'customerId' VALUE :NEW.customer_id, 
                'source' VALUE  'system_data',
                'userAccount' VALUE JSON_OBJECT(
                    'ID' VALUE :NEW.customer_id,
                    'profileCreationDate' VALUE TO_CHAR(:NEW.profile_creation_date, 'YYYY-MM-DD"T"HH24:MI:SS') 
                ),
                'testProfile' VALUE 'true'
            ) ;

    -- print json for test
    DBMS_OUTPUT.PUT_LINE(v_json_result);

    -- create the message payload
    message := SYS.AQ$_JMS_TEXT_MESSAGE.construct;
    message.set_text(v_json_result);

    -- set the consumer name 
    message_properties.correlation := 'my_subscriber';

    -- enqueue the message
    dbms_aq.enqueue(
        queue_name           => 'my_teq',           
        enqueue_options      => enqueue_options,       
        message_properties   => message_properties,     
        payload              => message,               
        msgid                => message_handle);
END;
/
DECLARE
    subscriber sys.aq$_agent;
BEGIN
    -- create the TEQ
    dbms_aqadm.create_transactional_event_queue(
        queue_name         => 'my_teq',
        multiple_consumers => true
    );
    
    -- start the TEQ
    dbms_aqadm.start_queue(
        queue_name         => 'my_teq'
    ); 

    --create a subscriber for the TEQ
    dbms_aqadm.add_subscriber(
        queue_name => 'my_teq',
        subscriber => sys.aq$_agent(
            'my_subscriber',    -- the subscriber name
            null,               -- address, only used for notifications
            0                   -- protocol
        ),
        rule => 'correlation = ''my_subscriber'''
    );
END;
/
COMMIT;
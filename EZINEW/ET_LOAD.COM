$SQL
    DECLARE SCHEMA FILE EZITRAK_DATABASE;

    INSERT INTO PERSON_DETAILS
           VALUES ("OPS ","Ops General","--------","JB","25-feb-1992");

    EXI

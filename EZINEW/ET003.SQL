MODULE		EZITRAK03_SQL
LANGUAGE	COBOL
AUTHORIZATION	ET_DB1
DECLARE EXTERNAL ET_DB1 SCHEMA AUTHORIZATION FOR FILENAME EZITRAK_DATABASE

DECLARE PROBLEM_DETAILS_C1 CURSOR FOR
	SELECT	PROBLEM_NUMBER
               ,PROBLEM_STATUS
               ,PRIORITY_ID
               ,APPLICATION_ID
               ,PROBLEM_DESC
               ,CONTACT_DATE
               ,CONTACT_PERSON_ID
               ,CONTACT_DEVICE
	FROM   PROBLEM_DETAILS
	WHERE  CONTACT_DATE    >= W010_CONTACT_DATE
	ORDER BY PROBLEM_NUMBER

	DECLARE PROBLEM_DETAILS_C2 CURSOR FOR
	SELECT	PROBLEM_NUMBER
               ,PROBLEM_STATUS
               ,PRIORITY_ID
               ,APPLICATION_ID
               ,PROBLEM_DESC
               ,CONTACT_DATE
               ,CONTACT_PERSON_ID
               ,CONTACT_DEVICE
	FROM   PROBLEM_DETAILS
	WHERE  PROBLEM_STATUS = W010_PROBLEM_STATUS
	ORDER BY PROBLEM_NUMBER

	DECLARE PROBLEM_DETAILS_C3 CURSOR FOR
	SELECT	PROBLEM_NUMBER
               ,PROBLEM_STATUS
               ,PRIORITY_ID
               ,APPLICATION_ID
               ,PROBLEM_DESC
               ,CONTACT_DATE
               ,CONTACT_PERSON_ID
               ,CONTACT_DEVICE
	FROM   PROBLEM_DETAILS
	WHERE  APPLICATION_ID = W010_APPLICATION_ID
	ORDER BY PROBLEM_NUMBER

	DECLARE PROBLEM_DETAILS_C4 CURSOR FOR
	SELECT	PROBLEM_NUMBER
               ,PROBLEM_STATUS
               ,PRIORITY_ID
               ,APPLICATION_ID
               ,PROBLEM_DESC
               ,CONTACT_DATE
               ,CONTACT_PERSON_ID
               ,CONTACT_DEVICE
	FROM   PROBLEM_DETAILS
	WHERE  PRIORITY_ID = W010_PRIORITY_ID
	ORDER BY PROBLEM_NUMBER

-------------------------------------------------------------

PROCEDURE ET_SS_PROBLEM_DETAILS
	       SQLCA
               W010_PROBLEM_NUMBER       SMALLINT
               W010_PROBLEM_STATUS       CHAR(1)
               W010_PRIORITY_ID          CHAR(1)
               W010_APPLICATION_ID       CHAR(3)
               W010_PROBLEM_DESC         CHAR(75)
               W010_CONTACT_DATE         DATE
               W010_CONTACT_PERSON_ID    CHAR(4)
               W010_CONTACT_DEVICE       CHAR(1)
               W010_OTHER_SYSTEM_CODE    CHAR(9)
	;
	       
	SELECT	PROBLEM_NUMBER
               ,PROBLEM_STATUS
               ,PRIORITY_ID
               ,APPLICATION_ID
               ,PROBLEM_DESC
               ,CONTACT_DATE
               ,CONTACT_PERSON_ID
               ,CONTACT_DEVICE
	INTO    W010_PROBLEM_NUMBER
               ,W010_PROBLEM_STATUS
               ,W010_PRIORITY_ID
               ,W010_APPLICATION_ID
               ,W010_PROBLEM_DESC
               ,W010_CONTACT_DATE
               ,W010_CONTACT_PERSON_ID
               ,W010_CONTACT_DEVICE
	FROM   PROBLEM_DETAILS
	WHERE  OTHER_SYSTEM_CODE = W010_OTHER_SYSTEM_CODE
	;

-------------------------------------------------------------

PROCEDURE ET_OC1_PROBLEM_DETAILS
	SQLCA
               W010_CONTACT_DATE         DATE
        ;
	OPEN PROBLEM_DETAILS_C1
	;

PROCEDURE ET_FC1_PROBLEM_DETAILS
	SQLCA
               W010_PROBLEM_NUMBER       SMALLINT
               W010_PROBLEM_STATUS       CHAR(1)
               W010_PRIORITY_ID          CHAR(1)
               W010_APPLICATION_ID       CHAR(3)
               W010_PROBLEM_DESC         CHAR(75)
               W010_CONTACT_DATE         DATE
               W010_CONTACT_PERSON_ID    CHAR(4)
               W010_CONTACT_DEVICE       CHAR(1)
        ;
	FETCH PROBLEM_DETAILS_C1
	INTO    W010_PROBLEM_NUMBER
               ,W010_PROBLEM_STATUS
               ,W010_PRIORITY_ID
               ,W010_APPLICATION_ID
               ,W010_PROBLEM_DESC
               ,W010_CONTACT_DATE
               ,W010_CONTACT_PERSON_ID
               ,W010_CONTACT_DEVICE
	;

PROCEDURE ET_CC1_PROBLEM_DETAILS
	SQLCA
	;
	CLOSE PROBLEM_DETAILS_C1
	;

-------------------------------------------------------------

PROCEDURE ET_OC2_PROBLEM_DETAILS
	SQLCA
               W010_PROBLEM_STATUS       CHAR(1)
        ;
	OPEN PROBLEM_DETAILS_C2
	;

PROCEDURE ET_FC2_PROBLEM_DETAILS
	SQLCA
               W010_PROBLEM_NUMBER       SMALLINT
               W010_PROBLEM_STATUS       CHAR(1)
               W010_PRIORITY_ID          CHAR(1)
               W010_APPLICATION_ID       CHAR(3)
               W010_PROBLEM_DESC         CHAR(75)
               W010_CONTACT_DATE         DATE
               W010_CONTACT_PERSON_ID    CHAR(4)
               W010_CONTACT_DEVICE       CHAR(1)
        ;
	FETCH PROBLEM_DETAILS_C2
	INTO    W010_PROBLEM_NUMBER
               ,W010_PROBLEM_STATUS
               ,W010_PRIORITY_ID
               ,W010_APPLICATION_ID
               ,W010_PROBLEM_DESC
               ,W010_CONTACT_DATE
               ,W010_CONTACT_PERSON_ID
               ,W010_CONTACT_DEVICE
	;

PROCEDURE ET_CC2_PROBLEM_DETAILS
	SQLCA
	;
	CLOSE PROBLEM_DETAILS_C2
	;

-------------------------------------------------------------

PROCEDURE ET_OC3_PROBLEM_DETAILS
	SQLCA
               W010_APPLICATION_ID       CHAR(3)
        ;
	OPEN PROBLEM_DETAILS_C3
	;

PROCEDURE ET_FC3_PROBLEM_DETAILS
	SQLCA
               W010_PROBLEM_NUMBER       SMALLINT
               W010_PROBLEM_STATUS       CHAR(1)
               W010_PRIORITY_ID          CHAR(1)
               W010_APPLICATION_ID       CHAR(3)
               W010_PROBLEM_DESC         CHAR(75)
               W010_CONTACT_DATE         DATE
               W010_CONTACT_PERSON_ID    CHAR(4)
               W010_CONTACT_DEVICE       CHAR(1)
        ;
	FETCH PROBLEM_DETAILS_C3
	INTO    W010_PROBLEM_NUMBER
               ,W010_PROBLEM_STATUS
               ,W010_PRIORITY_ID
               ,W010_APPLICATION_ID
               ,W010_PROBLEM_DESC
               ,W010_CONTACT_DATE
               ,W010_CONTACT_PERSON_ID
               ,W010_CONTACT_DEVICE
	;

PROCEDURE ET_CC3_PROBLEM_DETAILS
	SQLCA
	;
	CLOSE PROBLEM_DETAILS_C3
	;

-------------------------------------------------------------

PROCEDURE ET_OC4_PROBLEM_DETAILS
	SQLCA
               W010_PRIORITY_ID          CHAR(1)
        ;
	OPEN PROBLEM_DETAILS_C4
	;

PROCEDURE ET_FC4_PROBLEM_DETAILS
	SQLCA
               W010_PROBLEM_NUMBER       SMALLINT
               W010_PROBLEM_STATUS       CHAR(1)
               W010_PRIORITY_ID          CHAR(1)
               W010_APPLICATION_ID       CHAR(3)
               W010_PROBLEM_DESC         CHAR(75)
               W010_CONTACT_DATE         DATE
               W010_CONTACT_PERSON_ID    CHAR(4)
               W010_CONTACT_DEVICE       CHAR(1)
        ;
	FETCH PROBLEM_DETAILS_C4
	INTO    W010_PROBLEM_NUMBER
               ,W010_PROBLEM_STATUS
               ,W010_PRIORITY_ID
               ,W010_APPLICATION_ID
               ,W010_PROBLEM_DESC
               ,W010_CONTACT_DATE
               ,W010_CONTACT_PERSON_ID
               ,W010_CONTACT_DEVICE
	;

PROCEDURE ET_CC4_PROBLEM_DETAILS
	SQLCA
	;
	CLOSE PROBLEM_DETAILS_C4
	;

-------------------------------------------------------------

PROCEDURE ET_ST_RO_PROBLEM
		SQLCA
	;
		SET TRANSACTION
			READ ONLY
			RESERVING ET_DB1.PROBLEM_DETAILS  FOR SHARED READ
	;


PROCEDURE ET_CMT_TRN
	SQLCA
	;
		COMMIT
	;

PROCEDURE ET_RLB_TRN
	SQLCA
	;
		ROLLBACK
	;

-- ************ end of module *************************

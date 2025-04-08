MODULE		EZITRAK01_SQL
LANGUAGE	COBOL
AUTHORIZATION	ET_DB1
DECLARE EXTERNAL ET_DB1 SCHEMA AUTHORIZATION FOR FILENAME EZITRAK_DATABASE

PROCEDURE ET_SS_PROBLEM_DETAILS
	SQLCA
               W010_PROBLEM_NUMBER       SMALLINT
               W010_PROBLEM_STATUS       CHAR(1)
               W010_PRIORITY             CHAR(1)
               W010_APPLICATION_ID       CHAR(3)
               W010_PROBLEM_DESC         CHAR(75)
               W010_RECORDING_PERSON_ID  CHAR(4)
               W010_CONTACT_DATE         DATE
               W010_CONTACT_PERSON_ID    CHAR(4)
               W010_CONTACT_DEVICE       CHAR(1)
               W010_PERSON_ASSIGNED_ID   CHAR(4)
               W010_EST_TO_COMPLETE_DAYS SMALLINT
               W010_PROGRESS_DESC        CHAR(75)
               W010_SOLVED_DATE          DATE
               W010_SOLUTION_DESC        CHAR(75)
               W010_REC_USER             CHAR(8)
               W010_REC_TMSTAMP          DATE
	;
		SELECT	PROBLEM_NUMBER
               ,PROBLEM_STATUS
               ,PRIORITY
               ,APPLICATION_ID
               ,PROBLEM_DESC
               ,RECORDING_PERSON_ID
               ,CONTACT_DATE
               ,CONTACT_PERSON_ID
               ,CONTACT_DEVICE
               ,PERSON_ASSIGNED_ID
               ,EST_TO_COMPLETE_DAYS
               ,PROGRESS_DESC
               ,SOLVED_DATE
               ,SOLUTION_DESC
               ,REC_USER
               ,REC_TMSTAMP 
	INTO    W010_PROBLEM_NUMBER
               ,W010_PROBLEM_STATUS
               ,W010_PRIORITY
               ,W010_APPLICATION_ID
               ,W010_PROBLEM_DESC
               ,W010_RECORDING_PERSON_ID
               ,W010_CONTACT_DATE
               ,W010_CONTACT_PERSON_ID
               ,W010_CONTACT_DEVICE
               ,W010_PERSON_ASSIGNED_ID
               ,W010_EST_TO_COMPLETE_DAYS
               ,W010_PROGRESS_DESC
               ,W010_SOLVED_DATE
               ,W010_SOLUTION_DESC
               ,W010_REC_USER
               ,W010_REC_TMSTAMP 
		FROM   PROBLEM_DETAILS
		WHERE  PROBLEM_NUMBER    = W010_PROBLEM_NUMBER
	;

PROCEDURE ET_IR_PROBLEM_DETAILS
	SQLCA
	               W010_PROBLEM_NUMBER       SMALLINT
               W010_PROBLEM_STATUS       CHAR(1)
               W010_PRIORITY             CHAR(1)
               W010_APPLICATION_ID       CHAR(3)
               W010_PROBLEM_DESC         CHAR(75)
               W010_RECORDING_PERSON_ID  CHAR(4)
               W010_CONTACT_DATE         DATE
               W010_CONTACT_PERSON_ID    CHAR(4)
               W010_CONTACT_DEVICE       CHAR(1)
               W010_PERSON_ASSIGNED_ID   CHAR(4)
               W010_EST_TO_COMPLETE_DAYS SMALLINT
               W010_PROGRESS_DESC        CHAR(75)
               W010_SOLVED_DATE          DATE
               W010_SOLUTION_DESC        CHAR(75)
               W010_REC_USER             CHAR(8)
               W010_REC_TMSTAMP          DATE
	;
		INSERT	INTO PROBLEM_DETAILS
		VALUES
               (W010_PROBLEM_NUMBER
               ,W010_PROBLEM_STATUS
               ,W010_PRIORITY
               ,W010_APPLICATION_ID
               ,W010_PROBLEM_DESC
               ,W010_RECORDING_PERSON_ID
               ,W010_CONTACT_DATE
               ,W010_CONTACT_PERSON_ID
               ,W010_CONTACT_DEVICE
               ,W010_PERSON_ASSIGNED_ID
               ,W010_EST_TO_COMPLETE_DAYS
               ,W010_PROGRESS_DESC
               ,W010_SOLVED_DATE
               ,W010_SOLUTION_DESC
               ,W010_REC_USER
               ,W010_REC_TMSTAMP
		     )
	;

PROCEDURE ET_UR_PROBLEM_DETAILS
	SQLCA
               W010_PROBLEM_NUMBER       SMALLINT
               W010_PROBLEM_STATUS       CHAR(1)
               W010_PRIORITY             CHAR(1)
               W010_APPLICATION_ID       CHAR(3)
               W010_PROBLEM_DESC         CHAR(75)
               W010_RECORDING_PERSON_ID  CHAR(4)
               W010_CONTACT_DATE         DATE
               W010_CONTACT_PERSON_ID    CHAR(4)
               W010_CONTACT_DEVICE       CHAR(1)
               W010_PERSON_ASSIGNED_ID   CHAR(4)
               W010_EST_TO_COMPLETE_DAYS SMALLINT
               W010_PROGRESS_DESC        CHAR(75)
               W010_SOLVED_DATE          DATE
               W010_SOLUTION_DESC        CHAR(75)
               W010_REC_USER             CHAR(8)
               W010_REC_TMSTAMP          DATE
	;
		UPDATE PROBLEM_DETAILS
	          SET   PROBLEM_NUMBER       = W010_PROBLEM_NUMBER
                     ,  PROBLEM_STATUS       = W010_PROBLEM_STATUS
                     ,  PRIORITY             = W010_PRIORITY
                     ,  APPLICATION_ID       = W010_APPLICATION_ID
		     ,	PROBLEM_DESC         = W010_PROBLEM_DESC
                     ,  RECORDING_PERSON_ID  = W010_RECORDING_PERSON_ID
                     ,  CONTACT_DATE         = W010_CONTACT_DATE
                     ,  CONTACT_PERSON_ID    = W010_CONTACT_PERSON_ID
                     ,  CONTACT_DEVICE       = W010_CONTACT_DEVICE
                     ,  PERSON_ASSIGNED_ID   = W010_PERSON_ASSIGNED_ID
                     ,  EST_TO_COMPLETE_DAYS = W010_EST_TO_COMPLETE_DAYS
                     ,  PROGRESS_DESC        = W010_PROGRESS_DESC
                     ,  SOLVED_DATE          = W010_SOLVED_DATE
                     ,  SOLUTION_DESC        = W010_SOLUTION_DESC
		     ,	REC_USER             = W010_REC_USER
		     ,	REC_TMSTAMP          = W010_REC_TMSTAMP
		WHERE PROBLEM_NUMBER         = W010_PROBLEM_NUMBER
	;

PROCEDURE ET_DR_PROBLEM_DETAILS
	SQLCA
	W010_PROBLEM_NUMBER	          SMALLINT
	;
		DELETE	FROM PROBLEM_DETAILS
			WHERE PROBLEM_NUMBER	= W010_PROBLEM_NUMBER
	;

PROCEDURE ET_SS_PERSON_DETAILS
	SQLCA
               W010_PERSON_ID           CHAR(4)
               W010_PERSON_DESC         CHAR(25)
	;
		SELECT	PERSON_DESC
	INTO    W010_PERSON_DESC
		FROM   PERSON_DETAILS
		WHERE  PERSON_ID    = W010_PERSON_ID
	;

PROCEDURE ET_SS_PRIORITY_DETAILS
	SQLCA
               W010_PRIORITY_ID         CHAR(1)
               W010_PRIORITY_DESC       CHAR(25)
	;
		SELECT	PRIORITY_DESC
	INTO    W010_PRIORITY_DESC
		FROM   PRIORITY_DETAILS
		WHERE  PRIORITY_ID    = W010_PRIORITY_ID
	;

PROCEDURE ET_SS_APPLICATION_DETAILS
	SQLCA
               W010_APPLICATION_ID      CHAR(3)
               W010_APPLICATION_DESC    CHAR(25)
	;
		SELECT	APPLICATION_DESC
	INTO    W010_APPLICATION_DESC
		FROM   APPLICATION_DETAILS
		WHERE  APPLICATION_ID    = W010_APPLICATION_ID
	;

PROCEDURE ET_SS_STATUS_DETAILS
	SQLCA
               W010_STATUS_ID           CHAR(1)
               W010_STATUS_DESC         CHAR(25)
	;
		SELECT	STATUS_DESC
	INTO    W010_STATUS_DESC
		FROM   STATUS_DETAILS
		WHERE  STATUS_ID    = W010_STATUS_ID
	;

PROCEDURE ET_ST_RO_PROBLEM
		SQLCA
	;
		SET TRANSACTION
			READ ONLY
			RESERVING ET_DB1.PROBLEM_DETAILS     FOR SHARED READ
			        , ET_DB1.PERSON_DETAILS      FOR SHARED READ
			        , ET_DB1.PRIORITY_DETAILS    FOR SHARED READ
			        , ET_DB1.APPLICATION_DETAILS FOR SHARED READ
			        , ET_DB1.STATUS_DETAILS      FOR SHARED READ
	;

PROCEDURE ET_ST_RW_PROBLEM
	SQLCA
	;
		SET TRANSACTION
			READ WRITE
			RESERVING ET_DB1.PROBLEM_DETAILS FOR SHARED WRITE
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

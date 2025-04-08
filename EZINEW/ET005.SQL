MODULE		EZITRAK05_SQL
LANGUAGE	COBOL
AUTHORIZATION	ET_DB1
DECLARE EXTERNAL ET_DB1 SCHEMA AUTHORIZATION FOR FILENAME EZITRAK_DATABASE

DECLARE PERSON_DETAILS_C CURSOR FOR
		SELECT	PERSON_ID
		     ,  PERSON_DESC
                     ,  PERSON_PHONE
                     ,  REC_USER
                     ,  REC_TMSTAMP
		FROM   PERSON_DETAILS
		WHERE  PERSON_ID    >= W010_PERSON_ID
		ORDER BY PERSON_ID

PROCEDURE ET_OC_PERSON_DETAILS
	SQLCA
               W010_PERSON_ID           CHAR(4)
        ;
        OPEN PERSON_DETAILS_C
	;

PROCEDURE ET_FC_PERSON_DETAILS
	SQLCA
               W010_PERSON_ID           CHAR(4)
               W010_PERSON_DESC         CHAR(25)
               W010_PERSON_PHONE        CHAR(12)
               W010_REC_USER            CHAR(8)
               W010_REC_TMSTAMP         DATE
        ;
        FETCH PERSON_DETAILS_C
	INTO   W010_PERSON_ID
           ,   W010_PERSON_DESC
           ,   W010_PERSON_PHONE
           ,   W010_REC_USER
           ,   W010_REC_TMSTAMP
	;

PROCEDURE ET_CC_PERSON_DETAILS
	SQLCA
	;
        CLOSE PERSON_DETAILS_C
	;

PROCEDURE ET_IR_PERSON_DETAILS
	SQLCA
               W010_PERSON_ID            CHAR(4)
               W010_PERSON_DESC          CHAR(25)
               W010_PERSON_PHONE         CHAR(12)
               W010_REC_USER             CHAR(8)
               W010_REC_TMSTAMP          DATE
	;
		INSERT	INTO PERSON_DETAILS
		VALUES
               (W010_PERSON_ID
               ,W010_PERSON_DESC
               ,W010_PERSON_PHONE
               ,W010_REC_USER
               ,W010_REC_TMSTAMP
		     )
	;

PROCEDURE ET_UR_PERSON_DETAILS
	SQLCA
               W010_PERSON_ID            CHAR(4)
               W010_PERSON_DESC          CHAR(25)
               W010_PERSON_PHONE         CHAR(12)
               W010_REC_USER             CHAR(8)
               W010_REC_TMSTAMP          DATE
	;
		UPDATE PERSON_DETAILS
	          SET   PERSON_DESC          = W010_PERSON_DESC
                     ,  PERSON_PHONE         = W010_PERSON_PHONE
		     ,	REC_USER             = W010_REC_USER
		     ,	REC_TMSTAMP          = W010_REC_TMSTAMP
		WHERE PERSON_ID              = W010_PERSON_ID
	;

PROCEDURE ET_DR_PERSON_DETAILS
	SQLCA
	W010_PERSON_ID   	          CHAR(4)
	;
		DELETE	FROM PERSON_DETAILS
			WHERE PERSON_ID	 = W010_PERSON_ID
	;

PROCEDURE ET_SS_PERSON_DETAILS
	SQLCA
               W010_PERSON_ID           CHAR(4)
               W010_PERSON_DESC         CHAR(25)
               W010_PERSON_PHONE        CHAR(12)
               W010_REC_USER             CHAR(8)
               W010_REC_TMSTAMP          DATE
	;
		SELECT	PERSON_DESC
                     ,  PERSON_PHONE
                     ,  REC_USER
                     ,  REC_TMSTAMP
	INTO    W010_PERSON_DESC
              , W010_PERSON_PHONE
              , W010_REC_USER
              , W010_REC_TMSTAMP
		FROM   PERSON_DETAILS
		WHERE  PERSON_ID    = W010_PERSON_ID
	;

PROCEDURE ET_ST_RO_PERSON
		SQLCA
	;
		SET TRANSACTION
			READ ONLY
			RESERVING ET_DB1.PERSON_DETAILS   FOR SHARED READ
	;

PROCEDURE ET_ST_RW_PERSON
	SQLCA
	;
		SET TRANSACTION
			READ WRITE
			RESERVING ET_DB1.PERSON_DETAILS FOR SHARED WRITE
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

--liquibase formatted sql

--changeset dk98126:create-p_add_paper splitStatements:false
CREATE OR REPLACE PROCEDURE p_add_paper (p_id number, tit varchar2, absr varchar2, t clob, auth varchar2)
IS
BEGIN
  INSERT INTO PAPERS (PAPER_ID, TITLE, ABSTRACT, TEXT, AUTHORS)
  VALUES (p_id, tit, absr, t, auth);
EXCEPTION
  WHEN OTHERS 
     THEN NULL;
END p_add_paper;

-- BEGIN
--     p_add_paper (1, 'Information flow control in database program units based on formal verification',
--     'Many researches in the field of formal security models have been conducted so far. Cryptographic methods which are relevant to data transferring and storing security are not considered in the paper. Instead access control methods as well as information flow control mechanisms which can be used to guaranty secure data processing are in focus...',
--     'Many researches in the field of formal security models have been conducted so far. Cryptographic methods which are relevant to data transferring and storing security are not considered in the paper. Instead access control methods as well as information flow control mechanisms which can be used to guaranty secure data processing are in focus. Access control models have found wide application in the area of developing secure operating systems and database management systems, while information flow control is actively embedded into programming platforms. Despite all efforts in practice the approach relying solely on access control dominates when constructing production scale automated informational systems. Information flow control on application level if considered is rarely followed from the global security policy. In the research an attempt was made to justify the need of splicing both access control on system level and information flow control on application level. We also offer the concept of embedding of information flow control into database program units build on top of existent role-based access control system.', 'A.A.Timakov');
--     commit;
-- END;


--changeset dk98126:create-p_submit_paper splitStatements:false
CREATE OR REPLACE PROCEDURE p_submit_paper (s_id number, p_id number, c_id number, sub_date date, stat number)
IS
BEGIN
  INSERT INTO SUBMISSIONS (SUBMISSION_ID, PAPER_ID, CONFERENCE_ID, SUBMISSION_DATE, STATUS)
  VALUES (s_id, p_id, c_id, sub_date, stat);
EXCEPTION
  WHEN OTHERS 
     THEN NULL;
END p_submit_paper;

-- BEGIN
-- p_submit_paper (1, 1, 1, '12.09.2021', 0);
-- commit;
-- END;

--changeset dk98126:create-p_chahge_status splitStatements:false
CREATE OR REPLACE PROCEDURE p_chahge_status (s_id number, stat number)
IS
BEGIN
   UPDATE SUBMISSIONS
   SET STATUS = stat
   WHERE SUBMISSION_ID = s_id;
END p_chahge_status;

--changeset dk98126:create-f_is_accepted splitStatements:false
CREATE OR REPLACE FUNCTION f_is_accepted (s_id number) return boolean
IS
   v_status NUMBER;
BEGIN
   SELECT STATUS into v_status
   FROM SUBMISSIONS
   WHERE SUBMISSION_ID = s_id;
   IF v_status = 1
     THEN return TRUE;
     ELSE return FALSE;
   END IF;
END f_is_accepted;

-- DECLARE
--     flag varchar2(10) := 'FALSE';
-- BEGIN
--     IF  f_is_accepted (1)
--         THEN
--             flag := 'TRUE';
--         ELSE
--             flag := 'FALSE';
--     END IF;
--     dbms_output.put_line(flag);
-- END;

--changeset dk98126:create-p_allocate splitStatements:false
create or replace PROCEDURE p_allocate (id number, s_id number, sec_id number, alloc_date date)
IS
  PAPER_NOT_ACCEPTED EXCEPTION;
  v_p_id NUMBER;
  v_is_acc BOOLEAN;
BEGIN
  v_is_acc := f_is_accepted (s_id);
  IF v_is_acc
     THEN 
          SELECT paper_id into v_p_id
          FROM SUBMISSIONS
          WHERE submission_id = s_id;
          INSERT INTO ALLOCATIONS (ALLOCATION_ID, SUBMISSION_ID, SECTION_ID, ALLOCATION_DATE)
          VALUES (id, s_id, sec_id, alloc_date);
     ELSE RAISE PAPER_NOT_ACCEPTED;
  END IF;
EXCEPTION
     WHEN PAPER_NOT_ACCEPTED THEN
        INSERT INTO LOGS
        VALUES (1, 'an attempt was made to allocate unaccepted submission ' || s_id || ', ' || sysdate || '.');
     WHEN OTHERS THEN
        NULL;
END p_allocate;

-- BEGIN
--     p_allocate (1, 1, 1, sysdate);
--     commit;
-- END;
--
-- BEGIN
--     p_chahge_status(1, 1);
--     commit;
-- END;
--
-- BEGIN
--     p_allocate (1, 1, 1, sysdate);
--     commit;
-- END;
--
-- SELECT * FROM ALLOCATIONS;

--changeset dk98126:create-program_arr_typ splitStatements:false
CREATE OR REPLACE TYPE program_arr_typ AS VARRAY(1000) OF paper_arr_typ;

--changeset dk98126:create-f_getsection_program splitStatements:false
CREATE OR REPLACE FUNCTION f_getsection_program (s_id number) RETURN program_arr_typ
AS
  v_program program_arr_typ;
BEGIN
  v_program := NULL;
  SELECT paper_arr_typ(PAPER_ID, TITLE, ABSTRACT, TEXT, 'UNKNOWN_AUTH') BULK COLLECT INTO v_program
  FROM PAPERS
  WHERE PAPER_ID IN (SELECT PAPER_ID FROM ALLOCATIONS a JOIN SUBMISSIONS s 
                                     ON a.submission_id = s.submission_id
                     WHERE a.SECTION_ID = s_id);
  RETURN v_program;
END f_getsection_program;

-- DECLARE
--     v_program program_arr_typ;
-- BEGIN
--     v_program := f_getsection_program(1);
--     FOR a IN 1..v_program.count LOOP
--         dbms_output.put_line(v_program(a));
--     END LOOP;
-- END;

--changeset dk98126:create-f_getpaper splitStatements:false
CREATE OR REPLACE FUNCTION f_getpaper(p_id number) return paper_arr_typ
AS
  v_paper paper_arr_typ;
BEGIN
  SELECT paper_arr_typ(PAPER_ID, TITLE, ABSTRACT, TEXT, AUTHORS) INTO v_paper
  FROM PAPERS
  WHERE PAPER_ID = p_id;
  RETURN v_paper;
END f_getpaper;

-- DECLARE
--     v_paper paper_arr_typ;
-- BEGIN
--     v_paper := f_getpaper(1);
--     dbms_output.put_line(v_paper);
-- END;

--changeset dk98126:create-paper_arr_typ splitStatements:false
CREATE OR REPLACE TYPE paper_arr_typ AS VARRAY(1000) OF paper_arr_typ;

--changeset dk98126:create-f_getsubmissions splitStatements:false
CREATE OR REPLACE FUNCTION f_getsubmissions (c_id number) return paper_arr_typ
AS
  v_submissions paper_arr_typ;
BEGIN
  SELECT paper_arr_typ(PAPER_ID, TITLE, ABSTRACT, TEXT, 'UNKNOWN_AUTH') BULK COLLECT INTO v_submissions
  FROM PAPERS
  WHERE PAPER_ID IN (SELECT PAPER_ID FROM SUBMISSIONS 
                     WHERE CONFERENCE_ID = c_id);
  RETURN v_submissions;
END f_getsubmissions;

-- DECLARE
--     v_paper_arr paper_arr_typ;
-- BEGIN
--     v_paper_arr := f_getsubmissions(1);
--     FOR p IN 1..v_paper_arr.count LOOP
--         dbms_output.put_line(v_paper_arr(p));
--     END LOOP;
-- END;

--changeset dk98126:create-f_getaccepted splitStatements:false
CREATE OR REPLACE FUNCTION f_getaccepted(c_id number) return paper_arr_typ
AS
  v_accepted paper_arr_typ;
BEGIN
  SELECT paper_arr_typ(PAPER_ID, TITLE, ABSTRACT, TEXT, 'UNKNOWN_AUTH') BULK COLLECT INTO v_accepted
  FROM PAPERS
  WHERE PAPER_ID IN (SELECT PAPER_ID FROM SUBMISSIONS 
                     WHERE CONFERENCE_ID = c_id AND STATUS = 1);
  RETURN v_accepted;
END f_getaccepted;

-- DECLARE
--     v_paper_arr paper_arr_typ;
-- BEGIN
--     v_paper_arr := f_getaccepted(1);
--     FOR p IN 1..v_paper_arr.count LOOP
--         dbms_output.put_line(v_paper_arr(p));
--     END LOOP;
-- END;

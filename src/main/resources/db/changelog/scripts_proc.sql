CREATE OR REPLACE PROCEDURE p_add_paper(p_id number, tit varchar2, absr varchar2, t clob, auth varchar2)
    IS
BEGIN
    INSERT INTO papers (paper_id, title, abstract, text, authors)
    VALUES (p_id, tit, absr, t, auth);
EXCEPTION
    WHEN OTHERS
        THEN NULL;
END p_add_paper;

BEGIN
    p_add_paper(1, 'Information flow control in database program units based on formal verification',
                'Many researches in the field of formal security models have been conducted so far. Cryptographic methods which are relevant to data transferring and storing security are not considered in the paper. Instead access control methods as well as information flow control mechanisms which can be used to guaranty secure data processing are in focus...',
                'Many researches in the field of formal security models have been conducted so far. Cryptographic methods which are relevant to data transferring and storing security are not considered in the paper. Instead access control methods as well as information flow control mechanisms which can be used to guaranty secure data processing are in focus. Access control models have found wide application in the area of developing secure operating systems and database management systems, while information flow control is actively embedded into programming platforms. Despite all efforts in practice the approach relying solely on access control dominates when constructing production scale automated informational systems. Information flow control on application level if considered is rarely followed from the global security policy. In the research an attempt was made to justify the need of splicing both access control on system level and information flow control on application level. We also offer the concept of embedding of information flow control into database program units build on top of existent role-based access control system.',
                'A.A.Timakov');
    commit;
END;

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE p_submit_paper(s_id number, p_id number, c_id number, sub_date date, stat number)
    IS
BEGIN
    INSERT INTO submissions (submission_id, paper_id, conference_id, submission_date, status)
    VALUES (s_id, p_id, c_id, sub_date, stat);
EXCEPTION
    WHEN OTHERS
        THEN NULL;
END p_submit_paper;

BEGIN
    p_submit_paper(1, 1, 1, '12.09.2021', 0);
    commit;
END;

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE p_chahge_status(s_id number, stat number)
    IS
BEGIN
    UPDATE submissions
    SET status = stat
    WHERE submission_id = s_id;
END p_chahge_status;

BEGIN
    p_chahge_status(1, 0);
    commit;
END;

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION f_is_accepted(s_id number) return boolean
    IS
    v_status NUMBER;
BEGIN
    SELECT status
    into v_status
    FROM submissions
    WHERE submission_id = s_id;
    IF v_status = 1
    THEN
        return TRUE;
    ELSE
        return FALSE;
    END IF;
END f_is_accepted;

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

create or replace PROCEDURE p_allocate(id number, s_id number, sec_id number, alloc_date date)
    IS
    paper_not_accepted EXCEPTION;
    v_p_id   NUMBER;
    v_is_acc BOOLEAN;
BEGIN
    v_is_acc := f_is_accepted(s_id);
    IF v_is_acc
    THEN
        SELECT paper_id
        into v_p_id
        FROM submissions
        WHERE submission_id = s_id;
        INSERT INTO allocations (allocation_id, submission_id, section_id, allocation_date)
        VALUES (id, s_id, sec_id, alloc_date);
    ELSE
        RAISE paper_not_accepted;
    END IF;
EXCEPTION
    WHEN paper_not_accepted THEN
        INSERT INTO logs
        VALUES (1, 'an attempt was made to allocate unaccepted submission ' || s_id || ', ' || sysdate || '.');
    WHEN OTHERS THEN
        NULL;
END p_allocate;

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE TYPE paper_typ AS OBJECT
(
    paper_id NUMBER,
    title    VARCHAR2(1000),
    abstract VARCHAR2(4000),
    "TEXT"   CLOB,
    authors  VARCHAR2(1000)
);

CREATE OR REPLACE TYPE paper_arr_typ AS VARRAY(1000) OF paper_typ;

CREATE OR REPLACE FUNCTION f_getsection_program(s_id number) RETURN paper_arr_typ
AS
    v_program paper_arr_typ;
BEGIN
    v_program := NULL;
    SELECT paper_typ(paper_id, title, abstract, text, 'UNKNOWN_AUTH') BULK COLLECT
    INTO v_program
    FROM papers
    WHERE paper_id IN (SELECT paper_id
                       FROM allocations a
                                JOIN submissions s
                                     ON a.submission_id = s.submission_id
                       WHERE a.section_id = s_id);
    RETURN v_program;
END f_getsection_program;

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION f_getpaper(p_id number) return paper_typ
AS
    v_paper paper_typ;
BEGIN
    SELECT paper_typ(paper_id, title, abstract, text, authors)
    INTO v_paper
    FROM papers
    WHERE paper_id = p_id;
    RETURN v_paper;
END f_getpaper;


--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION f_getsubmissions(c_id number) return paper_arr_typ
AS
    v_submissions paper_arr_typ;
BEGIN
    SELECT paper_typ(paper_id, title, abstract, text, 'UNKNOWN_AUTH') BULK COLLECT
    INTO v_submissions
    FROM papers
    WHERE paper_id IN (SELECT paper_id
                       FROM submissions
                       WHERE conference_id = c_id);
    RETURN v_submissions;
END f_getsubmissions;

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION f_getaccepted(c_id number) return paper_arr_typ
AS
    v_accepted paper_arr_typ;
BEGIN
    SELECT paper_typ(paper_id, title, abstract, text, 'UNKNOWN_AUTH') BULK COLLECT
    INTO v_accepted
    FROM papers
    WHERE paper_id IN (SELECT paper_id
                       FROM submissions
                       WHERE conference_id = c_id
                         AND status = 1);
    RETURN v_accepted;
END f_getaccepted;

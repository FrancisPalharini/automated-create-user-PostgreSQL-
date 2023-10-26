--create function
CREATE OR REPLACE FUNCTION public.update_databaseuser(v_username text)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
          -- update password
          DECLARE
              -- create password using md5   
            v_password text;
          BEGIN
              --check if user already exist
            IF EXISTS (SELECT FROM pg_user WHERE  usename = v_username) 
                THEN
                       	-- create password
                        SELECT INTO v_password md5(random()::text);
                        --update password
                        EXECUTE FORMAT('ALTER ROLE %I WITH PASSWORD %L', v_username, v_password);
                        RETURN E'database: ' || (SELECT current_database()) ||E'\nuser: ' ||v_username || E'\npassword:  '||v_password;
                ELSE
                    RETURN 'User does not exists';              
                END IF;
                EXCEPTION
                WHEN others THEN
                    RETURN  SQLERRM;
          END;
          $function$
;


--call function
select update_databaseuser('user');

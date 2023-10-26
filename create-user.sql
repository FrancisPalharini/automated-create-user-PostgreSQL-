--You need already have create an privilege role before.

CREATE OR REPLACE FUNCTION public.create_databaseuser(v_username text, v_role text)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
     -- create role/user and grant privileges  
     DECLARE
        -- create password   
     	v_password text:= random_string(32);
     	v_database text := (SELECT current_database()); 
     BEGIN
         --check if the user already exists 
	     IF EXISTS (SELECT FROM pg_user WHERE  usename = v_username) 
          THEN
               RETURN 'User already exists';     
          
          ELSE
            --check if the role/gruop of privileges already exists 
          	IF EXISTS (SELECT FROM pg_roles WHERE  rolname = v_role) 
               THEN
                   --create user
               		EXECUTE FORMAT('CREATE ROLE %I LOGIN PASSWORD %L CONNECTION LIMIT 3', v_username, v_password);
                    --grant privileges
               		EXECUTE FORMAT('GRANT %I TO  %I ', v_role, v_username);
                    RETURN E'database: ' || v_database ||E'\nuser: ' ||v_username || E'\npassword:  '||v_password;
               ELSE
                    RETURN 'Role does not exists';
               END IF;
     
          END IF;
          EXCEPTION
          WHEN others THEN
               RETURN  SQLERRM;
     END;
     $function$
;
     
-- call function
  select create_databaseuser('user','privilege-role');


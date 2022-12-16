You need already have create an privilege role before.

-- create password

     Create or replace function random_string(length integer) returns text as
     $$
     declare
       chars text[] := '{0,1,2,3,4,5,6,7,8,9,A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z,.,+,-,[,],*,~,_,@,#,:,?}';
       result text := '';
       i integer := 0;
     begin
       if length < 0 then
       raise exception 'Given length cannot be less than 0';
       end if;
       for i in 1..length loop
       result := result || chars[1+random()*(array_length(chars, 1)-1)];
       end loop;
       return result;
     end;
     $$ language plpgsql;
     
-- create role(user)
    
    CREATE OR REPLACE FUNCTION create_databaseuser(
          v_username text,
          v_role text)
     RETURNS text AS
     $BODY$
     -- create user with password and add a privilege role 
     DECLARE
        -- password definition, you can choose length   
     	v_password text:= random_string(32);
     BEGIN
         --check if user already exists in the database 
	     IF EXISTS (SELECT FROM pg_user WHERE  usename = v_username) 
          THEN
               RETURN 'User already exists';     
          
          ELSE
            --check if privilege role already exists in the database  
          	IF EXISTS (SELECT FROM pg_roles WHERE  rolname = v_role) 
               THEN
                   --create user
               		EXECUTE FORMAT('CREATE ROLE %I LOGIN PASSWORD %L CONNECTION LIMIT 3', v_username, v_password);
                    --adding privilege role
               		EXECUTE FORMAT('GRANT %I TO  %I ', v_role, v_username);
                    RETURN v_password;
               ELSE
                    RETURN 'Role does not exists';
               END IF;
     
          END IF;
          EXCEPTION
          WHEN others THEN
               RETURN  SQLERRM;
     END;
     $BODY$
     LANGUAGE plpgsql
     
-- call function
  select create_databaseuser('user','privilege-role');


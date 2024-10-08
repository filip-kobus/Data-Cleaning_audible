-- 1. Creating table

	/*
	CREATE TABLE audible (
		`name` TEXT,
		`author` TEXT,
		`narrator` TEXT,
		`time` TEXT,
		`releasedate` TEXT,
		`language` TEXT,
		`stars` TEXT,
		`price` TEXT
	);
	*/

-- 2. Loading data into table
	
    /*
	LOAD DATA INFILE 'audible.csv'
	INTO TABLE audible
	FIELDS TERMINATED BY ','
	ENCLOSED BY '"'
	LINES TERMINATED BY '\n'
	IGNORE 1 LINES;
	*/
	-- 87489 row(s) affected Records: 87489  Deleted: 0  Skipped: 0  Warnings: 0
    
		-- data should be located in "...\MySQL\MySQL Server 8.0\Data\database_name" folder

-- 3. Getting rid of duplicates

	/*
	CREATE TABLE audible_staged1 LIKE audible; 
	ALTER TABLE audible_staged1
	ADD row_num int;
    
    INSERT INTO audible_staged1
	SELECT *, ROW_NUMBER() over(partition by `name`, `author`, `narrator`, `time`, `releasedate`, `language`, `stars`, `price`) as row_num
	FROM audible;
    
		-- If any row has the row_num > 1, it has a duplicate
		-- based on columns mentioned above in: over(partition by ...) function
    
    DELETE FROM audible_staged1
    WHERE row_num > 1;
    
    ALTER TABLE audible_staged1
    DROP COLUMN row_num;
    */

-- 4. Cleaning author and narrator ('Writtenby:GeronimoStilton' -> 'Geronimo Stilton')

		-- Created function for splitting author and narrathor name (doesnt work for Japaneese)
	
    /*
    DELIMITER //

		CREATE FUNCTION split_name(name VARCHAR(255))
		RETURNS VARCHAR(255)
		DETERMINISTIC
		BEGIN
			DECLARE i INT DEFAULT 1;
			DECLARE result VARCHAR(255) DEFAULT '';
			DECLARE len INT;
			DECLARE current_char CHAR(1);

			SET len = CHAR_LENGTH(name);
			
			WHILE i <= len DO
				SET current_char = SUBSTRING(name, i, 1);
				
				IF
				current_char = BINARY UPPER(current_char)
				AND i > 1
				AND current_char != '.'
				AND current_char != ','
				THEN
					SET result = CONCAT(result, ' ', current_char);
				ELSE
					SET result = CONCAT(result, current_char);
				END IF;
				
				SET i = i + 1;
			END WHILE;
			
			RETURN result;
		END

	// DELIMITER ;
    */
    
		-- Deleted Writenby:
    
    /*
	UPDATE audible_staged1
    SET author = TRIM('Writtenby:' FROM author);
    
    UPDATE audible_staged1
    SET narrator = TRIM('Narratedby:' FROM narrator);
    
    UPDATE audible_staged1
    SET author = split_name(author)
    WHERE REGEXP_LIKE(author, '.*[a-zA-ZА-я].*') = 1;
    
		-- It skips non latin and non cyrylic letters
    
    UPDATE audible_staged1
    SET narrator = split_name(narrator)
    WHERE REGEXP_LIKE(narrator, '.*[a-zA-ZА-я].*') = 1;
		-- split name only if it contains latin or cyrylic letters audible_staged1
    */

-- 5. Formatting time column (7hrs and 20 minutes -> 440)
    
    -- Function that converts hrs and minutes to minutes
    
    /*
    DELIMITER //
		CREATE FUNCTION time_to_min(time_input VARCHAR(255))
		RETURNS INT
		DETERMINISTIC
		BEGIN
			DECLARE minutes INT DEFAULT 0;
			DECLARE hours INT DEFAULT 0;
			            
            IF time_input LIKE '%hr%' AND time_input LIKE '%min%' THEN
				SET hours = CONVERT(SUBSTRING_INDEX(SUBSTRING_INDEX(time_input, ' ', 1), ' ', -1), SIGNED INTEGER);
                SET minutes = CONVERT(SUBSTRING_INDEX(SUBSTRING_INDEX(time_input, ' ', 4), ' ', -1), SIGNED INTEGER);
			
            ELSEIF time_input LIKE '%hr%' AND time_input NOT LIKE '%min%' THEN
				SET hours = CONVERT(SUBSTRING_INDEX(SUBSTRING_INDEX(time_input, ' ', 1), ' ', -1), SIGNED INTEGER);
			
			-- Less than 1 minute case
            ELSEIF time_input LIKE '%Less%' THEN
				SET minutes = 0;
            
            ELSE
				SET minutes = CONVERT(SUBSTRING_INDEX(SUBSTRING_INDEX(time_input, ' ', 1), ' ', -1), SIGNED INTEGER);
            END IF;
			
            SET minutes = minutes + (hours * 60);
            
			RETURN minutes;
		END

	// DELIMITER ;
    
	UPDATE audible_staged1
    SET `time` = time_to_min(`time`);
    
	ALTER TABLE audible_staged1
    MODIFY time int;
    
	ALTER TABLE audible_staged1
    RENAME COLUMN time TO time_in_minutes;
    */

-- 6. Formatting language column (english -> English)

	/*
	DELIMITER //
		CREATE FUNCTION capitalize_first_letter(word VARCHAR(255))
		RETURNS VARCHAR(255)
		DETERMINISTIC
		BEGIN
			DECLARE firstLetter char(1);
            DECLARE afterFirstLetter VARCHAR(30);
            SET firstLetter = UPPER(substr(word, 1, 1));
            SET afterFirstLetter = substr(word, 2, 30);
            RETURN CONCAT(firstLetter, afterFirstLetter);
		END

	// DELIMITER ;

	UPDATE audible_staged1
    SET `language` = capitalize_first_letter(`language`);
    */
    
-- 6. Formatting releasedate (from DD-MM-YY to YYYY-MM-DD)
    /*
    UPDATE audible_staged1
    SET releasedate = STR_TO_DATE(releasedate, '%d-%m-%Y');
    
    ALTER TABLE audible_staged1
    MODIFY releasedate date;
    */

-- 7. Formatting stars and adding ratings (
		-- from
        -- stars: '4.5 out of 5 stars41 ratings'
		-- to
		-- stars_out_of_5: 4.5
        -- ratings: 41) 
	
	/*
	DELIMITER //
		CREATE FUNCTION get_rating(input VARCHAR(255))
		RETURNS INT
		DETERMINISTIC
		BEGIN
			DECLARE rating VARCHAR(30);
			DECLARE result INT;
            
            IF input IS NOT NULL THEN
				SET rating = SUBSTRING_INDEX(SUBSTRING_INDEX(input, ' ', 5), ' ', -1);
				SET rating = TRIM('stars' FROM rating);
				SET rating = REPLACE(rating, ',', '');
				SET result = CONVERT(rating, SIGNED INTEGER);
				RETURN result;
			
            ELSE
				RETURN 0;

			END IF;
		END

	// DELIMITER ;

	UPDATE audible_staged1
    SET stars = NULL
    WHERE stars = 'Not rated yet';
    
    ALTER TABLE audible_staged1
    ADD ratings INT;
    
	UPDATE audible_staged1
    SET ratings = get_rating(stars);
    
	ALTER TABLE audible_staged1
    RENAME COLUMN stars TO stars_out_of_5;
	
    UPDATE audible_staged1
    SET stars_out_of_5 = SUBSTRING_INDEX(SUBSTRING_INDEX(stars_out_of_5, ' ', 1), ' ', -1)
    WHERE stars_out_of_5 IS NOT NULL;

	ALTER TABLE audible_staged1
    MODIFY stars_out_of_5 FLOAT(1);
    */

-- 8. Formatting price ('1,256.00' to 1256.00)
	
    /*
    SELECT price
    FROM audible_staged1
    WHERE price NOT REGEXP '^[0-9.]+$';
    
    UPDATE audible_staged1
	SET price = REPLACE(price, ',', '');
    
    UPDATE audible_staged1
	SET price = 0
    WHERE price = 'Free';
    
	ALTER TABLE audible_staged1
    MODIFY price FLOAT(2);
	*/

	-- RENAME TABLE audible_staged1 TO audible_cleaned;

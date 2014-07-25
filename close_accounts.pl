DELIMITER ;;
CREATE DEFINER=`bjones`@`localhost` PROCEDURE `closeAccount`(IN agent_id_given INT UNSIGNED, OUT result INT)
BEGIN
  DECLARE receipt_id_cash INT UNSIGNED;
  DECLARE receipt_id_promo INT UNSIGNED;
  DECLARE people_id INT UNSIGNED;
  DECLARE agent_balance DECIMAL(10,2);
  DECLARE agent_promo_balance DECIMAL(10,2);
  DECLARE agent_promo_balance_available DECIMAL(10,2);
  DECLARE cash_balance DECIMAL(12,2);
  DECLARE promo_balance DECIMAL(12,2);
  DECLARE promo_balance_available DECIMAL(12,2);
  DECLARE error_condition INT;
  DECLARE count INT;
  DECLARE notes VARCHAR(45);
  DECLARE l_last_row_fetched INT;
  DECLARE balance_remaining DECIMAL(12,2);
  DECLARE cc_transaction_id VARCHAR(64);

  DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    SET error_condition = 1;
  DECLARE CONTINUE HANDLER FOR NOT FOUND
    SET l_last_row_fetched = 1;

  SET result = 1;
  SET error_condition = 0;

  START TRANSACTION;
  SET people_id = getPeopleID( agent_id_given );

  SELECT count( agent_id ) INTO count
    FROM agent_cash_balance
    WHERE agent_id = agent_id_given FOR UPDATE;

  IF ( count = 0 )
  THEN
    INSERT INTO agent_cash_balance ( agent_id, balance )
      VALUEs ( agent_id_given, 0 );
  END IF;

  SELECT count( agent_id ) INTO count
    FROM agent_promo_balance
    WHERE agent_id = agent_id_given FOR UPDATE;

  IF ( count = 0 )
  THEN
    INSERT INTO agent_promo_balance ( agent_id, balance, balance_available )
      VALUE ( agent_id_given, 0, 0 );
  END IF;

  IF ( error_condition = 1 )
  THEN
    ROLLBACK;
    SET result = '0';
  ELSE
    COMMIT;
  END IF;

  IF ( error_condition = 0 )
  THEN
    START TRANSACTION;

    SELECT IFNULL(balance, 0) 
      INTO agent_balance 
      FROM agent_cash_balance 
      WHERE agent_id = agent_id_given FOR UPDATE;
    SELECT IFNULL(balance, 0), IFNULL(balance_available, 0) 
      INTO agent_promo_balance, agent_promo_balance_available 
      FROM agent_promo_balance 
      WHERE agent_id = agent_id_given FOR UPDATE;
    SELECT balance
      INTO cash_balance
      FROM cash_balance
      WHERE id = 1 FOR UPDATE;
    SELECT balance, balance_available
      INTO promo_balance, promo_balance_available
      FROM promo_balance
      WHERE id = 1 FOR UPDATE;

    IF ( ISNULL( cash_balance ) )
    THEN
      SET error_condition = 1;
    END IF;
    IF ( ISNULL( promo_balance ) )
    THEN
      SET error_condition = 1;
    END IF;
    IF ( ISNULL( promo_balance_available ) )
    THEN
      SET error_condition = 1;
    END IF;

    IF ( error_condition = 0 )
    THEN
      SET cash_balance = cash_balance + agent_balance;
      SET promo_balance = promo_balance + agent_promo_balance;
      SET promo_balance_available = promo_balance_available + agent_promo_balance_available;

      IF ( agent_balance >= 0 )
      THEN
        SET receipt_id_cash = insertReceipt ( 'Closing Account', 0, people_id, '', 0, agent_balance, '' );
      ELSE
        IF ( agent_balance < 0 )
        THEN
          SET receipt_id_cash = insertReceipt ( 'Closing Account', people_id, 0, '', 0, -agent_balance, '' );
        END IF;
      END IF;

  IF ( agent_promo_balance >= 0 )
  THEN
        SET receipt_id_promo = insertReceipt( 'Closing Account -- Promo Adjustment', people_id, 0,
          '', 0, agent_promo_balance, '' );
  ELSE
    IF ( agent_promo_balance < 0 )
    THEN
          SET receipt_id_promo = insertReceipt( 'Closing Account -- Promo Adjustment', people_id, 0, '', 0, -agent_promo_balance, '' );
        END IF;
      END IF;

      IF ( ISNULL( receipt_id_promo ) )
      THEN
    SET error_condition = 0;
  ELSE
    INSERT INTO agent_promo_transactions( agent_id, receipt_id, amount, amount_available, balance, balance_available ) VALUES ( agent_id_given, receipt_id_promo, -agent_promo_balance, -agent_promo_balance_available, 0, 0 );
    INSERT INTO promo_transactions ( receipt_id, amount, amount_available, balance, balance_available )
      VALUES ( receipt_id_promo, agent_promo_balance, agent_promo_balance_available,
               promo_balance, promo_balance_available );
    UPDATE agent_promo_balance SET balance = 0, balance_available = 0 WHERE agent_id = agent_id_given;
    UPDATE promo_balance 
      SET balance = promo_balance,
          balance_available = promo_balance_available 
      WHERE id = 1;
      END IF;
  
      INSERT INTO agent_cash_transactions( agent_id, receipt_id, amount, balance )
        VALUES ( agent_id_given, receipt_id_cash, -agent_balance, 0 );
      INSERT INTO cash_transactions( receipt_id, amount, balance )
        VALUES ( receipt_id_cash, agent_balance, cash_balance );

      UPDATE agent_cash_balance SET balance = 0 where agent_id = agent_id_given;
      UPDATE cash_balance SET balance = cash_balance WHERE id = 1;

  UPDATE leads.agents SET status='Prospect' WHERE id = agent_id_given;
    END IF;

    IF ( error_condition = 1 )
    THEN
      ROLLBACK;
      SET result = '0';
    ELSE
      COMMIT;
    END IF;
  END IF;
END;;
DELIMITER ;


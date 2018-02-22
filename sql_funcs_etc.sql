CREATE OR REPLACE FUNCTION calc_speed_optimum(vessel_type_code SMALLINT, length SMALLINT)
RETURNS REAL AS $$
BEGIN
	IF NOT vessel_type_code BETWEEN 70 AND 89 THEN 
		RAISE EXCEPTION 'Illegal vessel_type_code: %', $1;
	ELSIF NOT length BETWEEN 120 AND 500 THEN
		RAISE EXCEPTION 'Illegal length: %', $2;
	END IF;

	--speeds represent averages from global snapshot

	--cargo
	IF vessel_type_code BETWEEN 70 AND 79 THEN
		IF length BETWEEN 120 AND 199 THEN
			RETURN 12.99795748;
		ELSIF length BETWEEN 200 AND 299 THEN
			RETURN 13.99808324;
		ELSIF length BETWEEN 300 AND 500 THEN
			RETURN 15.11564212;
		END IF;
	--tanker
	ELSIF vessel_type_code BETWEEN 80 AND 89 THEN
		IF length BETWEEN 120 AND 199 THEN
			RETURN 13.52324599;
		ELSIF length BETWEEN 200 AND 299 THEN
			RETURN 13.14004736;
		ELSIF length BETWEEN 300 AND 500 THEN
			RETURN 12.85515499;
		END IF;
	END IF;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION calc_speed_buffer(vessel_type_code SMALLINT, length SMALLINT)
RETURNS REAL AS $$
BEGIN
	IF NOT vessel_type_code BETWEEN 70 AND 89 THEN 
		RAISE EXCEPTION 'Illegal vessel_type_code: %', $1;
	ELSIF NOT length BETWEEN 120 AND 500 THEN
		RAISE EXCEPTION 'Illegal length: %', $2;
	END IF;

	IF length BETWEEN 120 AND 199 THEN
		RETURN 0.50;
	ELSIF length BETWEEN 200 AND 299 THEN
		RETURN 0.75;
	ELSIF length BETWEEN 300 AND 500 THEN
		RETURN 1.00;
	END IF;

END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION calc_speed_threshold(vessel_type_code SMALLINT, length SMALLINT)
RETURNS REAL AS $$
BEGIN
	IF NOT vessel_type_code BETWEEN 70 AND 89 THEN 
		RAISE EXCEPTION 'Illegal vessel_type_code: %', $1;
	ELSIF NOT length BETWEEN 120 AND 500 THEN
		RAISE EXCEPTION 'Illegal length: %', $2;
	END IF;

	RETURN calc_speed_optimum(vessel_type_code, length) + calc_speed_buffer(vessel_type_code, length);

END;
$$ LANGUAGE plpgsql;



CREATE OR REPLACE FUNCTION calc_weight(vessel_type_code SMALLINT, length SMALLINT)
RETURNS REAL AS $$
BEGIN
	IF NOT vessel_type_code BETWEEN 70 AND 89 THEN 
		RAISE EXCEPTION 'Illegal vessel_type_code: %', $1;
	ELSIF NOT length BETWEEN 120 AND 500 THEN
		RAISE EXCEPTION 'Illegal length: %', $2;
	END IF;

	--cargo
	IF vessel_type_code BETWEEN 70 AND 79 THEN
		RETURN ((length/4.089)^2.630492139);
	--tanker
	ELSIF vessel_type_code BETWEEN 80 AND 89 THEN
		RETURN ((length/8.49089)^3.435233819);
	END IF;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION calc_fuel_usage(vessel_type_code SMALLINT, length SMALLINT, speed REAL)
RETURNS REAL AS $$
DECLARE
	weight REAL;
	teu REAL;
	fur REAL;
BEGIN
	IF NOT vessel_type_code BETWEEN 70 AND 89 THEN 
		RAISE EXCEPTION 'Illegal vessel_type_code: %', $1;
	ELSIF NOT length BETWEEN 120 AND 500 THEN
		RAISE EXCEPTION 'Illegal length: %', $2;
	END IF;

	weight = calc_weight(vessel_type_code, length);
	teu = weight / 13.4;
	
	--cargo
	IF vessel_type_code BETWEEN 70 AND 79 THEN
		IF teu < 5000 THEN
			--cargo1
			fur = (6.552702-(speed*1.414554)+(speed^2*0.093468)-(speed^3*0.001442));
		ELSIF teu < 8000 THEN
			--cargo2
			fur = (8.7679001-(speed*1.8889985)+(speed^2*0.1243076)-(speed^3*0.0019169));
		ELSIF teu < 10000 THEN
			--cargo3
			fur = (9.5938987-(speed*2.0680723)+(speed^2*0.1362459)-(speed^3*0.0021048));
		ELSIF teu < 13000 THEN
			--cargo4
			fur = (10.6904889-(speed*2.3071292)+(speed^2*0.1522018)-(speed^3*0.0023576));
		ELSIF teu < 19000 THEN
			--cargo5
			fur = (11.3462750-(speed*2.4488369)+(speed^2*0.1616760)-(speed^3*0.0025085));
		ELSE
			RAISE EXCEPTION 'Illegal teu: %', length;
		END IF;
	--tanker
	ELSIF vessel_type_code BETWEEN 80 AND 89 THEN
		IF weight < 50000 THEN
			--medium range 1
			fur = (-2.5298571+(speed*0.8149405)-(speed^2*0.0830357)+(speed^3*0.0032292));
		ELSIF weight < 60000 THEN
			--long range 1
			fur = (-2.8531429+(speed*0.8938095)-(speed^2*0.0882143)+(speed^3*0.0033333));
		ELSIF weight < 80000 THEN
			--aframax
			fur = (-2.7110000+(speed*0.8445833)-(speed^2*0.0825000)+(speed^3*0.0032292));
		ELSIF weight < 160000 THEN
			--suezmax
			fur = (-3.6130000+(speed*1.1012500)-(speed^2*0.105)+(speed^3*0.0040625));
		ELSE 
			--VLCC
			fur = (-2.8307143+(speed)-(speed^2*0.0798214)+(speed^3*0.0034375));
		END IF;
	END IF;
	RETURN fur;
END;
$$ LANGUAGE plpgsql;








CREATE OR REPLACE FUNCTION calc_fuel_usage(vessel_type_code SMALLINT, length SMALLINT, speed REAL)
RETURNS REAL AS $$
DECLARE
	weight REAL;
	teu REAL;
	fur REAL;
BEGIN
	IF NOT vessel_type_code BETWEEN 70 AND 89 THEN 
		RAISE EXCEPTION 'Illegal vessel_type_code: %', $1;
	ELSIF NOT length BETWEEN 120 AND 500 THEN
		RAISE EXCEPTION 'Illegal length: %', $2;
	END IF;

	weight = calc_weight(vessel_type_code, length);
	teu = weight / 13.4;
	
	--cargo
	IF vessel_type_code BETWEEN 70 AND 79 THEN
		IF teu < 5000 THEN
			--cargo1
			fur = (6.552702-(speed*1.414554)+(speed^2*0.093468)-(speed^3*0.001442));
		ELSIF teu < 8000 THEN
			--cargo2
			fur = (8.7679001-(speed*1.8889985)+(speed^2*0.1243076)-(speed^3*0.0019169));
		ELSIF teu < 10000 THEN
			--cargo3
			fur = (9.5938987-(speed*2.0680723)+(speed^2*0.1362459)-(speed^3*0.0021048));
		ELSIF teu < 13000 THEN
			--cargo4
			fur = (10.6904889-(speed*2.3071292)+(speed^2*0.1522018)-(speed^3*0.0023576));
		ELSIF teu < 19000 THEN
			--cargo5
			fur = (11.3462750-(speed*2.4488369)+(speed^2*0.1616760)-(speed^3*0.0025085));
		ELSE
			RAISE EXCEPTION 'Illegal teu: %', length;
		END IF;
	--tanker
	ELSIF vessel_type_code BETWEEN 80 AND 89 THEN
		IF weight < 50000 THEN
			--medium range 1
			fur = (-2.5298571+(speed*0.8149405)-(speed^2*0.0830357)+(speed^3*0.0032292));
		ELSIF weight < 60000 THEN
			--long range 1
			fur = (-2.8531429+(speed*0.8938095)-(speed^2*0.0882143)+(speed^3*0.0033333));
		ELSIF weight < 80000 THEN
			--aframax
			fur = (-2.7110000+(speed*0.8445833)-(speed^2*0.0825000)+(speed^3*0.0032292));
		ELSIF weight < 160000 THEN
			--suezmax
			fur = (-3.6130000+(speed*1.1012500)-(speed^2*0.105)+(speed^3*0.0040625));
		ELSE 
			--VLCC
			fur = (-2.8307143+(speed)-(speed^2*0.0798214)+(speed^3*0.0034375));
		END IF;
	END IF;
	RETURN fur;
END;
$$ LANGUAGE plpgsql;



CREATE OR REPLACE FUNCTION calc_group_custom(vessel_type_code SMALLINT, length SMALLINT)
RETURNS SMALLINT AS $$
BEGIN
	IF NOT vessel_type_code BETWEEN 70 AND 89 THEN 
		RAISE EXCEPTION 'Illegal vessel_type_code: %', $1;
	ELSIF NOT length BETWEEN 120 AND 500 THEN
		RAISE EXCEPTION 'Illegal length: %', $2;
	END IF;

	--cargo
	IF vessel_type_code BETWEEN 70 AND 79 THEN
		IF length BETWEEN 120 AND 199 THEN
			RETURN 1;
		ELSIF length BETWEEN 200 AND 299 THEN
			RETURN 2;
		ELSIF length BETWEEN 300 AND 500 THEN
			RETURN 3;
		END IF;
	--tanker
	ELSIF vessel_type_code BETWEEN 80 AND 89 THEN
		IF length BETWEEN 120 AND 199 THEN
			RETURN 4;
		ELSIF length BETWEEN 200 AND 299 THEN
			RETURN 5;
		ELSIF length BETWEEN 300 AND 500 THEN
			RETURN 6;
		END IF;
	END IF;
END;
$$ LANGUAGE plpgsql;

















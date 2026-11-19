-- Use psql; the demo row is never committed.
BEGIN;
INSERT INTO public.departments (department_name)
VALUES ('Demo department ' || txid_current())
RETURNING department_id AS demo_department_id \gset
SELECT * FROM public.departments WHERE department_id = :demo_department_id;
UPDATE public.departments SET department_name = department_name || ' updated'
WHERE department_id = :demo_department_id RETURNING *;
DELETE FROM public.departments WHERE department_id = :demo_department_id RETURNING *;
ROLLBACK;
-- Identity sequences may advance despite rollback.

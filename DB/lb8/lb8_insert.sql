
use covid;
show tables;
delete from analises;
delete from death;
delete from patient_daily_diary;
delete from survived;
delete from symptoms;
delete from vac_patient;
delete from vacines;
delete from patient_past_card;

delete from patients;

insert into patients (p_name, p_surname, p_age, p_emale,p_test) values
('Alice', 'Smith', 30, 'alice.smith@example.com',1),
('Bob', 'Johnson', 45, 'bob.johnson@example.com',0),
('Charlie', 'Brown', 22, 'charlie.brown@example.com',1),
('Diana', 'Miller', 58, 'diana.miller@example.com',1),
('Ethan', 'Davis', 37, 'ethan.davis@example.com',1),
('Fiona', 'Wilson', 29, 'fiona.wilson@example.com',1),
('George', 'Taylor', 62, 'george.taylor@example.com',1),
('Hannah', 'Anderson', 25, 'hannah.anderson@example.com',1),
('Isaac', 'Thomas', 41, 'isaac.thomas@example.com',1),
('Julia', 'Jackson', 33, 'julia.jackson@example.com',1),
('Kevin', 'White', 50, 'kevin.white@example.com',1),
('Laura', 'Harris', 28, 'laura.harris@example.com',1),
('Michael', 'Martin', 48, 'michael.martin@example.com',0),
('Nancy', 'Thompson', 60, 'nancy.thompson@example.com',1),
('Oliver', 'Garcia', 26, 'oliver.garcia@example.com',1),
('Patricia', 'Martinez', 39, 'patricia.martinez@example.com',1),
('Quinn', 'Robinson', 31, 'quinn.robinson@example.com',1),
('Rachel', 'Clark', 44, 'rachel.clark@example.com',1),
('Samuel', 'Rodriguez', 55, 'samuel.rodriguez@example.com',1),
('Tara', 'Lewis', 27, 'tara.lewis@example.com',1);

select* from patients;
insert into patient_past_card (p_id,p_history) values
(1,'Patient has a history of childhood asthma, managed with inhalers. No recent exacerbations.'),
(2,'Patient underwent appendectomy at age 12. Reports no complications. Allergies to peanuts.'),
(3,'Patient has a family history of heart disease. Smoker for 10 years, trying to quit. No other relevant past medical history.'),
(4,'Patient diagnosed with type 2 diabetes 5 years ago. On oral medications, glucose levels are currently well controlled.'),
(5,'Patient has a history of anxiety and depression, currently managed with medication and therapy. Stable condition.'),
(6,'Patient was diagnosed with hypertension 2 years ago. Currently taking medication to manage it and is under the care of a cardiologist.'),
(7,'Patient had a mild case of COVID-19 last year. No long-term complications reported. Full vaccination records on file.'),
(8,'Patient has a history of migraines since adolescence, triggered by stress. Manages with pain relievers.'),
(9,'Patient reports occasional back pain. No specific diagnosis; manages with physical therapy and over-the-counter pain relievers.'),
(10,'Patient has a history of seasonal allergies. Takes antihistamines as needed, particularly during spring and fall.'),
(11,'Patient has never been hospitalized and has no previous history of chronic illnesses. Only suffered from occasional flu.'),
(12,'Patient has a previous history of an anaphylactic reaction to a bee sting. Uses an EpiPen if necessary. Also allergic to shell fish'),
(13,'Patient has a history of arthritis in the knees; managed with exercise and over-the-counter medication. No mobility restrictions.'),
(14,'Patient had a surgery to repair a torn rotator cuff one year ago. Still undergoing physical therapy'),
(15,'Patient is 85 years old and reports no significant medical history, other than mild joint stiffness due to age.'),
(16,'Patient has a history of sleep apnea, uses a CPAP machine at night. No major issues reported'),
(17,'Patient has undergone routine checkups annually with no complications. No previous medical conditions.'),
(18,'Patient has a history of skin allergies. No other medical complications reported.'),
(19,'Patient has a history of food poisoning last year. No other medical conditions reported.'),
(20,'Patient has had multiple fractures throughout life and was hospitalized several times due to this.');

insert into  analises (p_id, p_analis, an_value) VALUES
(1, 'Blood Glucose', 110),
(1, 'Cholesterol', 200),
(1, 'Heart Rate', 75),
(2, 'Blood Glucose', 95),
(2, 'Cholesterol', 180),
(12, 'Heart Rate', 80),
(3, 'Blood Glucose', 120),
(3, 'Cholesterol', 220),
(15, 'Heart Rate', 70),
(4, 'Blood Glucose', 85),
(4, 'Cholesterol', 170),
(13, 'Heart Rate', 90),
(5, 'Blood Glucose', 105),
(17, 'Cholesterol', 190),
(5, 'Heart Rate', 65),
(6, 'Blood Glucose', 98),
(6, 'Cholesterol', 210),
(11, 'Heart Rate', 82),
(7, 'Blood Glucose', 115),
(20, 'Cholesterol', 230),
(7, 'Heart Rate', 78),
(8, 'Blood Glucose', 92),
(8, 'Cholesterol', 175),
(8, 'Heart Rate', 88),
(9, 'Blood Glucose', 102),
(18, 'Cholesterol', 195),
(9, 'Heart Rate', 72),
(16, 'Blood Glucose', 88),
(10, 'Cholesterol', 165),
(10, 'Heart Rate', 86);

insert into vacines (v_id, v_name, v_formula) values
(1, 'Influenza Vaccine1', 'A/Brisbane/02/2018 (H1N1)pdm09-like virus'),
(2,  'COVID-19 Vaccine1', 'mRNA-1273'),
(3,  'Influenza Vaccine2', 'A/Kansas/14/2017 (H3N2)-like virus'),
(4,  'COVID-19 Vaccine2', 'BNT162b2'),
(5,  'Hepatitis B Vaccine', 'Recombinant hepatitis B surface antigen'),
(6,  'Measles Vaccine', 'Live attenuated measles virus'),
(7,  'Influenza Vaccine2', 'B/Colorado/06/2017-like virus'),
(8,  'COVID-19 Vaccine3', 'Ad26.COV2.S'),
(9,  'Tetanus Vaccine', 'Tetanus toxoid'),
(10, 'Varicella Vaccine', 'Live attenuated varicella virus'),
(11, 'Influenza Vaccine3', 'B/Phuket/3073/2013-like virus'),
(12, 'COVID-19 Vaccine4', 'mRNA-1273'),
(13, 'Pneumococcal Vaccine', 'Polysaccharide vaccine'),
(14, 'Rotavirus Vaccine', 'Live attenuated rotavirus'),
(15, 'Influenza Vaccine4', 'A/Singapore/GP1908/2019 (H1N1)pdm09-like virus'),
(16, 'COVID-19 Vaccine5', 'BNT162b2'),
(17, 'Meningococcal Vaccine', 'Polysaccharide vaccine'),
(18,'HPV Vaccine', 'Recombinant HPV antigens'),
(19, 'Influenza Vaccine', 'A/Hong Kong/2671/2019 (H3N2)-like virus'),
(20, 'COVID-19 Vaccine6', 'Ad26.COV2.S');

insert into vac_patient (v_date, v_id, p_id) values
('2023-01-15', 1, 1),
('2023-01-15', 2, 1),
('2023-02-01', 3, 2),
('2023-02-01', 4, 2),
('2023-03-12', 9, 5),
('2023-03-12', 10, 5),
('2023-04-01', 11, 6),
('2023-04-01', 12, 6),
('2023-04-01', 2, 11);


insert into death (p_id,  p_death_reason) values
(1,  'COVID-19 Pneumonia with respiratory failure.'),
(2,  'Severe ARDS due to COVID-19 infection.'),
(3,  'COVID-19 related complications, including acute kidney injury.'),
(10,  'Exacerbation of COPD and acute respiratory failure due to COVID-19.'),
(15,  'Severe COVID-19 infection with secondary bacterial pneumonia.'),
(6,  'COVID-19 induced thromboembolic complications.'),
(4, 'COVID-19 associated acute kidney failure and sepsis.'),
(8,  'Complications from severe COVID-19 infection, including septic shock.');

insert survived (p_id, id_vacines) values
(11,  2),
(20,  1);
select* from patients;

insert into patient_daily_diary (p_id, p_date, p_dairy) values
-- Patient 1
(1, '2023-01-01', 'Initial symptoms: fever, cough, fatigue. Positive COVID test.'),
(1, '2023-01-03', 'Fever reduced, cough persists. Loss of taste reported.'),
(1, '2023-01-05', 'Mild cough, fatigue continues. Starting to feel slightly better.'),
-- Patient 2
(2, '2023-01-02', 'Sore throat, congestion, mild headache. Positive COVID test.'),
(2, '2023-01-04', 'Sore throat improving, cough developing. Congestion persists.'),
(2, '2023-01-06', 'Cough and congestion remain, but overall stable condition.'),
-- Patient 3
(3, '2023-01-03', 'High fever, severe body aches, chills. Positive COVID test.'),
(3, '2023-01-05', 'Fever still high, severe cough. Difficulty breathing reported.'),
(3, '2023-01-07', 'Fever reduced, cough improving. Breathing slightly better with oxygen.'),
-- Patient 4
(4, '2023-01-04', 'Loss of taste and smell, mild fatigue. Positive COVID test.'),
(4, '2023-01-06', 'Some taste returning. Fatigue continues, mild headache.'),
(4, '2023-01-08', 'Taste almost fully back. Congestion developing.'),
-- Patient 5
(5, '2023-01-05', 'Dry cough, sore throat, feeling weak and tired. Positive COVID test.'),
(5, '2023-01-07', 'Dry cough more intense, sore throat remains. Very weak and tired.'),
(5, '2023-01-09', 'Dry cough improved, some energy back. Sore throat still present.'),
-- Patient 6
(6, '2023-01-06', 'Mild fever, headache, fatigue. Positive COVID test.'),
(6, '2023-01-08', 'Fever gone, congestion started. Headache still present.'),
(6, '2023-01-10', 'Congestion improved. Overall fatigue subsiding.'),
-- Patient 7
(7, '2023-01-07', 'Sudden chills, body aches, mild fever. Positive COVID test.'),
(7, '2023-01-09', 'High fever, severe chills, loss of appetite.'),
(7, '2023-01-11', 'Fever starting to subside. Appetite slowly returning.'),
-- Patient 8
(8, '2023-01-08', 'Congestion, mild sore throat, fatigue. Positive COVID test.'),
(8, '2023-01-10', 'Congestion more intense. Muscle aches starting.'),
(8, '2023-01-12', 'Congestion improved. Fatigue remains.'),
-- Patient 9
(9, '2023-01-09', 'Mild cough, body aches. Feeling tired. Positive COVID test.'),
(9, '2023-01-11', 'Moderate cough, more intense body aches. Weakness reported.'),
(9, '2023-01-13', 'Cough improved. Body aches are less. Still tired.'),
-- Patient 10
(10, '2023-01-10', 'Moderate fever, chills. Severe fatigue. Positive COVID test.'),
(10, '2023-01-12', 'High fever, intense chills. Shortness of breath starting.'),
(10, '2023-01-14', 'Fever improving, mild shortness of breath. Fatigue is severe.'),
-- Patient 11
(11, '2023-01-11', 'Initial symptoms: fatigue and mild cough. Tested positive for COVID.'),
(11, '2023-01-13', 'Cough worsened, and fatigue persists, mild body aches reported.'),
(11, '2023-01-15', 'Cough has improved, and fatigue is also less intense, overall condition improving.'),
-- Patient 12
(12, '2023-01-12', 'Sore throat and congestion reported, also experiencing headaches and fatigue.'),
(12, '2023-01-14', 'Sore throat improved, headache persists, and congestion also remains.'),
(12, '2023-01-16', 'Headaches improved, but congestion is more intense, overall condition is still stable'),
-- Patient 13
(13, '2023-01-13', 'Experiencing body aches and chills, low-grade fever also reported.'),
(13, '2023-01-15', 'Chills are less intense, low-grade fever persists, and body aches remain.'),
(13, '2023-01-17', 'Chills and body aches are improving, low-grade fever persists, general condition is improving'),
-- Patient 14
(14, '2023-01-14', 'Loss of smell and taste reported, but no other symptoms yet.'),
(14, '2023-01-16', 'Loss of taste persists, mild congestion started. Smell remains impaired.'),
(14, '2023-01-18', 'Mild congestion reported, taste is starting to come back, smell is still impaired.'),
-- Patient 15
(15, '2023-01-15', 'Mild cough and fatigue, testing positive for covid today'),
(15, '2023-01-17', 'Cough persists, fatigue remains, also has a mild sore throat today.'),
(15, '2023-01-19', 'Mild cough and fatigue persists, and sore throat is starting to improve.'),
-- Patient 16
(16, '2023-01-16', 'Initial symptoms, including a low-grade fever and headache.'),
(16, '2023-01-18', 'Low-grade fever has improved, but a headache persists and congestion reported.'),
(16, '2023-01-20', 'Headache improved, and mild congestion and fatigue are still present'),
-- Patient 17
(17, '2023-01-17', 'Sudden onset of high fever and chills, also feeling weak.'),
(17, '2023-01-19', 'Fever remains, but chills improved, still very weak, and reported loss of appetite'),
(17, '2023-01-21', 'Fever is starting to improve, loss of appetite continues, but weakness is subsiding.'),
-- Patient 18
(18, '2023-01-18', 'Experiencing mild sore throat and fatigue, tested positive today'),
(18, '2023-01-20', 'Sore throat has improved, but mild congestion reported, fatigue persists'),
(18, '2023-01-22', 'Mild congestion is subsiding, fatigue continues, but overall condition is stable'),
-- Patient 19
(19, '2023-01-19', 'Mild cough and body aches also feeling generally unwell.'),
(19, '2023-01-21', 'Cough has worsened, body aches continue, feeling more tired today'),
(19, '2023-01-23', 'Cough is starting to improve, but body aches persists, general condition is still stable'),
-- Patient 20
(20, '2023-01-20', 'High fever and shortness of breath, also experiencing extreme fatigue.'),
(20, '2023-01-22', 'Fever has improved, shortness of breath persists, and extreme fatigue also continues'),
(20, '2023-01-24', 'Fever is subsiding, shortness of breath is also improving, still has severe fatigue');

insert into symptoms (p_id, pat_symptoms, id_vacine) values
(1, 'Fever, dry cough, fatigue', 2),
(2, 'Sore throat, congestion, headache', 4),
(3, 'High fever, body aches, difficulty breathing', NULL),
(4, 'Loss of taste and smell, fatigue', 8),
(5, 'Dry cough, sore throat, weakness', 10),
(6, 'Mild fever, headache, congestion', 12),
(7, 'Chills, body aches, loss of appetite', NULL),
(8, 'Congestion, sore throat, muscle aches', 16),
(9, 'Cough, body aches, weakness', 18),
(10, 'Fever, chills, shortness of breath', 20),
(11, 'Fatigue, mild cough, body aches', 2),
(12, 'Sore throat, headache, congestion', 4),
(13, 'Chills, body aches, low-grade fever', NULL),
(14, 'Loss of smell, mild congestion', 8),
(15, 'Mild cough, sore throat, fatigue', 10),
(16, 'Low-grade fever, headache, congestion', 12),
(17, 'High fever, chills, weakness', NULL),
(18, 'Sore throat, congestion, fatigue', 16),
(19, 'Cough, body aches, general malaise', 18),
(20, 'Shortness of breath, extreme fatigue', 20);

select   analises.p_analis,count(analises.p_analis) from  analises group by analises.p_analis;
select* from  vac_patient;
select* from patient_daily_diary;
select* from analises;
USE information_schema;

select table_name from referential_constraints
WHERE constraint_schema = 'covid'
AND referenced_table_name = 'patients'
AND delete_rule='CASCADE';
select column_name from INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'patients' ORDER BY ordinal_position;
;
use covid;
show columns from patients;
update analises set an_value = 10;
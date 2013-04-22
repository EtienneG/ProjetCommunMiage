DROP TABLE administrateur CASCADE CONSTRAINT;
DROP TABLE offre CASCADE CONSTRAINT;
DROP TABLE salaire CASCADE CONSTRAINT;
DROP TABLE experience_pro CASCADE CONSTRAINT;
DROP TABLE domaine CASCADE CONSTRAINT;
DROP TABLE contact_entreprise CASCADE CONSTRAINT;
DROP TABLE entreprise CASCADE CONSTRAINT;
DROP TABLE secteur_activite CASCADE CONSTRAINT;
DROP TABLE visibilite CASCADE CONSTRAINT;
DROP TABLE promotion CASCADE CONSTRAINT;
DROP TABLE formation CASCADE CONSTRAINT;
DROP TABLE etudiant CASCADE CONSTRAINT;
DROP TABLE identifiant CASCADE CONSTRAINT;
DROP SEQUENCE seq_sec_act_id;
DROP SEQUENCE seq_entr_id;
DROP SEQUENCE seq_contact_id;
DROP SEQUENCE seq_dom_id;
DROP SEQUENCE seq_exp_pro_id;
DROP SEQUENCE seq_off_id;

create table identifiant (
ide_login varchar2(25 char) not null,
ide_password varchar2(25 char) not null,
constraint pk_identifiant primary key (ide_login)
);

create table etudiant (
etu_id number(10) not null,
etu_nom varchar2(50 char) not null,
etu_prenom varchar2(50 char) not null,
etu_mail varchar2(100 char) , --not null,
etu_sexe char(1 char),
etu_adresse varchar2(200),
etu_telephone varchar2(20 char),
etu_dt_naiss date not null,
etu_etat number(1) default 0 not null , -- reinseigne si le compte est actif
etu_cv blob,
etu_photo blob,
etu_contactable number(1) default 0 not null,-- reinseigne si l'étudiant souhaite être contacté par une entreprise
etu_ide_login varchar2(25 char) not null,
constraint pk_etudiant primary key (etu_id),
constraint fk_etu_ide_login foreign key (etu_ide_login) references identifiant(ide_login),
constraint ck_etu_sexe check (etu_sexe in ('F', 'M')),
constraint ck_etu_etat check (etu_etat in (0, 1)),
constraint ck_etu_contactable check (etu_contactable in (0, 1)),
CONSTRAINT ck_etu_mail CHECK (REGEXP_LIKE(etu_mail,'^[a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,4}$' ))
);

--

create table formation (
form_cd_diplome varchar2(10 char) not null,
form_voie varchar2(15 char), --peut -etre à suprimer car infos dans le cd_diplome
form_niveau char(2 char) not null, --peut -etre à suprimer car infos dans le cd_diplome
form_libelle varchar2(200 char),
constraint pk_formation primary key (form_cd_diplome),
constraint ck_form_voie check (form_voie in ('CLASSIQUE', 'APPRENTISSAGE', 'IKSEM')), --peut -etre à suprimer car infos dans le cd_diplome
constraint ck_form_niveau check (form_voie in ('L3', 'M1', 'M2')), --peut -etre à suprimer car infos dans le cd_diplome
constraint ck_form_cd_diplome check (form_cd_diplome in ('LII3MII2', --L3 classique
													   'LII3MII3', --L3 App
													   'MA1MII2', --M1 Classique
													   'MA1MIIA', --M1 App
													   'MP2MII2', --M2 Classique
													   'MP2MIIA', --M2 App
													   'MR2MII7'--M2 App IKSEM
													   ))
);

create table promotion (
prom_cd_diplome varchar2(10 char) not null,
prom_etu_id number(10) not null,
prom_annee varchar2(9) not null,
prom_mention varchar2(10) default null,
promo_resultat varchar2(4),
constraint pk_promotion primary key (prom_cd_diplome, prom_etu_id, prom_annee ),
constraint fk_prom_cd_diplome foreign key (prom_cd_diplome) references formation(form_cd_diplome),
constraint fk_prom_etu_id foreign key (prom_etu_id) references etudiant(etu_id),
CONSTRAINT ck_prom_annee CHECK (REGEXP_LIKE(prom_annee,'^[0-9]{4}/[0-9]{4}$' )),
constraint ck_prom_mention check (prom_mention in ( 'AB', 'B', 'TB', 'P' )),
constraint ck_promo_resultat check (promo_resultat in ( 'ADM', --Admis
														'ADMH', --Admis par Homologation - Décret 2/8/1960
														'ADMI', --Admissible
														'ADMV', --Admis par VAE
														'AJ', --Ajourné
														'AVAA', --Attente validation de l'année antérieure
														'DEF',--Défaillant
														'AJAC',--Ajourné mais accès autorisé à étape sup.
														'ABI',--Absent
														'CMP',--Validé par compensation
														'NVAL',--Non validé
														'VAL',--Validé
														'DIS'--Dispense examen
														))
);

create table visibilite ( --peut etre la renommer en "relation"
vis_etu_id_1 number(10) not null, 
vis_etu_id_2 number(10) not null,
vis_etat char(10),
vis_visibilite_1 varchar2(20),
vis_visibilite_2 varchar2(20),
constraint pk_visibilite primary key (vis_etu_id_1, vis_etu_id_2),
constraint ck_vis_etat check (vis_etat in ( 'EN ATTENTE', 'ACCEPTEE', 'REFUSEE')),
constraint ck_vis_1 check (vis_visibilite_1 in ('Amis','Autre')), --définir les visibilités
constraint ck_vis_2 check (vis_visibilite_2 in ('Amis','Autre')) --définir les visibilités
);

create sequence seq_sec_act_id START WITH 1 INCREMENT BY 1;

create table secteur_activite (
sec_act_id number(10) not null, -- alimentée par la séquence seq_sec_act_id
sec_act_libelle varchar2(100 char),
constraint pk_secteur_activite primary key (sec_act_id)--clé primaire
);


create sequence seq_entr_id START WITH 1 INCREMENT BY 1;

create table entreprise (
entr_id number(10) not null, -- alimentée par la séquence seq_entr_id
entr_nom varchar2(100 char),
entr_type varchar2(25 char),
entr_nationalite varchar2(50 char),
entr_sec_act_id number(10),
entr_url varchar2(100 char),
constraint pk_entreprise primary key (entr_id),--clé primaire
constraint fk_entr_sec_act_id foreign key (entr_sec_act_id) references secteur_activite(sec_act_id), --clé étrangère de secteur_activite
constraint ck_entr_type check (entr_type in ( 'TPE', 'PME', 'GRANDE ENTREPRISE', 'MULTINATIONALE', 'AUTRES'))
);

create sequence seq_contact_id START WITH 1 INCREMENT BY 1;

create table contact_entreprise (
contact_id number(10) not null, -- alimentée par la séquence seq_contact_id
contact_nom varchar2(50 char) ,
contact_prenom varchar2(50 char) ,
contact_mail varchar2(100 char) not null,
contact_ide_login varchar2(25 char) not null,
contact_entr_id number(10) not null,
constraint pk_contact_entreprise primary key (contact_id), --clé primaire
constraint fk_contact_ide_login foreign key (contact_ide_login) references identifiant(ide_login), --clé étrangère de identifiant
constraint fk_contact_entr_id foreign key (contact_entr_id) references entreprise(entr_id), --clé étrangère de entreprise
CONSTRAINT ck_contact_mail CHECK (REGEXP_LIKE(contact_mail,'^[a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,4}$' ))
);

create sequence seq_dom_id START WITH 1 INCREMENT BY 1;

create table domaine (
dom_id number(10) not null, -- alimentée par la séquence seq_dom_id
dom_libelle varchar2(100 char),
constraint pk_domaine primary key (dom_id)--clé primaire
);


create sequence seq_exp_pro_id START WITH 1 INCREMENT BY 1;

create table experience_pro (
exp_pro_id number(10) not null,
exp_pro_description varchar2(4000 char),
exp_pro_dt_deb date not null,
exp_pro_dt_fin date,
exp_pro_lieu varchar2(50 char),
exp_pro_contrat varchar2(10 char),
exp_pro_manager number(1),
exp_pro_dom_id number(10), 
constraint pk_experience_pro primary key (exp_pro_id), --clé primaire
constraint fk_exp_pro_dom_id foreign key (exp_pro_dom_id) references domaine(dom_id), --clé étrangère de domaine
constraint ck_exp_pro_contrat check (exp_pro_contrat in ('CDD', 'CDI', 'STAGE', 'ALTERNANCE', 'INTERIM', 'PRESTATAIRE',  'AUTRES')),
constraint ck_exp_pro_manager check (exp_pro_manager in (0, 1))
);

create table salaire (
sala_etu_id number(10) not null,
sala_exp_pro_id number(10) not null,
sala_date date not null, --alimente avec la date courante si non renseigné
sala_montant number(6,2),
constraint pk_salaire primary key (sala_etu_id, sala_exp_pro_id, sala_date), --clé primaire
constraint fk_sala_etu_id foreign key (sala_etu_id) references etudiant(etu_id),
constraint fk_sala_exp_pro_id foreign key (sala_exp_pro_id) references experience_pro(exp_pro_id)
);


create sequence seq_off_id START WITH 1 INCREMENT BY 1;

create table offre(
off_id  number(10) not null,
off_description varchar2(4000 char),
off_remuneration number(6,2),
off_dt_deb date,
off_dt_parution date not null, --alimente par la date courante
off_contrat varchar2(10 char),
off_cont_id  number(10) not null,
off_entr_id number(10) not null,
constraint pk_offre primary key (off_id), --clé primaire
constraint ck_off_contrat check (off_contrat in ('CDD', 'CDI', 'STAGE', 'ALTERNANCE', 'INTERIM', 'PRESTATAIRE',  'AUTRES')),
constraint fk_off_cont_id foreign key (off_cont_id) references contact_entreprise(contact_id),
constraint fk_off_entr_id foreign key (off_entr_id) references entreprise(entr_id)
);


create table administrateur (
adm_id number(10) not null,
adm_nom varchar2(50 char) ,
adm_prenom varchar2(50 char) ,
adm_mail varchar2(100 char) not null,
adm_ide_login varchar2(25 char) not null,
constraint pk_administrateur primary key (adm_id), --clé primaire
constraint fk_adm_ide_login foreign key (adm_ide_login) references identifiant(ide_login), --clé étrangère de identifiant
CONSTRAINT ck_adm_mail CHECK (REGEXP_LIKE(adm_mail,'^[a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,4}$' ))
);
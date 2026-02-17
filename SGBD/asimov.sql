-- DDL for collegeAsimov: base de données de suivi des élèves
DROP DATABASE IF EXISTS collegeAsimov;

CREATE DATABASE IF NOT EXISTS collegeAsimov
	DEFAULT CHARACTER SET = utf8mb4
	DEFAULT COLLATE = utf8mb4_general_ci;
USE collegeAsimov;

-- Table des utilisateurs / rôles (authentification simplifiée)
CREATE TABLE IF NOT EXISTS users (
	idUser INT AUTO_INCREMENT PRIMARY KEY,
	username VARCHAR(100) NOT NULL UNIQUE,
	password_hash VARCHAR(255) NULL,
	role ENUM('admin','secretaire','proviseur','enseignant','eleve') NOT NULL,
	professeur_id INT NULL,
	eleve_id INT NULL,
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Professeurs
CREATE TABLE IF NOT EXISTS professeur (
	idProfesseur INT AUTO_INCREMENT PRIMARY KEY,
	nomProfesseur VARCHAR(100) NOT NULL,
	prenomProfesseur VARCHAR(100) NOT NULL,
	classeReferent INT NULL,
	principaleClasse VARCHAR(100) NULL,
	sexeProfesseur ENUM('M','F','Autre') DEFAULT 'Autre',
	emailProfesseur VARCHAR(255) NULL,
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Classes
CREATE TABLE IF NOT EXISTS classe (
	idClasse INT AUTO_INCREMENT PRIMARY KEY,
	nomClasse VARCHAR(100) NULL,
	lv2 VARCHAR(50) NULL,
	anneeScolaire VARCHAR(20) NOT NULL,
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Élèves
CREATE TABLE IF NOT EXISTS eleve (
	idEleve INT AUTO_INCREMENT PRIMARY KEY,
	nom VARCHAR(100) NOT NULL,
	prenom VARCHAR(100) NOT NULL,
	section VARCHAR(50) NULL,
	sexe ENUM('M','F','Autre') DEFAULT 'Autre',
	telephoneReferent VARCHAR(50) NULL,
	adresse TEXT NULL,
	current_classe_id INT NULL,
	referent_professeur_id INT NULL,
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	FOREIGN KEY (current_classe_id) REFERENCES classe(idClasse) ON DELETE SET NULL,
	FOREIGN KEY (referent_professeur_id) REFERENCES professeur(idProfesseur) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Historique des classes et moyennes semestrielles
CREATE TABLE IF NOT EXISTS historiqueClasse (
	idHistorique INT AUTO_INCREMENT PRIMARY KEY,
	eleve_id INT NOT NULL,
	classe_id INT NOT NULL,
	anneeEleve INT NULL,
	anneeScolaire VARCHAR(20) NOT NULL,
	moyenneSemestre1 DECIMAL(4,2) NULL,
	moyenneSemestre2 DECIMAL(4,2) NULL,
	validated_by INT NULL,
	validated_at DATETIME NULL,
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
	CONSTRAINT fk_hist_eleve FOREIGN KEY (eleve_id) REFERENCES eleve(idEleve) ON DELETE CASCADE,
	CONSTRAINT fk_hist_classe FOREIGN KEY (classe_id) REFERENCES classe(idClasse) ON DELETE CASCADE,
	CONSTRAINT fk_hist_validated_by FOREIGN KEY (validated_by) REFERENCES users(idUser) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Projets et participation
CREATE TABLE IF NOT EXISTS projet (
	idProjet INT AUTO_INCREMENT PRIMARY KEY,
	nomProjet VARCHAR(200) NOT NULL,
	dateProjet DATE NULL,
	dateFin DATE NULL,
	responsable_professeur_id INT NULL,
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
	FOREIGN KEY (responsable_professeur_id) REFERENCES professeur(idProfesseur) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS projet_participation (
	idParticipation INT AUTO_INCREMENT PRIMARY KEY,
	projet_id INT NOT NULL,
	eleve_id INT NOT NULL,
	dateDebut DATE NULL,
	dateFin DATE NULL,
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
	FOREIGN KEY (projet_id) REFERENCES projet(idProjet) ON DELETE CASCADE,
	FOREIGN KEY (eleve_id) REFERENCES eleve(idEleve) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Recherches de stage (un élève peut avoir plusieurs recherches/contacts)
CREATE TABLE IF NOT EXISTS recherche_stage (
	idRecherche INT AUTO_INCREMENT PRIMARY KEY,
	eleve_id INT NOT NULL,
	entreprise VARCHAR(255) NULL,
	contact_nom VARCHAR(200) NULL,
	contact_telephone VARCHAR(100) NULL,
	contact_email VARCHAR(255) NULL,
	nb_lettres_envoyees INT DEFAULT 0,
	nb_reponses_recues INT DEFAULT 0,
	dateEntretien DATE NULL,
	resultatEntretien VARCHAR(200) NULL,
	notes TEXT NULL,
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
	FOREIGN KEY (eleve_id) REFERENCES eleve(idEleve) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Stages (une entrée principale par stage réalisé ou prévu)
CREATE TABLE IF NOT EXISTS stage (
	idStage INT AUTO_INCREMENT PRIMARY KEY,
	eleve_id INT NOT NULL,
	entreprise VARCHAR(255) NULL,
	statut ENUM('recherche','convention_signee','realise','atteste') DEFAULT 'recherche',
	dateDebut DATE NULL,
	dateFin DATE NULL,
	entreprise_adresse TEXT NULL,
	entreprise_contact VARCHAR(255) NULL,
	notes TEXT NULL,
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
	FOREIGN KEY (eleve_id) REFERENCES eleve(idEleve) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Conventions de stage (PDF) liées à un stage
CREATE TABLE IF NOT EXISTS conventionStage (
	idConvention INT AUTO_INCREMENT PRIMARY KEY,
	stage_id INT NOT NULL,
	fichierPDFConventionStage VARCHAR(500) NOT NULL,
	dateSoumission DATETIME DEFAULT CURRENT_TIMESTAMP,
	dateValidation DATETIME NULL,
	validated_by INT NULL,
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
	FOREIGN KEY (stage_id) REFERENCES stage(idStage) ON DELETE CASCADE,
	FOREIGN KEY (validated_by) REFERENCES users(idUser) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Attestations de stage (PDF)
CREATE TABLE IF NOT EXISTS AttestationStage (
	idAttestation INT AUTO_INCREMENT PRIMARY KEY,
	stage_id INT NOT NULL,
	fichierPDFAttestation VARCHAR(500) NOT NULL,
	uploaded_by INT NULL,
	uploaded_at DATETIME DEFAULT CURRENT_TIMESTAMP,
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
	FOREIGN KEY (stage_id) REFERENCES stage(idStage) ON DELETE CASCADE,
	FOREIGN KEY (uploaded_by) REFERENCES users(idUser) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Journal d'audit minimal
CREATE TABLE IF NOT EXISTS audit_log (
	idAudit INT AUTO_INCREMENT PRIMARY KEY,
	user_id INT NULL,
	action VARCHAR(100) NOT NULL,
	object_type VARCHAR(100) NULL,
	object_id VARCHAR(100) NULL,
	details TEXT NULL,
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
	FOREIGN KEY (user_id) REFERENCES users(idUser) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Indexes supplémentaires pour les requêtes fréquentes
CREATE INDEX idx_eleve_referent ON eleve(referent_professeur_id);
CREATE INDEX idx_hist_eleve ON historiqueClasse(eleve_id);
CREATE INDEX idx_stage_eleve ON stage(eleve_id);

-- Notes:
-- - Les moyennes saisies par le secrétariat sont stockées dans `historiqueClasse`.
--   Seul un utilisateur ayant le rôle `proviseur` pourra modifier `moyenneSemestre1/2` après validation.
-- - Les fichiers PDF sont référencés par chemin/URL dans les colonnes `fichierPDF*`.
-- - Prévoir mécanisme d'upload sécurisé et stockage chiffré côté application/infrastructure.

-- Fin du script DDL initial

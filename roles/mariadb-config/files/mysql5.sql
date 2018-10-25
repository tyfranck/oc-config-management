CREATE TABLE SEQUENCE (
  SEQ_NAME VARCHAR(50) NOT NULL,
  SEQ_COUNT DECIMAL(38),
  PRIMARY KEY (SEQ_NAME)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO SEQUENCE(SEQ_NAME, SEQ_COUNT) values ('SEQ_GEN', 0);
INSERT INTO SEQUENCE(SEQ_NAME, SEQ_COUNT) values ('seq_mh_assets_asset', 0);
INSERT INTO SEQUENCE(SEQ_NAME, SEQ_COUNT) values ('seq_mh_assets_snapshot', 0);

CREATE TABLE mh_bundleinfo (
  id BIGINT(20) NOT NULL,
  bundle_name VARCHAR(128) NOT NULL,
  build_number VARCHAR(128) DEFAULT NULL,
  host VARCHAR(128) NOT NULL,
  bundle_id BIGINT(20) NOT NULL,
  bundle_version VARCHAR(128) NOT NULL,
  db_schema_version VARCHAR(128) DEFAULT NULL,
  PRIMARY KEY (id),
  CONSTRAINT UNQ_mh_bundleinfo UNIQUE (host, bundle_name, bundle_version)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE mh_organization (
  id VARCHAR(128) NOT NULL,
  anonymous_role VARCHAR(255),
  name VARCHAR(255),
  admin_role VARCHAR(255),
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE mh_organization_node (
  organization VARCHAR(128) NOT NULL,
  port int(11),
  name VARCHAR(255),
  PRIMARY KEY (organization, port, name),
  CONSTRAINT FK_mh_organization_node_organization FOREIGN KEY (organization) REFERENCES mh_organization (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE INDEX IX_mh_organization_node_pk ON mh_organization_node (organization);
CREATE INDEX IX_mh_organization_node_name ON mh_organization_node (name);
CREATE INDEX IX_mh_organization_node_port ON mh_organization_node (port);

CREATE TABLE mh_organization_property (
  organization VARCHAR(128) NOT NULL,
  name VARCHAR(255) NOT NULL,
  value TEXT(65535),
  PRIMARY KEY (organization, name),
  CONSTRAINT FK_mh_organization_property_organization FOREIGN KEY (organization) REFERENCES mh_organization (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE INDEX IX_mh_organization_property_pk ON mh_organization_property (organization);

CREATE TABLE mh_annotation (
  id BIGINT NOT NULL,
  inpoint INTEGER,
  outpoint INTEGER,
  mediapackage VARCHAR(128),
  session VARCHAR(128),
  created DATETIME,
  user_id VARCHAR(255),
  length INTEGER,
  type VARCHAR(128),
  value TEXT(65535),
  private TINYINT(1) DEFAULT 0,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE INDEX IX_mh_annotation_created ON mh_annotation (created);
CREATE INDEX IX_mh_annotation_inpoint ON mh_annotation (inpoint);
CREATE INDEX IX_mh_annotation_outpoint ON mh_annotation (outpoint);
CREATE INDEX IX_mh_annotation_mediapackage ON mh_annotation (mediapackage);
CREATE INDEX IX_mh_annotation_private ON mh_annotation (private);
CREATE INDEX IX_mh_annotation_user ON mh_annotation (user_id);
CREATE INDEX IX_mh_annotation_session ON mh_annotation (session);
CREATE INDEX IX_mh_annotation_type ON mh_annotation (type);

CREATE TABLE mh_capture_agent_role (
  id VARCHAR(128) NOT NULL,
  organization VARCHAR(128) NOT NULL,
  role VARCHAR(255),
  PRIMARY KEY (id, organization, role),
  CONSTRAINT FK_mh_capture_agent_role_organization FOREIGN KEY (organization) REFERENCES mh_organization (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE INDEX IX_mh_capture_agent_role_pk ON mh_capture_agent_role (id, organization);

CREATE TABLE mh_capture_agent_state (
  id VARCHAR(128) NOT NULL,
  organization VARCHAR(128) NOT NULL,
  configuration TEXT(65535),
  state TEXT(65535) NOT NULL,
  last_heard_from BIGINT NOT NULL,
  url TEXT(65535),
  PRIMARY KEY (id, organization),
  CONSTRAINT FK_mh_capture_agent_state_organization FOREIGN KEY (organization) REFERENCES mh_organization (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE mh_host_registration (
  id BIGINT NOT NULL,
  host VARCHAR(255) NOT NULL,
  address VARCHAR(39) NOT NULL,
  memory BIGINT NOT NULL,
  cores INTEGER NOT NULL,
  maintenance TINYINT(1) DEFAULT 0 NOT NULL,
  online TINYINT(1) DEFAULT 1 NOT NULL,
  active TINYINT(1) DEFAULT 1 NOT NULL,
  max_load FLOAT NOT NULL DEFAULT '1.0',
  PRIMARY KEY (id),
  CONSTRAINT UNQ_mh_host_registration UNIQUE (host)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE INDEX IX_mh_host_registration_online ON mh_host_registration (online);
CREATE INDEX IX_mh_host_registration_active ON mh_host_registration (active);

CREATE TABLE mh_service_registration (
  id BIGINT NOT NULL,
  path VARCHAR(255) NOT NULL,
  job_producer TINYINT(1) DEFAULT 0 NOT NULL,
  service_type VARCHAR(255) NOT NULL,
  online TINYINT(1) DEFAULT 1 NOT NULL,
  active TINYINT(1) DEFAULT 1 NOT NULL,
  online_from DATETIME,
  service_state int NOT NULL,
  state_changed DATETIME,
  warning_state_trigger BIGINT,
  error_state_trigger BIGINT,
  host_registration BIGINT,
  PRIMARY KEY (id),
  CONSTRAINT UNQ_mh_service_registration UNIQUE (host_registration, service_type),
  CONSTRAINT FK_mh_service_registration_host_registration FOREIGN KEY (host_registration) REFERENCES mh_host_registration (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE INDEX IX_mh_service_registration_service_type ON mh_service_registration (service_type);
CREATE INDEX IX_mh_service_registration_service_state ON mh_service_registration (service_state);
CREATE INDEX IX_mh_service_registration_active ON mh_service_registration (active);
CREATE INDEX IX_mh_service_registration_host_registration ON mh_service_registration (host_registration);

CREATE TABLE mh_job (
  id BIGINT NOT NULL,
  status INTEGER,
  payload MEDIUMTEXT,
  date_started DATETIME,
  run_time BIGINT,
  creator TEXT(65535) NOT NULL,
  instance_version BIGINT,
  date_completed DATETIME,
  operation VARCHAR(128),
  dispatchable TINYINT(1) DEFAULT 1,
  organization VARCHAR(128) NOT NULL,
  date_created DATETIME,
  queue_time BIGINT,
  creator_service BIGINT,
  processor_service BIGINT,
  parent BIGINT,
  root BIGINT,
  job_load FLOAT NOT NULL DEFAULT 1.0,
  blocking_job BIGINT DEFAULT NULL,
  PRIMARY KEY (id),
  CONSTRAINT FK_mh_job_creator_service FOREIGN KEY (creator_service) REFERENCES mh_service_registration (id) ON DELETE CASCADE,
  CONSTRAINT FK_mh_job_processor_service FOREIGN KEY (processor_service) REFERENCES mh_service_registration (id) ON DELETE CASCADE,
  CONSTRAINT FK_mh_job_parent FOREIGN KEY (parent) REFERENCES mh_job (id) ON DELETE CASCADE,
  CONSTRAINT FK_mh_job_root FOREIGN KEY (root) REFERENCES mh_job (id) ON DELETE CASCADE,
  CONSTRAINT FK_mh_job_organization FOREIGN KEY (organization) REFERENCES mh_organization (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE INDEX IX_mh_job_parent ON mh_job (parent);
CREATE INDEX IX_mh_job_root ON mh_job (root);
CREATE INDEX IX_mh_job_creator_service ON mh_job (creator_service);
CREATE INDEX IX_mh_job_processor_service ON mh_job (processor_service);
CREATE INDEX IX_mh_job_status ON mh_job (status);
CREATE INDEX IX_mh_job_date_created ON mh_job (date_created);
CREATE INDEX IX_mh_job_date_completed ON mh_job (date_completed);
CREATE INDEX IX_mh_job_dispatchable ON mh_job (dispatchable);
CREATE INDEX IX_mh_job_operation ON mh_job (operation);
CREATE INDEX IX_mh_job_statistics ON mh_job (processor_service, status, queue_time, run_time);

CREATE TABLE mh_job_argument (
  id BIGINT NOT NULL,
  argument TEXT(2147483647),
  argument_index INTEGER,
  CONSTRAINT FK_mh_job_argument_id FOREIGN KEY (id) REFERENCES mh_job (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE INDEX IX_mh_job_argument_id ON mh_job_argument (id);

CREATE TABLE mh_blocking_job (
  id BIGINT NOT NULL,
  blocking_job_list BIGINT,
  job_index INTEGER,
  CONSTRAINT FK_blocking_job_id FOREIGN KEY (id) REFERENCES mh_job (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE mh_job_context (
  id BIGINT NOT NULL,
  name VARCHAR(255) NOT NULL,
  value TEXT(65535),
  CONSTRAINT UNQ_mh_job_context UNIQUE (id, name),
  CONSTRAINT FK_mh_job_context_id FOREIGN KEY (id) REFERENCES mh_job (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE INDEX IX_mh_job_context_id ON mh_job_context (id);

CREATE TABLE mh_job_mh_service_registration (
  Job_id BIGINT NOT NULL,
  servicesRegistration_id BIGINT NOT NULL,
  PRIMARY KEY (Job_id, servicesRegistration_id),
  CONSTRAINT FK_mh_job_mh_service_registration_Job_id FOREIGN KEY (Job_id) REFERENCES mh_job (id) ON DELETE CASCADE,
  CONSTRAINT FK_mh_job_mh_service_registration_servicesRegistration_id FOREIGN KEY (servicesRegistration_id) REFERENCES mh_service_registration (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE INDEX IX_mh_job_mh_service_registration_servicesRegistration_id ON mh_job_mh_service_registration (servicesRegistration_id);

CREATE TABLE mh_incident (
  id BIGINT NOT NULL,
  jobid BIGINT,
  timestamp DATETIME,
  code VARCHAR(255),
  severity INTEGER,
  parameters TEXT(65535),
  details TEXT(65535),
  PRIMARY KEY (id),
  CONSTRAINT FK_mh_incident_jobid FOREIGN KEY (jobid) REFERENCES mh_job (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE INDEX IX_mh_incident_jobid ON mh_incident (jobid);
CREATE INDEX IX_mh_incident_severity ON mh_incident (severity);

CREATE TABLE mh_incident_text (
  id VARCHAR(255) NOT NULL,
  text VARCHAR(2038) NOT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE mh_scheduled_last_modified (
  capture_agent_id VARCHAR(255) NOT NULL,
  last_modified DATETIME NOT NULL,
  PRIMARY KEY (capture_agent_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE INDEX IX_mh_scheduled_last_modified_last_modified ON mh_scheduled_last_modified (last_modified);

CREATE TABLE mh_scheduled_extended_event (
  mediapackage_id VARCHAR(128) NOT NULL,
  organization VARCHAR(128) NOT NULL,
  PRIMARY KEY (mediapackage_id, organization),
  CONSTRAINT FK_mh_scheduled_extended_event_organization FOREIGN KEY (organization) REFERENCES mh_organization (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE mh_scheduled_transaction (
  id VARCHAR(128) NOT NULL,
  organization VARCHAR(128) NOT NULL,
  source VARCHAR(255) NOT NULL,
  last_modified DATETIME NOT NULL,
  PRIMARY KEY (id, organization),
  CONSTRAINT UNQ_mh_scheduled_transaction UNIQUE (id, organization, source),
  CONSTRAINT FK_mh_scheduled_transaction_organization FOREIGN KEY (organization) REFERENCES mh_organization (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE INDEX IX_mh_scheduled_transaction_source ON mh_scheduled_transaction (source);

CREATE TABLE mh_search (
  id VARCHAR(128) NOT NULL,
  series_id VARCHAR(128),
  organization VARCHAR(128),
  deletion_date DATETIME,
  access_control TEXT(65535),
  mediapackage_xml MEDIUMTEXT,
  modification_date DATETIME,
  PRIMARY KEY (id),
  CONSTRAINT FK_mh_search_organization FOREIGN KEY (organization) REFERENCES mh_organization (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE INDEX IX_mh_search_organization ON mh_search (organization);

CREATE TABLE mh_series (
  id VARCHAR(128) NOT NULL,
  organization VARCHAR(128) NOT NULL,
  access_control TEXT(65535),
  dublin_core TEXT(65535),
  opt_out   tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (id, organization),
  CONSTRAINT FK_mh_series_organization FOREIGN KEY (organization) REFERENCES mh_organization (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE mh_oaipmh (
  mp_id VARCHAR(128) NOT NULL,
  organization VARCHAR(128) NOT NULL,
  repo_id VARCHAR(255) NOT NULL,
  series_id VARCHAR(128),
  deleted tinyint(1) DEFAULT '0',
  modification_date DATETIME DEFAULT NULL,
  mediapackage_xml TEXT(65535) NOT NULL,
  PRIMARY KEY (mp_id, repo_id, organization),
  CONSTRAINT UNQ_mh_oaipmh UNIQUE (modification_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE INDEX IX_mh_oaipmh_modification_date ON mh_oaipmh (modification_date);

-- set to current date and time on insert
CREATE TRIGGER mh_init_oaipmh_date BEFORE INSERT ON `mh_oaipmh`
FOR EACH ROW SET NEW.modification_date = NOW();

-- set to current date and time on update
CREATE TRIGGER mh_update_oaipmh_date BEFORE UPDATE ON `mh_oaipmh`
FOR EACH ROW SET NEW.modification_date = NOW();

CREATE TABLE mh_oaipmh_elements (
  id INT(20) NOT NULL AUTO_INCREMENT,
  element_type VARCHAR(16) NOT NULL,
  flavor varchar(255) NOT NULL,
  xml TEXT(65535) NOT NULL,
  mp_id VARCHAR(128) NOT NULL,
  organization VARCHAR(128) NOT NULL,
  repo_id VARCHAR(255) NOT NULL,
  PRIMARY KEY (id),
  CONSTRAINT FK_mh_oaipmh_elements
    FOREIGN KEY (mp_id, repo_id, organization)
    REFERENCES mh_oaipmh (mp_id, repo_id, organization)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE mh_user_session (
  session_id VARCHAR(50) NOT NULL,
  user_ip VARCHAR(255),
  user_agent VARCHAR(255),
  user_id VARCHAR(255),
  PRIMARY KEY (session_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE INDEX IX_mh_user_session_user_id ON mh_user_session (user_id);

CREATE TABLE mh_user_action (
  id BIGINT NOT NULL,
  inpoint INTEGER,
  outpoint INTEGER,
  mediapackage VARCHAR(128),
  session_id VARCHAR(50) NOT NULL,
  created DATETIME,
  length INTEGER,
  type VARCHAR(128),
  playing TINYINT(1) DEFAULT 0,
  PRIMARY KEY (id),
  CONSTRAINT FK_mh_user_action_session_id FOREIGN KEY (session_id) REFERENCES mh_user_session (session_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE INDEX IX_mh_user_action_created ON mh_user_action (created);
CREATE INDEX IX_mh_user_action_inpoint ON mh_user_action (inpoint);
CREATE INDEX IX_mh_user_action_outpoint ON mh_user_action (outpoint);
CREATE INDEX IX_mh_user_action_mediapackage_id ON mh_user_action (mediapackage);
CREATE INDEX IX_mh_user_action_type ON mh_user_action (type);

CREATE TABLE mh_oaipmh_harvesting (
  url VARCHAR(255) NOT NULL,
  last_harvested datetime,
  PRIMARY KEY (url)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE mh_assets_snapshot (
  id BIGINT PRIMARY KEY NOT NULL,
  archival_date DATETIME NOT NULL,
  availability VARCHAR(32) NOT NULL,
  mediapackage_id VARCHAR(128) NOT NULL,
  mediapackage_xml LONGTEXT NOT NULL,
  series_id VARCHAR(128),
  organization_id VARCHAR(128) NOT NULL,
  owner VARCHAR(256) NOT NULL,
  version BIGINT NOT NULL,
  --
  CONSTRAINT UNQ_mh_assets_snapshot UNIQUE (mediapackage_id, version),
  CONSTRAINT FK_mh_assets_snapshot_organization FOREIGN KEY (organization_id) REFERENCES mh_organization (id),
  INDEX IX_mh_assets_snapshot_archival_date (archival_date),
  INDEX IX_mh_assets_snapshot_mediapackage_id (mediapackage_id),
  INDEX IX_mh_assets_snapshot_organization_id (organization_id),
  INDEX IX_mh_assets_snapshot_owner (owner)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE mh_assets_asset (
  id BIGINT PRIMARY KEY NOT NULL,
  snapshot_id BIGINT NOT NULL,
  checksum VARCHAR(64) NOT NULL,
  mediapackage_element_id VARCHAR(128) NOT NULL,
  mime_type VARCHAR(64),
  size BIGINT NOT NULL,
  --
  INDEX IX_mh_assets_asset_checksum (checksum),
  INDEX IX_mh_assets_asset_mediapackage_element_id (mediapackage_element_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE mh_assets_properties (
  id BIGINT PRIMARY KEY NOT NULL,
  val_bool TINYINT(1) DEFAULT 0,
  val_date DATETIME,
  val_long BIGINT,
  val_string VARCHAR(255),
  mediapackage_id VARCHAR(128) NOT NULL,
  namespace VARCHAR(128) NOT NULL,
  property_name VARCHAR(128) NOT NULL,
  --
  INDEX IX_mh_assets_properties_val_date (val_date),
  INDEX IX_mh_assets_properties_val_long (val_long),
  INDEX IX_mh_assets_properties_val_string (val_string),
  INDEX IX_mh_assets_properties_val_bool (val_bool),
  INDEX IX_mh_assets_properties_mediapackage_id (mediapackage_id),
  INDEX IX_mh_assets_properties_namespace (namespace),
  INDEX IX_mh_assets_properties_property_name (property_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE mh_assets_version_claim (
  mediapackage_id VARCHAR(128) PRIMARY KEY NOT NULL,
  last_claimed BIGINT NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- ACL manager
--
CREATE TABLE mh_acl_managed_acl (
  pk BIGINT(20) NOT NULL,
  acl TEXT NOT NULL,
  name VARCHAR(128) NOT NULL,
  organization_id VARCHAR(128) NOT NULL,
  PRIMARY KEY (pk),
  CONSTRAINT UNQ_mh_acl_managed_acl UNIQUE (name, organization_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE mh_acl_episode_transition (
  pk BIGINT(20) NOT NULL,
  workflow_params VARCHAR(255) DEFAULT NULL,
  application_date DATETIME DEFAULT NULL,
  workflow_id VARCHAR(128) DEFAULT NULL,
  done TINYINT(1) DEFAULT 0,
  episode_id VARCHAR(128) DEFAULT NULL,
  organization_id VARCHAR(128) DEFAULT NULL,
  managed_acl_fk BIGINT(20) DEFAULT NULL,
  PRIMARY KEY (pk),
  CONSTRAINT UNQ_mh_acl_episode_transition UNIQUE (episode_id, organization_id, application_date),
  CONSTRAINT FK_mh_acl_episode_transition_managed_acl_fk FOREIGN KEY (managed_acl_fk) REFERENCES mh_acl_managed_acl (pk)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE mh_acl_series_transition (
  pk BIGINT(20) NOT NULL,
  workflow_params VARCHAR(255) DEFAULT NULL,
  application_date DATETIME DEFAULT NULL,
  workflow_id VARCHAR(128) DEFAULT NULL,
  override TINYINT(1) DEFAULT 0,
  done TINYINT(1) DEFAULT 0,
  organization_id VARCHAR(128) DEFAULT NULL,
  series_id VARCHAR(128) DEFAULT NULL,
  managed_acl_fk BIGINT(20) DEFAULT NULL,
  PRIMARY KEY (pk),
  CONSTRAINT UNQ_mh_acl_series_transition UNIQUE (series_id, organization_id, application_date),
  CONSTRAINT FK_mh_acl_series_transition_managed_acl_fk FOREIGN KEY (managed_acl_fk) REFERENCES mh_acl_managed_acl (pk)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE mh_role (
  id bigint(20) NOT NULL,
  description varchar(255) DEFAULT NULL,
  name varchar(128) DEFAULT NULL,
  organization varchar(128) DEFAULT NULL,
  PRIMARY KEY (id),
  CONSTRAINT UNQ_mh_role UNIQUE (name, organization),
  CONSTRAINT FK_mh_role_organization FOREIGN KEY (organization) REFERENCES mh_organization (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE mh_group (
  id bigint(20) NOT NULL,
  group_id varchar(128) DEFAULT NULL,
  description varchar(255) DEFAULT NULL,
  name varchar(128) DEFAULT NULL,
  role varchar(255) DEFAULT NULL,
  organization varchar(128) DEFAULT NULL,
  PRIMARY KEY (id),
  CONSTRAINT UNQ_mh_group UNIQUE (group_id, organization),
  CONSTRAINT FK_mh_group_organization FOREIGN KEY (organization) REFERENCES mh_organization (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE mh_group_member (
  group_id bigint(20) NOT NULL,
  member varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE mh_group_role (
  group_id bigint(20) NOT NULL,
  role_id bigint(20) NOT NULL,
  PRIMARY KEY (group_id,role_id),
  CONSTRAINT UNQ_mh_group_role UNIQUE (group_id, role_id),
  CONSTRAINT FK_mh_group_role_group_id FOREIGN KEY (group_id) REFERENCES mh_group (id),
  CONSTRAINT FK_mh_group_role_role_id FOREIGN KEY (role_id) REFERENCES mh_role (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE mh_user (
  id bigint(20) NOT NULL,
  username varchar(128) DEFAULT NULL,
  password text,
  name varchar(256) DEFAULT NULL,
  email varchar(256) DEFAULT NULL,
  organization varchar(128) DEFAULT NULL,
  manageable TINYINT(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (id),
  CONSTRAINT UNQ_mh_user UNIQUE (username, organization),
  CONSTRAINT FK_mh_user_organization FOREIGN KEY (organization) REFERENCES mh_organization (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE INDEX IX_mh_role_pk ON mh_role (name, organization);

CREATE TABLE mh_user_role (
  user_id bigint(20) NOT NULL,
  role_id bigint(20) NOT NULL,
  PRIMARY KEY (user_id,role_id),
  CONSTRAINT UNQ_mh_user_role UNIQUE (user_id, role_id),
  CONSTRAINT FK_mh_user_role_role_id FOREIGN KEY (role_id) REFERENCES mh_role (id),
  CONSTRAINT FK_mh_user_role_user_id FOREIGN KEY (user_id) REFERENCES mh_user (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE mh_user_ref (
  id bigint(20) NOT NULL,
  username varchar(128) DEFAULT NULL,
  last_login datetime DEFAULT NULL,
  email varchar(255) DEFAULT NULL,
  name varchar(255) DEFAULT NULL,
  login_mechanism varchar(255) DEFAULT NULL,
  organization varchar(128) DEFAULT NULL,
  PRIMARY KEY (id),
  CONSTRAINT UNQ_mh_user_ref UNIQUE (username, organization),
  CONSTRAINT FK_mh_user_ref_organization FOREIGN KEY (organization) REFERENCES mh_organization (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE mh_user_ref_role (
  user_id bigint(20) NOT NULL,
  role_id bigint(20) NOT NULL,
  PRIMARY KEY (user_id, role_id),
  CONSTRAINT UNQ_mh_user_ref_role UNIQUE (user_id, role_id),
  CONSTRAINT FK_mh_user_ref_role_role_id FOREIGN KEY (role_id) REFERENCES mh_role (id),
  CONSTRAINT FK_mh_user_ref_role_user_id FOREIGN KEY (user_id) REFERENCES mh_user_ref (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE mh_user_settings (
  id bigint(20) NOT NULL,
  setting_key VARCHAR(255) NOT NULL,
  setting_value text NOT NULL,
  username varchar(128) NOT NULL,
  organization varchar(128) NOT NULL,
  PRIMARY KEY (id),
  CONSTRAINT UNQ_mh_user_settings UNIQUE (username, organization)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE mh_email_configuration (
  id BIGINT(20) NOT NULL,
  organization VARCHAR(128) NOT NULL,
  port INT(5) DEFAULT NULL,
  transport VARCHAR(255) DEFAULT NULL,
  username VARCHAR(255) DEFAULT NULL,
  server VARCHAR(255) NOT NULL,
  ssl_enabled TINYINT(1) NOT NULL DEFAULT '0',
  password VARCHAR(255) DEFAULT NULL,
  PRIMARY KEY (id),
  CONSTRAINT UNQ_mh_email_configuration UNIQUE (organization),
  CONSTRAINT FK_mh_email_configuration_organization FOREIGN KEY (organization) REFERENCES mh_organization (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE INDEX IX_mh_email_configuration_organization ON mh_email_configuration (organization);

CREATE TABLE mh_message_signature (
  id BIGINT(20) NOT NULL,
  organization VARCHAR(128) NOT NULL,
  name VARCHAR(255) NOT NULL,
  creation_date DATETIME NOT NULL,
  sender VARCHAR(255) NOT NULL,
  sender_name VARCHAR(255) NOT NULL,
  reply_to VARCHAR(255) DEFAULT NULL,
  reply_to_name VARCHAR(255) DEFAULT NULL,
  signature VARCHAR(255) NOT NULL,
  creator_username VARCHAR(255) NOT NULL,
  PRIMARY KEY (id),
  CONSTRAINT UNQ_mh_message_signature UNIQUE (organization, name),
  CONSTRAINT FK_mh_message_signature_organization FOREIGN KEY (organization) REFERENCES mh_organization (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE INDEX IX_mh_message_signature_organization ON mh_message_signature (organization);
CREATE INDEX IX_mh_message_signature_name ON mh_message_signature (name);

CREATE TABLE mh_message_template (
  id BIGINT(20) NOT NULL,
  organization VARCHAR(128) NOT NULL,
  body TEXT(65535) NOT NULL,
  creation_date DATETIME NOT NULL,
  subject VARCHAR(255) NOT NULL,
  name VARCHAR(255) NOT NULL,
  template_type VARCHAR(255) DEFAULT NULL,
  creator_username VARCHAR(255) NOT NULL,
  hidden TINYINT(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (id),
  CONSTRAINT UNQ_mh_message_template UNIQUE (organization, name),
  CONSTRAINT FK_mh_message_template_organization FOREIGN KEY (organization) REFERENCES mh_organization (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE INDEX IX_mh_message_template_organization ON mh_message_template (organization);
CREATE INDEX IX_mh_message_template_name ON mh_message_template (name);

CREATE TABLE mh_event_comment (
  id BIGINT(20) NOT NULL,
  organization VARCHAR(128) NOT NULL,
  event VARCHAR(128) NOT NULL,
  creation_date DATETIME NOT NULL,
  author VARCHAR(255) NOT NULL,
  text TEXT(65535) NOT NULL,
  reason VARCHAR(255) DEFAULT NULL,
  modification_date DATETIME NOT NULL,
  resolved_status TINYINT(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE mh_event_comment_reply (
  id BIGINT(20) NOT NULL,
  event_comment_id BIGINT(20) NOT NULL,
  creation_date DATETIME NOT NULL,
  author VARCHAR(255) NOT NULL,
  text TEXT(65535) NOT NULL,
  modification_date DATETIME NOT NULL,
  PRIMARY KEY (id),
  CONSTRAINT FK_mh_event_comment_reply_mh_event_comment FOREIGN KEY (event_comment_id) REFERENCES mh_event_comment (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE mh_series_elements (
  series VARCHAR(128) NOT NULL,
  organization VARCHAR(128) NOT NULL,
  type VARCHAR(128) NOT NULL,
  data BLOB,
  PRIMARY KEY (series, organization, type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE mh_series_property (
  organization VARCHAR(128) NOT NULL,
  series VARCHAR(128) NOT NULL,
  name VARCHAR(255) NOT NULL,
  value TEXT(65535),
  PRIMARY KEY (organization, series, name),
  CONSTRAINT FK_mh_series_property_organization_series FOREIGN KEY (organization, series) REFERENCES mh_series (organization, id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE INDEX IX_mh_series_property_pk ON mh_series_property (series);

CREATE TABLE mh_themes (
    id BIGINT(20) NOT NULL,
    organization VARCHAR(128) NOT NULL,
    creation_date DATETIME NOT NULL,
    username VARCHAR(128) NOT NULL,
    name VARCHAR(255) NOT NULL,
    isDefault tinyint(1) NOT NULL DEFAULT '0',
    description VARCHAR(255),
    bumper_active tinyint(1) NOT NULL DEFAULT '0',
    bumper_file VARCHAR(128),
    license_slide_active tinyint(1) NOT NULL DEFAULT '0',
    license_slide_background VARCHAR(128),
    license_slide_description VARCHAR(255),
    title_slide_active tinyint(1) NOT NULL DEFAULT '0',
    title_slide_background VARCHAR(128),
    title_slide_metadata VARCHAR(255),
    trailer_active tinyint(1) NOT NULL DEFAULT '0',
    trailer_file VARCHAR(128),
    watermark_active tinyint(1) NOT NULL DEFAULT '0',
    watermark_position VARCHAR(255),
    watermark_file VARCHAR(128),
    PRIMARY KEY (id),
    CONSTRAINT FK_mh_themes_organization FOREIGN KEY (organization) REFERENCES mh_organization (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE mh_ibm_watson_transcript_job (
    id BIGINT(20) NOT NULL,
    media_package_id VARCHAR(128) NOT NULL,
    track_id VARCHAR(128) NOT NULL,
    job_id  VARCHAR(128) NOT NULL,
    date_created datetime NOT NULL,
    date_completed datetime DEFAULT NULL,
    status VARCHAR(128) DEFAULT NULL,
    track_duration BIGINT NOT NULL,
    PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

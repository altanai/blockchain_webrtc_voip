DROP TABLE IF EXISTS `collection_cdrs`;

CREATE TABLE `collection_cdrs` (
    `id` bigint(20) NOT NULL auto_increment,
    `cdr_id` bigint(20) NOT NULL default '0',
    `src_username` varchar(64) NOT NULL default '',
    `src_domain` varchar(128) NOT NULL default '',
    `dst_username` varchar(64) NOT NULL default '',
    `dst_domain` varchar(128) NOT NULL default '',
    `dst_ousername` varchar(64) NOT NULL default '',
    `call_start_time` datetime NOT NULL default '0000-00-00 00:00:00',
    `duration` int(10) unsigned NOT NULL default '0',
    `sip_call_id` varchar(128) NOT NULL default '',
    `sip_from_tag` varchar(128) NOT NULL default '',
    `sip_to_tag` varchar(128) NOT NULL default '',
    `src_ip` varchar(64) NOT NULL default '',
    `cost` integer NOT NULL default '0',
    `rated` integer NOT NULL default '0',
    `sip_code` char(3) NOT NULL default '',
    `sip_reason` varchar(32) NOT NULL default '',
    `created` datetime NOT NULL,
    `flag_imported` integer NOT NULL default '0',
    PRIMARY KEY  (`id`)
);

DELIMITER //
CREATE TRIGGER copy_cdrs
AFTER INSERT
    ON cdrs FOR EACH ROW
BEGIN
    INSERT INTO collection_cdrs SET
        cdr_id = NEW.cdr_id,
        src_username = NEW.src_username,
        src_domain = NEW.src_domain,
        dst_username = NEW.dst_username,
        dst_domain = NEW.dst_domain,
        dst_ousername = NEW.dst_ousername,
        call_start_time = NEW.call_start_time,
        duration = NEW.duration,
        sip_call_id = NEW.sip_call_id,
        sip_from_tag = NEW.sip_from_tag,
        sip_to_tag = NEW.sip_to_tag,
        src_ip = NEW.src_ip,
        cost = NEW.cost,
        rated = NEW.rated,
        sip_code = 200,
        sip_reason = ''
        ;
END; //
DELIMITER ;

DELIMITER //
CREATE TRIGGER copy_missed_calls
AFTER INSERT
    ON missed_calls FOR EACH ROW
BEGIN
    INSERT INTO collection_cdrs SET
        cdr_id = NEW.cdr_id,
        src_username = NEW.src_user,
        src_domain = NEW.src_domain,
        dst_username = NEW.dst_user,
        dst_domain = NEW.dst_domain,
        dst_ousername = NEW.dst_ouser,
        call_start_time = NEW.time,
        duration = 0,
        sip_call_id = NEW.callid,
        sip_from_tag = NEW.from_tag,
        sip_to_tag = NEW.to_tag,
        src_ip = NEW.src_ip,
        cost = 0,
        rated = 0,
        sip_code = NEW.sip_code,
        sip_reason = NEW.sip_reason
        ;
END; //
DELIMITER ;





-- import cdrs
INSERT collection_cdrs (cdr_id, src_username, src_domain, dst_username, dst_domain, dst_ousername, call_start_time, duration, sip_call_id, sip_from_tag, sip_to_tag, src_ip, cost, rated, sip_code, sip_reason) SELECT cdr_id, src_username, src_domain, dst_username, dst_domain, dst_ousername, call_start_time, duration, sip_call_id, sip_from_tag, sip_to_tag,  src_ip, cost, rated, 200, '' FROM cdrs;


-- import missed_calls
INSERT collection_cdrs (cdr_id, src_username, src_domain, dst_username, dst_domain, dst_ousername, call_start_time, duration, sip_call_id, sip_from_tag, sip_to_tag, src_ip, cost, rated, sip_code, sip_reason) SELECT cdr_id, src_user, src_domain, dst_user, dst_domain, dst_ouser, time, 0, callid, from_tag, to_tag,  src_ip, 0, 0, sip_code, sip_reason FROM missed_calls;
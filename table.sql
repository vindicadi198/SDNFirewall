CREATE TABLE blocked(
    src_network varchar(39),
    src_prefix_length numeric(3),
    dst_network varchar(39),
    dst_prefix_length numeric(3),
    protocol char(1) NOT NULL,
    port int NOT NULL,
    priority int NOT NULL,
    CHECK (protocol in ('T','U')),
    CHECK (port>=1 AND port<=65536),
    CHECK (src_prefix_length>=0 AND src_prefix_length<=128),
    CHECK (dst_prefix_length>=0 AND dst_prefix_length<=128)
);

CREATE TABLE users(
	username varchar(40),
	email varchar(40) PRIMARY KEY,
	password varchar(100),
	CHECK (email LIKE ('%@iith.ac.in'))
);


CREATE TABLE suricata(
    src_network text,
    src_prefix_length numeric(3),
    dst_network text,
    dst_prefix_length numeric(3),
    protocol char(1) NOT NULL,
    port int NOT NULL,
    signature_id int NOT NULL PRIMARY KEY,
	apply numeric(1) NOT NULL,
    CHECK (protocol in ('T','U','I')),
    CHECK (port>=1 AND port<=65536),
    CHECK (src_prefix_length>=0 AND src_prefix_length<=128),
    CHECK (dst_prefix_length>=0 AND dst_prefix_length<=128)
);
create table rule_count(
  count int,
  signature_id int PRIMARY KEY
);
